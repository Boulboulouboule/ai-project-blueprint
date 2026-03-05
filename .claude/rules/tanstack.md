---
paths:
  - "apps/web/**"
---

# TanStack Rules

## TanStack Query

- Use `useQuery` for reads, `useMutation` for writes — never `useEffect` for data fetching
- Define query keys as constants: `const userKeys = { all: ['users'], detail: (id: string) => ['users', id] }`
- Invalidate on mutation: `queryClient.invalidateQueries({ queryKey: userKeys.all })`
- Set `staleTime` explicitly — default `0` causes unnecessary refetches

```tsx
const { data, isLoading } = useQuery({
  queryKey: userKeys.detail(id),
  queryFn: () => api.users.get({ param: { id } }),
  staleTime: 30_000,
});
```

## TanStack Router

- File-based routing in `src/routes/`
- Loaders fetch data before render — no loading spinners for initial data
- Search params typed via `validateSearch` with Zod
- Use `Link` for navigation (never `<a>` for internal links)
- Access params via `useParams()`, search via `useSearch()`

```tsx
export const Route = createFileRoute('/users/$id')({
  loader: ({ params }) => queryClient.ensureQueryData(userQuery(params.id)),
  component: UserPage,
});
```

## TanStack Start (SSR)

- Use `createServerFn` for server-only logic (DB access, secrets)
- Server functions are type-safe RPC — no manual fetch calls to internal APIs
- Middleware via `createMiddleware` for auth checks on server functions
