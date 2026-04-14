---
name: estimate-all
description: Estimate all active Linear tickets and generate an HTML report comparing current vs recommended story points.
user-invocable: true
argument: none
---

# Estimate All

Fetch all active Linear tickets, estimate each one, and generate an HTML report at `~/work/estimates/index.html`.

## Usage

- `/estimate-all`

## Step 1: Fetch Active Tickets

```bash
lc issue list --exclude-state Done,Canceled,Duplicate --order-by priority --limit 250 --json
```

Parse the JSON output. Each ticket has: `identifier`, `title`, `description`, `estimate`, `state`, `assignee`, `priority`, `comments`, `labels`.

## Step 2: Estimate Each Ticket

For each ticket, assess complexity on four dimensions:

| Factor | What to assess |
|--------|---------------|
| **Scope** | How many files, systems, or layers are touched? |
| **Ambiguity** | Are requirements clear? Could two engineers build the same thing? |
| **Dependencies** | Shared code, APIs, external services, coordination needed? |
| **Risk** | Unknowns, edge cases, things that could go wrong? |

Use comments to inform your assessment. Comments often contain clarifications, scope changes, or technical context.

Map to points using this scale:

| Points | Profile |
|--------|---------|
| **1** | Trivial. Single file, no ambiguity, no risk. |
| **2** | Small. Clear scope, 1-2 files, straightforward. |
| **3** | Moderate. Multiple files, some decisions needed. |
| **5** | Significant. Cross-cutting, design decisions, some unknowns. |
| **8** | Large. High ambiguity, multiple systems, research needed. |

Only use values 1, 2, 3, 5, or 8.

## Step 3: Generate HTML Report

Create `~/work/estimates/index.html` (mkdir -p the directory first).

The HTML page should:
- Be a single self-contained file with inline CSS
- Have a clean, professional look with a table layout
- Show a summary header with: total tickets, estimated count, unestimated count, date generated
- Include a table with columns:
  - **ID** (ticket identifier, linked if possible)
  - **Title**
  - **State** (with color coding: Todo=gray, In Progress=blue, In Review=purple, Backlog=dim, Triage=orange, QA=green, Blocked=red)
  - **Assignee**
  - **Current** (existing estimate from Linear, or "-")
  - **Recommended** (your estimate)
  - **Match** (checkmark if same, warning icon if different, dash if no current estimate)
  - **Reasoning** (one-line summary of why)
- Sort by priority (Critical first, then Urgent, High, Medium, Low, No priority)
- Highlight rows where current and recommended estimates differ
- Include a filter bar to toggle: All / Unestimated only / Mismatched only
- Use a light color scheme

## Step 4: Report Summary

After generating the HTML, output a brief summary:

```
## Estimates Report

Generated: ~/work/estimates/index.html
Tickets: [N] total, [X] estimated, [Y] unestimated, [Z] mismatched

### Mismatches (current != recommended)
- [ID] [title]: current [N] → recommended [M] ([reason])
```

## Rules

- Do NOT update any Linear tickets. This is read-only.
- Do NOT read the codebase. Estimate from ticket content only.
- Only use point values 1, 2, 3, 5, or 8.
- If a ticket has no description and no comments, flag lower confidence in reasoning.
- If a ticket feels larger than 8, note it should be broken down.
