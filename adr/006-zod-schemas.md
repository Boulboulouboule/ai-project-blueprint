# ADR-006: Zod Schemas

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a validation library that serves as a single source of truth for both TypeScript types and runtime validation. Schemas should be shareable between frontend and backend, and integrate with our API framework (Hono) for request validation and OpenAPI generation.

## Decision

Use **Zod** as the schema and validation library, centralized in `packages/shared`.

```
packages/shared/src/
├── index.ts
├── api-response.schema.ts    # Standard API envelope
├── pagination.schema.ts      # Shared pagination params
└── {feature}.schema.ts       # Feature-specific schemas
```

Key patterns:
- Schema-first design: define Zod schema → infer TypeScript type
- `z.infer<typeof Schema>` for type derivation (never duplicate types)
- Shared schemas imported by both `apps/api` and `apps/web`
- Hono's `@hono/zod-validator` uses schemas directly for request validation
- Naming: `{Entity}Schema` for Zod objects, `{Entity}` for inferred types

## Consequences

### Positive
- Single source of truth — schemas define both types and runtime validation
- Eliminates type/validation drift between frontend and backend
- First-class Hono integration via `@hono/zod-validator`
- Generates OpenAPI specs via `@hono/zod-openapi`
- Composable — schemas can extend, pick, omit, merge
- Excellent error messages with `.refine()` and `.transform()`

### Negative
- ~57KB bundle size (acceptable for server, consider tree-shaking for client)
- Learning curve for advanced features (discriminated unions, recursive schemas)
- Verbose for deeply nested schemas

### Risks
- Bundle size on the client if importing large schemas (mitigated by importing only what's needed)

## Alternatives Considered

### Yup
- **Pros**: Mature, popular with Formik
- **Cons**: Weaker TypeScript inference, less composable, fewer features
- **Why rejected**: Zod's TypeScript integration is significantly better.

### ArkType
- **Pros**: Faster, novel syntax
- **Cons**: Smaller community, less ecosystem integration, newer
- **Why rejected**: Ecosystem maturity matters — Zod integrates with Hono, Prisma, React Hook Form, etc.

### io-ts
- **Pros**: Functional programming approach, composable
- **Cons**: Steep learning curve, fp-ts dependency, verbose
- **Why rejected**: Too complex for the team. Zod achieves similar goals with simpler syntax.

### Manual types + class-validator
- **Pros**: Decorator-based, familiar to Java/C# developers
- **Cons**: Requires classes (not plain objects), runtime overhead, separate types from validation
- **Why rejected**: Breaks schema-first design. Types and validation are separate concerns.

## References

- [Zod docs](https://zod.dev)
- [@hono/zod-validator](https://github.com/honojs/middleware/tree/main/packages/zod-validator)
