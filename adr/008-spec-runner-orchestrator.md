# ADR-008: Spec-Runner Orchestrator for Phased Implementation

- **Status**: Accepted
- **Date**: 2026-03-04
- **Deciders**: Vincent

## Context

Complex feature implementations in a monorepo benefit from a structured, phased approach where each phase is independently verifiable. Single long Claude sessions suffer from context drift — the model's attention degrades as the context window fills, leading to inconsistent output quality across a session.

Anthropic's engineering blog on [effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) recommends running each phase in a fresh session ("compound, don't compact") and persisting handoff state between sessions explicitly.

This ADR documents the decision to adopt a `spec-runner.sh` orchestrator into project-dna.

## Decision

Introduce `scripts/spec-runner.sh` — a Bash orchestrator that:

1. Reads a spec's `checklist.md` (with YAML frontmatter) to discover phases
2. Runs each phase as a fresh `claude -p` session with `--output-format stream-json`
3. Inlines verification and handoff instructions into every phase prompt
4. Validates phase completion by reading the updated checklist
5. Aggregates cost/tool/duration metrics across phases
6. Optionally creates a PR after all phases complete

### Architecture

Five focused library modules (~100–200 lines each), sourced by the main script:

| Module | Responsibility |
|--------|---------------|
| `sr-config.sh` | CLI arg parsing, env defaults, dependency checks |
| `sr-monitor.sh` | NDJSON stream parsing, real-time status display |
| `sr-validate.sh` | Checklist frontmatter parsing, phase status reads |
| `sr-summary.sh` | Per-phase and full-run summaries, optional JSON output |
| `sr-prompts.sh` | Verify/handoff/PR prompt template builders |

### Checklist Format

`specs/{slug}/checklist.md` uses YAML frontmatter:

```yaml
---
title: "Feature Title"
status: pending
currentPhase: 1
totalPhases: N
branch: "feat/slug"
createdAt: "2026-03-04"
updatedAt: "2026-03-04"
---
```

Each phase section has a `**Status**` field that Claude updates to `completed` after verification.

### Verification Gate (inlined into every phase)

Every phase prompt includes mandatory verification steps:
1. `pnpm lint && pnpm typecheck`
2. `code-reviewer` agent on uncommitted changes
3. `pnpm test`
4. Fix-and-retry loop (max 3 iterations)

### Handoff Notes (inlined into every phase)

After verification, Claude writes structured completion notes (Summary, Key Files, Decisions, Blockers, Gotchas, Next Context) into `checklist.md` for the next phase's context.

## Consequences

### Positive
- Each phase starts fresh — no context drift between phases
- Structured handoff notes prevent information loss between sessions
- Phased approach makes large features reviewable incrementally
- `--dry-run` and `--phase N` flags support iterative development
- Machine-readable JSON output enables CI integration
- Modular library design (5 focused files) keeps each module under 200 lines

### Negative
- Additional tooling complexity — 6 new shell scripts to maintain
- Requires `claude` CLI, `jq`, `gh`, and `git` to be installed
- Each phase incurs cold-start overhead (new session, no shared tool cache)
- Shell-based approach limits testability (no unit tests for scripts)

### Risks
- Checklist sync issues if Claude fails mid-handoff — mitigated by retry logic
- bypassPermissions is the default mode — users must be aware Claude runs autonomously

## Alternatives Considered

### Single long session
- **Pros**: Simpler setup, no inter-phase state management
- **Cons**: Context drift after ~50K tokens; inconsistent output quality
- **Why rejected**: Core problem we're solving

### Claude SDK (TypeScript)
- **Pros**: Type-safe, testable, integrates with monorepo tooling
- **Cons**: Requires Node.js build step; shell is more portable for a CLI tool
- **Why rejected**: Shell is simpler for a dev-time orchestrator; can migrate later

### Separate skill files (SKILL.md per phase type)
- **Pros**: Reusable individually
- **Cons**: Requires extra Read tool calls per phase; slows session start
- **Why rejected**: Inlining prompts is faster and avoids file read overhead

## References

- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic: Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Continuous-Claude-v3](https://github.com/parcadei/Continuous-Claude-v3)
- [Context Engineering for AI Agents (Manus)](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
