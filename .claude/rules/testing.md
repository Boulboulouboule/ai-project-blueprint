---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/vitest.config.*"
---

# Testing Rules

## Framework & Coverage

- Vitest for all tests. Colocate: `users.service.ts` → `users.service.test.ts`
- Config per package: each package has `vitest.config.ts`
- Minimum 80% line coverage for `packages/`

## Test Structure

```typescript
describe('UserService', () => {
  describe('findById', () => {
    it('returns the user when found', async () => {
      // Arrange
      const userId = 'clx123';
      // Act
      const user = await userService.findById(userId);
      // Assert
      expect(user).toMatchObject({ id: userId });
    });

    it('returns null when user does not exist', async () => {
      const user = await userService.findById('nonexistent');
      expect(user).toBeNull();
    });
  });
});
```

## API Testing (Hono)

```typescript
it('returns 400 with invalid email', async () => {
  const res = await app.request('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'invalid', name: 'Test' }),
  });
  expect(res.status).toBe(400);
});
```

## Mocking

- Mock external services (HTTP APIs, email) — never mock internal modules
- Use `vi.mock()` for modules, `vi.fn()` for functions
- Prefer dependency injection over module mocking
- `afterEach(() => { vi.restoreAllMocks(); })`

## Component Testing

- Use `@testing-library/react`
- Test behavior, not implementation details
- Query by role, label, or text — not test IDs
- Avoid snapshot tests (brittle, low signal)
