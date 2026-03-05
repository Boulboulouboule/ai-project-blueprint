#!/usr/bin/env bash
# sr-summary.sh — Phase and run summary output
# Sourced by spec-runner.sh; does not execute standalone.

# ---------------------------------------------------------------------------
# Global run-level accumulators
# ---------------------------------------------------------------------------
_SR_RUN_TOTAL_TOOLS=0
_SR_RUN_TOTAL_TURNS=0
_SR_RUN_TOTAL_COST="0.00"
_SR_RUN_START_TS=0
_SR_RUN_PHASE_RESULTS=()   # "phase:duration:cost:tools:status" entries

# ---------------------------------------------------------------------------
# init_run_summary — call at start of the run
# ---------------------------------------------------------------------------
init_run_summary() {
  _SR_RUN_START_TS=$(date +%s)
  _SR_RUN_TOTAL_TOOLS=0
  _SR_RUN_TOTAL_TURNS=0
  _SR_RUN_TOTAL_COST="0.00"
  _SR_RUN_PHASE_RESULTS=()
}

# ---------------------------------------------------------------------------
# _format_elapsed — convert seconds to Xm Ys
# ---------------------------------------------------------------------------
_format_elapsed() {
  local secs=$1
  local mins=$(( secs / 60 ))
  local rem=$(( secs % 60 ))
  if [[ $mins -gt 0 ]]; then
    echo "${mins}m ${rem}s"
  else
    echo "${rem}s"
  fi
}

# ---------------------------------------------------------------------------
# _add_floats — portable float addition using awk
# ---------------------------------------------------------------------------
_add_floats() {
  awk "BEGIN { printf \"%.4f\", $1 + $2 }"
}

# ---------------------------------------------------------------------------
# print_phase_summary — display summary after one phase completes
# Usage: print_phase_summary <phase_num> <status> [stat_vars...]
#   stat_vars are output from get_monitor_stats() — eval'd into local scope
# ---------------------------------------------------------------------------
print_phase_summary() {
  local phase_num="$1"
  local status="$2"   # "completed" | "failed" | "incomplete"

  # Parse monitor stats from environment (set by get_monitor_stats export)
  local tool_count="${_SR_TOOL_COUNT:-0}"
  local turn_count="${_SR_TURN_COUNT:-0}"
  local cost_usd="${_SR_COST_USD:-0.00}"
  local elapsed_secs=$(( $(date +%s) - ${_SR_PHASE_START_TS:-$(date +%s)} ))
  local elapsed
  elapsed=$(_format_elapsed "$elapsed_secs")

  local icon="✅"
  [[ "$status" == "failed" ]] && icon="❌"
  [[ "$status" == "incomplete" ]] && icon="⚠️ "

  echo ""
  echo "  ${icon} Phase ${phase_num} ${status}"
  echo "  ┌────────────────────────────────────┐"
  printf "  │  %-10s  %-10s  %-10s  │\n" "Duration" "Tools" "Cost"
  printf "  │  %-10s  %-10s  \$%-9s  │\n" "$elapsed" "$tool_count" "$cost_usd"
  echo "  └────────────────────────────────────┘"
  echo ""

  # Accumulate into run totals
  _SR_RUN_TOTAL_TOOLS=$(( _SR_RUN_TOTAL_TOOLS + tool_count ))
  _SR_RUN_TOTAL_TURNS=$(( _SR_RUN_TOTAL_TURNS + turn_count ))
  _SR_RUN_TOTAL_COST=$(_add_floats "$_SR_RUN_TOTAL_COST" "$cost_usd")
  _SR_RUN_PHASE_RESULTS+=("${phase_num}:${elapsed}:${cost_usd}:${tool_count}:${status}")
}

# ---------------------------------------------------------------------------
# print_run_summary — display summary after all phases complete
# ---------------------------------------------------------------------------
print_run_summary() {
  local total_elapsed
  total_elapsed=$(_format_elapsed $(( $(date +%s) - _SR_RUN_START_TS )) )
  local phase_count="${#_SR_RUN_PHASE_RESULTS[@]}"

  echo ""
  echo "══════════════════════════════════════════════"
  echo "  Run Complete"
  echo "══════════════════════════════════════════════"
  echo ""
  echo "  Phases:    ${phase_count}"
  echo "  Duration:  ${total_elapsed}"
  echo "  Tools:     ${_SR_RUN_TOTAL_TOOLS}"
  echo "  Turns:     ${_SR_RUN_TOTAL_TURNS}"
  printf "  Cost:      \$%s\n" "$_SR_RUN_TOTAL_COST"
  echo ""
  echo "  Phase breakdown:"
  for entry in "${_SR_RUN_PHASE_RESULTS[@]}"; do
    IFS=':' read -r p_num p_elapsed p_cost p_tools p_status <<< "$entry"
    local p_icon="✅"
    [[ "$p_status" == "failed" ]] && p_icon="❌"
    [[ "$p_status" == "incomplete" ]] && p_icon="⚠️ "
    printf "    %s Phase %-2s  %8s  \$%-8s  %d tools\n" \
      "$p_icon" "$p_num" "$p_elapsed" "$p_cost" "$p_tools"
  done
  echo ""
}

# ---------------------------------------------------------------------------
# write_json_summary — write machine-readable summary to file
# Usage: write_json_summary <spec_slug> <output_file>
# ---------------------------------------------------------------------------
write_json_summary() {
  local spec_slug="$1"
  local output_file="${2:-${SR_JSON_OUTPUT_FILE:-.spec-runner-summary.json}}"
  local total_elapsed_secs=$(( $(date +%s) - _SR_RUN_START_TS ))

  local phases_json="["
  local first=true
  for entry in "${_SR_RUN_PHASE_RESULTS[@]}"; do
    IFS=':' read -r p_num p_elapsed p_cost p_tools p_status <<< "$entry"
    [[ "$first" == "false" ]] && phases_json+=","
    phases_json+=$(jq -n \
      --argjson num "$p_num" \
      --arg elapsed "$p_elapsed" \
      --arg cost "$p_cost" \
      --argjson tools "$p_tools" \
      --arg status "$p_status" \
      '{phase: $num, duration: $elapsed, cost_usd: $cost, tools: $tools, status: $status}')
    first=false
  done
  phases_json+="]"

  jq -n \
    --arg slug "$spec_slug" \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson elapsed "$total_elapsed_secs" \
    --argjson tools "$_SR_RUN_TOTAL_TOOLS" \
    --argjson turns "$_SR_RUN_TOTAL_TURNS" \
    --arg cost "$_SR_RUN_TOTAL_COST" \
    --argjson phases "$phases_json" \
    '{
      spec_slug: $slug,
      timestamp: $timestamp,
      total_elapsed_secs: $elapsed,
      total_tools: $tools,
      total_turns: $turns,
      total_cost_usd: $cost,
      phases: $phases
    }' > "$output_file"

  echo "  📄 JSON summary written to: ${output_file}"
}
