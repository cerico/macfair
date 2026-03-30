# Test Coverage Analysis

Static analysis of test coverage gaps — does not run tests (that's CI's job).

## Step 1: Map Changed Files to Tests

For each changed source file, find its corresponding test file:

```bash
# Get changed source files (exclude test files themselves)
git diff --name-only main...HEAD | grep -E '\.(ts|tsx|js|jsx)$' | grep -v -E '\.(test|spec)\.'
```

For each source file, search for a matching test:
- `src/foo.ts` → `src/foo.test.ts`, `src/__tests__/foo.test.ts`, `tests/foo.test.ts`
- Flag any changed source file with NO corresponding test file.

## Step 2: Analyse Test Quality

Read each changed source file and its test file. Check for:

1. **Untested branches** — count `if`, `else`, `catch`, `case` in source. Check if the test file exercises each path. Flag branches with no corresponding test assertion.
2. **Happy-path-only tests** — test file only tests the success case, ignores error/edge paths.
3. **Assertion quality** — tests that call functions but don't assert on results, or only assert `toHaveBeenCalled` on mocks.
4. **Missing edge cases** — no tests for null/undefined/empty/zero/negative inputs where the source handles them.
5. **Flaky patterns** — `setTimeout`/`sleep` in tests instead of fake timers, tests dependent on execution order.
6. **New code without new tests** — significant new logic added but no test file updated or created.

## Reporting

For each finding, report:
- File path
- What's missing: "no test file", "error path untested", "only happy path tested", etc.
- Priority: HIGH (no tests at all for new logic), MEDIUM (partial coverage), LOW (quality improvement)
