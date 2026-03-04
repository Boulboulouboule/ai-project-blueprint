---
description: Generate an Architecture Decision Record
---

# Create ADR: $ARGUMENTS

## Instructions

You are creating an Architecture Decision Record for **$ARGUMENTS**. Follow these steps:

### Step 1: Determine the Next ADR Number
Read the files in `adr/` and find the highest existing ADR number. The new ADR will be the next number (zero-padded to 3 digits).

### Step 2: Read the Template
Read `adr/_template.adr.md` to understand the expected format.

### Step 3: Research Context
- Read `AGENTS.md` and existing ADRs for project context
- Look at relevant code in the codebase
- Consider the current tech stack and conventions

### Step 4: Generate the ADR

Create `adr/{NNN}-{kebab-case-title}.md` with:

1. **Title**: `ADR-{NNN}: {Title}`
2. **Status**: `Proposed`
3. **Date**: Today's date
4. **Deciders**: Team
5. **Context**: The problem or decision we need to make. Include forces at play and constraints.
6. **Decision**: What we're proposing. Be specific — include code examples if helpful.
7. **Consequences**:
   - **Positive**: Benefits of this decision (3-5 items)
   - **Negative**: Drawbacks we accept (2-3 items)
   - **Risks**: What could go wrong and mitigations
8. **Alternatives Considered**: At least 2 alternatives with pros, cons, and rejection reason
9. **References**: Links to relevant docs or resources

### Step 5: Update the ADR README
Add the new ADR to the index table in `adr/README.md`.

### Step 6: Report
After creating the file, report:
- File path created
- One-sentence summary of the decision
- Key tradeoff being made
- Status: Proposed (needs team review)

## Quality Checklist
- [ ] Context explains WHY the decision is needed
- [ ] Decision is specific and actionable
- [ ] At least 2 alternatives with honest pros/cons
- [ ] Consequences include both positive AND negative
- [ ] Risks include mitigations
