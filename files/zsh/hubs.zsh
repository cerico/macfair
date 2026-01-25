# Learning Hubs - Dashboard and navigation
# Management happens in Claude via /hub skill

HUBS_DIR="$HOME/.claude/hubs"
HUBS_REGISTRY="$HUBS_DIR/registry.json"

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
  data=$(/opt/homebrew/bin/jq -r '.hubs[] | [.name, (.progress // ""), (.last_accessed // 0), (.next_action // ""), (.note // ""), (.path // ""), (.status // "active")] | @tsv' "$HUBS_REGISTRY" 2>/dev/null)

  local now index active_count
  now=$(date +%s)
  index=0
  active_count=0

  local name progress last_accessed next_action note hub_path hub_status

  # First pass: count active hubs and maybe cd if target specified
  if [[ -n "$target_num" && "$target_num" =~ ^[0-9]+$ ]]; then
    while IFS=$'\t' read -r name progress last_accessed next_action note hub_path hub_status; do
      [[ -z "$name" ]] && continue
      [[ "$hub_status" == "archived" ]] && continue
      active_count=$((active_count + 1))
      if [[ "$active_count" == "$target_num" && -n "$hub_path" && -d "$hub_path" ]]; then
        cd "$hub_path" && return
      fi
    done <<< "$data"
  fi

  # List all hubs
  while IFS=$'\t' read -r name progress last_accessed next_action note hub_path hub_status; do
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
    [[ -n "$progress" ]] && info="$progress"
    [[ -n "$next_action" ]] && info="${info:+$info  }$next_action"
    [[ -n "$note" ]] && info="${info:+$info  }\"$note\""

    local display_path=""
    [[ -n "$hub_path" ]] && display_path="${hub_path/#$HOME/~}"

    printf "%d. %-13s %s%-18s%s %s%s %s%s%s\n" "$index" "$time_ago" "$c_blue" "$name" "$c_clear" "$info" "$warn" "$c_yellow" "$display_path" "$c_clear"
  done <<< "$data"
}
