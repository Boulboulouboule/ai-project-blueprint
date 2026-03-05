# Project DNA

A project template for full-stack TypeScript applications. Clone it, run the init script, start building.

## Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | TanStack Start, TanStack Router, TanStack Query, React 19 |
| **Backend** | Hono, Zod validation |
| **Database** | Prisma, PostgreSQL |
| **Styling** | Tailwind CSS v4 |
| **Components** | Shared UI library with Vitest + Testing Library |
| **Monorepo** | Turborepo, pnpm workspaces |
| **Tooling** | TypeScript 5.9, ESLint 9, Prettier |

## Quick Start

```bash
# Clone the template
git clone https://github.com/Boulboulouboule/ai-project-blueprint.git my-app
cd my-app

# Initialize with your project name
./scripts/init.sh my-app

# Add AI/Claude Code configuration (optional)
node /path/to/quodalia/ai-setup/init.js

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
└── scripts/
    └── init.sh                 # Project initialization script
```

## AI Configuration

AI/Claude Code configuration is managed separately via [quodalia/ai-setup](https://github.com/quodalia/ai-setup).

After cloning this template, run `init.js` from that repo to install:
- Claude Code agents, skills, and rules tailored to the detected stack
- Hook scripts for formatting, type-checking, and session management
- `specs/` directory with feature spec templates

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

## Documentation

- [`adr/`](adr/) — Architecture Decision Records

## License

MIT
