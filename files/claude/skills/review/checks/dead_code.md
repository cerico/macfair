# Dead Code Detection

Tooling-backed dead code detection using Semgrep and manual analysis.

## Step 1: Run Semgrep Rules

For each changed `.ts`, `.tsx`, `.js`, `.jsx` file, run `mcp__semgrep__semgrep_scan_with_custom_rule` with this rule:

```yaml
rules:
  - id: unreachable-after-return
    pattern: |
      return ...;
      $STMT;
    message: "Unreachable code after return statement"
    languages: [typescript, javascript]
    severity: WARNING

  - id: unreachable-after-throw
    pattern: |
      throw ...;
      $STMT;
    message: "Unreachable code after throw statement"
    languages: [typescript, javascript]
    severity: WARNING

  - id: unreachable-after-break
    patterns:
      - pattern: |
          break;
          $STMT;
    message: "Unreachable code after break statement"
    languages: [typescript, javascript]
    severity: WARNING

  - id: empty-else-block
    pattern: |
      if (...) {
        ...
      } else {
      }
    message: "Empty else block — remove it"
    languages: [typescript, javascript]
    severity: WARNING

  - id: empty-catch-block
    pattern: |
      try { ... } catch (...) { }
    message: "Empty catch block — at minimum log the error"
    languages: [typescript, javascript]
    severity: WARNING

  - id: duplicate-conditional-branch
    pattern: |
      if (...) {
        $BODY
      } else {
        $BODY
      }
    message: "Both branches are identical — the conditional is dead logic"
    languages: [typescript, javascript]
    severity: WARNING
```

## Step 2: Manual Analysis

Review the diff for patterns tooling misses:

1. **Always-true/false conditions** — `if (true)`, `if (DEBUG)` where DEBUG is hardcoded, `x !== undefined` after non-null assertion
2. **Unused exports** — functions/types exported but not imported anywhere in the changed files' dependents
3. **Commented-out code blocks** — not dead "code" per se but dead weight
4. **Redundant null checks** — checking for null after TypeScript already narrowed the type

## Reporting

For each finding, report:
- File path and line number
- Source: `semgrep` or `manual`
- What's dead and why
- Suggested action: remove, or investigate if unsure about usage elsewhere
