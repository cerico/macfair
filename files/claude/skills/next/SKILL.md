---
name: next
description: Suggest what to do next based on current project state. Run when you're done with a task or unsure what skill to use.
---

# Next

Analyze project state and suggest the most appropriate next action.

## When to Use

- Finished a task, wondering what's next
- Not sure which skill to run
- Starting a session and want guidance
- Feel stuck or overwhelmed

## Instructions

### 1. Check Project State

Run these checks to understand current state:

```bash
# Git status
git status --short
git branch --show-current

# Are we ahead/behind main?
git rev-list --left-right --count main...HEAD 2>/dev/null || echo "no main branch"

# Any uncommitted changes?
git diff --stat

# Recent activity
git log --oneline -5
```

### 2. Check for Signals

Look for indicators of what needs attention:

| Signal | Suggests |
|--------|----------|
| Uncommitted changes on feature branch | `/refactor` then commit |
| On main with no changes | Check `TODO.md` or ask what to build |
| PR open for current branch | `/review-pr` for final check |
| `tmp/*.md` files from previous reviews | Review suggestions, decide what to address |
| Build errors in terminal | `/debug` |
| `TODO.md` has unchecked items | `/todo` |
| Package updates available | `/outdated` |

### 3. Check Files

```bash
# TODO.md exists and has items?
[[ -f TODO.md ]] && grep -c "^\- \[ \]" TODO.md

# tmp/ has review files?
ls tmp/*.md 2>/dev/null

# Any error logs?
ls *.log tmp/*.log 2>/dev/null
```

### 4. Decision Tree

```
What's the current state?
│
├── Uncommitted changes on branch?
│   └── Run /refactor → review and improve before committing
│
├── Changes committed but not pushed?
│   └── Run /preflight → catch issues before PR
│
├── Ready to create PR?
│   └── Run /review-pr on your own branch → final sanity check
│
├── PR exists and approved?
│   └── Merge and deploy
│
├── On main, nothing in progress?
│   ├── TODO.md has items? → /todo
│   ├── Want to check dependencies? → /outdated
│   └── Ask user what to build next
│
├── Something broken?
│   └── /debug
│
├── Tests need review?
│   └── /test-review
│
└── Not sure?
    └── /skills to see all options
```

## Output Format

```markdown
## What's Next?

**Current State:**
- Branch: `{branch-name}`
- Status: {clean / uncommitted changes / ahead of main by X commits}
- TODO.md: {X items remaining / not found}

**Recommended Action:**

### /refactor
{Why this is recommended based on current state}

**Other Options:**
- `/preflight` - {when this would be useful}
- `/todo` - {when this would be useful}

**Or tell me what you want to work on.**
```

## Skill Quick Reference

| Skill | Use When |
|-------|----------|
| `/refactor` | Review your branch, improve until 90+ |
| `/review-pr` | Review someone's PR or final-check your own |
| `/preflight` | Quick issue scan before creating PR |
| `/debug` | Something's broken, find the cause |
| `/test-review` | Check test coverage and quality |
| `/todo` | Work through TODO.md tasks |
| `/outdated` | Check for major version upgrades |
| `/scaffold-route` | Create new Next.js feature |
| `/zod-extract` | Centralize inline Zod schemas |
| `/prototype` | Quick React demo |
| `/infopage` | Generate reference HTML page |
| `/creative-design` | Distinctive UI for landing pages |
| `/mcp` | Build MCP server |
| `/skills` | List all available skills |

## Notes

- This skill is for orientation, not automation
- It suggests, you decide
- If none of the suggestions fit, just say what you want to do
- Run `/skills` if you want the full list with descriptions
