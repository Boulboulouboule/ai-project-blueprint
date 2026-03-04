---
paths:
  - "**/*.tsx"
  - "apps/web/**"
  - "packages/ui/**"
---

# React Rules

## Component Patterns

- One component per file, file name matches component name (PascalCase)
- Use function declarations, not arrow functions, for components
- Props type defined above the component: `type ButtonProps = { ... }`
- Destructure props in the function signature

```tsx
type ButtonProps = {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
};

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button onClick={onClick} className={styles[variant]}>
      {label}
    </button>
  );
}
```

## Hooks

- Custom hooks in a `hooks/` directory or colocated with the feature
- Prefix with `use`: `useAuth`, `useDebounce`
- Keep hooks focused — one responsibility per hook
- Use TanStack Query for server state (never `useEffect` + `useState` for data fetching)

## State Management

- Server state: TanStack Query (`useQuery`, `useMutation`)
- URL state: TanStack Router search params
- Local UI state: `useState` / `useReducer`
- Avoid global state libraries unless proven necessary

## Performance

- Avoid premature `useMemo`/`useCallback` — only optimize measured bottlenecks
- Use `React.lazy()` for route-level code splitting
- Key lists with stable, unique identifiers (never array index)

## TanStack Router

- File-based routing in `src/routes/`
- Loaders fetch data before render — no loading spinners for initial data
- Search params typed via `validateSearch` with Zod
- Use `Link` for navigation (never `<a>` for internal links)
