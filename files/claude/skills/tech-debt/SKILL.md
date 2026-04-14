---
name: tech-debt
description: Capture a pre-existing tech debt finding as a fleeting note in second-brain Inbox.
user-invocable: true
argument: description of the tech debt item (optional — will prompt if omitted)
---

# Tech Debt

Write a fleeting note to `~/second-brain/Inbox/` for a tech debt finding. Used after reviews surface pre-existing issues that don't belong in the current branch.

## Usage

- `/tech-debt date-fns format used instead of formatInTimeZone in MessageItem` — direct capture
- `/tech-debt` — prompt for description

## Steps

1. Determine the source project from the current working directory or git remote name
2. Ensure directory exists: `mkdir -p ~/second-brain/Inbox`
3. Generate filename: `YYYYMMDD-HHMMSS-tech-debt-<slug>.md`
4. Write the note:

```yaml
---
source: <project name>
tags: [tech-debt]
created: YYYY-MM-DDTHH:MM:SS
---
```

4. Body should include:
   - What the issue is
   - Where in the codebase (file path and line if known)
   - Why it matters
   - Keep it atomic — one issue per note

5. Confirm the note was written with the filename

## Integration with /review (Planned)

When `/review` surfaces pre-existing issues, it should offer three actions per issue:
1. **Fix** — address in current branch
2. **Debt** — run `/tech-debt` to capture it
3. **Dismiss** — skip
