---
name: review
description: Review code changes with configurable depth. Level 1 (quick), 2 (standard), 3 (deep), 4 (experimental).
user-invocable: true
argument: level (1-4, default 2)
---

# Code Review

Review the current branch's changes against main.

## Usage

- `/review` or `/review 2` - Standard review
- `/review 1` - Quick sanity check
- `/review 3` - Deep analysis (core checks)
- `/review 4` - Experimental (Level 3 + advanced checks for evaluation)

## Setup

```bash
# Get the diff
git diff main...HEAD

# Get list of changed files
git diff --name-only main...HEAD
```

---

## Level 1: Quick

Fast sanity check. Only blockers.

- [ ] Types compile (`tsc --noEmit`)
- [ ] No obvious runtime errors
- [ ] No secrets or credentials in diff
- [ ] No console.log/debugger statements left in
- [ ] Imports resolve

Output: "No blockers found" or list of blockers. No grade.

---

## Level 2: Standard

Full review with grade.

### Checklist

**Logic & Correctness**
- [ ] Code does what the PR description says
- [ ] Edge cases handled (null, empty, zero, negative)
- [ ] Error paths handled appropriately

**Types & Safety**
- [ ] No `any` types introduced
- [ ] Null/undefined properly checked
- [ ] Type assertions (`as`) justified

**React Patterns**
- [ ] No useEffect for derived state (use useMemo or compute directly)
- [ ] No useEffect for data fetching (use React Query/tRPC/server components)
- [ ] Dependencies arrays correct
- [ ] No missing keys in lists

**API & Data**
- [ ] API returns only needed fields
- [ ] No N+1 queries visible in diff
- [ ] Mutations invalidate relevant caches

**Security Basics**
- [ ] User input validated/sanitized
- [ ] No SQL/command injection vectors
- [ ] Auth checks present where needed

**Style**
- [ ] Follows existing patterns in codebase
- [ ] No commented-out code
- [ ] Clear naming

### Output Format

```
## Review: [PR/Branch name]

### Summary
[2-3 sentences on what this change does and overall impression]

### Issues
[List any problems found, grouped by severity]

### Suggestions
[Optional improvements, not blockers]

### Grade: [A-F] ([score]/100)
```

---

## Level 3: Deep

Everything in Level 2, plus read and apply each check file in `checks/` directory.

For each check file:
1. Read the file from `~/.claude/skills/review/checks/`
2. Apply its rules to the diff
3. Report findings under a heading matching the check name

### Check files to load

**Core (always applied)**
- `security.md` - Security audit
- `async.md` - Async/await patterns
- `errors.md` - Error handling coverage
- `concurrency.md` - Race conditions
- `idempotency.md` - Idempotent operations
- `timezones.md` - Date/timezone handling
- `memory.md` - Memory leaks

**Shell/Infra (for .sh, .zsh, .yml files)**
- `shell.md` - Shell script quality
- `ansible.md` - Ansible task quality
- `dotfiles.md` - Dotfiles/config management

**React/JS (for .ts, .tsx, .js, .jsx files)**
- `nplus1.md` - Database and API query patterns
- `accessibility.md` - a11y compliance
- `hooks.md` - React Rules of Hooks
- `antipatterns.md` - React antipatterns
- `state.md` - State mutation patterns
- `performance.md` - Performance issues
- `boundaries.md` - Error boundaries and fault tolerance

### Output Format

Same as Level 2, but with additional sections for each check that found issues.

---

## Level 4: Experimental

Everything in Level 3, plus experimental checks being evaluated for promotion to Level 3.

Run periodically to see if any of these should become standard checks.

### Additional check files to load

- `ast.md` - Dead code, complexity, duplicates, dependency graphs
- `advanced-security.md` - Prototype pollution, ReDoS, timing attacks
- `framework.md` - Next.js, tRPC, Prisma, RSC patterns
- `testing.md` - Test coverage gaps and quality
- `documentation.md` - JSDoc, comments, README sync
- `dependencies.md` - Vulnerabilities, unused deps, licenses
- `git.md` - Commit messages, large files, conflict markers

### Output Format

Same as Level 3, but with additional sections for experimental checks. Note which experimental checks found useful issues - candidates for promotion to Level 3.

### Promoting Checks

If an experimental check consistently finds real issues, promote it to Level 3:
1. Move the check file entry from Level 4 list to Level 3 list
2. Update this file
