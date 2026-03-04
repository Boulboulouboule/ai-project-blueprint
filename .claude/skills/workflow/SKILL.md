# /workflow

Remind me of the feature implementation workflow before starting new work.

## Feature Implementation Workflow

### 0. Research & Reuse _(mandatory before any new implementation)_

- **GitHub first:** `gh search repos` and `gh search code` for existing implementations
- **Check registries:** npm, PyPI, crates.io — prefer battle-tested libraries
- **Find adaptable implementations:** Look for open-source projects solving 80%+ of the problem
- Prefer adopting/porting a proven approach over writing net-new code

### 1. Plan First

- Use **planner** agent to create implementation plan
- Identify dependencies and risks
- Break down into phases

### 2. TDD Approach

- Use **tdd-guide** agent
- Write tests first (RED) → implement (GREEN) → refactor (IMPROVE)
- Verify 80%+ coverage

### 3. Code Review

- Use **code-reviewer** agent immediately after writing code
- Address CRITICAL and HIGH issues; fix MEDIUM when possible

### 4. Commit & Push

- Follow conventional commits format (`feat:`, `fix:`, `refactor:`, etc.)
- Run `pnpm lint && pnpm typecheck && pnpm test` before committing
