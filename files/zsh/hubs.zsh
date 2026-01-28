# Learning Hubs - Dashboard and navigation
# Management happens in Claude via /hub skill

HUBS_DIR="$HOME/.claude/hubs"
HUBS_REGISTRY="$HUBS_DIR/registry.json"

# Remove current directory from registry
hub_rm() {
  [[ -f "$HUBS_REGISTRY" ]] || { echo "No registry"; return 1; }

  local current_path="$(pwd)"
  local existing
  existing=$(/opt/homebrew/bin/jq -r --arg p "$current_path" '.hubs[] | select(.path == $p) | .name' "$HUBS_REGISTRY" 2>/dev/null)

  if [[ -z "$existing" ]]; then
    echo "Not registered: $current_path"
    return 1
  fi

  local tmp_file=$(mktemp)
  /opt/homebrew/bin/jq --arg p "$current_path" '.hubs = [.hubs[] | select(.path != $p)]' \
    "$HUBS_REGISTRY" > "$tmp_file" && mv "$tmp_file" "$HUBS_REGISTRY"

  echo "Removed: $existing"
}

# Initialize current directory as a hub
hub() {
  local cmd="$1"

  # Handle subcommands
  [[ "$cmd" == "rm" || "$cmd" == "remove" ]] && { hub_rm; return; }

  [[ -d "$HUBS_DIR" ]] || mkdir -p "$HUBS_DIR"
  [[ -f "$HUBS_REGISTRY" ]] || echo '{"hubs":[]}' > "$HUBS_REGISTRY"

  local current_path="$(pwd)"
  local name="${1:-$(basename "$current_path")}"

  # Check if already registered
  local existing
  existing=$(/opt/homebrew/bin/jq -r --arg p "$current_path" '.hubs[] | select(.path == $p) | .name' "$HUBS_REGISTRY" 2>/dev/null)

  if [[ -n "$existing" ]]; then
    echo "Already registered: $existing"
    return 0
  fi

  # Create CLAUDE.md stub if doesn't exist
  if [[ ! -f "CLAUDE.md" ]]; then
    cat > CLAUDE.md << 'EOF'
# Hub: Fresh

This is a new hub. On first session, Claude should:

1. **Discover** - Look at directory structure, files, context
2. **Identify type** - Learning path? Project? Research? Creative?
3. **Ask questions** - What's the goal? Current state? Target outcome?
4. **Scaffold** - Update registry and this CLAUDE.md with hub-specific instructions

## Discovery Prompts

- What exists here already?
- What does the user want to achieve?
- What's the timeframe?
- How should progress be tracked?

After discovery, replace this file with hub-specific instructions.
EOF
    echo "Created CLAUDE.md stub"
  fi

  # Register in hub registry with type: hub
  local now tmp_file
  now=$(date +%s)
  tmp_file=$(mktemp)
  /opt/homebrew/bin/jq --arg name "$name" --arg path "$current_path" --arg now "$now" \
    '.hubs += [{"name": $name, "path": $path, "type": "hub", "status": "active", "last_accessed": ($now | tonumber), "progress": "", "next_action": "Run discovery", "note": ""}]' \
    "$HUBS_REGISTRY" > "$tmp_file" && mv "$tmp_file" "$HUBS_REGISTRY"

  echo "Registered hub: $name"
  echo "Start Claude session to run discovery"
}

hubs() {
  local c_blue=$'\e[34m'
  local c_yellow=$'\e[33m'
  local c_clear=$'\e[0m'
  local target_num="$1"

  [[ -d "$HUBS_DIR" ]] || mkdir -p "$HUBS_DIR"
  [[ -f "$HUBS_REGISTRY" ]] || { echo '{"hubs":[]}' > "$HUBS_REGISTRY"; return; }

  local hub_count
  hub_count=$(/opt/homebrew/bin/jq '.hubs | length' "$HUBS_REGISTRY" 2>/dev/null) || { echo "Error reading registry"; return 1; }

  if [[ "$hub_count" == "0" || -z "$hub_count" ]]; then
    echo "No hubs"
    return
  fi

  local data
  data=$(/opt/homebrew/bin/jq -r '.hubs[] | select(.type != "gsd") | "\(.name)|\(.progress // "")|\(.last_accessed // 0)|\(.next_action // "")|\(.note // "")|\(.path // "")|\(.status // "active")"' "$HUBS_REGISTRY" 2>/dev/null)

  local now index active_count
  now=$(date +%s)
  index=0
  active_count=0

  local name progress last_accessed next_action note hub_path hub_status

  # First pass: count active hubs and maybe cd if target specified
  if [[ -n "$target_num" && "$target_num" =~ ^[0-9]+$ ]]; then
    while IFS='|' read -r name progress last_accessed next_action note hub_path hub_status; do
      [[ -z "$name" ]] && continue
      [[ "$hub_status" == "archived" ]] && continue
      active_count=$((active_count + 1))
      if [[ "$active_count" == "$target_num" && -n "$hub_path" && -d "$hub_path" ]]; then
        cd "$hub_path" && return
      fi
    done <<< "$data"
  fi

  # List all hubs
  while IFS='|' read -r name progress last_accessed next_action note hub_path hub_status; do
    [[ -z "$name" ]] && continue
    [[ "$hub_status" == "archived" ]] && continue
    index=$((index + 1))

    local time_ago="never"
    local warn=""

    if [[ "$last_accessed" != "0" && -n "$last_accessed" ]]; then
      local diff=$(( now - last_accessed ))
      local days=$(( diff / 86400 ))
      local hours=$(( diff / 3600 ))
      local mins=$(( diff / 60 ))

      if [[ $mins -lt 1 ]]; then
        time_ago="just now"
      elif [[ $mins -lt 60 ]]; then
        [[ $mins -eq 1 ]] && time_ago="1 minute ago" || time_ago="$mins minutes ago"
      elif [[ $hours -lt 24 ]]; then
        [[ $hours -eq 1 ]] && time_ago="1 hour ago" || time_ago="$hours hours ago"
      elif [[ $days -eq 1 ]]; then
        time_ago="1 day ago"
      else
        time_ago="$days days ago"
      fi

      [[ $days -gt 14 ]] && warn=" ⚠️"
    fi

    local info=""
    [[ -n "$next_action" ]] && info="$next_action"
    [[ -n "$note" ]] && info="${info:+$info  }\"$note\""

    local display_path=""
    [[ -n "$hub_path" ]] && display_path="${hub_path/#$HOME/~}"

    printf "%d. %-13s %s%-12s%s %-24s%s %s%-24s%s %s\n" "$index" "$time_ago" "$c_blue" "$name" "$c_clear" "$info" "$warn" "$c_yellow" "$display_path" "$c_clear" "$progress"
  done <<< "$data"
}
