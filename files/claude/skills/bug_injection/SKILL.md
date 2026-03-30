---
name: bug-injection
description: Benchmark the /review skill by injecting known bugs and scoring detection rate.
user-invocable: true
argument: optional --report to create a GitHub issue with results
---

# Review Benchmark

Calibrate the `/review` skill by injecting known bugs into throwaway files, running a review, and scoring what gets caught.

## Flow

### Step 1: Create Test Fixtures

Create a temporary directory `tmp/review-benchmark/` with throwaway source files containing deliberate bugs. Each bug has an ID comment (`// BUG-01`, `// BUG-02`, etc.) on the line above it for scoring.

Generate files from the bug catalog below. Each file should be realistic enough that the review has context to work with (imports, types, surrounding logic).

### Step 2: Stage as a Diff

```bash
git checkout -b review-benchmark-tmp
git add tmp/review-benchmark/
git commit -m "tmp: review benchmark fixtures"
```

### Step 3: Run Review

Run `/review 3` and capture the output. The review will analyse the diff containing the injected bugs.

### Step 4: Score

For each bug in the catalog, check whether the review flagged it:
- **Caught** — review identified the issue (even if wording differs)
- **Missed** — review did not mention it
- **Partial** — review flagged the area but misidentified the problem

### Step 5: Report

Format the results:

```
## Review Benchmark Results — [project name] — [date]

Detection rate: X/Y (Z%)

### By Category
| Category        | Caught | Missed | Partial |
|-----------------|--------|--------|---------|
| Logic           | ...    | ...    | ...     |
| Security        | ...    | ...    | ...     |
| Dead code       | ...    | ...    | ...     |
| Complexity      | ...    | ...    | ...     |
| Error handling  | ...    | ...    | ...     |
| Test quality    | ...    | ...    | ...     |

### Missed Bugs
[List each missed bug with its ID, category, and what it was]

### Recommendations
[Which review checks need strengthening based on misses]
```

**Default mode**: print the report to the console.

**`--report` mode**: create a GitHub issue with the results:

```bash
gh issue create \
  --title "Review benchmark: X/Y (Z%) — [date]" \
  --label "review-benchmark" \
  --body "$REPORT"
```

This mode is designed for cron/scheduled runs. The issue serves as a historical record of detection rates over time and surfaces regressions.

### Step 6: Clean Up

```bash
git checkout -
git branch -D review-benchmark-tmp
rm -rf tmp/review-benchmark/
```

## Bug Catalog

### Logic Bugs
- **BUG-01**: Off-by-one in array slice (`arr.slice(0, arr.length - 1)` drops last element)
- **BUG-02**: Inverted boolean condition (`if (!isValid)` where `if (isValid)` was intended)
- **BUG-03**: indexOf truthy check (`if (arr.indexOf(x))` misses index 0)
- **BUG-04**: Assignment in conditional (`if (x = 5)` instead of `===`)
- **BUG-05**: Wrong comparison operator (`>=` instead of `>` for boundary)
- **BUG-06**: Silent promise (async call without await, result discarded)

### Security Bugs
- **BUG-07**: Hardcoded API key in source
- **BUG-08**: User input in RegExp without escaping
- **BUG-09**: String comparison on auth token (timing attack)
- **BUG-10**: Missing auth check on destructive endpoint
- **BUG-11**: XSS via unsanitised innerHTML

### Dead Code
- **BUG-12**: Unreachable code after return
- **BUG-13**: Both if/else branches identical
- **BUG-14**: Unused function exported but never imported

### Complexity
- **BUG-15**: 5-level nested conditionals
- **BUG-16**: Triple-nested ternary
- **BUG-17**: Function with 80+ lines and 12 branches

### Error Handling
- **BUG-18**: Empty catch block swallowing errors
- **BUG-19**: Generic catch that loses error type
- **BUG-20**: Missing error handling on fetch call

### Test Quality
- **BUG-21**: Test with no assertions (just renders component)
- **BUG-22**: Test that only mocks and checks mock was called
- **BUG-23**: setTimeout in test instead of fake timers

Each benchmark run generates all 23 bugs. The detection rate across categories shows exactly where `/review` is blind.
