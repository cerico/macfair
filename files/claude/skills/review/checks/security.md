# Security Analysis

Tooling-backed security analysis using Semgrep default rules, custom rules, and manual review.

## Step 1: Semgrep Default Scan

Run `mcp__semgrep__semgrep_scan` on each changed `.ts`, `.tsx`, `.js`, `.jsx` file.

This runs Semgrep's curated security rules covering OWASP top 10: injection, XSS, SSRF, path traversal, hardcoded secrets, insecure crypto, and more.

Report each finding with: rule ID, severity, file:line, and the message.

## Step 2: Semgrep Custom Rules

Run `mcp__semgrep__semgrep_scan_with_custom_rule` on the same files with supplementary rules from:

`~/.claude/skills/review/rules/security.yaml`

These cover patterns the default Semgrep set may miss: JWT in localStorage, CORS wildcards, unescaped regex input, timing-unsafe secret comparisons, prototype pollution via bracket notation, hardcoded secrets, and dynamic code execution.

## Step 3: Manual Review

For patterns that need contextual understanding:

1. **Auth checks** — mutations/deletes without auth middleware. Look for route handlers that modify data without verifying the user owns the resource.
2. **Data exposure** — API responses returning entire database objects instead of selected fields. Check for password hashes, internal IDs, or PII leaking.
3. **Rate limiting** — auth endpoints (login, register, password reset) without rate limiting.
4. **IDOR** — user-supplied IDs used to fetch/modify resources without ownership checks.
5. **SSRF** — user-supplied URLs passed to fetch/axios/http without allowlist validation.

## Reporting

For each finding, report:
- Source: `semgrep`, `semgrep-custom`, or `manual`
- Severity: ERROR (must fix before merge) or WARNING (should fix)
- OWASP category where applicable (e.g., A01:2021 Broken Access Control)
- Specific remediation with code example
