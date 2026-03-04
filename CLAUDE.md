# Claude Instructions

Claude-specific instructions for this project. Read `AGENTS.md` first for universal conventions.

## MCP Servers

This project connects to the following MCP servers (configured in `.claude.json`):
- **Context7** — Up-to-date library documentation lookup
- **TanStack CLI** — TanStack-specific guidance
- **Prisma** — Schema and query assistance

Use these servers when you need current documentation rather than relying on training data.

## Available Skills

| Skill | When to Use |
|-------|-------------|
| `/scaffold [name]` | Bootstrap a new project from scratch |
| `/create-spec [feature]` | Before implementing a new feature |
| `/create-adr [title]` | After making a technical decision |
| `/create-feature [name]` | After a spec is approved, scaffold the vertical slice |
| `/code-review` | Before committing — checks for issues |
| `/plan [description]` | Before complex work — creates a phased plan |

## File Patterns

When asked to create or modify files, follow these patterns:

### New API Feature
```
apps/api/src/features/{name}/
├── {name}.route.ts     # Hono route definitions
├── {name}.service.ts   # Business logic (optional)
└── {name}.test.ts      # Tests using app.request()
```

### New Schema
```
packages/shared/src/{name}.schema.ts
```
Then re-export from `packages/shared/src/index.ts`.

### New UI Component
```
packages/ui/src/{name}/
├── {name}.tsx
└── {name}.test.tsx
```
Then re-export from `packages/ui/src/index.ts`.

### New Page/Route
```
apps/web/src/routes/{path}.tsx
```

## Tool Usage Preferences

- Use `Write` for new files, `Edit` for modifications
- Use `Glob` to find files by pattern before modifying
- Use `Grep` to search for existing usage before adding new code
- Run `pnpm typecheck` after TypeScript changes to verify
- Run `pnpm test` after logic changes to verify

## Code Style

- TypeScript strict mode — no `any`, no `@ts-ignore`
- Explicit return types on exported functions
- `type` imports for type-only imports
- Functional patterns: pure functions, immutability, composition
- Error handling: typed errors, Result pattern for expected failures

## When Unsure

1. Check `adr/` for prior architectural decisions
2. Check `specs/` for feature requirements
3. Look at existing code in the same directory for patterns
4. Ask the user rather than guessing
