# Project DNA

AI-optimized project bootstrap system. Contains reusable skills, rules, templates, and architecture decisions for generating full-stack TypeScript monorepo projects.

## What's Included

### Skills (`.claude/commands/`)

| Skill | Description |
|-------|-------------|
| `/scaffold [name]` | Bootstrap a complete Turborepo project |
| `/create-spec [feature]` | Generate a feature specification |
| `/create-adr [title]` | Create an Architecture Decision Record |
| `/create-feature [name]` | Scaffold a vertical slice (schema + route + service + test) |
| `/code-review` | Review code for security, quality, and convention compliance |
| `/plan [description]` | Create a phased implementation plan |

### Generated Stack

| Layer | Technology |
|-------|-----------|
| Monorepo | Turborepo + pnpm |
| Frontend | TanStack Start (React 19, Router, Query) |
| Backend | Hono (Web Standards API, type-safe RPC) |
| Database | Prisma + PostgreSQL |
| Styling | Tailwind CSS v4 |
| Validation | Zod |
| Testing | Vitest |
| Linting | ESLint + Prettier |

### Cursor Rules (`.cursor/rules/`)

8 technology-specific rule files for consistent AI-generated code:
- TypeScript, React, Hono API, Prisma, Testing, Tailwind, Zod, Project Structure

### Architecture Decision Records (`adr/`)

7 base ADRs documenting key technology choices with alternatives considered and tradeoffs.

## Quick Start

1. Open a terminal in a directory where you want to create a new project
2. Run `/scaffold my-app` in Claude Code
3. Claude generates the entire project, installs dependencies, and initializes git
4. `cd my-app && pnpm dev` to start developing

## Project Structure

```
project-dna/
├── .claude/commands/     # 6 Claude Code skills
├── .cursor/rules/        # 8 Cursor rule files
├── specs/                # Feature spec template
├── adr/                  # 7 base ADRs + template
├── AGENTS.md             # Universal agent instructions
├── CLAUDE.md             # Claude-specific instructions
└── README.md
```

## Updating the Scaffold

The scaffold is a single markdown file (`.claude/commands/scaffold.md`). To update:

1. Edit the file contents for the phase you want to change
2. Test by running `/scaffold test-project` in a clean directory
3. Verify all checks pass: `pnpm install && pnpm test && pnpm build && pnpm typecheck && pnpm lint`
