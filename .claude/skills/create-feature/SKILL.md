---
disable-model-invocation: false
user-invocable: true
description: Scaffold a vertical slice feature with all layers
---

# Create Feature: $ARGUMENTS

## Instructions

You are scaffolding a complete vertical slice for the **$ARGUMENTS** feature. This creates all layers: schema, types, API route, service, tests, and UI component.

### Step 1: Check for a Spec
Look for `specs/$ARGUMENTS/spec.md`. If it exists, use it as the source of truth for the data model, API, and components. If not, ask the user if they want to create one first with `/create-spec $ARGUMENTS`.

### Step 2: Read Project Conventions
- Read `AGENTS.md` for naming and structure conventions
- Read `.cursor/rules/project-structure.mdc` for file organization
- Look at existing features for patterns to follow

### Step 3: Create the Schema (packages/shared)

Create `packages/shared/src/$ARGUMENTS.schema.ts`:
```typescript
import { z } from 'zod';

export const {Entity}Schema = z.object({
  id: z.string().cuid(),
  // fields from spec
  createdAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
});

export type {Entity} = z.infer<typeof {Entity}Schema>;

export const Create{Entity}Schema = {Entity}Schema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
export type Create{Entity} = z.infer<typeof Create{Entity}Schema>;

export const Update{Entity}Schema = Create{Entity}Schema.partial();
export type Update{Entity} = z.infer<typeof Update{Entity}Schema>;
```

Then add the export to `packages/shared/src/index.ts`.

### Step 4: Create the Prisma Model (packages/db)

Add the model to `packages/db/prisma/schema.prisma` following conventions:
- cuid for id
- snake_case mapping
- createdAt/updatedAt

Remind the user to run `pnpm db:migrate` after.

### Step 5: Create the API Route (apps/api)

Create `apps/api/src/features/$ARGUMENTS/`:

**{name}.route.ts** — Hono route with CRUD endpoints:
- `GET /` — List (with pagination)
- `POST /` — Create (with Zod validation)
- `GET /:id` — Get by ID
- `PATCH /:id` — Update (with Zod validation)
- `DELETE /:id` — Delete

**{name}.service.ts** — Business logic using Prisma client from `@repo/db`

**{name}.test.ts** — Tests for each endpoint using `app.request()`

### Step 6: Mount the Route

Add the route to `apps/api/src/app.ts`:
```typescript
import { {name}Route } from './features/{name}/{name}.route';
app.route('/{name}', {name}Route);
```

### Step 7: Create UI Components (if applicable)

Create basic components in `apps/web/src/routes/` or `packages/ui/src/`:
- List view component
- Detail/form component

### Step 8: Report

After creating all files, report:
- List of files created
- Prisma migration reminder
- API endpoints available
- Suggested next steps (run tests, seed data, etc.)

## Files Created
```
packages/shared/src/{name}.schema.ts        # Zod schemas + types
packages/db/prisma/schema.prisma            # Updated with new model
apps/api/src/features/{name}/{name}.route.ts
apps/api/src/features/{name}/{name}.service.ts
apps/api/src/features/{name}/{name}.test.ts
apps/api/src/app.ts                         # Updated with route mount
```
