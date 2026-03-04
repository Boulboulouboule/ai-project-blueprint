# Feature Specifications

This directory contains feature specifications that describe what to build before implementation begins.

## Why Specs?

Specs serve as the contract between planning and implementation. They ensure:
- All stakeholders agree on scope before coding starts
- AI agents have clear, unambiguous requirements to follow
- Test plans are defined upfront, not as an afterthought
- Data models and API contracts are reviewed before implementation

## Structure

Specs are nested by feature:

```
specs/
├── auth/
│   ├── spec.md              # Auth feature spec
│   └── oauth/
│       └── spec.md          # OAuth sub-feature spec
├── users/
│   └── spec.md              # Users feature spec
└── _template.spec.md        # Template for new specs
```

## Creating a New Spec

Use the `/create-spec` skill:

```
/create-spec user-authentication
```

This generates `specs/user-authentication/spec.md` from the template with AI-assisted content.

## Syncing Specs with Code

Use the `spec-checker` agent to keep specs aligned with the codebase. Specs are living documentation — code is the source of truth.

## Workflow

1. **Draft** — Author creates the spec using `/create-spec`
2. **In Review** — Team reviews and provides feedback
3. **Approved** — Spec is finalized, implementation can begin
4. **Implemented** — Feature is complete and all tests pass

## Tips for Good Specs

- Keep user stories focused and testable
- Define the data model early — it drives everything else
- List API endpoints with expected request/response shapes
- Write the test plan before implementation (TDD mindset)
- Mark items as "Out of Scope" to prevent scope creep
