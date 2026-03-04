#!/usr/bin/env bash
# sr-validate.sh — Checklist parsing and phase completion validation
# Sourced by spec-runner.sh; does not execute standalone.

# ---------------------------------------------------------------------------
# find_spec_dir — locate the spec directory for a given slug
# Usage: find_spec_dir <slug>
# Outputs: path to spec directory
# Returns: 0 if found, 1 if not found
# ---------------------------------------------------------------------------
find_spec_dir() {
  local slug="$1"
  local specs_dir="${SR_SPECS_DIR:-specs}"
  local candidate="${specs_dir}/${slug}"

  if [[ -d "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi

  echo "❌ Spec directory not found: ${candidate}" >&2
  echo "   Create it with: mkdir -p ${candidate}" >&2
  echo "   Then add a checklist.md (copy from specs/_checklist.template.md)" >&2
  return 1
}

# ---------------------------------------------------------------------------
# find_checklist — locate checklist.md within a spec directory
# Usage: find_checklist <spec_dir>
# ---------------------------------------------------------------------------
find_checklist() {
  local spec_dir="$1"
  local checklist="${spec_dir}/checklist.md"

  if [[ -f "$checklist" ]]; then
    echo "$checklist"
    return 0
  fi

  echo "❌ checklist.md not found in: ${spec_dir}" >&2
  echo "   Copy template: cp specs/_checklist.template.md ${checklist}" >&2
  return 1
}

# ---------------------------------------------------------------------------
# parse_frontmatter — extract a single key from YAML frontmatter
# Usage: parse_frontmatter <checklist_path> <key>
# Outputs: value string
# ---------------------------------------------------------------------------
parse_frontmatter() {
  local checklist="$1"
  local key="$2"

  # Extract value between --- delimiters, then grep for key
  awk '/^---/{if(found) exit; found=1; next} found' "$checklist" \
    | grep "^${key}:" \
    | head -1 \
    | sed "s/^${key}:[[:space:]]*//" \
    | tr -d '"'
}

# ---------------------------------------------------------------------------
# get_current_phase — read currentPhase from frontmatter
# Usage: get_current_phase <checklist_path>
# ---------------------------------------------------------------------------
get_current_phase() {
  local val
  val=$(parse_frontmatter "$1" "currentPhase")
  echo "${val:-1}"
}

# ---------------------------------------------------------------------------
# get_total_phases — read totalPhases from frontmatter
# Usage: get_total_phases <checklist_path>
# Returns 0 if totalPhases is 0 (not yet set)
# ---------------------------------------------------------------------------
get_total_phases() {
  local val
  val=$(parse_frontmatter "$1" "totalPhases")
  echo "${val:-0}"
}

# ---------------------------------------------------------------------------
# get_status — read top-level status from frontmatter
# ---------------------------------------------------------------------------
get_status() {
  parse_frontmatter "$1" "status"
}

# ---------------------------------------------------------------------------
# get_branch — read branch from frontmatter
# ---------------------------------------------------------------------------
get_branch() {
  parse_frontmatter "$1" "branch"
}

# ---------------------------------------------------------------------------
# get_phase_status — get the status of a specific phase section
# Usage: get_phase_status <checklist_path> <phase_num>
# Looks for "**Status**: `<value>`" under "## Phase N"
# ---------------------------------------------------------------------------
get_phase_status() {
  local checklist="$1"
  local phase_num="$2"

  awk "
    /^## Phase ${phase_num}[^0-9]/ { in_phase=1 }
    /^## Phase [0-9]/ && !/^## Phase ${phase_num}[^0-9]/ { in_phase=0 }
    in_phase && /\*\*Status\*\*:/ {
      line = \$0
      gsub(/.*\`/, \"\", line)
      gsub(/\`.*/, \"\", line)
      print line
      exit
    }
  " "$checklist"
}

# ---------------------------------------------------------------------------
# get_prior_completion_notes — extract completion notes from all phases
# before the given phase number.
# Usage: get_prior_completion_notes <checklist_path> <current_phase>
# ---------------------------------------------------------------------------
get_prior_completion_notes() {
  local checklist="$1"
  local current_phase="$2"
  local notes=""

  for (( p=1; p<current_phase; p++ )); do
    local phase_notes
    phase_notes=$(awk "
      /^## Phase ${p}[^0-9]/ { in_phase=1; next }
      /^## Phase [0-9]/ && !/^## Phase ${p}[^0-9]/ { in_phase=0 }
      in_phase && /^#### Completion Notes/ { in_notes=1; next }
      in_notes && /^---/ { exit }
      in_notes && /^## / { exit }
      in_notes { print }
    " "$checklist")

    if [[ -n "$phase_notes" ]]; then
      notes+="### Phase ${p} Notes"$'\n'
      notes+="$phase_notes"$'\n\n'
    fi
  done

  echo "${notes:-No prior phase notes available.}"
}

# ---------------------------------------------------------------------------
# get_phase_content — extract the full content of a phase section
# Usage: get_phase_content <checklist_path> <phase_num>
# ---------------------------------------------------------------------------
get_phase_content() {
  local checklist="$1"
  local phase_num="$2"

  awk "
    /^## Phase ${phase_num}[^0-9]/ { in_phase=1; print; next }
    /^## Phase [0-9]/ && !/^## Phase ${phase_num}[^0-9]/ { in_phase=0 }
    /^---/ && in_phase { exit }
    in_phase { print }
  " "$checklist"
}

# ---------------------------------------------------------------------------
# list_phases — list all phase numbers found in checklist
# Usage: list_phases <checklist_path>
# Outputs: space-separated phase numbers
# ---------------------------------------------------------------------------
list_phases() {
  local checklist="$1"
  grep -oP '(?<=^## Phase )\d+' "$checklist" | sort -n | tr '\n' ' '
}

# ---------------------------------------------------------------------------
# validate_phase_complete — check if a phase was marked completed
# Usage: validate_phase_complete <checklist_path> <phase_num>
# Returns: 0 if completed, 1 otherwise
# ---------------------------------------------------------------------------
validate_phase_complete() {
  local checklist="$1"
  local phase_num="$2"
  local status

  status=$(get_phase_status "$checklist" "$phase_num")

  if [[ "$status" == "completed" ]]; then
    return 0
  fi

  echo "⚠️  Phase ${phase_num} status is '${status:-unknown}' (expected 'completed')" >&2
  return 1
}

# ---------------------------------------------------------------------------
# update_frontmatter_field — update a single frontmatter key in-place
# Usage: update_frontmatter_field <checklist_path> <key> <value>
# ---------------------------------------------------------------------------
update_frontmatter_field() {
  local checklist="$1"
  local key="$2"
  local value="$3"

  # Use sed to replace the key line within the frontmatter block
  local tmp
  tmp=$(mktemp)
  awk -v key="$key" -v val="$value" '
    /^---/{block++}
    block==1 && $0 ~ "^"key":" { print key": "val; next }
    { print }
  ' "$checklist" > "$tmp"
  mv "$tmp" "$checklist"
}
