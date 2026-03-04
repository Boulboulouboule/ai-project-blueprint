---
paths:
  - "**/*.schema.ts"
  - "packages/shared/**"
---

# Zod Schema Rules

## Schema-First Design

Define schemas first, derive types from them — never write types manually when they can be inferred.

```typescript
export const UserSchema = z.object({
  id: z.string().cuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['admin', 'user']),
  createdAt: z.coerce.date(),
});

export type User = z.infer<typeof UserSchema>;
```

## Naming

- Schema: `{Entity}Schema`, Type: `{Entity}`, Create: `Create{Entity}Schema`, Update: `Update{Entity}Schema`
- File: `{entity}.schema.ts`

```typescript
// users.schema.ts
export const UserSchema = z.object({ ... });
export type User = z.infer<typeof UserSchema>;

export const CreateUserSchema = UserSchema.omit({ id: true, createdAt: true });
export type CreateUser = z.infer<typeof CreateUserSchema>;

export const UpdateUserSchema = CreateUserSchema.partial();
export type UpdateUser = z.infer<typeof UpdateUserSchema>;
```

## Composition

- Use `.pick()`, `.omit()`, `.partial()`, `.extend()`, `.merge()` to derive schemas
- Use `z.discriminatedUnion()` for tagged unions
- Use `.transform()` for computed fields or normalization

## Shared Schemas (packages/shared)

- `ApiResponseSchema` — envelope `{ data, error, meta }`
- `PaginationSchema` — `{ page, limit, total }`

## Don'ts

- Never use `z.any()` without transformation/narrowing
- Never duplicate a schema — compose from existing ones
