# Tool Permissions

Cross-repo working document. Updated by commit command, reviewed via `/permissions` skill.
Source of truth for allow/deny rules remains `files/claude/settings.json` in antwerp.

## Allow

Auto-approved tool calls. These are in settings.json and run without prompting.

- `mcp__playwright__browser_*` — browser automation (navigate, click, type, screenshot, etc.)
- `WebFetch(domain:*)` — fetch any web domain
- `WebSearch` — web search
- `Read(*)` — read any file
- `Glob(*)` — find files by pattern
- `Grep(*)` — search file contents
- `Skill(skill:review-pr)` — PR review skill
- `Bash(pnpm *)` — pnpm commands (list, build, dev, test, lint, outdated, why, remove, install, add, prisma)
- `Bash(git *)` — all git commands
- `Bash(gh issue *)` — GitHub issues
- `Bash(gh pr view/list/checks *)` — GitHub PR read operations
- `Bash(gh api --method GET *)` — GitHub API read-only
- `Bash(semgrep *)` — security scanning
- `Bash(nightshift:*)` — nightshift agent commands
- `Bash(/usr/local/bin/speak *)` — TTS voice output

## Deny

Blocked tool calls. Always prompt regardless of allow rules.

- `Bash(git push *)` — pushing code requires explicit approval
- `Bash(gh pr create *)` — PR creation requires explicit approval
- `Read(**/.env*)` — environment files with secrets
- `Read(**/.npmrc)` — npm auth config
- `Read(**/tokens.zsh)` — token files
- `Read(**/keys.zsh)` — key files
- `Read(**/*.pem)` — certificates
- `Read(**/.ssh/*)` — SSH keys

## Supervised

Good tool calls we actively want to approve each time. Conscious decision to keep prompting.


## Undecided

Tool calls that prompted during sessions but haven't been categorised yet.
Populated automatically by the commit command. Review with `/permissions`.

