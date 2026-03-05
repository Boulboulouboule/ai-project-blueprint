---
title: "{FEATURE_TITLE}"
status: pending
currentPhase: 1
totalPhases: 0
branch: "feat/{slug}"
createdAt: "{YYYY-MM-DD}"
updatedAt: "{YYYY-MM-DD}"
---

# {FEATURE_TITLE}

> **Spec**: `specs/{slug}/spec.md`
> **Branch**: `feat/{slug}`

## Progress

- Phase 1: {Name} — `pending`
- Phase 2: {Name} — `pending`

---

## Phase 1: {Name}

**Goal**: {One sentence — what this phase achieves and why it's a natural boundary}

**Status**: `pending`

### Resume Context

{2–4 sentences written for a fresh Claude session with no prior context.
Cover: what already exists, what this phase builds, key files to read first, any gotchas.}

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

{Written for a fresh session. Reference Phase 1 Completion Notes for what was built.}

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
