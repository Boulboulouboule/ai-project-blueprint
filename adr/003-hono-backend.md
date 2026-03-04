# ADR-003: Hono Backend API

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a backend framework for our API server that is lightweight, type-safe, and follows Web Standards. It should support OpenAPI generation, middleware composition, and provide a type-safe RPC client for the frontend.

## Decision

Use **Hono** as the backend API framework running on Node.js.

```
apps/api/
├── src/
│   ├── app.ts              # Hono app factory + global middleware
│   ├── index.ts            # Node.js entry (serve)
│   ├── middleware/          # Shared middleware
│   └── features/           # Feature modules (route + handler + test)
│       └── health/
│           ├── health.route.ts
│           └── health.test.ts
```

Key patterns:
- Feature-based routing with `app.route('/prefix', featureApp)`
- Hono RPC client (`hc<AppType>`) for type-safe API calls from the frontend
- Zod validation via `@hono/zod-validator` middleware
- OpenAPI spec generation via `@hono/zod-openapi`

## Consequences

### Positive
- Web Standards API (Request/Response) — same mental model as TanStack Start server functions
- Type-safe RPC client (`hc`) gives end-to-end type safety without tRPC
- ~14KB bundle — extremely lightweight
- Runs on Node, Bun, Deno, Cloudflare Workers — maximum deployment flexibility
- First-class Zod integration for validation and OpenAPI generation
- Middleware composition is clean and composable

### Negative
- Younger ecosystem than Express/Fastify — fewer middleware packages
- Some Node.js-specific packages may need adapters for Web Standards API
- Team needs to learn Hono's middleware and routing patterns

### Risks
- Fewer battle-tested production deployments compared to Express/Fastify (mitigated by growing adoption and Cloudflare backing)

## Alternatives Considered

### Fastify
- **Pros**: Mature, fast, large plugin ecosystem, schema-based validation
- **Cons**: ~200KB, Node-specific, no native type-safe client, no Web Standards
- **Why rejected**: Heavier footprint, tied to Node.js, doesn't provide type-safe RPC client. Web Standards alignment with TanStack Start is more valuable.

### Express
- **Pros**: Most popular, largest ecosystem
- **Cons**: Callback-based, slow, no built-in type safety, aging architecture
- **Why rejected**: Legacy patterns, no type safety story, significantly slower than alternatives.

### tRPC + any HTTP server
- **Pros**: Strong type safety, popular in T3 stack
- **Cons**: Adds a layer of abstraction, not REST-friendly, harder to use with non-TS clients
- **Why rejected**: Hono's RPC client provides similar type safety while producing standard REST/OpenAPI endpoints.

## References

- [Hono docs](https://hono.dev)
- [Hono RPC client](https://hono.dev/docs/guides/rpc)
- [@hono/zod-openapi](https://github.com/honojs/middleware/tree/main/packages/zod-openapi)
