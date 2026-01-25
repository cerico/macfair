---
name: hub
description: Manage the current directory as a hub. Add, update progress, set next action, archive.
---

# Hub

Manage current directory as a hub. Shell `hubs` shows all; this skill manages one.

## Registry

`~/.claude/hubs/registry.json` - single source of truth:

```json
{
  "hubs": [
    {
      "name": "security",
      "path": "/Users/brew/learning/cyber",
      "status": "active",
      "last_accessed": 1737785000,
      "progress": "24/100",
      "next_action": "Complete CSRF exercise",
      "note": "working through OWASP top 10",
      "current_level": 2,
      "levels_completed": [0, 1]
    },
    {
      "name": "mountain",
      "path": "/Users/brew/projects/mountain",
      "status": "active",
      "last_accessed": 1737780000,
      "progress": "",
      "next_action": "Fix auth bug",
      "note": ""
    }
  ]
}
```

All fields live here. No separate hub.json files. Shell reads this, Claude writes this.

## Commands

### /hub (no args)
Check if current directory is a hub.
- If yes: show status, offer to update
- If no: offer to add it

### /hub add [name]
Add current directory as hub. Name defaults to directory name.

### /hub progress <value>
Set progress (e.g., "30/100", "3/10 chapters", or "" to clear).

### /hub next <action>
Set next action.

### /hub note <text>
Set note.

### /hub done
Update last_accessed to now. Run this after meaningful work, or Claude runs it automatically after commits.

### /hub archive
Set status to "archived". Hidden from shell `hubs` output.

### /hub unarchive
Set status to "active".

### /hub remove
Remove from registry entirely.

## Implementation

Use jq via Bash. Registry path: `~/.claude/hubs/registry.json`

```bash
# Check if current dir is a hub
jq --arg p "$(pwd)" '.hubs[] | select(.path == $p)' ~/.claude/hubs/registry.json

# Add hub
jq --arg name "foo" --arg path "$(pwd)" --arg now "$(date +%s)" \
  '.hubs += [{"name": $name, "path": $path, "status": "active", "last_accessed": ($now | tonumber), "progress": "", "next_action": "", "note": ""}]' \
  ~/.claude/hubs/registry.json > /tmp/reg.json && mv /tmp/reg.json ~/.claude/hubs/registry.json

# Update field
jq --arg p "$(pwd)" --arg val "new value" \
  '(.hubs[] | select(.path == $p) | .next_action) = $val' \
  ~/.claude/hubs/registry.json > /tmp/reg.json && mv /tmp/reg.json ~/.claude/hubs/registry.json

# Update last_accessed
jq --arg p "$(pwd)" --arg now "$(date +%s)" \
  '(.hubs[] | select(.path == $p) | .last_accessed) = ($now | tonumber)' \
  ~/.claude/hubs/registry.json > /tmp/reg.json && mv /tmp/reg.json ~/.claude/hubs/registry.json
```

## Auto-update

After commits in a hub directory, Claude should run `/hub done` to update last_accessed.
