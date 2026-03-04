# Feature Spec: {FEATURE_NAME}

- **Status**: Draft | In Review | Approved | Implemented
- **Date**: {YYYY-MM-DD}
- **Author**: {name}
- **Related ADRs**: (optional)

## Summary

One paragraph describing the feature and its value to users.

## User Stories

- As a {role}, I want to {action} so that {benefit}.
- As a {role}, I want to {action} so that {benefit}.

## Data Model

```prisma
model Example {
  id        String   @id @default(cuid())
  // fields
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## API Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/{resource} | List resources | Yes |
| POST | /api/{resource} | Create resource | Yes |
| GET | /api/{resource}/:id | Get resource | Yes |
| PATCH | /api/{resource}/:id | Update resource | Yes |
| DELETE | /api/{resource}/:id | Delete resource | Yes |

## Zod Schemas

```typescript
export const ExampleSchema = z.object({
  // fields
});

export type Example = z.infer<typeof ExampleSchema>;
```

## UI Components

- [ ] List view
- [ ] Detail view
- [ ] Create/Edit form
- [ ] Delete confirmation

## Test Plan

### Unit Tests
- [ ] Schema validation (valid + invalid inputs)
- [ ] Service logic (CRUD operations)

### Integration Tests
- [ ] API endpoint responses (status codes, payloads)
- [ ] Database operations (create, read, update, delete)

### E2E Tests (if applicable)
- [ ] User flow: create → view → edit → delete

## Out of Scope

- Items explicitly not included in this feature

## Open Questions

- Questions that need answers before implementation
