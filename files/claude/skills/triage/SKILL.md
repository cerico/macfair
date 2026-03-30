---
name: triage
description: Pull unassigned or backlog Linear issues, grade by urgency, and suggest what to work on next.
user-invocable: true
argument: optional --team TEAM to filter by team key
---

# Triage

Process your Linear inbox. Pull issues, grade them, recommend what to work on next.

## Step 1: Detect Team

```bash
# Check for .linear file in repo root, or use --team flag
if [[ -f .linear ]]; then
  TEAM=$(< .linear)
elif [[ "$1" == "--team" && -n "$2" ]]; then
  TEAM="$2"
fi
```

If no team is found, list available teams and ask:

```bash
lc team list --json | jq -r '.[].key'
```

## Step 2: Pull Issues

Run three queries in parallel:

```bash
# Unassigned issues (no owner)
lc issue list --team "$TEAM" --state "Triage,Backlog" --json --limit 50

# Your assigned issues not started
lc issue mine --json

# Issues due soon
lc issue list --team "$TEAM" --due-date-before "$(date -v+7d +%Y-%m-%d)" --json --limit 20
```

## Step 3: Grade Each Issue

For each issue, assign an urgency grade:

| Grade | Criteria |
|-------|----------|
| **P0** | Blocking other work, has a due date within 48h, or explicitly marked urgent/critical |
| **P1** | Due this week, or a dependency for upcoming work |
| **P2** | Important but no time pressure |
| **P3** | Nice to have, backlog material |

Use these signals to grade:
- **Priority field** from Linear (urgent, high, medium, low, none)
- **Due date** proximity
- **Labels** (bug > feature > improvement > chore)
- **Age** — old unassigned issues are either important (everyone avoids them) or stale (should be closed)
- **Relation to current branch** — if the issue relates to what you're working on, bump it up

## Step 4: Present

Format as a table sorted by grade:

```
## Triage: [TEAM] — [date]

| Grade | ID | Title | State | Priority | Due | Age |
|-------|----|-------|-------|----------|-----|-----|
| P0 | ... | ... | ... | ... | ... | ... |

### Recommended next
[Pick the top 1-2 issues with reasoning]

### Stale (consider closing)
[Issues older than 90 days with no activity]
```

## Step 5: Act

Ask the user what they want to do:

1. **Work on an issue** — create a branch with `gbr` and start
2. **Assign an issue** — `lc issue update [ID] --assignee [name]`
3. **Close stale issues** — `lc issue update [ID] --state "Canceled"`
4. **Skip** — just wanted the overview
