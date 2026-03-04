---
name: backend-patterns
description: Backend architecture patterns, API design, database optimization, and server-side best practices for Hono, Prisma, and Zod in a Turborepo monorepo.
origin: ECC
---

# Backend Development Patterns

Backend architecture patterns and best practices for the `apps/api` Hono service in this monorepo.

**Stack context:** Hono (API framework), Zod validation via `zValidator`, Prisma + PostgreSQL via `@repo/db`, schemas from `@repo/shared`, OpenAPI via `@hono/zod-openapi`, RPC client via `AppType` export.

## When to Activate

- Designing REST API endpoints with Hono routes
- Implementing service or repository layers
- Optimizing Prisma queries (N+1, select, includes)
- Structuring error handling and Zod validation for APIs
- Building Hono middleware (auth, logging, rate limiting)
- Setting up background jobs or async processing

## API Design Patterns

### RESTful API Structure

```typescript
// ✅ Resource-based URLs
GET    /api/markets                 # List resources
GET    /api/markets/:id             # Get single resource
POST   /api/markets                 # Create resource
PUT    /api/markets/:id             # Replace resource
PATCH  /api/markets/:id             # Update resource
DELETE /api/markets/:id             # Delete resource

// ✅ Query parameters for filtering, sorting, pagination
GET /api/markets?status=active&sort=volume&limit=20&offset=0
```

### Hono Route Structure

Feature-based routes at `apps/api/src/features/{name}/{name}.route.ts`:

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { CreateMarketSchema } from '@repo/shared'
import { marketService } from './market.service'

const markets = new Hono()

markets.get('/', async (c) => {
  const data = await marketService.findAll()
  return c.json({ data })
})

markets.get('/:id', async (c) => {
  const id = c.req.param('id')
  const data = await marketService.findById(id)
  if (!data) return c.json({ error: 'Not found' }, 404)
  return c.json({ data })
})

markets.post('/', zValidator('json', CreateMarketSchema), async (c) => {
  const body = c.req.valid('json')
  const data = await marketService.create(body)
  return c.json({ data }, 201)
})

export { markets }
```

### Exporting AppType for RPC

Always export `AppType` from the root app for the frontend RPC client:

```typescript
// apps/api/src/index.ts
import { Hono } from 'hono'
import { markets } from './features/markets/markets.route'

const app = new Hono().basePath('/api')
  .route('/markets', markets)

export type AppType = typeof app
export default app
```

## Repository Pattern

Abstract Prisma data access behind a repository:

```typescript
// features/markets/market.repository.ts
import { db } from '@repo/db'
import type { CreateMarketInput } from '@repo/shared'

export const marketRepository = {
  async findAll(filters?: { status?: string }) {
    return db.market.findMany({
      where: filters?.status ? { status: filters.status } : undefined,
      select: { id: true, name: true, status: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
    })
  },

  async findById(id: string) {
    return db.market.findUnique({ where: { id } })
  },

  async create(data: CreateMarketInput) {
    return db.market.create({ data })
  },

  async update(id: string, data: Partial<CreateMarketInput>) {
    return db.market.update({ where: { id }, data })
  },

  async delete(id: string) {
    return db.market.delete({ where: { id } })
  },
}
```

## Service Layer Pattern

Business logic separated from data access:

```typescript
// features/markets/market.service.ts
import { marketRepository } from './market.repository'
import type { CreateMarketInput } from '@repo/shared'

export const marketService = {
  async findAll() {
    return marketRepository.findAll({ status: 'active' })
  },

  async findById(id: string) {
    return marketRepository.findById(id)
  },

  async create(data: CreateMarketInput) {
    // Business logic before persistence
    return marketRepository.create(data)
  },
}
```

## Middleware Pattern

```typescript
// middleware/auth.ts
import type { MiddlewareHandler } from 'hono'
import { verify } from 'hono/jwt'

export const authMiddleware: MiddlewareHandler = async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) return c.json({ error: 'Unauthorized' }, 401)

  try {
    const payload = await verify(token, process.env.JWT_SECRET!)
    c.set('user', payload)
    await next()
  } catch {
    return c.json({ error: 'Invalid token' }, 401)
  }
}

// Usage
markets.use('*', authMiddleware)
markets.post('/', zValidator('json', CreateMarketSchema), async (c) => {
  const user = c.get('user')
  // ...
})
```

## Database Patterns

### Prisma Query Optimization

```typescript
// ✅ GOOD: Select only needed columns
const markets = await db.market.findMany({
  select: { id: true, name: true, status: true },
  where: { status: 'active' },
  orderBy: { createdAt: 'desc' },
  take: 20,
  skip: offset,
})

// ❌ BAD: Fetch everything
const markets = await db.market.findMany()
```

### N+1 Query Prevention

```typescript
// ❌ BAD: N+1 problem
const markets = await db.market.findMany()
for (const market of markets) {
  market.creator = await db.user.findUnique({ where: { id: market.creatorId } })
}

// ✅ GOOD: Use Prisma include
const markets = await db.market.findMany({
  include: { creator: { select: { id: true, name: true } } },
})
```

### Transaction Pattern

```typescript
async function createMarketWithPosition(
  marketData: CreateMarketInput,
  positionData: CreatePositionInput
) {
  return db.$transaction(async (tx) => {
    const market = await tx.market.create({ data: marketData })
    const position = await tx.position.create({
      data: { ...positionData, marketId: market.id },
    })
    return { market, position }
  })
}
```

## Error Handling

### Centralized Error Handler

```typescript
// errors.ts
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string
  ) {
    super(message)
  }
}

// Hono error handler
app.onError((err, c) => {
  if (err instanceof ApiError) {
    return c.json({ error: err.message }, err.statusCode as 400 | 401 | 403 | 404 | 500)
  }
  if (err instanceof z.ZodError) {
    return c.json({ error: 'Validation failed', details: err.errors }, 400)
  }
  console.error('Unexpected error:', err)
  return c.json({ error: 'Internal server error' }, 500)
})
```

### Retry with Exponential Backoff

```typescript
async function fetchWithRetry<T>(fn: () => Promise<T>, maxRetries = 3): Promise<T> {
  let lastError: Error

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (err) {
      lastError = err as Error
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000))
      }
    }
  }

  throw lastError!
}
```

## Authentication & Authorization

### JWT + Role-Based Access

```typescript
import { sign, verify } from 'hono/jwt'

type Role = 'admin' | 'user'

const rolePermissions: Record<Role, string[]> = {
  admin: ['read', 'write', 'delete'],
  user: ['read', 'write'],
}

export function requirePermission(permission: string): MiddlewareHandler {
  return async (c, next) => {
    const user = c.get('user') as { role: Role }
    if (!rolePermissions[user.role]?.includes(permission)) {
      return c.json({ error: 'Insufficient permissions' }, 403)
    }
    await next()
  }
}

// Usage
markets.delete('/:id', authMiddleware, requirePermission('delete'), async (c) => {
  const id = c.req.param('id')
  await marketService.delete(id)
  return c.json({ data: null }, 204)
})
```

## Rate Limiting

```typescript
import { rateLimiter } from 'hono-rate-limiter'

app.use(
  rateLimiter({
    windowMs: 60_000,   // 1 minute
    limit: 100,
    keyGenerator: (c) => c.req.header('x-forwarded-for') ?? 'unknown',
  })
)
```

## Structured Logging

```typescript
app.use(async (c, next) => {
  const start = Date.now()
  const requestId = crypto.randomUUID()

  console.log(JSON.stringify({
    requestId,
    method: c.req.method,
    path: c.req.path,
    timestamp: new Date().toISOString(),
  }))

  await next()

  console.log(JSON.stringify({
    requestId,
    status: c.res.status,
    durationMs: Date.now() - start,
  }))
})
```

**Remember**: Keep routes thin — validation in `zValidator`, business logic in services, data access in repositories.
