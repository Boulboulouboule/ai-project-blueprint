---
paths:
  - "apps/api/**"
---

# Hono API Rules

## App Structure

```
apps/api/src/
├── app.ts               # createApp() factory + global middleware
├── index.ts             # serve(app) entry point
├── middleware/
│   ├── error-handler.ts
│   └── logger.ts
└── features/
    └── {feature}/
        ├── {feature}.route.ts
        ├── {feature}.service.ts  (if needed)
        └── {feature}.test.ts
```

## Route Patterns

- Each feature exports a Hono instance: `export const usersRoute = new Hono()`
- Mount in app.ts: `app.route('/users', usersRoute)`
- Use `@hono/zod-validator` for request validation
- Return consistent `{ data }` response shape

```typescript
export const usersRoute = new Hono()
  .get('/', async (c) => {
    const users = await userService.findAll();
    return c.json({ data: users });
  })
  .post('/', zValidator('json', CreateUserSchema), async (c) => {
    const body = c.req.valid('json');
    const user = await userService.create(body);
    return c.json({ data: user }, 201);
  });
```

## Type-Safe Client

```typescript
// app.ts
const app = createApp();
export type AppType = typeof app;
// Frontend: hc<AppType>(baseUrl)
```

## Error Handling

- Use Hono's `HTTPException` for expected errors
- Global error handler in `app.ts` formats all errors consistently
- Never expose stack traces in production
- Log errors with context (request ID, path, method)

## Testing

- Use `app.request()` — no HTTP server needed
- Test happy path + error cases + validation errors
- Mock external services, not internal modules
