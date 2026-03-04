---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Strict Mode

- `strict: true` is non-negotiable — never use `// @ts-ignore` without a comment explaining why
- Never use `any` — use `unknown` and narrow, or define a proper type
- Enable `noUncheckedIndexedAccess` for safer array/object access

## Naming

- Files: `kebab-case.ts` or `{name}.{type}.ts` (e.g., `users.route.ts`)
- Types/Interfaces: PascalCase
- Functions/Variables: camelCase
- Constants: UPPER_SNAKE_CASE only for true globals (`MAX_RETRIES`)
- Enums: Avoid — use `as const` objects or union types

## Type Patterns

- Prefer `type` over `interface` unless you need declaration merging
- Derive types from Zod schemas: `type User = z.infer<typeof UserSchema>`
- Use `satisfies` for type-safe object literals: `const config = { ... } satisfies Config`
- Never duplicate types that can be inferred

## Functions

- `function` declarations for top-level functions (hoisting + readable stack traces)
- Arrow functions for callbacks and inline functions
- Keep functions under 30 lines — extract if longer
- Explicitly annotate exported function return types

## Imports

- `import type { User }` for type-only imports
- Barrel exports (`index.ts`) only at package boundaries
- No circular imports — if detected, restructure

## Error Handling

- Typed errors: `class NotFoundError extends Error { constructor(resource: string, id: string) }`
- Never swallow errors with empty catch blocks
- Result pattern for expected failures, throw for unexpected ones
