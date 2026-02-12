# Learning Hubs - Dashboard and navigation
# Management happens in Claude via /hub skill

HUBS_DIR="$HOME/.claude/hubs"
HUBS_REGISTRY="$HUBS_DIR/registry.json"

hub() {
  local cmd="$1"

  # No args: show usage
  if [[ -z "$cmd" ]]; then
    echo "Usage: hub <command>"
    echo "  hub list         List all hubs"
    echo "  hub create [name] Register current directory as a hub"
    echo "  hub rm           Remove current directory from registry"
    echo "  hub rm <name>    Remove hub by name"
    echo "  hub <number>     Navigate to hub by index"
    echo "  hub <name>       Navigate to hub by name"
    return
  fi

  # Numeric: navigate to hub
  if [[ "$cmd" =~ ^[0-9]+$ ]]; then
    _hub_nav "$cmd"
    return
  fi

  # Subcommands
  case "$cmd" in
    list|ls) hubs ;;
    create) _hub_create "${@:2}" ;;
    rm|remove) _hub_rm "${@:2}" ;;
    *) _hub_nav_name "$cmd" ;;
  esac
}

_hub_nav() {
  local target="$1"
  [[ -f "$HUBS_REGISTRY" ]] || { echo "No registry"; return 1; }

  local data
  data=$(jq -r '.hubs[] | select(.type != "gsd") | select(.status != "archived") | .path' "$HUBS_REGISTRY" 2>/dev/null)

  local index=0
  while IFS= read -r hub_path; do
    [[ -z "$hub_path" ]] && continue
    index=$((index + 1))
    if [[ "$index" -eq "$target" && -d "$hub_path" ]]; then
      cd "$hub_path" && return
    fi
  done <<< "$data"

  echo "No hub at index $target"
  return 1
}

_hub_nav_name() {
  local name="$1"
  [[ -f "$HUBS_REGISTRY" ]] || { echo "No registry"; return 1; }

  local hub_path
  hub_path=$(jq -r --arg n "$name" '.hubs[] | select(.type != "gsd") | select(.status != "archived") | select(.name | ascii_downcase == ($n | ascii_downcase)) | .path' "$HUBS_REGISTRY" 2>/dev/null)

  if [[ -n "$hub_path" && -d "$hub_path" ]]; then
    cd "$hub_path" && return
  fi

  echo "No hub matching: $name"
  return 1
}

_hub_create() {
  [[ -d "$HUBS_DIR" ]] || mkdir -p "$HUBS_DIR"
  [[ -f "$HUBS_REGISTRY" ]] || echo '{"hubs":[]}' > "$HUBS_REGISTRY"

  local current_path="$(pwd)"
  local name="${1:-$(basename "$current_path")}"

  local existing
  existing=$(jq -r --arg p "$current_path" '.hubs[] | select(.path == $p) | .name' "$HUBS_REGISTRY" 2>/dev/null)

  if [[ -n "$existing" ]]; then
    echo "Already registered: $existing"
    return 0
  fi

  local tpl_dir="$HOME/.templates/hub"
  if [[ ! -f "CLAUDE.md" ]]; then
    [[ -f "$tpl_dir/CLAUDE.md" ]] || { echo "Hub templates not found at $tpl_dir. Run: make claude"; return 1; }
    cp "$tpl_dir/CLAUDE.md" CLAUDE.md
    echo "Created CLAUDE.md from template"
  fi

  local now tmp_file
  now=$(date +%s)
  tmp_file=$(mktemp)
  jq --arg name "$name" --arg path "$current_path" --arg now "$now" \
    '.hubs += [{"name": $name, "path": $path, "type": "hub", "status": "active", "last_accessed": ($now | tonumber), "progress": "", "next_action": "Run discovery", "note": ""}]' \
    "$HUBS_REGISTRY" > "$tmp_file"
  [[ -s "$tmp_file" ]] && jq -e . "$tmp_file" >/dev/null 2>&1 \
    && mv "$tmp_file" "$HUBS_REGISTRY" || { rm -f "$tmp_file"; echo "Failed to update registry"; return 1; }

  echo "Registered hub: $name"
  echo "Start Claude session to run discovery"
}

_hub_rm() {
  [[ -f "$HUBS_REGISTRY" ]] || { echo "No registry"; return 1; }

  local name="$1"

  if [[ -n "$name" ]]; then
    # Remove by name
    local found
    found=$(jq -r --arg n "$name" '.hubs[] | select(.name == $n and .type != "gsd") | .name' "$HUBS_REGISTRY" 2>/dev/null)
    if [[ -z "$found" ]]; then
      echo "Not found: $name"
      return 1
    fi
    local tmp_file=$(mktemp)
    jq --arg n "$name" '.hubs = [.hubs[] | select(.name != $n or .type == "gsd")]' \
      "$HUBS_REGISTRY" > "$tmp_file"
    [[ -s "$tmp_file" ]] && jq -e . "$tmp_file" >/dev/null 2>&1 \
      && mv "$tmp_file" "$HUBS_REGISTRY" || { rm -f "$tmp_file"; echo "Failed to update registry"; return 1; }
    echo "Removed: $name"
  else
    # Remove by current path
    local current_path="$(pwd)"
    local existing
    existing=$(jq -r --arg p "$current_path" '.hubs[] | select(.path == $p and .type != "gsd") | .name' "$HUBS_REGISTRY" 2>/dev/null)
    if [[ -z "$existing" ]]; then
      echo "Not registered: $current_path"
      return 1
    fi
    local tmp_file=$(mktemp)
    jq --arg p "$current_path" '.hubs = [.hubs[] | select(.path != $p or .type == "gsd")]' \
      "$HUBS_REGISTRY" > "$tmp_file"
    [[ -s "$tmp_file" ]] && jq -e . "$tmp_file" >/dev/null 2>&1 \
      && mv "$tmp_file" "$HUBS_REGISTRY" || { rm -f "$tmp_file"; echo "Failed to update registry"; return 1; }
    echo "Removed: $existing"
  fi
}

hubs() {
  local c_blue=$'\e[34m'
  local c_yellow=$'\e[33m'
  local c_clear=$'\e[0m'

  [[ -d "$HUBS_DIR" ]] || mkdir -p "$HUBS_DIR"
  [[ -f "$HUBS_REGISTRY" ]] || { echo '{"hubs":[]}' > "$HUBS_REGISTRY"; return; }

  local hub_count
  hub_count=$(jq '.hubs | length' "$HUBS_REGISTRY" 2>/dev/null) || { echo "Error reading registry"; return 1; }

  if [[ "$hub_count" == "0" || -z "$hub_count" ]]; then
    echo "No hubs"
    return
  fi

  local data
  data=$(jq -r '.hubs[] | select(.type != "gsd") | "\(.name)|\(.progress // "")|\(.last_accessed // 0)|\(.next_action // "")|\(.note // "")|\(.path // "")|\(.status // "active")"' "$HUBS_REGISTRY" 2>/dev/null)

  local now index
  now=$(date +%s)
  index=0

  local name progress last_accessed next_action note hub_path hub_status

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

_hub_complete() {
  local -a subcommands
  subcommands=(
    'list:List all hubs'
    'ls:List all hubs'
    'create:Register current directory as a hub'
    'rm:Remove hub from registry'
    'remove:Remove hub from registry'
  )

  if (( CURRENT == 2 )); then
    _describe 'subcommand' subcommands
    local -a hubs
    hubs=(${(f)"$(jq -r '.hubs[] | select(.type != "gsd") | select(.status != "archived") | .name' ~/.claude/hubs/registry.json 2>/dev/null)"})
    [[ ${#hubs} -gt 0 ]] && _describe 'hub' hubs
  elif (( CURRENT == 3 )); then
    case "$words[2]" in
      rm|remove)
        local -a hubs
        hubs=(${(f)"$(jq -r '.hubs[] | select(.type != "gsd") | select(.status != "archived") | .name' ~/.claude/hubs/registry.json 2>/dev/null)"})
        [[ ${#hubs} -gt 0 ]] && _describe 'hub' hubs
        ;;
    esac
  fi
}
compdef _hub_complete hub 2>/dev/null
