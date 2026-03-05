#!/usr/bin/env bash
# sr-prompts.sh — Prompt template functions for spec-runner
# Sourced by spec-runner.sh; does not execute standalone.

# ---------------------------------------------------------------------------
# get_verify_prompt — verification gate instructions
# Injected at the end of every phase prompt so Claude self-verifies.
# ---------------------------------------------------------------------------
get_verify_prompt() {
  cat <<'VERIFY_PROMPT'

---

## Verification Gate (REQUIRED before marking phase complete)

Run the following in order. Fix any failures before proceeding.

### Step 1: Lint & Type-check
```bash
pnpm lint && pnpm typecheck
```
- If lint fails: fix each error, do not disable rules unless intentional
- If typecheck fails: fix type errors, do not use `any` or `@ts-ignore`

### Step 2: Code Review
Launch the `code-reviewer` agent on any uncommitted changes:
```
Use Agent tool with subagent_type=code-reviewer
```
- Address all critical/high findings
- Document accepted medium/low findings in Completion Notes

### Step 3: Tests
```bash
pnpm test
```
- All existing tests must pass
- New code requires new tests (80%+ coverage on packages)
- If tests fail: fix root cause, do not skip or mock excessively

### Step 4: Fix-and-Retry Loop
If any step fails:
1. Fix the issue
2. Re-run that step
3. Maximum 3 iterations per step — if still failing after 3 tries, note it as a blocker in Completion Notes and stop

VERIFY_PROMPT
}

# ---------------------------------------------------------------------------
# get_handoff_prompt — completion notes instructions
# Injected after verification; Claude writes structured notes into checklist.md
# ---------------------------------------------------------------------------
get_handoff_prompt() {
  local phase_num="${1:-?}"
  local checklist_path="${2:-specs/UNKNOWN/checklist.md}"

  cat <<HANDOFF_PROMPT

---

## Handoff Notes (REQUIRED — write before finishing)

After all verification steps pass, update \`${checklist_path}\` with:

1. **Update frontmatter**:
   - Set \`status\` for Phase ${phase_num} to \`completed\`
   - Set \`currentPhase\` to $((phase_num + 1))
   - Update \`updatedAt\` to today's date

2. **Fill in "#### Completion Notes" under Phase ${phase_num}** with:
   - **Summary**: 2–3 sentences on what was built
   - **Key Files**: List of files created/modified with one-line descriptions
   - **Decisions**: Architectural choices made and WHY (rationale)
   - **Blockers**: Anything left unresolved (or "None")
   - **Gotchas**: Tricky edge cases or non-obvious constraints future phases must know
   - **Next Context**: The single most important thing the next phase needs to know

3. **Update phase status** from \`in-progress\` to \`completed\` in the task list

Write these notes in the file — do not just summarize in your response.

HANDOFF_PROMPT
}

# ---------------------------------------------------------------------------
# get_pr_prompt — PR creation instructions
# Called after all phases complete (or via --auto-pr)
# ---------------------------------------------------------------------------
get_pr_prompt() {
  local spec_dir="${1:-specs/UNKNOWN}"
  local spec_slug="${2:-unknown}"

  cat <<PR_PROMPT

---

## Create Pull Request

All phases are complete. Create a PR following project-dna conventions.

### Steps

1. **Check git status**:
   ```bash
   git status
   git log main..HEAD --oneline
   ```

2. **Push branch** (if not already pushed):
   ```bash
   git push -u origin HEAD
   ```

3. **Create PR** using \`gh pr create\` with:

   **Title format**: \`feat: {concise description of feature}\`
   - Use conventional commit type: feat | fix | refactor | docs | chore
   - Keep under 70 characters

   **Body** must include:
   - ## Summary (3–5 bullet points of what changed)
   - ## Phases Completed (list each phase with one-line summary)
   - ## Test Plan (checkbox list of how to verify)
   - Link to spec: \`specs/${spec_slug}/spec.md\`
   - Footer: \`🤖 Generated with [Claude Code](https://claude.com/claude-code)\`

4. **After PR is created**: Output the PR URL

### Checklist before creating PR
- [ ] \`pnpm lint && pnpm typecheck\` passes
- [ ] \`pnpm test\` passes
- [ ] All phase completion notes written in \`${spec_dir}/checklist.md\`
- [ ] Branch is up to date with main (no merge conflicts)

PR_PROMPT
}

# ---------------------------------------------------------------------------
# build_phase_prompt — assemble the full prompt for a given phase
# Usage: build_phase_prompt <phase_num> <phase_content> <checklist_path> <prior_notes>
# Outputs the complete prompt string to stdout
# ---------------------------------------------------------------------------
build_phase_prompt() {
  local phase_num="$1"
  local phase_content="$2"
  local checklist_path="$3"
  local prior_notes="$4"

  # Front-load the constraint to keep it in context window priority position
  cat <<PHASE_PROMPT
## Context Budget Constraint
This session has a ${SR_CONTEXT_WINDOW}-token context window. Be concise in tool outputs.
When reading large files, use targeted line ranges. Prefer grep/glob over reading entire directories.

---

## Phase ${phase_num} Implementation

${phase_content}

---

## Prior Phase Context

The following completion notes from previous phases contain critical context:

${prior_notes:-"(No prior phases — this is Phase 1)"}

---
$(get_verify_prompt)
$(get_handoff_prompt "$phase_num" "$checklist_path")
PHASE_PROMPT
}
