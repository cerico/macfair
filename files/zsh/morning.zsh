# Morning Briefing - aggregated next actions across all projects
# Usage: morning        Show briefing
#        morning <N>    Navigate to project N

HUBS_DIR="$HOME/.claude/hubs"
HUBS_REGISTRY="$HUBS_DIR/registry.json"

_morning_time_ago() {
  local last_accessed="$1" now="$2"
  [[ "$last_accessed" == "0" || -z "$last_accessed" ]] && echo "never" && return

  local elapsed=$(( now - last_accessed ))
  local days=$(( elapsed / 86400 ))
  local hours=$(( elapsed / 3600 ))
  local mins=$(( elapsed / 60 ))

  if [[ $mins -lt 1 ]]; then
    echo "just now"
  elif [[ $mins -lt 60 ]]; then
    echo "${mins}m ago"
  elif [[ $hours -lt 24 ]]; then
    echo "${hours}h ago"
  elif [[ $days -eq 1 ]]; then
    echo "1d ago"
  else
    echo "${days}d ago"
  fi
}

_morning_next_step() {
  local hub_path="$1" hub_type="$2" next_action="$3"

  if [[ "$hub_type" == "gsd" || -f "$hub_path/.planning/STATE.md" ]]; then
    local handoff="$hub_path/tmp/handoff.md"
    if [[ -f "$handoff" ]]; then
      local line
      line=$(sed -n '/^## Next/,/^## /{/^## Next/d;/^## /d;/^$/d;p;}' "$handoff" | head -1)
      [[ -n "$line" ]] && { echo "${line#- }"; return; }
    fi

    local state="$hub_path/.planning/STATE.md"
    if [[ -f "$state" ]]; then
      local status_line
      status_line=$(grep -m1 "^Status:" "$state" | sed 's/Status: *//')
      [[ -n "$status_line" ]] && { echo "$status_line"; return; }
    fi

    echo "Run /gsd:resume-work"
    return
  fi

  [[ -n "$next_action" && "$next_action" != "null" ]] && { echo "$next_action"; return; }
  echo "No next action set"
}

_morning_git_status() {
  local hub_path="$1"
  [[ -d "$hub_path/.git" ]] || return
  local count
  count=$(git -C "$hub_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [[ "$count" -gt 0 ]] && echo "$count"
}

morning() {
  local c_blue=$'\e[34m'
  local c_yellow=$'\e[33m'
  local c_dim=$'\e[2m'
  local c_clear=$'\e[0m'
  local c_bold=$'\e[1m'

  [[ -f "$HUBS_REGISTRY" ]] || { echo "No hubs registry. Run: hub create"; return 1; }

  local target_num="$1"
  local now
  now=$(date +%s)

  # Pre-sorted by last_accessed descending
  local raw_data
  raw_data=$(jq -r '[.hubs[] | select(.status != "archived")] | sort_by(-.last_accessed) | .[] | "\(.name)|\(.path)|\(.last_accessed // 0)|\(.type // "")|\(.next_action // "")|\(.progress // "")"' "$HUBS_REGISTRY" 2>/dev/null)

  [[ -z "$raw_data" ]] && { echo "No active projects"; return; }

  # Build arrays for grouping (already sorted by recency)
  local -a attention_entries active_entries parked_entries
  local name hub_path last_accessed hub_type next_action progress
  local elapsed days uncommitted next_step time_ago phase_info pct status_line state_file entry

  while IFS='|' read -r name hub_path last_accessed hub_type next_action progress; do
    [[ -z "$name" ]] && continue
    [[ ! -d "$hub_path" ]] && continue

    elapsed=$(( now - last_accessed ))
    days=$(( elapsed / 86400 ))
    uncommitted=$(_morning_git_status "$hub_path")
    next_step=$(_morning_next_step "$hub_path" "$hub_type" "$next_action")
    time_ago=$(_morning_time_ago "$last_accessed" "$now")

    phase_info="" pct="" status_line=""
    state_file="$hub_path/.planning/STATE.md"
    if [[ "$hub_type" == "gsd" || -f "$state_file" ]]; then
      if [[ -f "$state_file" ]]; then
        phase_info=$(grep -m1 "^Phase:" "$state_file" 2>/dev/null | sed 's/Phase: *//' | sed 's/ (.*//')
        pct=$(grep -m1 "^Progress:" "$state_file" 2>/dev/null | grep -oE '[0-9]+%' | head -1)
        status_line=$(grep -m1 "^Status:" "$state_file" 2>/dev/null | sed 's/Status: *//')
      fi
    fi

    # entry: name|time_ago|phase_info|pct|status_line|next_step|uncommitted|hub_type|progress|hub_path
    entry="$name|$time_ago|$phase_info|$pct|$status_line|$next_step|$uncommitted|$hub_type|$progress|$hub_path"

    if [[ -n "$uncommitted" || $days -lt 2 ]]; then
      attention_entries+=("$entry")
    elif [[ $days -lt 30 ]] && { [[ -f "$state_file" ]] || [[ -n "$next_action" && "$next_action" != "null" ]]; }; then
      active_entries+=("$entry")
    else
      parked_entries+=("$entry")
    fi
  done <<< "$raw_data"

  local total=$(( ${#attention_entries[@]} + ${#active_entries[@]} + ${#parked_entries[@]} ))

  # Navigation mode
  if [[ -n "$target_num" && "$target_num" =~ ^[0-9]+$ ]]; then
    local idx=0
    for entry in "${attention_entries[@]}" "${active_entries[@]}" "${parked_entries[@]}"; do
      idx=$((idx + 1))
      [[ "$idx" -eq "$target_num" ]] && { cd "${entry##*|}" && return; }
    done
    echo "No project at index $target_num"
    return 1
  fi

  # Display
  local day_name date_str
  day_name=$(date +%A)
  date_str=$(date "+%b %-d")
  echo ""
  echo "${c_bold}Morning Briefing${c_clear} ${c_dim}— $day_name, $date_str${c_clear}"

  local global_idx=0

  _morning_print() {
    local entry="$1"
    global_idx=$((global_idx + 1))

    local e_name e_time e_phase e_pct e_status e_next e_uncommitted e_type e_progress e_path
    IFS='|' read -r e_name e_time e_phase e_pct e_status e_next e_uncommitted e_type e_progress e_path <<< "$entry"

    if [[ "$e_type" == "gsd" || -f "$e_path/.planning/STATE.md" ]]; then
      local pd=""
      [[ -n "$e_phase" ]] && pd="Phase $e_phase"
      local sd="$e_status"
      [[ ${#sd} -gt 30 ]] && sd="${sd:0:27}..."
      printf "  ${c_dim}%2d.${c_clear} %-9s ${c_blue}%-15s${c_clear} %-16s %-6s %s\n" \
        "$global_idx" "$e_time" "$e_name" "$pd" "$e_pct" "$sd"
    else
      local pd=""
      [[ -n "$e_progress" && "$e_progress" != "null" ]] && pd="$e_progress"
      [[ ${#pd} -gt 30 ]] && pd="${pd:0:27}..."
      printf "  ${c_dim}%2d.${c_clear} %-9s ${c_blue}%-15s${c_clear} %33s ${c_dim}hub${c_clear}\n" \
        "$global_idx" "$e_time" "$e_name" "$pd"
    fi

    # Truncate long next steps
    [[ ${#e_next} -gt 80 ]] && e_next="${e_next:0:77}..."
    printf "      Next: %s\n" "$e_next"
    [[ -n "$e_uncommitted" ]] && printf "      ${c_yellow}%s files uncommitted${c_clear}\n" "$e_uncommitted"
  }

  if [[ ${#attention_entries[@]} -gt 0 ]]; then
    echo ""
    echo "  ${c_bold}NEEDS ATTENTION${c_clear}"
    for entry in "${attention_entries[@]}"; do
      echo ""
      _morning_print "$entry"
    done
  fi

  if [[ ${#active_entries[@]} -gt 0 ]]; then
    echo ""
    echo "  ${c_bold}ACTIVE${c_clear}"
    for entry in "${active_entries[@]}"; do
      echo ""
      _morning_print "$entry"
    done
  fi

  if [[ ${#parked_entries[@]} -gt 0 ]]; then
    echo ""
    echo "  ${c_bold}PARKED${c_clear}"
    for entry in "${parked_entries[@]}"; do
      echo ""
      _morning_print "$entry"
    done
  fi

  echo ""
  echo "${c_dim}${total} projects — ${#attention_entries[@]} need attention, ${#active_entries[@]} active, ${#parked_entries[@]} parked${c_clear}"
  echo "${c_dim}Run: morning <N> to cd to project${c_clear}"
  echo ""
}
