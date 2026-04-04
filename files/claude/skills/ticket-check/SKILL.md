---
name: ticket-check
description: Grade ticket clarity and whether the branch actually fixes the issue described in the ticket.
user-invocable: true
argument: ticket ID (e.g. MIN-1916). If omitted, extract from branch name.
---

# Ticket Check

Grade a ticket's clarity and whether the current branch's code changes actually fix the described issue.

## Usage

- `/ticket-check` - Auto-detect ticket from branch name
- `/ticket-check MIN-1916` - Specify ticket explicitly

## Step 1: Identify the Ticket

If no ticket ID provided, extract from the current branch name:

```bash
git branch --show-current
```

Parse the ticket ID from common branch patterns:
- `gareth/min-1916-slug` → `MIN-1916`
- `gh-123-slug` → GitHub issue #123
- `fix/PROJ-456-slug` → `PROJ-456`

## Step 2: Fetch the Ticket

Try sources in order until one succeeds:

1. **Linear** — Use `mcp__claude_ai_Linear__get_issue` or `mcp__claude_ai_Linear__list_issues` with the ticket ID
2. **GitHub** — `gh issue view <number>` if the ID is numeric or matches a GH issue
3. **Branch name only** — If neither source has the ticket, use the branch name as the sole signal. Flag this as degraded confidence.

Capture:
- Title
- Description / acceptance criteria
- Priority / severity
- Labels
- Any linked issues or context

## Step 3: Grade Ticket Clarity (A-F, /100)

Evaluate the ticket on these dimensions:

| Dimension | Weight | What to look for |
|-----------|--------|------------------|
| **Problem statement** | 25% | Is the user-facing problem clearly described? Can you understand what's broken without reading the code? |
| **Reproduction path** | 20% | Steps to reproduce, affected users/scenarios, frequency |
| **Acceptance criteria** | 25% | What does "fixed" look like? Are there measurable conditions? |
| **Scope boundaries** | 15% | Is it clear what's in/out of scope? Could two engineers read this and build the same thing? |
| **Context & evidence** | 15% | Links to logs, screenshots, error messages, related tickets |

### Scoring guide

- **A (90-100)**: Could hand to any engineer and they'd build the right thing
- **B (80-89)**: Minor ambiguity but intent is clear
- **C (70-79)**: Key details missing, requires assumptions
- **D (60-69)**: Vague enough that different engineers would build different things
- **F (<60)**: Title-only, no description, or actively misleading

If ticket clarity is C or below, list the specific ambiguities that could lead to a wrong fix.

## Step 4: Understand the Fix

```bash
git diff main...HEAD
git diff --name-only main...HEAD
git log --oneline main...HEAD
```

Read changed files. For each change, understand:
- What code path is being modified
- What trigger/condition activates this code
- What user scenario would exercise this path

## Step 5: Grade Solution Alignment (A-F, /100)

Evaluate whether the code changes fix the problem described in the ticket:

| Dimension | Weight | What to look for |
|-----------|--------|------------------|
| **Root cause match** | 35% | Does the fix address the actual root cause described in the ticket, or a symptom/adjacent issue? Trace the user scenario from the ticket through the code to verify. |
| **Completeness** | 25% | Does the fix cover all scenarios implied by the ticket? Are there code paths where the same bug still exists? (Run a mental sibling audit against the ticket's scope, not just the diff's scope.) |
| **No over-fix** | 15% | Does the fix stay within the ticket's scope, or does it fix things the ticket didn't ask for? (Over-fixing isn't always bad but should be flagged.) |
| **Regression safety** | 15% | Could the fix break existing behaviour? Are there tests? |
| **User experience** | 10% | From the user's perspective, would this fix resolve their reported issue? |

### Scoring guide

- **A (90-100)**: Fix directly addresses root cause, covers all paths, well-tested
- **B (80-89)**: Fixes the issue but minor gaps (e.g. one edge case, missing test)
- **C (70-79)**: Partially fixes the issue — some scenarios still broken
- **D (60-69)**: Fixes a related but different problem than what the ticket describes
- **F (<60)**: Fix doesn't address the ticket at all, or makes it worse

### Root cause tracing

This is the most important part. For each claim in the ticket:

1. Identify the specific user action or system event
2. Trace it through the code to find where it fails
3. Check if the diff modifies that specific failure point
4. If the diff modifies a *different* failure point, flag the mismatch

## Output Format

```
## Ticket Check: [TICKET-ID]

### Ticket
**Title**: [title]
**Source**: Linear / GitHub / branch name only
**Description**: [1-2 sentence summary]

### Ticket Clarity: [A-F] ([score]/100)
[Brief justification per dimension. List ambiguities if C or below.]

### Solution Alignment: [A-F] ([score]/100)

**Root cause trace**:
- Ticket describes: [what the user experiences]
- Expected failure point: [where in the code this would fail]
- Fix modifies: [what the diff actually changes]
- Match: [yes/partial/no] — [explanation]

**Coverage gaps**: [any scenarios from the ticket not addressed by the fix]
**Over-fix**: [any changes beyond ticket scope]
**Regression risk**: [low/medium/high — why]

### Verdict
[1-2 sentences: ship it / needs work / wrong fix]
```
