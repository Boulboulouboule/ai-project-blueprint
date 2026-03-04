# ADR-005: Tailwind CSS v4

- **Status**: Accepted
- **Date**: 2026-03-03
- **Deciders**: Team

## Context

We need a styling solution that is fast, maintainable, and works well with component-based architecture. The solution should integrate with Vite's build pipeline and support design tokens without additional tooling.

## Decision

Use **Tailwind CSS v4** with the Vite plugin for zero-config integration.

```css
/* app.css — Tailwind v4 entry point */
@import "tailwindcss";

@theme {
  --color-primary: #3b82f6;
  --color-secondary: #64748b;
  --font-sans: "Inter", sans-serif;
  --radius-default: 0.5rem;
}
```

Key patterns:
- CSS-native configuration via `@theme` — no `tailwind.config.js` needed
- Vite plugin (`@tailwindcss/vite`) for automatic content detection
- Design tokens defined as CSS custom properties
- Component styles use utility classes directly in JSX

## Consequences

### Positive
- 5x faster builds compared to Tailwind v3 (Oxide engine, written in Rust)
- CSS-native tokens (`@theme`) eliminate JavaScript config file
- Vite plugin auto-detects content — no manual `content` array
- Design tokens are standard CSS custom properties — accessible everywhere
- Utility-first approach produces small, consistent CSS bundles

### Negative
- Utility class verbosity can make JSX harder to read (mitigated by extracting components)
- Team must learn Tailwind v4's new `@theme` syntax (different from v3's config)
- Some v3 plugins may not yet support v4

### Risks
- Ecosystem plugins lagging behind v4 (mitigated by v4's CSS-native approach reducing need for plugins)

## Alternatives Considered

### CSS Modules
- **Pros**: Scoped by default, standard CSS, no runtime
- **Cons**: More files, harder to maintain consistency, no utility system
- **Why rejected**: Higher maintenance burden, no design system benefits.

### Styled Components / Emotion
- **Pros**: Co-located styles, dynamic styling
- **Cons**: Runtime cost, SSR complexity, larger bundle
- **Why rejected**: Runtime CSS-in-JS adds unnecessary overhead and SSR complexity.

### Tailwind v3
- **Pros**: Mature, battle-tested, huge ecosystem
- **Cons**: Slower builds, requires JS config, manual content configuration
- **Why rejected**: v4 is stable and the performance + DX improvements are significant.

## References

- [Tailwind CSS v4 docs](https://tailwindcss.com/docs)
- [Tailwind Vite plugin](https://tailwindcss.com/docs/installation/vite)
