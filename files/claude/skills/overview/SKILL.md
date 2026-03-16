---
name: overview
description: Probe a codebase by analysing every semantic commit month-by-month. Produces graded summaries, a synopsis, and an honest overall assessment. Designed for brownfield projects.
user-invocable: true
argument: options (optional, e.g. "exclude:dependabot", "include:chore")
---

# Overview

Rapidly build a mental model of an unfamiliar codebase by analysing its commit history. Produces month-by-month graded summaries, a synopsis, and an honest overall assessment.

Best used when taking on a brownfield project — understand what was built, how well it was built, and where the risks are.

## Workflow

### Phase 1: Scope

```bash
git log --oneline --all
```

Determine:
- Date range (first to last commit)
- Total semantic commits (`feat`, `fix`, `refactor`, `perf`, `docs` prefixes)
- By default, exclude `chore` commits (release bumps, dependency updates, config tweaks). Include them if the user passes `include:chore`
- If an author-to-exclude argument was provided, exclude their commits
- Group remaining commits by month, show counts to user

Present the scope summary and ask user to confirm before proceeding.

### Phase 2: Set up output directory

Derive the project name from the git remote (`origin`) or fall back to the current directory name.

```bash
# e.g. git@github.com:user/cool-app.git → cool-app
PROJECT_NAME=$(basename -s .git "$(git remote get-url origin 2>/dev/null)" 2>/dev/null || basename "$PWD")
OUTPUT_DIR="$HOME/overviews/$PROJECT_NAME"
mkdir -p "$OUTPUT_DIR"
```

All output goes to `~/overviews/{project-name}/` — never into the project repo itself.

### Phase 3: Generate monthly documents

For each month with commits, create `~/overviews/{project-name}/YYYY-MM.md`.

Use **parallel subagents** — one per month — to speed this up. Give each subagent the month range and repo path.

#### Subagent prompt template

```
Analyse all semantic commits in YYYY-MM for this repo. For each commit:
1. Read the actual diff (`git show <hash>`) — don't just restate the message
2. Write a 2-4 sentence explanation of what changed and why it matters
3. Grade the commit A-F with a score out of 100

Grading criteria:
- Code quality: clean, well-structured, appropriate abstraction level
- Commit hygiene: right-sized change, clear message, single concern
- Impact: does this move the product forward meaningfully

Be honest — accuracy over flattery.

Write the output to ~/overviews/{project-name}/YYYY-MM.md in this format:

# [Month Name] YYYY

**Theme:** [1-2 sentence summary of the month's focus]

---

### YYYY-MM-DD — commit message
**Hash:** `full-hash`
**Author:** developer name
**Grade:** B+ (82)
**Files changed:** N files (+X, -Y)

[2-4 sentence explanation based on the diff]

---

[repeat for each commit]

Include a header with month name, commit count, and a 1-2 line theme summary.
Exclude chore commits unless user opted in with include:chore.
```

### Phase 4: Developer report cards

Create `~/overviews/{project-name}/DEVELOPERS.md`. For each developer who contributed:

- Name and commit count
- Grade (A-F) with score out of 100
- Strengths (with specific commit examples)
- Weaknesses (with specific commit examples)
- Areas of the codebase they own (where most of their commits land)
- Summary: one paragraph characterising their work

Rank developers by volume, then by grade. This is the "who built what and how well" view.

### Phase 5: Synopsis

After all monthly documents are written, create `~/overviews/{project-name}/SYNOPSIS.md`:

- One section per month
- Month name and theme
- Grade (A-F) and score for the month overall
- 3-5 sentence summary of the most important things that happened
- ASCII quality trajectory chart at the bottom showing grade over time

### Phase 6: Overall assessment

Create `~/overviews/{project-name}/OVERALL.md` — a one-page honest assessment:

- What was built (brief)
- What was done well (with specific examples from the commits)
- What could be better (with specific examples)
- The arc of the project (how quality changed over time)
- A single overall grade A-F with score out of 100

Be honest. The point is to understand what you're walking into.

## Key Rules

- Output goes to `~/overviews/{project-name}/` — never into the project repo
- Grading must be honest — accuracy over flattery
- Read actual diffs, not just commit messages
- `chore` commits excluded by default, included with `include:chore` argument
- Parallel subagents for months with many commits
- Focus on surfacing risks, patterns, and quality trends — this is due diligence
