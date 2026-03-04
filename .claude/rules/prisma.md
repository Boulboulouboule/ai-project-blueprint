---
paths:
  - "packages/db/**"
  - "**/schema.prisma"
---

# Prisma Rules

## Schema Conventions

- Models: PascalCase. Fields: camelCase.
- Always include `id` (cuid), `createdAt`, `updatedAt` on every model
- `@@map("table_name")` for snake_case tables, `@map("column_name")` for snake_case columns

```prisma
model UserProfile {
  id        String   @id @default(cuid())
  email     String   @unique
  firstName String   @map("first_name")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("user_profiles")
}
```

## Client Pattern

Singleton to prevent connection exhaustion in dev:

```typescript
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined };
export const db = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;
```

## Migration Workflow

1. Edit `schema.prisma`
2. `pnpm db:migrate` (`prisma migrate dev --name <description>`)
3. Commit migration files alongside schema changes
4. CI/prod: `prisma migrate deploy`

## Queries

- Use `select` to pick only needed fields (avoid over-fetching)
- Use `include` sparingly — prefer separate queries to avoid N+1
- Use transactions for multi-step operations: `db.$transaction([...])`
- Use `upsert` for idempotent seeding
