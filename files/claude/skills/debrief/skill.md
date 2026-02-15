---
name: debrief
description: "Spoken morning briefing: what happened last session, what's planned today."
user_invocable: true
---

# Debrief

Give a spoken summary of previous session work and today's plan.

## Steps

1. Look for context in this order (use the first sources found):
   - `tmp/handoff.md` in the current project
   - Recent auto-memory files in the project's `.claude/projects/` memory directory
   - Recent git log (`git log --since="yesterday" --oneline`)

2. From whatever context you find, compose a brief spoken debrief covering:
   - **Yesterday**: What was worked on, key decisions, anything left unfinished
   - **Today**: What's next, any blockers

3. Keep it conversational and concise — aim for 30-60 seconds of speech. No bullet points, no markdown, just natural sentences.

4. Speak the debrief aloud:
   ```bash
   /usr/local/bin/speak "Your debrief text here"
   ```

5. Also print the debrief text to the terminal for reference.

## Rules

- If no handoff or context is found, say so honestly and summarise from recent git history instead
- Never fabricate session details — only report what you can verify from files or git
- Strip all markdown formatting from the spoken version
- Split into multiple speak calls if over 400 words
