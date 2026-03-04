# Agent Instructions

Universal instructions for all AI coding agents (Claude, Cursor, Copilot, etc.)

## Architecture

This is a **Turborepo monorepo** with pnpm workspaces:

| Directory | Purpose | Key Tech |
|-----------|---------|----------|
| `apps/web` | Frontend + BFF | TanStack Start, TanStack Router, TanStack Query |
| `apps/api` | Backend API | Hono, Zod validation, OpenAPI |
| `packages/shared` | Schemas + types | Zod (single source of truth) |
| `packages/ui` | Component library | React, Tailwind CSS v4 |
| `packages/db` | Database layer | Prisma, PostgreSQL |
| `tooling/` | Build configs | ESLint, TypeScript, Prettier |

## Import Boundaries

```
apps/ → packages/    ✅
packages/ → packages/ ✅ (no circular)
packages/ → apps/    ❌ NEVER
```

Internal packages use `@repo/` scope: `@repo/shared`, `@repo/db`, `@repo/ui`.

## Conventions

### Files
- `kebab-case.ts` for plain files
- `{name}.{type}.ts` for typed files: `.route.ts`, `.service.ts`, `.schema.ts`, `.test.ts`
- Components: `PascalCase.tsx`, one component per file

### Types
- **Schema-first**: Define Zod schema → derive type with `z.infer<typeof Schema>`
- **Never** duplicate types that can be inferred
- Schemas: `{Entity}Schema`, Types: `{Entity}`, Create: `Create{Entity}Schema`

### API Routes (Hono)
- Feature-based: `features/{name}/{name}.route.ts`
- Validate with `@hono/zod-validator`: `zValidator('json', Schema)`
- Return consistent `{ data }` envelope
- Export `AppType` for RPC client

### Components (React)
- Function declarations, not arrow functions
- Props type defined above component
- Use TanStack Query for server state, Router search params for URL state
- Semantic HTML, accessible by default

### Testing (Vitest)
- Colocated: `users.service.ts` → `users.service.test.ts`
- API tests: use `app.request()` (no HTTP server)
- AAA pattern: Arrange → Act → Assert
- Target: 80% coverage on packages

### Database (Prisma)
- Every model: `id` (cuid), `createdAt`, `updatedAt`
- snake_case in DB via `@@map()` / `@map()`
- PrismaClient singleton from `packages/db`
- Migrations committed alongside schema changes

### Styling (Tailwind v4)
- Utility classes in JSX, no `@apply`
- Design tokens via `@theme` in CSS
- Use theme tokens (`bg-primary`), never hardcode colors

## Workflow

1. **Before implementing**: Check `specs/` for a feature spec. If none exists, create one with `/create-spec`.
2. **Before a technical decision**: Check `adr/` for prior decisions. Record new decisions with `/create-adr`.
3. **Feature development**: Use `/create-feature` to scaffold the vertical slice.
4. **Before committing**: Run `pnpm lint && pnpm typecheck && pnpm test`.
5. **Code review**: Use the `code-reviewer` agent to check for issues.

## Skills

| Skill | Purpose |
|-------|---------|
| `/create-spec [feature]` | Create a feature specification |
| `/create-adr [title]` | Record an architectural decision |
| `/plan [description]` | Create a phased implementation plan |
| `/create-feature [name]` | Scaffold a vertical slice (also model-invocable) |

## Agents

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Read-only code review with severity-rated report |
| `test-runner` | Run tests, analyze failures, suggest fixes |
| `spec-checker` | Sync specs with code, detect drift |

## Commands

| Command | Purpose |
|---------|---------|
| `pnpm dev` | Start all apps in dev mode |
| `pnpm build` | Build all packages + apps |
| `pnpm test` | Run all tests |
| `pnpm lint` | Lint all packages |
| `pnpm typecheck` | Type check all packages |
| `pnpm db:migrate` | Run Prisma migrations |
| `pnpm db:seed` | Seed the database |
| `pnpm db:studio` | Open Prisma Studio |

## Don'ts

- Don't use `any` — use `unknown` and narrow
- Don't create files without reading existing ones first
- Don't add dependencies without checking if one already exists in the monorepo
- Don't modify `tooling/` configs without understanding downstream impact
- Don't skip tests — every feature needs tests
- Don't import from `apps/` into `packages/`
