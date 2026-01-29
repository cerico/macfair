# GSD (Get Shit Done) convenience wrappers
# Usage: gsd <command> [args]

# Reclaim from git-svn plugin
unalias gsd 2>/dev/null
alias projects=gsd

HUBS_DIR="$HOME/.claude/hubs"
HUBS_REGISTRY="$HUBS_DIR/registry.json"

# Register current directory as a GSD project
gsd_register() {
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

  # Register with type: gsd
  local now tmp_file
  now=$(date +%s)
  tmp_file=$(mktemp)
  /opt/homebrew/bin/jq --arg name "$name" --arg path "$current_path" --arg now "$now" \
    '.hubs += [{"name": $name, "path": $path, "type": "gsd", "status": "active", "last_accessed": ($now | tonumber)}]' \
    "$HUBS_REGISTRY" > "$tmp_file" && mv "$tmp_file" "$HUBS_REGISTRY"

  echo "Registered GSD project: $name"
}

# Remove current directory from registry
gsd_rm() {
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

# Show info for current project (GSD or hub)
unalias info 2>/dev/null
info() {
  local c_blue=$'\e[34m'
  local c_green=$'\e[32m'
  local c_yellow=$'\e[33m'
  local c_clear=$'\e[0m'
  local current_path="$(pwd)"
  local found=false

  # Git info first (if in a git repo)
  if [[ -d .git || $(git rev-parse --git-dir 2>/dev/null) ]]; then
    type _tab_uncommitted &>/dev/null && _tab_uncommitted
    type _tab_commits &>/dev/null && _tab_commits
    type _tab_todos &>/dev/null && _tab_todos
  fi

  # Check for GSD project
  local state_file=".planning/STATE.md"
  if [[ -f "$state_file" ]]; then
    local name=$(basename "$current_path")
    local phase=$(grep -m1 "^Phase:" "$state_file" | sed 's/Phase: *//')
    local gsd_status=$(grep -m1 "^Status:" "$state_file" | sed 's/Status: *//')
    local progress=$(grep -m1 "^Progress:" "$state_file" | sed 's/Progress: *//')
    local focus=$(grep -m1 "^\*\*Current focus:\*\*" "$state_file" | sed 's/\*\*Current focus:\*\* *//')
    local last_activity=$(grep -m1 "^Last activity:" "$state_file" | sed 's/Last activity: *//')

    echo ""
    echo "${c_blue}${name}${c_clear} (GSD)"
    [[ -n "$focus" ]] && echo "Focus: ${c_green}${focus}${c_clear}"
    [[ -n "$phase" ]] && echo "Phase: $phase"
    [[ -n "$gsd_status" ]] && echo "Status: $gsd_status"
    [[ -n "$progress" ]] && echo "$progress"
    [[ -n "$last_activity" ]] && echo "${c_yellow}Last: ${last_activity}${c_clear}"
    found=true
  fi

  # Check for hub (if not already GSD)
  if [[ "$found" == "false" && -f "$HUBS_REGISTRY" ]]; then
    local hub_data=$(/opt/homebrew/bin/jq -r --arg p "$current_path" '.hubs[] | select(.path == $p and .type != "gsd") | "\(.name)|\(.progress // "")|\(.next_action // "")|\(.note // "")"' "$HUBS_REGISTRY" 2>/dev/null)

    if [[ -n "$hub_data" ]]; then
      local name progress next_action note
      IFS='|' read -r name progress next_action note <<< "$hub_data"

      echo ""
      echo "${c_blue}${name}${c_clear} (Hub)"
      [[ -n "$next_action" ]] && echo "Next: ${c_green}${next_action}${c_clear}"
      [[ -n "$progress" ]] && echo "Progress: $progress"
      [[ -n "$note" ]] && echo "Note: ${c_yellow}${note}${c_clear}"
      found=true
    fi
  fi

  [[ "$found" == "false" ]] && echo -e "\nNot a registered project"
}

# List all GSD projects with live state from STATE.md
gsds() {
  local c_blue=$'\e[34m'
  local c_yellow=$'\e[33m'
  local c_clear=$'\e[0m'
  local target_num="$1"

  [[ -f "$HUBS_REGISTRY" ]] || { echo "No hubs registry"; return 1; }

  local hub_data index=0 found_any=false now
  hub_data=$(/opt/homebrew/bin/jq -r '.hubs | map(select(.status != "archived")) | sort_by(-.last_accessed) | .[] | "\(.name)|\(.path)|\(.last_accessed // 0)|\(.type // "")"' "$HUBS_REGISTRY" 2>/dev/null)
  now=$(date +%s)

  [[ -z "$hub_data" ]] && { echo "No projects"; return; }

  local name hub_path last_accessed hub_type state_file phase_line progress_line status_line pct time_ago display_path elapsed days hours mins

  while IFS='|' read -r name hub_path last_accessed hub_type; do
    [[ -z "$name" ]] && continue

    state_file="$hub_path/.planning/STATE.md"
    # Show if type=gsd OR (no type and has STATE.md)
    [[ "$hub_type" == "gsd" ]] || [[ -f "$state_file" ]] || continue

    found_any=true
    index=$((index + 1))

    # If target specified, cd to it
    if [[ -n "$target_num" && "$target_num" =~ ^[0-9]+$ && "$index" == "$target_num" ]]; then
      cd "$hub_path" && return
    fi

    # Parse STATE.md for live state (if exists)
    if [[ -f "$state_file" ]]; then
      phase_line=$(grep -m1 "^Phase:" "$state_file" 2>/dev/null | sed 's/Phase: *//')
      progress_line=$(grep -m1 "^Progress:" "$state_file" 2>/dev/null | sed 's/Progress: *//')
      status_line=$(grep -m1 "^Status:" "$state_file" 2>/dev/null | sed 's/Status: *//')
      pct=$(echo "$progress_line" | grep -oE '[0-9]+%' | head -1)
    else
      phase_line="(not initialized)"
      status_line=""
      pct=""
    fi

    # Time ago
    time_ago="never"
    if [[ "$last_accessed" != "0" && -n "$last_accessed" ]]; then
      elapsed=$(( now - last_accessed ))
      days=$(( elapsed / 86400 ))
      hours=$(( elapsed / 3600 ))
      mins=$(( elapsed / 60 ))

      if [[ $mins -lt 1 ]]; then
        time_ago="just now"
      elif [[ $mins -lt 60 ]]; then
        [[ $mins -eq 1 ]] && time_ago="1 min ago" || time_ago="${mins}m ago"
      elif [[ $hours -lt 24 ]]; then
        [[ $hours -eq 1 ]] && time_ago="1 hr ago" || time_ago="${hours}h ago"
      elif [[ $days -eq 1 ]]; then
        time_ago="1 day ago"
      else
        time_ago="${days}d ago"
      fi
    fi

    display_path="${hub_path/#$HOME/~}"

    printf "%d. %-10s %s%-14s%s %-34s %-6s %-16s %s%s%s\n" \
      "$index" \
      "$time_ago" \
      "$c_blue" "$name" "$c_clear" \
      "$phase_line" \
      "$pct" \
      "$status_line" \
      "$c_yellow" "$display_path" "$c_clear"

  done <<< "$hub_data"

  $found_any || echo "No GSD projects found (no hubs with .planning/STATE.md)"
}

gsd() {
  local cmd="$1"
  [[ -n "$cmd" ]] && shift

  # Number argument = cd to that project
  [[ "$cmd" =~ ^[0-9]+$ ]] && { gsds "$cmd"; return; }

  case "$cmd" in
    help|--help|-h|"")
      gsds
      echo ""
      cat <<'EOF'
Commands:
  info            Show info for current project (or just run 'info')
  register [name] Register current dir as GSD project
  rm              Remove current dir from registry
  new             Start new project (/gsd:new-project)
  milestone [n]   Start new milestone (/gsd:new-milestone [name])
  map [area]      Map existing codebase (/gsd:map-codebase [area])
  discuss [N]     Discuss a phase (/gsd:discuss-phase N)
  plan [N]        Plan a phase (/gsd:plan-phase N)
  exec [N]        Execute a phase (/gsd:execute-phase N)
  verify [N]      Verify work (/gsd:verify-work N)
  resume          Resume work (/gsd:resume-work)
  pause           Pause work (/gsd:pause-work)
  progress        Check progress (/gsd:progress)
  add [desc]      Add a todo (/gsd:add-todo [desc])
  todos           Check todos (/gsd:check-todos)
  debug [desc]    Debug an issue (/gsd:debug [desc])
EOF
      ;;

    list|ls)
      gsds "$@"
      ;;

    register|reg)
      gsd_register "$@"
      ;;

    rm|remove)
      gsd_rm
      ;;

    info)
      info
      ;;

    new)
      claude "/gsd:new-project"
      ;;

    milestone)
      claude "/gsd:new-milestone $*"
      ;;

    map)
      claude "/gsd:map-codebase $*"
      ;;

    discuss)
      claude "/gsd:discuss-phase $*"
      ;;

    plan)
      claude "/gsd:plan-phase $*"
      ;;

    exec|execute)
      claude "/gsd:execute-phase $*"
      ;;

    verify)
      claude "/gsd:verify-work $*"
      ;;

    resume)
      claude "/gsd:resume-work"
      ;;

    pause)
      claude "/gsd:pause-work"
      ;;

    progress|status)
      claude "/gsd:progress"
      ;;

    add)
      claude "/gsd:add-todo $*"
      ;;

    todos)
      claude "/gsd:check-todos"
      ;;

    debug)
      claude "/gsd:debug $*"
      ;;

    *)
      echo "Unknown command: $cmd"
      echo "Run 'gsd help' for usage."
      return 1
      ;;
  esac
}

# Completion
_gsd() {
  local commands="info register rm new milestone map discuss plan exec verify resume pause progress add todos debug help"
  _arguments "1:command:($commands)"
}
compdef _gsd gsd 2>/dev/null
