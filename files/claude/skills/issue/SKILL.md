---
name: issue
description: Create a GitHub issue for the current repo and report the number. Does not create a branch — user runs gbr manually when ready.
user-invocable: true
argument: optional description of the issue
---

# Issue

Create a GitHub issue and report the number. Do NOT create a branch or switch context.

## Instructions

1. If the user provided a description, use it. Otherwise ask what the issue is about.

2. Draft a concise title and body. The body should include:
   - What the problem or feature is
   - Why it matters (if known)
   - Suggested fix or approach (if known)

3. Create the issue:

```bash
gh issue create --title "<title>" --body "<body>"
```

4. Report the issue number and URL. Remind the user they can run `gbr <number>` when ready to start work.

## Rules

- Do NOT create a branch
- Do NOT switch away from the current branch
- Do NOT run `gbr`
- The user decides when and how to start work (branch vs worktree)
