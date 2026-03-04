# Claude Instructions

## MCP Servers

- **Context7** — Use for current library documentation instead of relying on training data.

## Architecture

Turborepo monorepo with pnpm workspaces:

| Directory | Purpose | Key Tech |
|-----------|---------|----------|
| `apps/web` | Frontend + BFF | TanStack Start, TanStack Router, TanStack Query |
| `apps/api` | Backend API | Hono, Zod validation, OpenAPI |
| `packages/shared` | Schemas + types | Zod (single source of truth) |
| `packages/ui` | Component library | React, Tailwind CSS v4 |
| `packages/db` | Database layer | Prisma, PostgreSQL |
| `packages/auth` | Auth library | BetterAuth, Prisma adapter |
| `tooling/` | Build configs | Biome, TypeScript |

**Import boundaries:**
```
apps/ → packages/    ✅
packages/ → packages/ ✅ (no circular)
packages/ → apps/    ❌ NEVER
```

Internal packages use `@repo/` scope: `@repo/shared`, `@repo/db`, `@repo/ui`, `@repo/auth`.

## Conventions

**Files:** `kebab-case.ts` for plain files, `{name}.{type}.ts` for typed files (`.route.ts`, `.service.ts`, `.schema.ts`, `.test.ts`). Components: `PascalCase.tsx`, one per file.

**Types:** Schema-first — define Zod schema, derive type with `z.infer<typeof Schema>`. Never duplicate types. Names: `{Entity}Schema`, `{Entity}`, `Create{Entity}Schema`.

**API Routes (Hono):** Feature-based `features/{name}/{name}.route.ts`. Validate with `zValidator('json', Schema)`. Return `{ data }` envelope. Export `AppType` for RPC client.

**Components (React):** Function declarations. Props type above component. TanStack Query for server state, Router search params for URL state.

**Testing (Vitest):** Colocated tests. API tests via `app.request()`. AAA pattern. 80% coverage on packages.

**Database (Prisma):** Every model: `id` (cuid), `createdAt`, `updatedAt`. snake_case via `@@map()`/`@map()`. Singleton PrismaClient from `packages/db`. Commit migrations with schema.

**Styling (Tailwind v4):** Utility classes in JSX, no `@apply`. Design tokens via `@theme`. Use theme tokens (`bg-primary`), never hardcode colors.

## File Patterns

**New API feature:**
```
apps/api/src/features/{name}/
├── {name}.route.ts
├── {name}.service.ts   (if needed)
└── {name}.test.ts
```

**New schema:** `packages/shared/src/{name}.schema.ts` → re-export from `packages/shared/src/index.ts`

**New UI component:** `packages/ui/src/{name}/{name}.tsx` + `{name}.test.tsx` → re-export from `packages/ui/src/index.ts`

**New page:** `apps/web/src/routes/{path}.tsx`

## Commands

| Command | Purpose |
|---------|---------|
| `pnpm dev` | Start all apps in dev mode |
| `pnpm build` | Build all packages + apps |
| `pnpm test` | Run all tests |
| `pnpm lint` | Lint all packages (Biome) |
| `pnpm check` | Lint + format check (Biome) |
| `pnpm format` | Auto-format all files (Biome) |
| `pnpm typecheck` | Type check all packages |
| `pnpm db:migrate` | Run Prisma migrations |
| `pnpm db:seed` | Seed the database |
| `pnpm db:studio` | Open Prisma Studio |
| `./scripts/spec-runner.sh <slug>` | Run phased implementation from `specs/<slug>/checklist.md` |
| `./scripts/spec-runner.sh <slug> --dry-run` | Preview phases without executing |
| `./scripts/spec-runner.sh <slug> --phase N` | Resume from phase N |
| `/plan-spec <description>` | Create `specs/{slug}/spec.md` + `checklist.md` for spec-runner |

## Don'ts

- Don't use `any` — use `unknown` and narrow
- Don't create files without reading existing ones first
- Don't add dependencies without checking if one already exists in the monorepo
- Don't modify `tooling/` configs without understanding downstream impact
- Don't skip tests — every feature needs tests
- Don't import from `apps/` into `packages/`

## When Unsure

1. Check `adr/` for prior architectural decisions
2. Check `specs/` for feature requirements
3. Look at existing code in the same directory for patterns
4. Ask the user rather than guessing
