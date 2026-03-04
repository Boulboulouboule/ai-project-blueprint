# ADR-004: Prisma + PostgreSQL

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a database layer that provides type-safe queries, declarative schema management, and reliable migrations. The solution should integrate seamlessly with TypeScript and support a shared database package consumed by both the API and potentially server functions in the web app.

## Decision

Use **Prisma ORM** with **PostgreSQL** as the database, packaged in `packages/db`.

```
packages/db/
├── prisma/
│   └── schema.prisma     # Declarative schema (single source of truth)
├── src/
│   ├── index.ts           # PrismaClient singleton export
│   └── seed.ts            # Seed data script
└── package.json
```

Key patterns:
- PrismaClient singleton pattern (prevents connection exhaustion in dev)
- Schema-first design — types are generated from the schema
- Migration workflow: `prisma migrate dev` (local) → `prisma migrate deploy` (CI/prod)
- PostgreSQL runs in Docker for local development

## Consequences

### Positive
- Best TypeScript integration of any ORM — full autocompletion, type-safe queries
- Declarative schema is readable by AI agents and humans alike
- Migration system is reliable and production-tested
- `prisma generate` produces types that stay in sync with the database
- Active ecosystem with Prisma Studio, Prisma Accelerate, Prisma Pulse

### Negative
- N+1 query risk with nested includes (mitigated by `findMany` patterns and query logging)
- Less control over generated SQL compared to query builders like Drizzle or Kysely
- Prisma Client adds ~2MB to node_modules (acceptable for server-side)
- Schema changes require a migration step (not just code changes)

### Risks
- Complex queries may need raw SQL fallback (`$queryRaw`)
- Connection pooling in serverless requires Prisma Accelerate or PgBouncer

## Alternatives Considered

### Drizzle ORM
- **Pros**: SQL-like syntax, lighter, more control over queries, better for complex joins
- **Cons**: Less mature migration system, manual type definitions, steeper learning curve
- **Why rejected**: Prisma's developer experience and type generation are superior for rapid development. The team values productivity over SQL control.

### Kysely
- **Pros**: Type-safe query builder, lightweight, composable
- **Cons**: No schema management, no migrations, requires separate tools
- **Why rejected**: Too low-level — we'd need to add migration tooling and type generation separately.

### TypeORM
- **Pros**: Mature, supports decorators, active record pattern
- **Cons**: Poor TypeScript types, buggy migrations, inconsistent behavior
- **Why rejected**: Type safety is inadequate. Known reliability issues with migrations.

## References

- [Prisma docs](https://www.prisma.io/docs)
- [Prisma best practices](https://www.prisma.io/docs/guides/performance-and-optimization)
