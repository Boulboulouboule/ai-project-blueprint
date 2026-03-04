# Project DNA

An AI-optimized project template for full-stack TypeScript applications. Clone it, rename it, start building.

## Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | TanStack Start, TanStack Router, TanStack Query, React 19 |
| **Backend** | Hono, Zod validation |
| **Database** | Prisma, PostgreSQL |
| **Styling** | Tailwind CSS v4 |
| **Components** | Shared UI library with Vitest + Testing Library |
| **Monorepo** | Turborepo, pnpm workspaces |
| **Tooling** | ESLint 9, TypeScript 5.9, Prettier |

## Quick Start

```bash
# Clone the template
git clone https://github.com/Boulboulouboule/ai-project-blueprint.git my-app
cd my-app

# Initialize with your project name
./scripts/init.sh my-app

# Start PostgreSQL
docker compose up -d

# Run database migrations
pnpm db:migrate

# Start development
pnpm dev
```

- Web: http://localhost:3000
- API: http://localhost:3001

## Project Structure

```
├── apps/
│   ├── api/                    # Hono backend API
│   └── web/                    # TanStack Start frontend
├── packages/
│   ├── shared/                 # Zod schemas + shared types
│   ├── ui/                     # React component library
│   └── db/                     # Prisma + PostgreSQL
├── tooling/
│   ├── eslint/                 # ESLint configurations
│   ├── typescript/             # TypeScript configurations
│   └── prettier/               # Prettier configuration
├── specs/                      # Feature specifications
├── adr/                        # Architecture Decision Records
├── .claude/skills/             # Claude Code skills
├── .claude/agents/             # Claude Code agents
└── .cursor/rules/              # Cursor IDE rules
```

## AI Configuration

This template is optimized for AI-assisted development with pre-configured skills, agents, and rules.

### Skills (Claude Code)

| Skill | Purpose |
|-------|---------|
| `/create-spec [feature]` | Generate a feature specification |
| `/create-adr [title]` | Record an architectural decision |
| `/plan [description]` | Create a phased implementation plan |
| `/create-feature [name]` | Scaffold a complete vertical slice |

### Agents (Claude Code)

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Read-only code review with severity-rated report |
| `test-runner` | Run tests, analyze failures, suggest fixes |
| `spec-checker` | Sync specs with code, detect drift |

### Cursor Rules

8 rule files in `.cursor/rules/` covering TypeScript, React, Hono, Prisma, testing, Tailwind, Zod, and project structure conventions.

## Scripts

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

## Documentation

- [`AGENTS.md`](AGENTS.md) — Universal agent instructions and conventions
- [`CLAUDE.md`](CLAUDE.md) — Claude-specific instructions
- [`specs/`](specs/) — Feature specifications
- [`adr/`](adr/) — Architecture Decision Records (7 base decisions)

## License

MIT
