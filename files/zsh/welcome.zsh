# Terminal Dashboard
# Displays on new iTerm windows, also available via `dashboard` command
# Sourced last (alphabetically after volz.zsh) so hubs.zsh and nav.zsh are loaded

_dashboard_header() {
  local title="$1"
  local first="${2:-}"
  local hint="${3:-}"
  [[ -z "$first" ]] && echo ""
  if [[ -n "$hint" ]]; then
    printf "\e[1;34m%s\e[0m %s\e[2m➜ %s\e[0m\n" "$title" "" "$hint"
  else
    echo -e "\e[1;34m$title\e[0m"
  fi
}

_dashboard_system() {
  local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}')
  local mem_pct=$(memory_pressure 2>&1 | sed -n 's/.*free percentage: \([0-9]*\)%.*/\1/p')

  local mem_color=$'\e[2m'
  if [[ -n "$mem_pct" && "$mem_pct" =~ ^[0-9]+$ ]]; then
    [[ "$mem_pct" -lt 30 ]] && mem_color=$'\e[31m'
    [[ "$mem_pct" -lt 50 && "$mem_pct" -ge 30 ]] && mem_color=$'\e[33m'
  fi

  _dashboard_header "System" "" "memory_pressure"
  echo -e "${disk} free  ${mem_color}${mem_pct:-?}% mem\e[0m"
}

_dashboard_claudes() {
  local ps_data=$(ps -eo tty=,pid=,%cpu=,%mem=,state=,lstart=,comm= | grep -E "claude$")
  [[ -z "$ps_data" ]] && return

  local active=$(echo "$ps_data" | awk '$1 != "??"')
  local orphans=$(echo "$ps_data" | awk '$1 == "??"')
  local sorted="${active}${orphans:+$'\n'$orphans}"
  [[ -z "$sorted" ]] && return

  _dashboard_header "Claude Sessions" "" "claudes"
  echo "#  PID    TTY    CPU   MEM   STATE   DIR"
  local i=0
  echo "$sorted" | while read tty pid cpu mem state lstart1 lstart2 lstart3 lstart4 lstart5 comm; do
    ((i++))
    local proc_state="$state"
    [[ "$tty" == "??" ]] && proc_state="ORPHAN"
    local cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | grep ^n | cut -c2- | sed "s|^${HOME}|~|")
    [[ -z "$cwd" ]] && cwd="-"
    [[ ${#cwd} -gt 25 ]] && cwd="…${cwd: -24}"
    printf "%d  %-6s %-6s %-5s %-5s %-7s %s\n" "$i" "$pid" "$tty" "$cpu" "${mem}%" "$proc_state" "$cwd"
  done
}

_dashboard_hubs() {
  [[ ! -f "$HUBS_REGISTRY" ]] && return

  local hub_count
  hub_count=$(/opt/homebrew/bin/jq '.hubs | length' "$HUBS_REGISTRY" 2>/dev/null)
  [[ "$hub_count" == "0" || -z "$hub_count" ]] && return

  local data
  data=$(/opt/homebrew/bin/jq -r '.hubs[] | "\(.name)|\(.progress // "")|\(.last_accessed // 0)|\(.next_action // "")|\(.status // "active")"' "$HUBS_REGISTRY" 2>/dev/null)

  local has_active=false
  while IFS='|' read -r name progress last_accessed next_action hub_status; do
    [[ -z "$name" ]] && continue
    [[ "$hub_status" == "archived" ]] && continue
    has_active=true
    break
  done <<< "$data"
  [[ "$has_active" == "false" ]] && return

  _dashboard_header "Hubs" "" "hubs"
  local now index
  now=$(date +%s)
  index=0

  while IFS='|' read -r name progress last_accessed next_action hub_status; do
    [[ -z "$name" ]] && continue
    [[ "$hub_status" == "archived" ]] && continue
    index=$((index + 1))

    local time_ago="never"
    local warn=""

    if [[ "$last_accessed" != "0" && -n "$last_accessed" ]]; then
      local diff=$(( now - last_accessed ))
      local days=$(( diff / 86400 ))
      local hours=$(( diff / 3600 ))

      if [[ $hours -lt 24 ]]; then
        [[ $hours -eq 0 ]] && time_ago="<1h" || time_ago="${hours}h ago"
      elif [[ $days -eq 1 ]]; then
        time_ago="1 day"
      else
        time_ago="${days} days"
      fi

      [[ $days -gt 14 ]] && warn=" ⚠️"
    fi

    local info=""
    [[ -n "$next_action" ]] && info=" → $next_action"

    printf "%d. \e[34m%-12s\e[0m %-10s%s%s\n" "$index" "$name" "$time_ago" "$info" "$warn"
  done <<< "$data"
}

_dashboard_repos() {
  [[ ! -f "$DIR_HISTORY_FILE" ]] && return

  _dashboard_header "Recent Repos" first "dh"
  printf "%60s %7s %7s\n" "" "commits" "changed"

  head -8 "$DIR_HISTORY_FILE" 2>/dev/null | while read -r repo; do
    [[ -z "$repo" ]] && continue
    _format_repo_line "$repo"
  done
}

_is_new_window() {
  local parent_name=$(ps -o comm= -p $PPID 2>/dev/null)
  [[ "$parent_name" == "login" || "$parent_name" == "launchd" ]]
}

dashboard() {
  _dashboard_repos
  _dashboard_hubs
  _dashboard_claudes
  _dashboard_system
  echo ""
}

alias dash=dashboard
alias info=dashboard
alias welcome=dashboard

_tab_git_files() {
  local filter="$1" label="$2"
  local files=$(git status --short 2>/dev/null)
  [[ -n "$filter" ]] && files=$(echo "$files" | grep "$filter")
  [[ -z "$files" ]] && return

  local count=$(echo "$files" | wc -l | tr -d ' ')
  echo -e "\e[33m${count} ${label}\e[0m"
  echo "$files"
}

_tab_uncommitted() { _tab_git_files "" "files uncommitted"; }
_tab_untracked() { _tab_git_files '^??' "untracked"; }

_tab_commits() {
  local default=$(_default_branch 2>/dev/null)
  local ahead=$(git rev-list --count ${default}..HEAD 2>/dev/null)
  [[ "${ahead:-0}" -eq 0 ]] && return

  echo ""
  echo -e "\e[32m${ahead} commits ahead\e[0m"
  commits $ahead
}

_tab_todos() {
  local todo_file=""
  [[ -f "TODO.md" ]] && todo_file="TODO.md"
  [[ -f ".planning/TODO.md" ]] && todo_file=".planning/TODO.md"
  [[ -z "$todo_file" ]] && return

  local todos=$(grep -E '^\s*-\s*\[ \]' "$todo_file" 2>/dev/null | head -3)
  [[ -z "$todos" ]] && return

  echo ""
  echo -e "\e[1;34mTodos\e[0m"
  echo "$todos" | while read line; do
    local item=$(echo "$line" | sed 's/^\s*-\s*\[ \]/•/')
    echo "  $item"
  done
}

tabin() {
  [[ -f .terminal-profile ]] && type cpr &>/dev/null && cpr "$(cat .terminal-profile)"
  _tab_uncommitted
  _tab_commits
  _tab_todos
}

# Auto-run on new iTerm sessions (skip if sourced from git hook)
if [[ -z "$GIT_HOOK" && -n "$ITERM_SESSION_ID" ]]; then
  if _is_new_window; then
    dashboard
  elif [[ -d .git ]]; then
    tabin
  fi
fi
