---
name: permissions
description: Review undecided tool permissions and promote them to Allow or Supervised. Run when prompted by Slack alert or when you want to triage tool permissions.
user_invocable: true
---

# Permissions Review

Review and triage undecided tool call permissions.

## When to Use

- After receiving a Slack alert about undecided permissions
- When you want to review what tools Claude has been prompted for
- Periodically to keep the permissions list tidy

## Instructions

1. Read `~/.claude/permissions.md`
2. Check the **Undecided** section. If empty, say so and exit.
3. For each undecided entry, present it to the user with context:
   - What the tool does
   - Whether it's safe to auto-allow
   - Whether supervision adds value
4. Ask the user for each: **Allow**, **Supervised**, or **Skip** (leave undecided for now)
5. For items marked **Allow**:
   - Move to the Allow section in `~/.claude/permissions.md`
   - Read `~/macfair/files/claude/settings.json`
   - Add the appropriate pattern to `permissions.allow` array
   - Write the updated settings.json
   - Tell the user to run `make claude` to deploy
6. For items marked **Supervised**:
   - Move to the Supervised section in `~/.claude/permissions.md` with a note on why
7. For items marked **Skip**:
   - Leave in Undecided
8. Write the updated `~/.claude/permissions.md`

## Important

- The source of truth for allow rules is `~/macfair/files/claude/settings.json`
- The permissions.md file is a working document, not config
- Never edit deployed files at `~/.claude/settings.json` directly
- Batch the AskUserQuestion calls where possible to reduce interruptions
