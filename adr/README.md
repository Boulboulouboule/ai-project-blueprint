# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the project.

## What is an ADR?

An ADR is a short document that captures a significant architectural decision made along with its context and consequences. ADRs are numbered sequentially and are never deleted — when a decision is changed, a new ADR supersedes the old one.

## Creating a New ADR

Use the `/create-adr` skill:

```
/create-adr caching-strategy
```

This auto-numbers the ADR, generates from the template, and sets status to "Proposed".

## Status Lifecycle

1. **Proposed** — Under discussion
2. **Accepted** — Approved and in effect
3. **Deprecated** — No longer relevant
4. **Superseded** — Replaced by a newer ADR

## Index

| ADR | Decision | Status |
|-----|----------|--------|
| [001](001-turborepo-monorepo.md) | Turborepo + pnpm monorepo | Accepted |
| [002](002-tanstack-start.md) | TanStack Start frontend | Accepted |
| [003](003-hono-backend.md) | Hono backend API | Accepted |
| [004](004-prisma-postgresql.md) | Prisma + PostgreSQL | Accepted |
| [005](005-tailwind-v4.md) | Tailwind CSS v4 | Accepted |
| [006](006-zod-schemas.md) | Zod schemas | Accepted |
| [007](007-ai-friendly-architecture.md) | AI-friendly architecture | Accepted |
