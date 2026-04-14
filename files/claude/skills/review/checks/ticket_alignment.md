# Ticket Alignment

Verify the branch implementation matches the ticket's stated problem, not an adjacent or drifted interpretation.

## Step 1: Identify the Ticket

Extract ticket ID from the branch name:

- `gh-N-*` → GitHub issue: `gh issue view N --json title,body,labels`
- `*min-N-*` or `*MIN-N-*` → Linear ticket: `lc issue get MIN-N --json` (skip if `lc` unavailable)
- Numeric-only or unrecognised → attempt `gh issue view N`

If no ticket source resolves, flag as **degraded confidence** and skip to Step 3 using commit messages only.

## Step 2: Extract Ticket Requirements

From the ticket, extract:

1. **Problem statement** — what is broken or missing from the user's perspective
2. **Acceptance criteria** — explicit conditions for "done" (may be implicit in description)
3. **Scope boundaries** — what is explicitly in/out of scope

If the ticket source is Linear and `lc` is available, also fetch comments:

```bash
lc comment list <TICKET_ID> --json
```

Comments often contain clarifying decisions that narrow or redirect scope.

## Step 3: Map Diff to Ticket

Get the diff:

```bash
git diff $(git merge-base HEAD origin/main)...HEAD --name-only
git diff $(git merge-base HEAD origin/main)...HEAD
```

For each changed file/function, classify:

1. **Direct fix** — change directly addresses the ticket's problem statement
2. **Supporting change** — enables the fix (migrations, types, imports) but doesn't fix the issue alone
3. **Unrelated** — change has no clear connection to the ticket

## Step 4: Alignment Check

### Root cause match

Trace the user scenario from the ticket through the code:

1. What user action or system event triggers the reported problem?
2. Where in the code does that fail?
3. Does the diff modify that specific failure point?
4. If the diff modifies a *different* point, flag the mismatch

### Acceptance criteria coverage

For each acceptance criterion from Step 2:
- Is there a corresponding code change that satisfies it?
- Flag any criteria with no matching change as **uncovered**

### Scope check

- Are there "Unrelated" changes from Step 3 that suggest scope creep?
- Scope creep isn't always wrong but should be flagged

### Ticket-justified changes

Before flagging any code change as a problem in other review checks, cross-reference it against the ticket requirements. If a change is directly required by the ticket (e.g. a UI behaviour change the ticket explicitly asks for), it must not be flagged as an issue. Suppress or override findings from other checks that conflict with ticket requirements.

## Reporting

Rate alignment: **Aligned** / **Partially aligned** / **Misaligned**

For each finding, report:
- Ticket says: [requirement or problem]
- Code does: [what the diff actually implements]
- Verdict: match / partial / mismatch
- Severity: ERROR (wrong fix) or WARNING (drift, may be intentional)
