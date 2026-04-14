---
name: estimate
description: Read a Linear ticket and estimate story points (1, 2, 3, 5, 8) based on scope, ambiguity, dependencies, and risk.
user-invocable: true
argument: ticket ID (e.g. MAC-42). If omitted, extract from branch name.
---

# Estimate

Read a Linear ticket and recommend a story point estimate.

## Usage

- `/estimate` — auto-detect ticket from branch name
- `/estimate MAC-42` — specify ticket explicitly

## Step 1: Identify the Ticket

If no ticket ID provided, extract from the current branch name:

```bash
git branch --show-current
```

Parse the ticket ID from common branch patterns:
- `gh-123-slug` → GitHub issue #123 (look up linked Linear ticket)
- `gareth/mac-42-slug` → `MAC-42`
- `fix/PROJ-456-slug` → `PROJ-456`

## Step 2: Fetch the Ticket

```bash
lc issue get <TICKET-ID> --json
lc comment list <TICKET-ID> --json
```

This returns title, description, estimate, state, assignee, priority, and labels. Comments are fetched separately.

Comments often contain clarifications, scope changes, or technical context that affect complexity. Factor these into your assessment.

If the ticket has no description or is title-only, flag this and estimate based on title alone with lower confidence.

## Step 3: Assess Complexity

Evaluate the ticket on four dimensions:

| Factor | What to assess |
|--------|---------------|
| **Scope** | How many files, systems, or layers are touched? Is it a single change or cross-cutting? |
| **Ambiguity** | Are requirements clear? Could two engineers read this and build the same thing? |
| **Dependencies** | Does this touch shared code, APIs, external services, or require coordination? |
| **Risk** | How likely are unknowns, edge cases, or things that could go wrong? Is there prior art? |

Rate each factor: Low / Medium / High.

## Step 4: Map to Points

Use this scale:

| Points | Profile |
|--------|---------|
| **1** | Trivial. Single file, no ambiguity, no risk. Copy-paste with minor edits. |
| **2** | Small. Clear scope, 1-2 files, straightforward implementation. |
| **3** | Moderate. Multiple files, some decisions needed, manageable risk. |
| **5** | Significant. Cross-cutting changes, design decisions required, some unknowns. |
| **8** | Large. High ambiguity, multiple systems, research needed, significant risk. |

If the ticket feels larger than 8, note that it should be broken down.

## Output Format

```
## Estimate: [TICKET-ID]

**Title**: [title]
**Current estimate**: [existing points if set, or "none"]

| Factor | Rating | Notes |
|--------|--------|-------|
| Scope | Low/Med/High | [brief reason] |
| Ambiguity | Low/Med/High | [brief reason] |
| Dependencies | Low/Med/High | [brief reason] |
| Risk | Low/Med/High | [brief reason] |

**Recommended: [N] points**

[1-2 sentence justification]
```

## Rules

- Do NOT update the Linear ticket. User does this manually.
- Do NOT read the codebase to inform the estimate. This is a ticket-level estimate, not a code review.
- If the ticket lacks a description, say so and flag lower confidence.
- Only use values 1, 2, 3, 5, or 8. No in-between values.
