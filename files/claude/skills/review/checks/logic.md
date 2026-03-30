# Business Logic Correctness

Structured verification that the code does what it claims to do.

## Step 1: Establish Intent

Determine what this change is supposed to do:

1. If the branch matches `gh-N-*`, run `gh issue view N` and read the requirements.
2. Read commit messages: `git log --oneline main...HEAD`
3. If a PR exists, read its description: `gh pr view --json body`

Summarise the stated intent in 1-2 sentences before proceeding.

## Step 2: Semgrep Common Logic Bugs

Run `mcp__semgrep__semgrep_scan_with_custom_rule` on changed files with rules from:

`~/.claude/skills/review/rules/logic.yaml`

These catch mechanical logic errors: off-by-one in array slicing, inverted boolean conditions, assignment in conditionals, and unawaited promises.

## Step 3: Trace Each Code Path

For each function or handler changed in the diff, manually trace through:

1. **Happy path** — does the main flow produce the correct result for the stated intent?
2. **Error paths** — do error conditions return/throw the right thing? Are errors swallowed silently?
3. **Boundary conditions** — what happens at 0, 1, empty, max? Off-by-one in loops, slices, pagination?
4. **State transitions** — if the code changes state (DB, cache, store), is the before/after transition valid? Can you reach an invalid state?
5. **Data flow** — trace variables from input to output. Are transformations correct? Is anything silently dropped or coerced?
6. **Money arithmetic** — if variables suggest monetary values (price, amount, cost, total, fee, balance), check for floating-point arithmetic. Flag and recommend integer cents or a decimal library.

## Step 4: Cross-Reference Intent vs Implementation

Compare the stated intent (Step 1) against what the code actually does (Step 3):

1. **Missing requirements** — does the issue ask for something the code doesn't implement?
2. **Scope creep** — does the code do something the issue didn't ask for?
3. **Subtle mismatches** — issue says "greater than", code uses `>=`. Issue says "all users", code filters by role.

## Reporting

For each finding, report:
- What was expected (from issue/PR/commits)
- What the code actually does
- Severity: ERROR (wrong behaviour) or WARNING (ambiguous, needs clarification)
- Specific line references
