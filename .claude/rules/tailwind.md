---
paths:
  - "**/*.tsx"
  - "**/*.css"
---

# Tailwind CSS v4 Rules

## Setup

- Plugin: `@tailwindcss/vite` (no PostCSS config needed)
- Entry CSS: `@import "tailwindcss";`
- Design tokens via `@theme` block:

```css
@theme {
  --color-primary: #3b82f6;
  --color-secondary: #64748b;
  --font-sans: "Inter", sans-serif;
  --radius-default: 0.5rem;
}
```

## Class Conventions

- Group logically: layout → spacing → sizing → typography → visual → states
- Responsive: `sm:`, `md:`, `lg:`
- States: `hover:`, `focus:`, `disabled:`
- Use `clsx`/`tailwind-merge` for conditional classes

## Component Extraction

When utility classes exceed ~6-8, extract a component (not a CSS class):

```tsx
export function Badge({ variant, children }: BadgeProps) {
  return (
    <span className={clsx(
      'inline-flex items-center px-2 py-1 text-xs font-medium rounded-full',
      variant === 'success' && 'bg-success/10 text-success',
      variant === 'error' && 'bg-error/10 text-error',
    )}>
      {children}
    </span>
  );
}
```

## Don'ts

- Don't use `@apply` to create utility groups
- Don't create custom CSS that duplicates Tailwind utilities
- Don't hardcode colors — always use theme tokens (`bg-primary`, not `bg-[#3b82f6]`)
