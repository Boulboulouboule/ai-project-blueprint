---
argument-hint: "[description of what to build]"
description: Create a spec + phased checklist ready to run with spec-runner.sh
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Plan Spec: $ARGUMENTS

You are creating a complete implementation spec for: **$ARGUMENTS**

This produces two files in `specs/{slug}/` that drive `.claude/scripts/spec-runner.sh`.

---

## Step 1: Validate Input

If `$ARGUMENTS` is empty, ask the user to describe what they want to build. Do not proceed until you have a clear description.

---

## Step 2: Explore the Codebase

Before planning, understand the current state:

- Read `CLAUDE.md` for architecture, conventions, and import boundaries
- Check `adr/` for relevant architectural decisions
- Check `specs/` for related existing specs
- Use Glob + Grep to find files that will be affected
- Identify which packages/apps are involved (`apps/web`, `apps/api`, `packages/shared`, `packages/db`, `packages/ui`)

---

## Step 3: Determine Complexity

| Aspect | Simple (1–2 packages, ≤3 phases) | Complex (3+ packages, 4+ phases) |
|--------|----------------------------------|----------------------------------|
| spec.md | Summary + Scope + Components + Acceptance Criteria | All sections including data model, API, schemas, UI, test plan |
| checklist.md | Minimal Resume Context, tasks with file paths | Full Resume Context per phase, detailed task notes |

---

## Step 4: Generate slug and create directory

- Derive a kebab-case slug from the title (e.g. `add-user-notifications`)
- Create `specs/{slug}/`
- Do **not** include an issue number prefix (this is project-dna, not omecare)

---

## Step 5: Write `specs/{slug}/spec.md`

Follow the structure from `specs/_template.spec.md`.

**Required sections**: Summary, Affected Components table (package → what changes), Acceptance Criteria

**Include only relevant optional sections**: User Stories, Data Model (Prisma), API Endpoints, Zod Schemas, UI Components, Test Plan, Out of Scope, Open Questions

Keep it concise — this is a reference document, not a design doc. `spec.md` is **read-only after creation**.

---

## Step 6: Write `specs/{slug}/checklist.md`

This is the **single mutable state file** for the entire implementation. It contains frontmatter, progress, tasks, handoff context, and audit trail.

### Frontmatter

```yaml
---
title: "{Feature Title}"
status: pending
currentPhase: 1
totalPhases: {N}
branch: "feat/{slug}"
createdAt: "{YYYY-MM-DD}"
updatedAt: "{YYYY-MM-DD}"
---
```

Status values: `pending` | `in-progress` | `blocked` | `review` | `done`

### Full checklist format

````markdown
---
title: "{title}"
status: pending
currentPhase: 1
totalPhases: {N}
branch: "feat/{slug}"
createdAt: "{date}"
updatedAt: "{date}"
---

# {title}

> **Spec**: `specs/{slug}/spec.md`
> **Branch**: `feat/{slug}`

## Progress

- Phase 1: {Name} — `pending`
- Phase 2: {Name} — `pending`
- Phase 3: {Name} — `pending`

---

## Phase 1: {Name}

**Goal**: {One sentence — what this phase achieves and why it's a natural boundary}

**Status**: `pending`

### Resume Context

{2–4 sentences written for a fresh Claude session that has NOT seen prior context.
Cover: what already exists, what this phase builds, key files to read first, any gotchas.
Example: "The Zod schemas in packages/shared are the source of truth. This phase adds the
Prisma model and migration only — no API routes yet. Read packages/db/prisma/schema.prisma first."}

### Tasks

- [ ] {Task description} — `{path/to/file.ts}`
- [ ] {Task description} — `{path/to/file.ts}` — note: {implementation hint}

### Verification

```bash
pnpm lint && pnpm typecheck && pnpm test
```

### Completion Notes

*(filled when phase completes — serves as handoff to next phase)*

---

## Phase 2: {Name}

**Goal**: {One sentence}

**Status**: `pending`

### Resume Context

{Written for a fresh session. Reference Phase 1 Completion Notes for what was built.
Example: "Phase 1 added the Prisma model. Read Phase 1 Completion Notes above for decisions made.
This phase adds the Hono route and Zod validation. Key files: apps/api/src/features/..."}

### Tasks

- [ ] {Task description} — `{path/to/file.ts}`
- [ ] {Task description} — `{path/to/file.ts}`

### Verification

```bash
pnpm lint && pnpm typecheck && pnpm test
```

### Completion Notes

*(filled when phase completes)*

---

## Implementation Log

| Date | Phase | Summary |
|------|-------|---------|

## How to Continue

```bash
.claude/scripts/spec-runner.sh {slug}            # resume from currentPhase
.claude/scripts/spec-runner.sh {slug} --dry-run  # preview remaining phases
.claude/scripts/spec-runner.sh {slug} --phase N  # start from specific phase
```
````

### Phase design rules

- **Independent**: Each phase is completable and verifiable on its own
- **Small**: 3–8 tasks, all finishable in one focused session (~50 min)
- **Ordered**: Dependencies flow forward — no circular deps between phases
- **Typical phase order for a full-stack feature**:
  1. Shared schemas + types (`packages/shared`)
  2. Database model + migration (`packages/db`)
  3. API route + service (`apps/api`)
  4. UI components + page (`apps/web`)
  5. Tests + polish (if not colocated in earlier phases)

### Task format rules

- Always include the target file path: `— \`path/to/file.ts\``
- Include implementation hint where non-obvious: `— note: use zValidator('json', Schema)`
- Keep task granularity at 5–15 min each
- Reference existing patterns by file path, not by description

### Completion Notes format (written by Claude at phase end)

```markdown
### Completion Notes
- **Completed**: {ISO timestamp}
- **Summary**: {1–2 sentences of what was accomplished}
- **Key files**: {files created/modified}
- **Decisions**: {WHY you chose approaches, not just WHAT}
- **Blockers**: {unresolved issues — "None" if clean}
- **Gotchas**: {surprising behaviors, edge cases, things next phase must know}
- **Next context**: {specific guidance for the next phase}
- **Verification**: lint:pass typecheck:pass tests:pass
```

Quality rules (from Continuous-Claude-v3):
- Decisions: Include WHY, not just WHAT
- Don't repeat information already in spec.md
- Don't include full file contents (use paths)
- Next context: Actionable, specific — not generic

---

## Step 7: Output Summary

After creating both files, display:

```
Plan created: {title}

specs/{slug}/
  spec.md       (requirements — read-only)
  checklist.md  (tasks + state + handoff — single source of truth)

{N} phases, {M} tasks total

To run:
  .claude/scripts/spec-runner.sh {slug}           # execute all phases
  .claude/scripts/spec-runner.sh {slug} --dry-run # preview first

Open Questions:
{List any questions that need answers before starting, or "None"}
```

---

## Guidelines

- `checklist.md` is the **only file that gets updated** during execution — `spec.md` is frozen
- Resume Context is written **now** (at plan time), not at runtime — it front-loads context for fresh sessions
- Don't over-engineer phases — 3 phases for a simple feature, 5 max for complex ones
- If a phase would touch more than 8 files, split it
