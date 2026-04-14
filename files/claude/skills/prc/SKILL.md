---
name: prc
description: Fetch and address all PR review comments (any reviewer, not just bots) on the current branch's PR.
user-invocable: true
argument: optional PR number (auto-detects from current branch if omitted)
---

# PR Comments

Fetch all review comments from the current PR and address them with judgement. Works with any reviewer — humans, CodeRabbit, Greptile, or any other bot.

## Usage

- `/prc` - Fetch comments for current branch's PR
- `/prc 556` - Fetch comments for a specific PR

## Steps

### 1. Detect PR

```bash
# If no argument, detect from current branch
gh pr list --head "$(git branch --show-current)" --json number,url -q '.[0]'
```

If no PR found, tell the user and stop.

### 2. Fetch all comments

```bash
REPO="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"
PR_NUMBER="${1:-$(gh pr list --head "$(git branch --show-current)" --json number -q '.[0].number')}"
PR_AUTHOR="$(gh pr view "$PR_NUMBER" --json author -q '.author.login')"

# Inline comments (most actionable) — exclude PR author's own comments
gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" --paginate \
  | jq -s --arg author "$PR_AUTHOR" '[.[][] | select(.user.login != $author) | {id, path, line, body, html_url, user: .user.login}]'

# Review summaries — exclude PR author
gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews" --paginate \
  | jq -s --arg author "$PR_AUTHOR" '[.[][] | select(.user.login != $author) | {id, state, body, user: .user.login}]'
```

### 3. Grade and present findings

For each comment, read the actual code and CLAUDE.md conventions, then assign your own grade A-F with a score out of 100. Do NOT parrot any reviewer's severity markers — apply independent judgement.

**Resolved comments:** If a comment says "Resolved in `<sha>`", check if the fix is already on the current branch. The SHA may differ after a rebase — search by commit message instead:

```bash
git log --oneline --grep="<first line of resolved commit message>"
```

If a match is found, mark the comment as already resolved (N/A) and skip grading.

**Grading scale:**
- **A (90-100)** — Real bug, security issue, or will break at runtime. Fix this.
- **B (75-89)** — Legitimate improvement, meaningful code quality gain.
- **C (50-74)** — Valid point but low impact. Fix if convenient.
- **D (25-49)** — Overly cautious or stylistic preference that doesn't match project conventions.
- **F (0-24)** — Pedantic, wrong, or conflicts with project patterns. Ignore.

Display each comment in a numbered list with grade, score, and reviewer:

```
1. B 78 [coderabbitai] files/zsh/git.zsh:8 — run_id can be literal "null", guard needed
2. A 92 [teammate] src/api/auth.ts:45 — missing auth check on admin endpoint
3. F 15 [greptile] files/gh-dash/config.yml:81 — suggests removing config (unrelated)
```

If no comments found, say so and stop.

### 4. User decides

Ask the user which comments to address. Accept:
- `all` — address every comment
- `1, 3` — specific numbers
- `skip` — done, don't fix anything
- Or freeform like "fix the first one, ignore the nitpick"

### 5. Apply fixes with judgement

For each selected comment:
1. Read the file and surrounding code
2. Evaluate whether the suggestion is correct and appropriate
3. If valid: apply the fix
4. If disagree: explain why and skip it
5. Show what was changed

Do NOT blindly apply suggestions. Use the project's CLAUDE.md conventions and your own judgement. Reviewers can be wrong, overly pedantic, or suggest changes that conflict with project patterns.

### 6. Summary

After addressing comments, show a summary:
```
Fixed: 1, 2
Skipped: 3 (nitpick, not worth the churn)
```
