# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

## File Organization

- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type

## Error Handling

- Handle errors explicitly at every level
- Provide user-friendly messages in UI-facing code
- Log detailed context on the server side
- Never silently swallow errors

## Input Validation

- Validate all user input before processing
- Use schema-based validation (Zod)
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Code Quality Checklist

- [ ] Functions are small (<50 lines), files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling at every level
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)
