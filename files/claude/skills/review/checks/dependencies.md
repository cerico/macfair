# Dependency Analysis

Check for dependency issues - vulnerabilities, unused deps, duplicates, licenses.

## Patterns to Find

### Security Vulnerabilities
- Dependencies with known CVEs
- Outdated packages with security patches available
- Packages that are unmaintained/abandoned
- Transitive dependencies with issues

### Unused Dependencies
- Packages in package.json not imported anywhere
- Dev dependencies that should be regular dependencies (or vice versa)
- Duplicate packages at different versions
- Packages imported but never used

### License Compatibility
- GPL dependencies in MIT projects (viral license)
- Missing license declarations
- Commercial/proprietary dependencies
- License changes in updates

### Dependency Hygiene
- Pinned versions that prevent security updates
- Floating versions that cause inconsistent builds
- Missing lockfile
- Lockfile not committed

## Examples

```json
// BAD - vulnerable dependency
{
  "dependencies": {
    "lodash": "4.17.20"  // CVE-2021-23337
  }
}

// GOOD - patched version
{
  "dependencies": {
    "lodash": "4.17.21"
  }
}
```

```json
// BAD - unused dependency
{
  "dependencies": {
    "moment": "^2.29.0"  // never imported in codebase
  }
}
```

```json
// BAD - dev dependency used in production
{
  "devDependencies": {
    "zod": "^3.0.0"  // but imported in src/validators.ts
  }
}

// GOOD - correct category
{
  "dependencies": {
    "zod": "^3.0.0"
  }
}
```

```json
// BAD - incompatible license
{
  "license": "MIT",
  "dependencies": {
    "gpl-library": "^1.0.0"  // GPL contaminates your MIT code
  }
}
```

```json
// BAD - overly permissive version
{
  "dependencies": {
    "react": "*"  // could get any version
  }
}

// BAD - overly strict version
{
  "dependencies": {
    "react": "18.2.0"  // won't get patch updates
  }
}

// GOOD - semver range
{
  "dependencies": {
    "react": "^18.2.0"  // gets patches and minor updates
  }
}
```

## Commands to Run

```bash
# Check for vulnerabilities
npm audit
# or
pnpm audit

# Find unused dependencies
npx depcheck

# Check for outdated packages
npm outdated

# Check licenses
npx license-checker --summary
```
