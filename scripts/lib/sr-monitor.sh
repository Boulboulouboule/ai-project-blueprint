#!/usr/bin/env bash
# sr-monitor.sh — NDJSON stream parsing and real-time progress display
# Sourced by spec-runner.sh; does not execute standalone.

# ---------------------------------------------------------------------------
# Global monitoring state
# ---------------------------------------------------------------------------
_SR_TOOL_COUNT=0
_SR_TURN_COUNT=0
_SR_INPUT_TOKENS=0
_SR_OUTPUT_TOKENS=0
_SR_COST_USD="0.00"
_SR_PHASE_START_TS=0
_SR_LAST_TOOL=""
_SR_TIMER_PID=""

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
# _context_pct — calculate context usage percentage
# ---------------------------------------------------------------------------
_context_pct() {
  local tokens=$1
  local window="${SR_CONTEXT_WINDOW:-200000}"
  echo $(( (tokens * 100) / window ))
}

# ---------------------------------------------------------------------------
# _print_status_line — overwrite current terminal line with status
# ---------------------------------------------------------------------------
_print_status_line() {
  local elapsed
  elapsed=$(_format_elapsed $(( $(date +%s) - _SR_PHASE_START_TS )) )
  local ctx_pct
  ctx_pct=$(_context_pct "$_SR_INPUT_TOKENS")
  printf "\r\033[K  ⏳ %s | ctx: %d%% | tools: %d | turns: %d | last: %s" \
    "$elapsed" "$ctx_pct" "$_SR_TOOL_COUNT" "$_SR_TURN_COUNT" "${_SR_LAST_TOOL:-none}" >&2
}

# ---------------------------------------------------------------------------
# _start_status_timer — background process that refreshes status line
# ---------------------------------------------------------------------------
_start_status_timer() {
  (
    while true; do
      sleep 5
      kill -USR1 $$ 2>/dev/null || break
    done
  ) &
  _SR_TIMER_PID=$!
}

# ---------------------------------------------------------------------------
# _stop_status_timer — kill the background timer
# ---------------------------------------------------------------------------
_stop_status_timer() {
  if [[ -n "$_SR_TIMER_PID" ]]; then
    kill "$_SR_TIMER_PID" 2>/dev/null || true
    _SR_TIMER_PID=""
  fi
}

# ---------------------------------------------------------------------------
# _handle_status_signal — SIGUSR1 handler to refresh status line
# ---------------------------------------------------------------------------
_handle_status_signal() {
  _print_status_line
}

# ---------------------------------------------------------------------------
# _process_ndjson_line — parse one NDJSON line and update state
# ---------------------------------------------------------------------------
_process_ndjson_line() {
  local line="$1"
  local type

  # Pre-filter: skip lines that clearly aren't JSON events we care about
  [[ "$line" != "{"* ]] && return

  type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
  [[ -z "$type" ]] && return

  case "$type" in
    message_start)
      _SR_TURN_COUNT=$(( _SR_TURN_COUNT + 1 ))
      local input_tokens
      input_tokens=$(echo "$line" | jq -r '.message.usage.input_tokens // 0' 2>/dev/null)
      _SR_INPUT_TOKENS=$(( _SR_INPUT_TOKENS + input_tokens ))
      ;;

    message_delta)
      local output_tokens
      output_tokens=$(echo "$line" | jq -r '.usage.output_tokens // 0' 2>/dev/null)
      _SR_OUTPUT_TOKENS=$(( _SR_OUTPUT_TOKENS + output_tokens ))
      ;;

    tool_use)
      _SR_TOOL_COUNT=$(( _SR_TOOL_COUNT + 1 ))
      local tool_name
      tool_name=$(echo "$line" | jq -r '.name // "unknown"' 2>/dev/null)
      _SR_LAST_TOOL="$tool_name"
      _print_status_line
      ;;

    result)
      # Session complete — extract final cost if available
      local cost
      cost=$(echo "$line" | jq -r '.cost_usd // empty' 2>/dev/null)
      [[ -n "$cost" ]] && _SR_COST_USD="$cost"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# _periodic_summary — print a mid-run summary every SUMMARY_INTERVAL seconds
# ---------------------------------------------------------------------------
_periodic_summary() {
  local elapsed
  elapsed=$(_format_elapsed $(( $(date +%s) - _SR_PHASE_START_TS )) )
  local ctx_pct
  ctx_pct=$(_context_pct "$_SR_INPUT_TOKENS")

  echo "" >&2
  echo "  📊 Periodic summary at ${elapsed}:" >&2
  echo "     Context: ${ctx_pct}% (${_SR_INPUT_TOKENS} tokens)" >&2
  echo "     Tools called: ${_SR_TOOL_COUNT} | Turns: ${_SR_TURN_COUNT}" >&2
  echo "     Last tool: ${_SR_LAST_TOOL:-none}" >&2
}

# ---------------------------------------------------------------------------
# process_and_monitor — main entry point
# Reads NDJSON from stdin (piped from claude -p --output-format stream-json)
# and processes each line.
#
# Usage:
#   claude -p "$PROMPT" --output-format stream-json | process_and_monitor
#
# Returns the exit code of the claude process (via pipefail).
# ---------------------------------------------------------------------------
process_and_monitor() {
  _SR_TOOL_COUNT=0
  _SR_TURN_COUNT=0
  _SR_INPUT_TOKENS=0
  _SR_OUTPUT_TOKENS=0
  _SR_COST_USD="0.00"
  _SR_PHASE_START_TS=$(date +%s)
  _SR_LAST_TOOL=""

  # Set up SIGUSR1 handler for status line refresh
  trap '_handle_status_signal' USR1

  _start_status_timer

  local last_summary_ts=$_SR_PHASE_START_TS
  local summary_interval="${SR_SUMMARY_INTERVAL:-120}"

  while IFS= read -r line; do
    _process_ndjson_line "$line"

    # Periodic summary check
    local now
    now=$(date +%s)
    if (( now - last_summary_ts >= summary_interval )); then
      _periodic_summary
      last_summary_ts=$now
    fi
  done

  _stop_status_timer
  trap - USR1

  # Clear status line
  printf "\r\033[K" >&2
}

# ---------------------------------------------------------------------------
# get_monitor_stats — output current stats as key=value pairs
# ---------------------------------------------------------------------------
get_monitor_stats() {
  echo "tool_count=${_SR_TOOL_COUNT}"
  echo "turn_count=${_SR_TURN_COUNT}"
  echo "input_tokens=${_SR_INPUT_TOKENS}"
  echo "output_tokens=${_SR_OUTPUT_TOKENS}"
  echo "cost_usd=${_SR_COST_USD}"
  echo "elapsed_secs=$(( $(date +%s) - _SR_PHASE_START_TS ))"
}
