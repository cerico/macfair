# Complexity Analysis

Tooling-backed complexity detection using Semgrep + manual analysis.

## Step 1: Run Semgrep Rules

For each changed `.ts`, `.tsx`, `.js`, `.jsx` file, run `mcp__semgrep__semgrep_scan_with_custom_rule` with this rule:

```yaml
rules:
  - id: deep-nesting-4
    patterns:
      - pattern: |
          if (...) {
            ...
            if (...) {
              ...
              if (...) {
                ...
                if (...) {
                  ...
                }
              }
            }
          }
    message: "Deeply nested conditionals (4+ levels) — extract early returns or helper functions"
    languages: [typescript, javascript]
    severity: WARNING

  - id: nested-ternary
    pattern: "$A ? $B ? $C : $D : $E"
    message: "Nested ternary — use if/else or extract to a function"
    languages: [typescript, javascript]
    severity: WARNING

  - id: deep-nested-ternary-3
    pattern: "$A ? $B ? $C ? $D : $E : $F : $G"
    message: "Triple-nested ternary — seriously, use if/else"
    languages: [typescript, javascript]
    severity: ERROR

  - id: deep-callback-nesting
    patterns:
      - pattern: |
          $F1(..., function(...) {
            ...
            $F2(..., function(...) {
              ...
              $F3(..., function(...) {
                ...
              })
            })
          })
    message: "Deeply nested callbacks (3+ levels) — use async/await or extract functions"
    languages: [typescript, javascript]
    severity: WARNING

  - id: deep-arrow-nesting
    patterns:
      - pattern: |
          $F1(..., (...) => {
            ...
            $F2(..., (...) => {
              ...
              $F3(..., (...) => {
                ...
              })
            })
          })
    message: "Deeply nested arrow functions (3+ levels) — use async/await or extract functions"
    languages: [typescript, javascript]
    severity: WARNING
```

## Step 2: Manual Analysis

For each function in the diff, assess:

1. **Branch count** — count `if`, `else if`, `else`, `case`, `&&`, `||`, `? :` within the function. Flag if > 10.
2. **Function length** — flag functions longer than 50 lines.
3. **Nesting depth** — if semgrep missed any deep nesting (e.g., mixed if/try/for), flag manually.
4. **Parameter count** — flag functions with > 4 parameters.

## Reporting

For each finding, report:
- File path and line number
- The rule ID or manual check that flagged it
- Severity: ERROR (must fix) or WARNING (should fix)
- Specific refactoring suggestion (early return, extract function, use lookup table, etc.)

Group findings by file. Skip files with zero findings.
