---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
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
- Never use `useEffect` + `useState` for data fetching — use a data-fetching library

## State Management

- Server state: data-fetching library (e.g. TanStack Query)
- URL state: router search params
- Local UI state: `useState` / `useReducer`
- Avoid global state libraries unless proven necessary

## Performance

- Avoid premature `useMemo`/`useCallback` — only optimize measured bottlenecks
- Use `React.lazy()` for route-level code splitting
- Key lists with stable, unique identifiers (never array index)
