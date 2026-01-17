---
name: review-pr
description: Review a pull request and provide feedback with a grade. Use for reviewing others' code or final check on your own PR.
---

# Review PR

Review a pull request, provide constructive feedback, and assign a grade.

## When to Use

- Reviewing a teammate's PR
- Final sanity check on your own PR before merge
- Learning from others' code

## Instructions

### 1. Get PR Context

If given a PR number:
```bash
gh pr view <number>
gh pr diff <number>
```

If reviewing current branch:
```bash
git log main..HEAD --oneline
git diff main
```

### 2. Understand the Change

Before reviewing code, understand intent:
- What problem does this solve?
- What's the approach?
- Is the scope appropriate?

### 3. Review Checklist

#### Correctness
- [ ] Does it do what the PR description says?
- [ ] Edge cases handled?
- [ ] Error cases handled?

#### Code Quality
- [ ] Clear naming (variables, functions, files)
- [ ] No unnecessary complexity
- [ ] DRY - no copy-paste code
- [ ] Single responsibility (functions do one thing)

#### TypeScript
- [ ] No `any` types
- [ ] Proper null handling
- [ ] Types reflect actual data shape

#### React (if applicable)
- [ ] Proper component boundaries
- [ ] Hooks used correctly
- [ ] No unnecessary re-renders
- [ ] Client/server split makes sense

#### Testing
- [ ] Tests added for new functionality?
- [ ] Edge cases covered?

> **Note:** Don't run test suites - CI handles that. Review that tests exist and cover the new logic.

#### Security
- [ ] No secrets in code
- [ ] User input validated
- [ ] No injection vulnerabilities

#### Performance
- [ ] No N+1 queries
- [ ] No unnecessary data fetching
- [ ] Large lists paginated or virtualized

#### Data Flow (cross-file bugs)
- [ ] **Decimal precision**: If a value is formatted (e.g., `toFixed(2)`) for display, is the same rounded value used in calculations that must match? Trace values from DB → API → UI
- [ ] **Type consistency**: Do API endpoints return the same types for the same fields across different code paths? (e.g., string vs Prisma Decimal for `total`)
- [ ] **Sorting/comparison**: Are numeric values stored as strings? If so, do table columns use numeric `sortingFn` instead of default string comparison?

### 4. Provide Feedback

For each issue found:
```
**File:** path/to/file.ts:42
**Severity:** blocker | suggestion | nitpick
**Issue:** {what's wrong}
**Suggestion:** {how to fix}
```

Severity guide:
- **blocker**: Must fix before merge (bugs, security, breaking changes)
- **suggestion**: Should fix, but not blocking (code quality, performance)
- **nitpick**: Optional, stylistic (naming, formatting)

### 5. Assign Grade

| Grade | Meaning | Action |
|-------|---------|--------|
| A (90-100) | Ship it | Approve |
| B (80-89) | Minor issues | Approve with comments |
| C (70-79) | Needs work | Request changes |
| D (60-69) | Significant issues | Request changes |
| F (<60) | Fundamental problems | Request major revision |

## Output Format

```markdown
## PR Review: {PR title or branch name}

**Grade: {letter}** ({score}/100)

### Summary
{One paragraph: what this PR does and overall impression}

### What's Good
- {positive point}
- {positive point}

### Blockers (must fix)
- **file.ts:42** - {issue and suggestion}

### Suggestions (should fix)
- **file.ts:78** - {issue and suggestion}

### Nitpicks (optional)
- **file.ts:15** - {minor observation}

### Verdict
{Approve / Approve with comments / Request changes}

{If approving: "Good to merge after addressing [blockers/suggestions]"}
{If requesting changes: "Please address blockers before re-review"}
```

## Deep Checks (do these for non-trivial PRs)

### Data Flow Tracing

For any PR that touches calculations, API responses, or display formatting:

1. **Find the source**: Where does the value originate? (DB field, calculation, user input)
2. **Trace transformations**: List every place the value is transformed (parsed, formatted, rounded)
3. **Check consumers**: Do all consumers expect the same format/precision?

Example red flags:
```typescript
// API endpoint
monthlyRate: invoice.letting.monthlyRate?.toFixed(2)  // rounded here

// Calculation function
baseCost = new Decimal(letting.monthlyRate).mul(months)  // but raw value used here
```

### Type Boundary Checks

When an endpoint returns data from multiple sources (e.g., different invoice types):

1. **Check each code path**: Does `fieldX` return the same type in all branches?
2. **Check serialization**: Prisma Decimal vs string vs number - what arrives at the client?
3. **Check consumers**: Does the UI handle all possible types?

```typescript
// Red flag: mixed types
return {
  total: isLetting ? calculatedTotal : invoice.total  // string vs Decimal
}
```

### Table Sorting Audit

For any PR adding/modifying table columns with numeric data:

1. **Check accessor**: Is it `accessorKey` (raw value) or `accessorFn` (transformed)?
2. **Check sortingFn**: Missing = string comparison. Numeric columns need:
   ```typescript
   sortingFn: (a, b) => parseFloat(a.getValue('total')) - parseFloat(b.getValue('total'))
   ```

## Good Review Practices

### Be Constructive
- Explain *why* something is an issue, not just that it is
- Offer solutions, not just criticism
- Acknowledge good work

### Be Specific
```
# Bad
"This could be cleaner"

# Good
"Consider extracting lines 45-60 into a `validateInput()` function -
it would make the main function easier to follow and the validation reusable"
```

### Ask Questions
If you don't understand something, ask:
```
"I'm not sure why we need this check on line 34 -
could you add a comment explaining the edge case it handles?"
```

### Separate Style from Substance
Don't block PRs over formatting if you have automated linting.
Focus on logic, architecture, and correctness.

## Notes

- Review the PR, not the person
- Assume good intent - the author tried their best
- If a PR is too large to review well, it's okay to ask for it to be split
- Don't let perfect be the enemy of good - ship improvements
