# Dependency Analysis

Tooling-backed dependency vulnerability and hygiene checks.

## Step 1: Semgrep Supply Chain Scan

Run `mcp__semgrep__semgrep_scan_supply_chain` to detect known vulnerabilities in third-party dependencies via lockfile analysis.

Report each finding with: package name, severity, CVE/advisory ID, and recommended version.

## Step 2: Package Audit

Run the appropriate audit command based on the project's package manager:

```bash
# Detect package manager and run audit
if [[ -f pnpm-lock.yaml ]]; then
  pnpm audit --json | jq '.advisories // .'
elif [[ -f yarn.lock ]]; then
  yarn audit --json | jq '.data // .'
elif [[ -f package-lock.json ]]; then
  npm audit --json | jq '.vulnerabilities // .'
fi
```

Filter to moderate/high/critical severity. Skip low/info unless the count is alarming.

## Step 3: Diff-Scoped Checks

Only for packages added or changed in the current diff:

1. **New dependencies** — check if the package is maintained (last publish date, open issues, weekly downloads). Flag if unmaintained (no release in 2+ years).
2. **Version changes** — check if the change is a major bump. Flag if no migration notes are referenced in the PR.
3. **Category** — verify dev vs production placement. Flag `devDependencies` that are imported in `src/`.

## Step 4: Manual Analysis

Review `package.json` changes in the diff for:

1. **Wildcard versions** — `*` or `>=` ranges that could pull breaking changes
2. **Pinned versions** — exact versions without `^` or `~` that block security patches
3. **Duplicate purpose** — adding a package when an existing dep already does the same thing (e.g., adding `axios` when `fetch` is used everywhere)
4. **Missing lockfile update** — `package.json` changed but lockfile not in the diff

## Reporting

For each finding, report:
- Source: `semgrep-sca`, `audit`, or `manual`
- Package name and version
- Severity: CRITICAL, HIGH, MODERATE, or LOW
- Specific action: upgrade to version X, replace with Y, move to devDependencies, etc.

Group by severity, highest first.
