---
disable-model-invocation: true
argument-hint: "[description]"
description: Create a phased implementation plan for complex work
---

# Implementation Plan: $ARGUMENTS

## Instructions

You are creating a detailed implementation plan for: **$ARGUMENTS**

### Step 1: Understand the Scope
- Read `AGENTS.md` for project conventions and architecture
- Check `specs/` for any relevant feature specs
- Check `adr/` for relevant architectural decisions
- Explore the codebase to understand current state and patterns
- Identify affected files and packages

### Step 2: Break Down the Work

Analyze the requirements and decompose into phases. Each phase should be:
- **Independent**: Can be tested/verified before moving to the next phase
- **Small**: Completable in one focused session
- **Ordered**: Dependencies flow forward (no circular dependencies between phases)

### Step 3: Identify Risks

For each phase, identify:
- **Blockers**: What could prevent completion?
- **Unknowns**: What needs research or experimentation?
- **Dependencies**: External services, APIs, or team decisions needed?

### Step 4: Generate the Plan

Format as:

```markdown
## Plan: {title}

### Overview
{1-2 sentences summarizing the approach}

### Phases

#### Phase 1: {name}
**Goal**: {what this phase achieves}
**Files**:
- `path/to/file.ts` — {what changes}
**Steps**:
1. {step}
2. {step}
**Verification**: {how to confirm this phase is complete}
**Risks**: {any risks}

#### Phase 2: {name}
...

### Dependencies
- [ ] {external dependency or decision needed}

### Estimated Complexity
- **Total phases**: {N}
- **Highest risk phase**: Phase {N} — {reason}

### Definition of Done
- [ ] All phases complete
- [ ] Tests passing (`pnpm test`)
- [ ] Types check (`pnpm typecheck`)
- [ ] Linting clean (`pnpm lint`)
- [ ] Code reviewed (`/code-review`)
```

### Step 5: Review

After generating the plan:
- Verify each phase can be independently verified
- Check that the phase order respects dependencies
- Ensure no phase is too large (max ~10 files changed per phase)
- Confirm the Definition of Done is comprehensive

Present the plan to the user and ask for approval before implementing.
