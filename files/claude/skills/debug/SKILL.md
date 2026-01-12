---
name: debug
description: Trace errors and unexpected behavior to find root causes. Use when something's broken and you don't know why.
---

# Debug

Systematically trace errors, unexpected behavior, or broken functionality to find root causes.

## When to Use

- Error messages you don't understand
- Something that "just stopped working"
- Unexpected behavior (wrong data, missing UI, etc.)
- Build/test failures
- API returning wrong status codes

## Instructions

### 1. Gather Context

Ask for or find:
- **Error message** (exact text, stack trace)
- **What was expected** vs what happened
- **When it started** (after a specific change? randomly?)
- **Reproducibility** (always? sometimes? specific conditions?)

### 2. Check Recent Changes

```bash
git log --oneline -10
git diff HEAD~3 --name-only
```

Did something change recently that could cause this?

### 3. Trace the Error

Follow the stack trace or data flow:

```
Error location → Called by → Called by → Entry point
```

For each step:
1. Read the relevant code
2. Identify what inputs it receives
3. Check what could make it fail

### 4. Common Culprits

#### Runtime Errors
- [ ] Null/undefined access (`Cannot read property 'x' of undefined`)
- [ ] Type mismatches (expected string, got object)
- [ ] Missing environment variables
- [ ] Import/export mismatches

#### React Errors
- [ ] Hydration mismatch (server vs client render different)
- [ ] Hook rules violation (conditional hooks, wrong order)
- [ ] Missing key prop in lists
- [ ] State update on unmounted component

#### API Errors
- [ ] Wrong HTTP method
- [ ] Missing/malformed request body
- [ ] Auth token expired/missing
- [ ] CORS issues
- [ ] Database connection failed

#### Build Errors
- [ ] TypeScript type errors
- [ ] Missing dependencies
- [ ] Circular imports
- [ ] Invalid config (next.config, tsconfig, etc.)

#### Data Errors
- [ ] Schema mismatch (DB vs code)
- [ ] Timezone issues (UTC vs local)
- [ ] Encoding issues (UTF-8, JSON parsing)
- [ ] Stale cache

### 5. Isolate the Problem

Narrow down:
1. Does it fail in all environments or just one?
2. Does it fail for all users/data or specific cases?
3. Can you reproduce with minimal code?

### 6. Verify the Fix

After fixing:
1. Confirm the original error is gone
2. Check for regressions (did fixing this break something else?)
3. Add a test if appropriate to prevent recurrence

## Output Format

```markdown
## Debug Report

**Symptom:** {what the user reported}

**Root Cause:** {what's actually wrong}

**Trace:**
1. {entry point} - {what happens here}
2. {next function} - {what happens here}
3. {failure point} - {why it fails}

**Fix:**
{file}:{line} - {what to change}

**Verification:**
- [ ] Error no longer occurs
- [ ] Related functionality still works

**Prevention:**
{Optional: test to add, validation to include, etc.}
```

## Debugging Strategies

### Binary Search
If you don't know where the bug is:
1. Find a known-good state (commit, branch, or code path)
2. Find the bad state
3. Check halfway between
4. Repeat until you find the breaking change

### Rubber Duck
Explain the problem out loud (or to Claude):
- What should happen?
- What actually happens?
- What have you tried?

Often the act of explaining reveals the issue.

### Add Logging
Temporarily add console.log at key points:
```typescript
console.log('Function called with:', input)
console.log('After transform:', result)
console.log('Returning:', output)
```

Remove after debugging.

### Check Assumptions
The bug is often in something you "know" is correct:
- That env var is set... is it?
- That function returns a string... does it?
- That data exists... does it?

## Notes

- Start with the error message - it usually points close to the problem
- Don't guess - trace the actual code path
- If stuck after 15 minutes, step back and question assumptions
- Some bugs are environment-specific - check dev vs prod differences
