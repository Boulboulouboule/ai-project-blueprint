# ADR-007: AI-Friendly Architecture

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

AI coding agents (Claude, Cursor, Copilot) are integral to our development workflow. The codebase architecture significantly impacts AI agent effectiveness — studies show that well-structured projects with clear conventions, colocated files, and explicit boundaries improve AI-generated code accuracy by 40-60%. We need architectural principles that optimize for both human and AI developer experience.

## Decision

Adopt **AI-friendly architecture** principles across the entire codebase:

### 1. Flat, Feature-Based Structure
```
features/
└── users/
    ├── users.route.ts      # Route definitions
    ├── users.service.ts     # Business logic
    ├── users.schema.ts      # Zod schemas
    └── users.test.ts        # Colocated tests
```

### 2. Naming Conventions
- Files: `{feature}.{type}.ts` (e.g., `users.route.ts`, `users.service.ts`)
- Schemas: `{Entity}Schema` → type `{Entity}` via `z.infer`
- Components: PascalCase, one per file, file matches component name
- Tests: colocated as `{name}.test.ts`

### 3. Agent Configuration Files
- `AGENTS.md` — Universal agent instructions (architecture, conventions, workflow)
- `CLAUDE.md` — Claude-specific instructions (tool usage, file patterns)
- `.cursor/rules/*.mdc` — Cursor-specific rules per technology
- `.claude/commands/*.md` — Reusable skills (scaffold, create-feature, etc.)

### 4. Explicit Boundaries
- `packages/` have clear public APIs via `index.ts` barrel exports
- Import restrictions: apps import packages, never the reverse
- Each package has its own `tsconfig.json` extending a shared base

### 5. Schema-First Design
- Zod schemas are the single source of truth for data shapes
- Types are derived (`z.infer`), never manually duplicated
- Schemas live in `packages/shared`, imported everywhere

## Consequences

### Positive
- AI agents produce more accurate code when files follow predictable patterns
- Flat structure keeps relevant context within AI token limits
- Colocated tests mean agents always find related tests
- Named conventions eliminate ambiguity for both AI and humans
- Agent config files provide consistent instructions across tools

### Negative
- More upfront structure and conventions to establish
- Feature-based grouping can feel unusual for teams used to layer-based structure
- Agent config files need maintenance as conventions evolve

### Risks
- Over-documenting conventions (mitigated by keeping files concise and linking to examples)
- Conventions becoming stale (mitigated by `/code-review` skill checking compliance)

## Alternatives Considered

### Layer-Based Architecture (controllers/, services/, models/)
- **Pros**: Traditional, familiar to most developers
- **Cons**: Related files scattered across directories, AI agents need more context to make changes
- **Why rejected**: Feature-based grouping keeps all related code together, reducing context needed.

### No Agent Configuration
- **Pros**: Less maintenance
- **Cons**: AI agents rely on generic patterns, produce inconsistent code, miss project conventions
- **Why rejected**: The ROI of agent configuration is extremely high — small files, large productivity gains.

### Micro-Frontends / Micro-Services
- **Pros**: Team autonomy, independent deployment
- **Cons**: Massive complexity, AI agents lose cross-service context
- **Why rejected**: Premature for most projects. Monorepo with clear boundaries achieves similar isolation with better DX.

## References

- [AI-Friendly Codebase Practices (2025-2026)](https://www.anthropic.com/research/building-effective-agents)
- [Feature-Sliced Design](https://feature-sliced.design/)
