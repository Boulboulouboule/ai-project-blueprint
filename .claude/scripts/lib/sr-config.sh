#!/usr/bin/env bash
# sr-config.sh — Configuration defaults and environment parsing for spec-runner
# Sourced by spec-runner.sh; does not execute standalone.

# ---------------------------------------------------------------------------
# Defaults (override via environment variables)
# ---------------------------------------------------------------------------

: "${SR_CONTEXT_WINDOW:=200000}"
: "${SR_MODEL:=sonnet}"
: "${SR_PERMISSION_MODE:=bypassPermissions}"
: "${SR_SPECS_DIR:=specs}"
: "${SR_DRY_RUN:=false}"
: "${SR_AUTO_PR:=true}"
: "${SR_SUMMARY_INTERVAL:=120}"
: "${SR_OUTPUT_JSON:=false}"
: "${SR_JSON_OUTPUT_FILE:=.spec-runner-summary.json}"

# ---------------------------------------------------------------------------
# Derived constants
# ---------------------------------------------------------------------------

SR_VERSION="1.0.0"
SR_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SR_LIB_DIR="${SR_SCRIPT_DIR}/lib"

# ---------------------------------------------------------------------------
# parse_args — process CLI flags and set global variables
# Usage: parse_args "$@"
# Sets: SPEC_SLUG, SR_START_PHASE, SR_DRY_RUN, SR_MODEL,
#       SR_AUTO_PR, SR_OUTPUT_JSON
# ---------------------------------------------------------------------------
parse_args() {
  if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
  fi

  # Handle --help/-h before consuming spec slug
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    print_usage
    exit 0
  fi

  SPEC_SLUG="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        SR_DRY_RUN=true
        shift
        ;;
      --phase)
        SR_START_PHASE="${2:?'--phase requires a number'}"
        shift 2
        ;;
      --model)
        SR_MODEL="${2:?'--model requires a value'}"
        shift 2
        ;;
      --allow-bypass)
        SR_PERMISSION_MODE="bypassPermissions"
        echo "⚠️  WARNING: Running with bypassPermissions — Claude can execute any tool without confirmation." >&2
        shift
        ;;
      --no-pr)
        SR_AUTO_PR=false
        shift
        ;;
      --output-json)
        SR_OUTPUT_JSON=true
        shift
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        print_usage >&2
        exit 1
        ;;
    esac
  done

  # Default start phase if not specified
  : "${SR_START_PHASE:=}"
}

# ---------------------------------------------------------------------------
# print_usage — print help text
# ---------------------------------------------------------------------------
print_usage() {
  cat <<EOF
spec-runner v${SR_VERSION} — Phased implementation orchestrator

Usage:
  .claude/scripts/spec-runner.sh <spec-slug> [options]

Arguments:
  spec-slug       Directory name under ${SR_SPECS_DIR}/ containing checklist.md

Options:
  --dry-run       Show phases without executing
  --phase N       Start from phase N (default: resume from currentPhase in checklist)
  --model MODEL   Override Claude model (default: ${SR_MODEL})
  --allow-bypass  Use bypassPermissions mode (prints warning; this is the default)
  --no-pr         Skip automatic PR creation after all phases complete
  --output-json   Write machine-readable summary to ${SR_JSON_OUTPUT_FILE}
  -h, --help      Show this help

Environment variables:
  SR_CONTEXT_WINDOW   Token budget hint for Claude (default: ${SR_CONTEXT_WINDOW})
  SR_MODEL            Claude model (default: ${SR_MODEL})
  SR_PERMISSION_MODE  Permission mode (default: ${SR_PERMISSION_MODE})
  SR_SPECS_DIR        Path to specs directory (default: ${SR_SPECS_DIR})
  SR_SUMMARY_INTERVAL Seconds between periodic summaries (default: ${SR_SUMMARY_INTERVAL})

Examples:
  .claude/scripts/spec-runner.sh my-feature --dry-run
  .claude/scripts/spec-runner.sh my-feature --phase 2
  .claude/scripts/spec-runner.sh my-feature --no-pr --output-json
EOF
}

# ---------------------------------------------------------------------------
# check_dependencies — verify required tools are available
# ---------------------------------------------------------------------------
check_dependencies() {
  local missing=()
  for cmd in claude jq gh git; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "❌ Missing required tools: ${missing[*]}" >&2
    echo "   Install missing tools and retry." >&2
    exit 1
  fi
}
