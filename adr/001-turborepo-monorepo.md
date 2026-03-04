# ADR-001: Turborepo + pnpm Monorepo

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a repository structure that supports multiple apps (web, api) and shared packages (db, shared, ui) with efficient builds and clear dependency boundaries. The codebase must be optimized for AI-assisted development, where agents benefit from unified context and consistent patterns.

## Decision

Use **Turborepo** as the monorepo build orchestrator with **pnpm** as the package manager.

Structure:
```
apps/       → Deployable applications (web, api)
packages/   → Shared libraries (db, shared, ui)
tooling/    → Build configs (eslint, typescript, prettier)
```

## Consequences

### Positive
- Single repository gives AI agents full context across all packages
- Turborepo's task graph enables parallel builds with correct ordering
- pnpm's strict dependency isolation prevents phantom dependencies
- Shared tooling configs eliminate duplication across packages
- Remote caching (optional) speeds up CI dramatically

### Negative
- Initial setup complexity is higher than a single-package project
- pnpm's strictness can cause issues with packages that rely on hoisting
- All team members must understand the monorepo workflow

### Risks
- Large monorepos can slow down git operations over time (mitigated by shallow clones in CI)

## Alternatives Considered

### Nx
- **Pros**: More features, project graph visualization, generators
- **Cons**: Heavier, more opinionated, steeper learning curve
- **Why rejected**: Turborepo is simpler and sufficient for our needs. Nx's generators are replaced by our `/scaffold` and `/create-feature` skills.

### Separate Repositories
- **Pros**: Independent deployment, simpler per-repo
- **Cons**: Cross-repo changes are painful, no shared types without publishing, AI agents lose context
- **Why rejected**: Fragments the codebase, makes AI-assisted development much harder

### npm/yarn workspaces (no orchestrator)
- **Pros**: Simpler setup
- **Cons**: No task graph, no caching, manual build ordering
- **Why rejected**: Doesn't scale — build ordering becomes a maintenance burden

## References

- [Turborepo docs](https://turbo.build/repo/docs)
- [pnpm workspaces](https://pnpm.io/workspaces)
