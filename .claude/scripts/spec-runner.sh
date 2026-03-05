#!/usr/bin/env bash
# spec-runner.sh — Phased implementation orchestrator for project-dna
#
# Runs each implementation phase in a fresh `claude -p` session to prevent
# context drift, following Anthropic's harness patterns for long-running agents.
#
# Usage:
#   .claude/scripts/spec-runner.sh <spec-slug> [options]
#
# See --help for full usage.
#
# Architecture: sources 4 library modules from scripts/lib/
#   sr-config.sh    — Configuration and CLI parsing
#   sr-monitor.sh   — Real-time NDJSON stream monitoring
#   sr-validate.sh  — Checklist parsing and validation
#   sr-summary.sh   — Phase and run summaries
#   sr-prompts.sh   — Prompt template builders

set -euo pipefail

# ---------------------------------------------------------------------------
# Bootstrap: locate and source library modules
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

for lib in sr-config sr-monitor sr-validate sr-summary sr-prompts; do
  lib_path="${LIB_DIR}/${lib}.sh"
  if [[ ! -f "$lib_path" ]]; then
    echo "❌ Missing library: ${lib_path}" >&2
    echo "   Ensure scripts/lib/ contains all sr-*.sh files." >&2
    exit 1
  fi
  # shellcheck source=scripts/lib/sr-config.sh
  source "$lib_path"
done

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  parse_args "$@"
  check_dependencies

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  spec-runner v${SR_VERSION}"
  echo "══════════════════════════════════════════════"
  echo ""

  # Locate spec directory and checklist
  local spec_dir
  spec_dir=$(find_spec_dir "$SPEC_SLUG") || exit 1

  local checklist
  checklist=$(find_checklist "$spec_dir") || exit 1

  echo "  Spec:    ${spec_dir}"
  echo "  Model:   ${SR_MODEL}"
  echo "  Mode:    ${SR_PERMISSION_MODE}"
  echo ""

  # Read checklist metadata
  local current_phase total_phases status branch
  current_phase=$(get_current_phase "$checklist")
  total_phases=$(get_total_phases "$checklist")
  status=$(get_status "$checklist")
  branch=$(get_branch "$checklist")

  # Determine start phase
  local start_phase
  if [[ -n "${SR_START_PHASE:-}" ]]; then
    start_phase="$SR_START_PHASE"
    echo "  ℹ️  Overriding start phase: ${start_phase}"
  else
    start_phase="$current_phase"
  fi

  # Validate total phases is configured
  if [[ "$total_phases" -eq 0 ]]; then
    echo "❌ totalPhases is 0 in checklist frontmatter." >&2
    echo "   Edit ${checklist} and set totalPhases to the number of phases." >&2
    exit 1
  fi

  # Validate start phase is in range
  if [[ "$start_phase" -gt "$total_phases" ]]; then
    echo "✅ All ${total_phases} phases already completed (status: ${status})." >&2
    exit 0
  fi

  echo "  Status:  ${status}"
  echo "  Branch:  ${branch:-not set}"
  echo "  Phases:  ${start_phase}–${total_phases}"
  echo ""

  # --dry-run: show plan without executing
  if [[ "$SR_DRY_RUN" == "true" ]]; then
    run_dry "$checklist" "$start_phase" "$total_phases"
    exit 0
  fi

  # Ensure we're on the right branch
  ensure_branch "$branch"

  # Initialize run-level tracking
  init_run_summary

  # -----------------------------------------------------------------------
  # Phase loop
  # -----------------------------------------------------------------------
  local all_succeeded=true

  for (( phase=start_phase; phase<=total_phases; phase++ )); do
    run_phase "$phase" "$total_phases" "$checklist" "$spec_dir" || {
      all_succeeded=false
      break
    }
  done

  # -----------------------------------------------------------------------
  # Post-run
  # -----------------------------------------------------------------------
  print_run_summary

  if [[ "$SR_OUTPUT_JSON" == "true" ]]; then
    write_json_summary "$SPEC_SLUG"
  fi

  if [[ "$all_succeeded" == "true" && "$SR_AUTO_PR" == "true" ]]; then
    create_pr "$spec_dir" "$SPEC_SLUG" "$checklist"
  fi
}

# ---------------------------------------------------------------------------
# run_dry — show phase plan without executing
# ---------------------------------------------------------------------------
run_dry() {
  local checklist="$1"
  local start_phase="$2"
  local total_phases="$3"

  echo "  DRY RUN — phases to execute:"
  echo ""

  for (( phase=start_phase; phase<=total_phases; phase++ )); do
    local phase_status
    phase_status=$(get_phase_status "$checklist" "$phase")
    local content_preview
    content_preview=$(get_phase_content "$checklist" "$phase" | head -3 | tail -1)

    printf "  Phase %-2s  [%-10s]  %s\n" \
      "$phase" "${phase_status:-pending}" "${content_preview:0:60}"
  done

  echo ""
  echo "  Run without --dry-run to execute."
}

# ---------------------------------------------------------------------------
# ensure_branch — checkout feature branch if not already on it
# ---------------------------------------------------------------------------
ensure_branch() {
  local branch="$1"

  if [[ -z "$branch" || "$branch" == "not set" ]]; then
    return 0
  fi

  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "")

  if [[ "$current_branch" != "$branch" ]]; then
    echo "  🌿 Switching to branch: ${branch}"
    if git show-ref --verify --quiet "refs/heads/${branch}"; then
      git checkout "$branch"
    else
      echo "  Creating new branch: ${branch}"
      git checkout -b "$branch"
    fi
  fi
}

# ---------------------------------------------------------------------------
# run_phase — execute a single phase in a fresh claude session
# ---------------------------------------------------------------------------
run_phase() {
  local phase_num="$1"
  local total_phases="$2"
  local checklist="$3"
  local spec_dir="$4"

  echo "──────────────────────────────────────────────"
  echo "  Phase ${phase_num} / ${total_phases}"
  echo "──────────────────────────────────────────────"
  echo ""

  # Build the phase prompt
  local phase_content prior_notes prompt

  phase_content=$(get_phase_content "$checklist" "$phase_num")
  if [[ -z "$phase_content" ]]; then
    echo "❌ No content found for Phase ${phase_num} in ${checklist}" >&2
    return 1
  fi

  prior_notes=$(get_prior_completion_notes "$checklist" "$phase_num")
  prompt=$(build_phase_prompt "$phase_num" "$phase_content" "$checklist" "$prior_notes")

  # Update phase status to in-progress
  update_frontmatter_field "$checklist" "updatedAt" "$(date +%Y-%m-%d)"

  echo "  🚀 Starting Phase ${phase_num} session..."
  echo ""

  # Build claude command flags
  local claude_flags=(
    --model "$SR_MODEL"
    --output-format stream-json
    --permission-mode "$SR_PERMISSION_MODE"
    --max-turns 50
  )

  # Execute in fresh session, pipe through monitor
  local exit_code=0
  claude -p "$prompt" "${claude_flags[@]}" 2>&1 | process_and_monitor || exit_code=$?

  echo ""

  # Check completion
  if validate_phase_complete "$checklist" "$phase_num"; then
    print_phase_summary "$phase_num" "completed"
    return 0
  fi

  # Phase did not self-complete — prompt user
  echo "  ⚠️  Phase ${phase_num} did not mark itself as completed."
  echo ""

  if prompt_continue "$phase_num"; then
    print_phase_summary "$phase_num" "incomplete"
    return 0
  else
    print_phase_summary "$phase_num" "failed"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# prompt_continue — ask user whether to continue despite incomplete phase
# ---------------------------------------------------------------------------
prompt_continue() {
  local phase_num="$1"

  if [[ ! -t 0 ]]; then
    # Non-interactive mode: stop
    echo "  Non-interactive mode: stopping after incomplete phase." >&2
    return 1
  fi

  echo -n "  Continue to next phase anyway? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# create_pr — run claude in a fresh session to create the PR
# ---------------------------------------------------------------------------
create_pr() {
  local spec_dir="$1"
  local spec_slug="$2"
  local checklist="$3"

  echo "──────────────────────────────────────────────"
  echo "  Creating Pull Request"
  echo "──────────────────────────────────────────────"
  echo ""

  local pr_prompt
  pr_prompt=$(get_pr_prompt "$spec_dir" "$spec_slug")

  local claude_flags=(
    --model "$SR_MODEL"
    --output-format stream-json
    --permission-mode "$SR_PERMISSION_MODE"
    --max-turns 10
  )

  claude -p "$pr_prompt" "${claude_flags[@]}" 2>&1 | process_and_monitor

  echo ""
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
main "$@"
