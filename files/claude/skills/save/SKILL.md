---
name: save
description: Save session context and exit. Writes tmp/handoff.md for the next session to pick up automatically.
---

# Save

Save session context and exit cleanly.

## Steps

1. Review the conversation to understand what was worked on, decisions made, and what's next.

2. Write `tmp/handoff.md` (create `tmp/` if needed):

```markdown
# Handoff
**Date**: [today's date]
**Branch**: [current git branch, or "n/a"]
## Summary
[1-2 sentences: what we worked on this session]
## Decisions
- [key decisions made]
## Next
- [what to do next session]
## Blockers
- [any blockers, or "none"]
```

3. If the current directory is a hub, run `/hub next <action>` with the most important next step.

4. Print: `Session saved.`

5. Exit the session by running this Bash command:

```bash
kill -INT $CLAUDE_WRAPPER_PID 2>/dev/null || echo "Type /exit to close."
```

If `CLAUDE_WRAPPER_PID` is not set (session started without the wrapper), the fallback message tells the user to type `/exit`.

## Rules

- Fill in ALL sections from conversation context. Never leave placeholders.
- Keep it concise. The next session needs orientation, not a transcript.
- If there are no blockers, write "none".
- If there's no git branch, write "n/a".
- The kill command MUST be the very last thing executed. Nothing after it.
