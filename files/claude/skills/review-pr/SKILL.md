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
- [ ] Existing tests still pass?
- [ ] Edge cases covered?

#### Security
- [ ] No secrets in code
- [ ] User input validated
- [ ] No injection vulnerabilities

#### Performance
- [ ] No N+1 queries
- [ ] No unnecessary data fetching
- [ ] Large lists paginated or virtualized

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
