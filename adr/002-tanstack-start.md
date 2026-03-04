# ADR-002: TanStack Start Frontend

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a React-based frontend framework that provides server-side rendering (SSR), type-safe routing, and Vite-native tooling. The framework should integrate well with our Hono API backend and support modern patterns like server functions for BFF (Backend-for-Frontend) operations.

## Decision

Use **TanStack Start** as the full-stack React framework, leveraging TanStack Router for type-safe routing and TanStack Query for server state management.

```
apps/web/
├── src/
│   ├── routes/          # File-based routing (type-safe)
│   ├── lib/             # Utilities, API client
│   └── styles/          # Tailwind CSS entry
├── app.config.ts        # TanStack Start config
└── vite.config.ts
```

## Consequences

### Positive
- Fully type-safe routing — route params, search params, and loaders are all typed
- Vite-native — fast HMR, optimized builds, consistent with the rest of our stack
- Server functions provide BFF capability without a separate layer
- TanStack Query integration gives mature caching, optimistic updates, and background refetch
- File-based routing reduces boilerplate

### Negative
- Smaller community than Next.js — fewer tutorials, Stack Overflow answers
- Still maturing — some APIs may change between versions
- Team needs to learn TanStack Router conventions (loaders, search params)

### Risks
- Breaking changes in minor versions during RC phase (mitigated by pinning versions)

## Alternatives Considered

### Next.js (App Router)
- **Pros**: Largest community, Vercel ecosystem, mature
- **Cons**: Opinionated about deployment (Vercel-optimized), React Server Components add complexity, not Vite-native
- **Why rejected**: Too tightly coupled to Vercel. RSC model adds cognitive overhead. We prefer Vite-native for consistency.

### Remix
- **Pros**: Web Standards focused, good data loading patterns
- **Cons**: Merging with React Router v7, uncertain direction, less type safety out of the box
- **Why rejected**: Transition period creates stability risk. TanStack Router's type safety is superior.

### Vite + React Router (SPA)
- **Pros**: Simple, well-understood
- **Cons**: No SSR, no type-safe routing, more manual setup
- **Why rejected**: We need SSR for performance and SEO.

## References

- [TanStack Start docs](https://tanstack.com/start)
- [TanStack Router docs](https://tanstack.com/router)
