---
description: Generate a feature specification from template
---

# Create Feature Specification: $ARGUMENTS

## Instructions

You are creating a feature specification for **$ARGUMENTS**. Follow these steps:

### Step 1: Read the Template
Read `specs/_template.spec.md` to understand the expected format.

### Step 2: Understand the Context
- Read `AGENTS.md` for project conventions
- Check `adr/` for relevant architectural decisions
- Check existing `specs/` for style reference
- Look at existing code in the codebase to understand current patterns

### Step 3: Generate the Spec

Create the file `specs/$ARGUMENTS.spec.md` with:

1. **Summary**: One paragraph describing the feature and its user value
2. **User Stories**: 3-5 user stories in "As a {role}, I want {action} so that {benefit}" format
3. **Data Model**: Prisma schema for any new/modified models (follow conventions from `prisma.mdc`)
4. **API Endpoints**: Table of endpoints with method, path, description, auth requirement
5. **Zod Schemas**: TypeScript code for request/response schemas (follow `zod-schemas.mdc`)
6. **UI Components**: Checklist of components needed
7. **Test Plan**: Categorized test cases (unit, integration, e2e)
8. **Out of Scope**: Items explicitly excluded
9. **Open Questions**: Anything that needs clarification

### Step 4: Set Metadata
- Status: **Draft**
- Date: today's date
- Author: User (to be updated)

### Step 5: Report
After creating the file, report:
- File path created
- Summary of user stories
- Any open questions that need answers before implementation

## Quality Checklist
- [ ] Every user story is testable
- [ ] Data model follows Prisma conventions (cuid, timestamps, snake_case mapping)
- [ ] API endpoints follow RESTful conventions
- [ ] Zod schemas match the data model
- [ ] Test plan covers happy path + error cases
