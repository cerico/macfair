---
name: refactor
description: Review branch changes, grade A-F, and refactor until quality score reaches 90+
---

# Refactor

Review code changes in current branch against main, grade the quality, and iteratively refactor until the code meets a minimum quality threshold of 90/100.

## Instructions

### 1. Get Changed Files

```bash
git diff main --name-only
```

Get the full diff for context:

```bash
git diff main
```

### 2. Run Vitest

Run Vitest in CI mode before grading:

```bash
pnpm vitest run --reporter=verbose
```

If tests fail, factor that into the grade (deduct from Test Coverage score). Don't run Playwright - ask the user to run those manually if needed.

### 3. Review and Grade

Review the code changes for:

- **Correctness**: Does the code do what it's supposed to?
- **TypeScript**: No `any`, proper types, strict mode compliance (see TypeScript Check below)
- **React patterns**: Proper hooks usage, client/server boundaries
- **Code style**: Follows project conventions (no semicolons, proper imports)
- **Error handling**: Appropriate error boundaries and handling
- **Performance**: No obvious N+1 queries, unnecessary re-renders
- **Security**: No vulnerabilities (XSS, injection, etc.)
- **Accessibility**: Proper aria attributes, semantic HTML
- **Test coverage**: New logic/features have tests, edge cases covered (checks tests exist, doesn't run them). See Test Coverage Deep Check below.
- **DRY**: No unnecessary duplication
- **Clarity**: Code is readable and self-documenting

**Also include all checks from `/preflight`** (dead code, git hygiene, env vars, imports, dates, etc.). A score of 90+ means preflight would pass.

Assign a letter grade (A-F) and a score out of 100.

### 4. Branch Logic

#### If score >= 90

1. Output to terminal: "Good enough, let's ship it!"
2. List what could have made the score higher (but don't block on it)
3. Get the current branch name:
   ```bash
   git branch --show-current
   ```
4. Create `tmp/` directory in project root if it doesn't exist
5. Write suggestions to `tmp/{branch-name}.md` with:
   - Final grade and score
   - Summary of what's good
   - List of potential improvements (nice-to-have)

#### If score < 90

1. Identify the issues bringing the score down
2. Refactor the code to fix those issues
3. After refactoring, re-review and grade again
4. Repeat until score >= 90
5. Then follow the >= 90 flow above

## Grading Scale

| Grade | Score Range | Meaning |
|-------|-------------|---------|
| A+ | 97-100 | Exceptional - production ready, exemplary code |
| A | 93-96 | Excellent - minor nitpicks only |
| A- | 90-92 | Very Good - meets quality bar |
| B+ | 87-89 | Good - small issues to address |
| B | 83-86 | Above Average - some improvements needed |
| B- | 80-82 | Satisfactory - multiple issues |
| C+ | 77-79 | Adequate - significant issues |
| C | 73-76 | Acceptable - needs work |
| C- | 70-72 | Below Average - substantial issues |
| D | 60-69 | Poor - major problems |
| F | <60 | Failing - fundamental issues |

## Output Format

### Terminal Output (always)

```
## Code Review: {branch-name}

> **Tests:** Vitest ran in CI mode. Playwright skipped - run manually if needed.

**Grade: {grade}** ({score}/100)

### Summary
{Brief description of what the changes do}

### What's Good
- {positive point 1}
- {positive point 2}

### Issues Found
- {file}:{line} - {issue description}

### Score Breakdown
- Correctness: {x}/15
- TypeScript: {x}/10
- React Patterns: {x}/10
- Code Style: {x}/10
- Error Handling: {x}/10
- Performance: {x}/10
- Security: {x}/10
- Test Coverage: {x}/10
- Accessibility: {x}/5
- DRY: {x}/5
- Clarity: {x}/5

{If score >= 90: "Good enough, let's ship it!"}
{If score < 90: "Refactoring to improve score..."}
```

### Markdown File (tmp/{branch-name}.md)

Only written when score >= 90 (either initially or after refactoring):

```markdown
# Code Review: {branch-name}

**Date:** {date}
**Final Grade:** {grade} ({score}/100)

## Summary
{What the changes accomplish}

## What's Good
{List of positive aspects}

## Potential Improvements
{Things that could have pushed the score higher - nice to have, not blockers}

## Refactoring History (if applicable)
{If refactoring was needed, list what was changed and score progression}
```

## TypeScript Check

Some projects have legacy type errors in unrelated files. To check only changed files:

```bash
# Check if 'types' target is available in make output
make 2>/dev/null | grep -q 'types' && make types || pnpm tsc --noEmit
```

Use `make types` if available (checks changed files only), otherwise fall back to `pnpm tsc --noEmit`.

## Test Coverage Deep Check

Don't just check if new helper functions have tests - trace the code path:

1. **Integration over unit**: If you add a helper function `getX()`, find where it's called (e.g., `calculateY()`) and verify `calculateY()` has tests covering the new logic
2. **Follow the call chain**: New code in `utils/foo.ts` → used by `calculateBar()` → verify `calculateBar.test.ts` covers the new behavior
3. **Test the behavior, not just the function**: A test for `getMonthsInBillingInterval()` returning 3 is good, but a test proving `calculateLettingInvoiceCosts()` actually multiplies by 3 for quarterly is better

Example gap to catch:
- ❌ "Added tests for `getMonthsInBillingInterval()`" (tests the helper)
- ✅ "Added tests for `calculateLettingInvoiceCosts()` with QUARTERLY billing" (tests the integration)

## Edge Case Analysis

Actively question defensive code patterns:

1. **Fallback values**: When you see `x ?? defaultValue` or `x ? fn(x) : fallback`, ask:
   - What happens when the fallback is used?
   - Is the fallback correct for all scenarios?
   - Should this be an error instead of a silent default?

2. **Optional chaining**: When you see `obj?.prop`, trace what happens when `obj` is null:
   - Does downstream code handle the undefined correctly?
   - Are there tests for the null case?

3. **Type narrowing**: When interfaces allow null/undefined, verify the code handles both branches

Example to catch:
```typescript
const months = billing?.interval ? getMonths(billing.interval) : 1
const cost = new Decimal(billing?.rate || 0).mul(months)
```
Ask: "If `billing` is null, we get `0 * 1 = 0`. Is that correct, or should this throw?"

## Notes

- Focus on meaningful improvements, not bikeshedding
- Each refactoring iteration should target the highest-impact issues first
- Don't over-engineer - fix what's wrong, don't add unnecessary complexity
- If stuck in a loop (same issues keep appearing), break out and explain why
- Maximum 5 refactoring iterations to prevent infinite loops
