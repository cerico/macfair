---
name: recap
description: Summarise what happened in this session so far. Use when switching between Claude sessions or returning after a break.
user_invocable: true
---

# Recap

Summarise the current session for quick re-orientation.

## Steps

1. Review the conversation history in this session. Identify:
   - What was worked on
   - Key decisions made and why
   - What changed (files edited, commits made)
   - Current state (done, in progress, blocked)
   - What's next

2. Print a concise recap:

```
## Recap

**Branch**: [current branch]
**Working on**: [1 sentence]

### Done
- [completed items]

### Decisions
- [key decisions with reasoning]

### Current state
[where things stand right now]

### Next
- [what to do next]
```

## Rules

- Only report what actually happened in this session, never fabricate
- Keep it scannable. One line per item, no paragraphs
- Skip sections that have nothing to report
- If commits were made, mention them by message
- If a plan exists, mention its status (draft, approved, in progress, done)
- Run `git status` and `git log --oneline -3` to ground the recap in actual state
