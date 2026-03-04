---
description: Review code for security, quality, and convention compliance
---

# Code Review

## Instructions

Perform a thorough code review of the staged/changed files. Check each category below and produce a severity-rated report.

### Step 1: Identify Changed Files
Run `git diff --name-only HEAD` (or `git diff --staged --name-only` if there are staged changes) to find files to review. If no git changes, review the files in the current working directory.

### Step 2: Review Categories

#### 🔴 Critical (must fix before commit)

**Security**
- [ ] No hardcoded secrets, API keys, or passwords
- [ ] No `.env` files staged for commit
- [ ] No SQL injection (raw queries without parameterization)
- [ ] No XSS vectors (unescaped user input in HTML/JSX)
- [ ] No command injection (user input in shell commands)
- [ ] No CORS misconfiguration (wildcard `*` in production)

**Type Safety**
- [ ] No `any` types (use `unknown` and narrow)
- [ ] No `@ts-ignore` or `@ts-expect-error` without justification
- [ ] No type assertions (`as`) that could mask bugs

#### 🟡 Warning (should fix)

**Code Quality**
- [ ] Functions under 30 lines
- [ ] No duplicated logic (DRY — but don't over-abstract)
- [ ] No console.log/debug statements left in production code
- [ ] Error handling: no empty catch blocks, errors are typed
- [ ] No unused imports, variables, or dead code

**Conventions**
- [ ] File naming follows `{name}.{type}.ts` pattern
- [ ] Schema-first: types derived from Zod schemas, not manually defined
- [ ] Import boundaries respected (packages don't import from apps)
- [ ] Tests colocated with source files

**Testing**
- [ ] New code has corresponding tests
- [ ] Tests cover happy path + error cases
- [ ] No hardcoded test data that could break (use factories/fixtures)

#### 🔵 Info (nice to fix)

**Performance**
- [ ] No N+1 query patterns (nested Prisma includes)
- [ ] No unnecessary re-renders (missing deps in useEffect/useMemo)
- [ ] Large arrays use pagination, not load-all

**Accessibility**
- [ ] Interactive elements are keyboard accessible
- [ ] Images have alt text
- [ ] Semantic HTML used appropriately

### Step 3: Generate Report

Format the report as:

```markdown
## Code Review Report

### Summary
{total issues found} issues: {critical} critical, {warnings} warnings, {info} info

### 🔴 Critical
1. **{file}:{line}** — {description}
   Fix: {suggested fix}

### 🟡 Warning
1. **{file}:{line}** — {description}
   Fix: {suggested fix}

### 🔵 Info
1. **{file}:{line}** — {description}
   Fix: {suggested fix}

### ✅ Passed
- {things that look good}
```

### Step 4: Verdict

End with a clear verdict:
- **✅ APPROVE** — No critical issues, safe to commit
- **⚠️ APPROVE WITH WARNINGS** — No critical issues, but warnings should be addressed
- **❌ REQUEST CHANGES** — Critical issues must be fixed before committing
