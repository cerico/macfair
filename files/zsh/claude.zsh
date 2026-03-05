# Claude Code helpers

# Remove any old aliases to allow function definitions
unalias claude clauden claudev claudevn claudep claudevp claudex claudepod discuss 2>/dev/null

CLAUDE_LOCKFILE=".claude-session.lock"

_wez_focus_pane() {
  local target_pane="$1"
  [[ -z "$target_pane" ]] && return 1
  local pane_json
  pane_json=$(wezterm cli list --format json 2>/dev/null)
  local tab_id
  tab_id=$(echo "$pane_json" | jq -r --arg pid "$target_pane" '[.[] | select(.pane_id == ($pid | tonumber))][0].tab_id // empty')
  [[ -z "$tab_id" ]] && return 1
  local shell_pane
  shell_pane=$(echo "$pane_json" | jq -r --arg tab "$tab_id" --arg pid "$target_pane" '[.[] | select(.tab_id == ($tab | tonumber) and .pane_id != ($pid | tonumber))][0].pane_id // empty')
  wezterm cli activate-pane --pane-id "$target_pane" 2>/dev/null
  local rc=$?
  [[ -n "$shell_pane" ]] && printf '%s\n' "printf '\\e]1337;SetUserVar=focus=MQ==\\a'" | wezterm cli send-text --pane-id "$shell_pane" --no-paste
  return $rc
}

_wez_focus_tty() {
  local tty="$1"
  [[ -z "$tty" ]] && return 1
  local pane_id
  pane_id=$(wezterm cli list --format json 2>/dev/null | jq -r --arg tty "$tty" '[.[] | select(.tty_name | endswith($tty))] | .[0].pane_id // empty' 2>/dev/null)
  [[ -z "$pane_id" ]] && return 1
  _wez_focus_pane "$pane_id"
}

_wez_spawn_window() {
  if wezterm cli list &>/dev/null; then
    wezterm cli spawn --new-window --cwd "$1"
    return
  fi
  open -a WezTerm
  local retries=0
  while ! wezterm cli list &>/dev/null && (( retries < 20 )); do
    sleep 0.3
    ((retries++))
  done
  wezterm cli list &>/dev/null || return 1
  local first_pane
  first_pane=$(wezterm cli list --format json 2>/dev/null | jq -r '.[0].pane_id')
  [[ -n "$first_pane" && "$first_pane" != "null" ]] && echo "$first_pane"
}

_wez_layout() {
  local main_pane="$1"
  shift

  local right_pane
  right_pane=$(wezterm cli split-pane --right --percent 30 --pane-id "$main_pane" --cwd "$PWD")
  [[ -z "$right_pane" ]] && { echo "Split failed"; return 1; }

  local bottom_right
  bottom_right=$(wezterm cli split-pane --bottom --percent 50 --pane-id "$right_pane" --cwd "$PWD")

  printf 'clear\n' | wezterm cli send-text --pane-id "$right_pane" --no-paste
  [[ -n "$bottom_right" ]] && printf 'clear\n' | wezterm cli send-text --pane-id "$bottom_right" --no-paste

  wezterm cli activate-pane --pane-id "$main_pane"
  local cmd=$(printf '%q ' "$@")
  printf '%s\n' "$cmd" | wezterm cli send-text --pane-id "$main_pane" --no-paste
}

_claude_wez() {
  local session="${${PWD##*/}//[.:]/_}"
  local state_file="/tmp/wez_claude_${session}"

  if [[ -f "$state_file" ]]; then
    local saved_pane
    saved_pane=$(cat "$state_file")
    local pane_json
    pane_json=$(wezterm cli list --format json 2>/dev/null)
    local pane_tty
    pane_tty=$(echo "$pane_json" | jq -r --arg pid "$saved_pane" '[.[] | select(.pane_id == ($pid | tonumber))][0].tty_name // empty')
    if [[ -n "$pane_tty" ]]; then
      if ps -t "$pane_tty" -o comm= 2>/dev/null | grep -q '^claude$'; then
        _wez_focus_pane "$saved_pane"
        return
      fi
      local cmd=$(printf '%q ' "$@")
      printf '%s\n' "$cmd" | wezterm cli send-text --pane-id "$saved_pane" --no-paste
      _wez_focus_pane "$saved_pane"
      return
    fi
    rm -f "$state_file"
  fi

  local main_pane
  if [[ -n "$WEZTERM_PANE" ]]; then
    main_pane="$WEZTERM_PANE"
  else
    main_pane=$(_wez_spawn_window "$PWD")
    [[ -z "$main_pane" ]] && { echo "Could not create WezTerm window"; return 1; }
  fi

  _wez_layout "$main_pane" "$@" && echo "$main_pane" > "$state_file"
}

_claude_lock() {
  if [[ -f "$CLAUDE_LOCKFILE" ]]; then
    local lock_pid=$(cat "$CLAUDE_LOCKFILE" 2>/dev/null)
    if [[ "$lock_pid" =~ ^[0-9]+$ ]] && kill -0 "$lock_pid" 2>/dev/null; then
      echo "Session active (PID $lock_pid)"
      return 1
    fi
    rm -f "$CLAUDE_LOCKFILE"
  fi
  echo $$ > "$CLAUDE_LOCKFILE"
  trap '_claude_unlock' EXIT INT TERM
  return 0
}

_claude_unlock() {
  [[ -f "$CLAUDE_LOCKFILE" ]] && [[ "$(cat "$CLAUDE_LOCKFILE" 2>/dev/null)" == "$$" ]] && rm -f "$CLAUDE_LOCKFILE"
  trap - EXIT INT TERM
}

_claude_run() {
  _claude_lock || return 1
  CLAUDE_WRAPPER_PID=$$ command claude "$@"
  local ret=$?
  _claude_unlock
  return $ret
}

_claude_maybe_gsd() {
  local -a flags=("$@")
  _claude_run "${flags[@]}"
}

claude() {
  local -a args=(command claude --permission-mode plan)
  [[ $# -gt 0 ]] && args+=("$@")
  _claude_wez "${args[@]}"
}
clauden() {
  [[ $# -eq 0 ]] && { _claude_maybe_gsd; return; }
  _claude_run "$@"
}
claudev() {
  local voice='Always speak responses aloud using the /speak skill. Every response should be voiced via Kokoro TTS. Before any tool call that needs permission, speak what you are about to do so the user knows to check the screen.'
  [[ $# -eq 0 ]] && { _claude_maybe_gsd --permission-mode plan --append-system-prompt "$voice"; return; }
  _claude_run --permission-mode plan --append-system-prompt "$voice" "$@"
}
claudevn() {
  local voice='Always speak responses aloud using the /speak skill. Every response should be voiced via Kokoro TTS. Before any tool call that needs permission, speak what you are about to do so the user knows to check the screen.'
  [[ $# -eq 0 ]] && { _claude_maybe_gsd --append-system-prompt "$voice"; return; }
  _claude_run --append-system-prompt "$voice" "$@"
}
claudex() {
  command -v podman &>/dev/null || { echo "claudex requires Podman"; return 1; }
  podman run --rm -it \
    --userns=keep-id \
    -v "$(pwd):/work" \
    -v "$HOME/.claude:/home/claude/.claude:ro" \
    -w /work \
    claudepod \
    claude --dangerously-skip-permissions "$@"
}

discuss() {
  local voice='Always speak every response aloud using the /speak skill (Kokoro TTS on port 8880, then afplay). Skip code blocks in the spoken version - focus on reasoning, strategy, and discussion. The user can see the full text on screen, so the spoken part should be conversational. Before any tool call that needs permission, speak what you are about to do so the user knows to check the screen.'
  local -a args=(command claude --permission-mode plan --append-system-prompt "$voice")
  [[ $# -gt 0 ]] && args+=("$@")
  _claude_wez "${args[@]}"
}

vps() {
  [[ -z "$1" ]] && { sshs; return; }
  local host="$1" session="vps_${1//[.:]/_}"
  shift
  local state_file="/tmp/wez_${session}"
  if [[ -f "$state_file" ]]; then
    local saved_pane
    saved_pane=$(cat "$state_file")
    if wezterm cli list --format json 2>/dev/null | jq -e --arg pid "$saved_pane" '[.[] | select(.pane_id == ($pid | tonumber))] | length > 0' &>/dev/null; then
      wezterm cli activate-pane --pane-id "$saved_pane" 2>/dev/null
      osascript -e 'tell application "WezTerm" to activate'
      return
    fi
    rm -f "$state_file"
  fi

  local macfair="$HOME/macfair"
  local main_pane
  if [[ -n "$WEZTERM_PANE" ]]; then
    main_pane="$WEZTERM_PANE"
  else
    main_pane=$(_wez_spawn_window "$macfair")
    [[ -z "$main_pane" ]] && { echo "Could not create WezTerm window"; return 1; }
  fi

  local right_pane
  right_pane=$(wezterm cli split-pane --right --percent 30 --pane-id "$main_pane" --cwd "$macfair")
  [[ -z "$right_pane" ]] && { echo "Split failed"; return 1; }

  local bottom_right
  bottom_right=$(wezterm cli split-pane --bottom --percent 30 --pane-id "$right_pane" --cwd "$macfair")

  printf 'clear && ssh %s\n' "$(printf '%q' "$host")" | wezterm cli send-text --pane-id "$right_pane" --no-paste
  [[ -n "$bottom_right" ]] && printf 'clear\n' | wezterm cli send-text --pane-id "$bottom_right" --no-paste

  echo "$main_pane" > "$state_file"
  wezterm cli activate-pane --pane-id "$main_pane"
  local -a args=(command claude --permission-mode plan)
  [[ $# -gt 0 ]] && args+=("$@")
  local cmd=$(printf '%q ' "${args[@]}")
  printf '%s; rm -f %s\n' "$cmd" "$(printf '%q' "$state_file")" | wezterm cli send-text --pane-id "$main_pane" --no-paste
}

claudewright() {
  claude mcp add playwright npx @playwright/mcp@latest
}

curate() {
  local vault="$HOME/second-brain"
  [[ -d "$vault" ]] || { echo "No vault at $vault"; return 1; }
  cd "$vault" && command claude -p "/curate"
}

# List Claude sessions, or jump to one by index (active first, orphans last)
claudes() {
  local idx="${1:-}"
  local ps_data=$(ps -eo tty=,pid=,%cpu=,%mem=,state=,lstart=,comm= | grep -E "claude$")
  local active=$(echo "$ps_data" | awk '$1 != "??"')
  local orphans=$(echo "$ps_data" | awk '$1 == "??"')
  local sorted="${active}${orphans:+$'\n'$orphans}"
  [[ -z "$sorted" ]] && { echo "No sessions"; [[ -n "$idx" ]] && return 1 || return 0; }

  if [[ -n "$idx" ]]; then
    local ttys=($(echo "$sorted" | awk '{print $1}'))
    local count=${#ttys[@]}
    if [[ ! "$idx" =~ ^[0-9]+$ ]] || [[ "$idx" -lt 1 ]] || [[ "$idx" -gt $count ]]; then
      echo "No session at index $idx ($count available)"
      return 1
    fi
    local tty="${ttys[$idx]}"
    [[ "$tty" == "??" ]] && { echo "Session $idx is orphaned. Use 'claudekill' to clean up."; return 1; }
    _wez_focus_tty "$tty" || echo "Could not find WezTerm pane for tty $tty"
    return
  fi

  echo "#\tPID\tTTY\t%CPU\tMEM\tSTATE\tSTARTED\tDIR"
  echo "-\t---\t---\t----\t---\t-----\t-------\t---"
  local i=0
  echo "$sorted" | while read tty pid cpu mem state lstart1 lstart2 lstart3 lstart4 lstart5 comm; do
    ((i++))
    local started="${lstart2} ${lstart3} ${lstart4:0:5}"
    local proc_state="$state"
    [[ "$tty" == "??" ]] && proc_state="ORPHAN"
    local cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | grep ^n | cut -c2- | sed "s|^${HOME}|~|")
    [[ -z "$cwd" ]] && cwd="-"
    [[ ${#cwd} -gt 20 ]] && cwd="…${cwd: -19}"
    echo "${i}\t${pid}\t${tty}\t${cpu}\t${mem}%\t${proc_state}\t${started}\t${cwd}"
  done | column -t -s $'\t'
}

# Browse and search Claude conversations across projects
conversations() {
  local claude_dir="$HOME/.claude/projects"
  local c_blue=$'\e[34m' c_dim=$'\e[2m' c_yellow=$'\e[33m' c_clear=$'\e[0m'
  local -a conv_files=()

  _conv_sorted() {
    local -a matches=("$claude_dir"/*/*.jsonl(N))
    [[ ${#matches[@]} -eq 0 ]] && { conv_files=(); return; }
    conv_files=($(ls -t -- "${matches[@]}" | head -25))
  }

  _conv_display() {
    [[ ${#conv_files[@]} -eq 0 ]] && { echo "No conversations found"; return; }
    local idx=0
    for f in "${conv_files[@]}"; do
      ((idx++))
      local project="${f:h:t}"
      project="${project/#-Users-brew-/}"
      project="${project//-//}"
      [[ ${#project} -gt 25 ]] && project="…${project: -24}"
      local date=$(stat -f '%Sm' -t '%b %d %H:%M' "$f" 2>/dev/null)
      local slug=$(python3 -c "
import json,sys
with open(sys.argv[1]) as fh:
    for line in fh:
        d=json.loads(line)
        s=d.get('slug','')
        if s: print(s); break
" "$f" 2>/dev/null)
      if [[ -z "$slug" ]]; then
        local sid="${f:t:r}"
        slug="${sid:0:12}…"
      fi
      printf "${c_dim}%3d.${c_clear} ${c_yellow}%-14s${c_clear} ${c_blue}%-25s${c_clear} %s\n" "$idx" "$date" "$project" "$slug"
    done
  }

  _conv_search() {
    local matches=$(grep -rFl "$1" "$claude_dir"/*/*.jsonl 2>/dev/null)
    [[ -z "$matches" ]] && { echo "No conversations matching '$1'"; return 1; }
    conv_files=($(echo "$matches" | xargs ls -t 2>/dev/null | head -25))
  }

  _conv_resume() {
    local target=$1
    [[ $target -lt 1 || $target -gt ${#conv_files[@]} ]] && { echo "No conversation at index $target (${#conv_files[@]} available)"; return 1; }
    local file="${conv_files[$target]}"
    local session_id="${file:t:r}"
    echo "Resuming: $session_id"
    _claude_run --resume "$session_id"
  }

  if [[ -z "$1" ]]; then
    _conv_sorted
    _conv_display
  elif [[ "$1" =~ ^[0-9]+$ ]]; then
    _conv_sorted
    _conv_resume "$1"
  elif [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
    _conv_search "$1" && _conv_resume "$2"
  else
    _conv_search "$1" && _conv_display
  fi
}

# Kill orphaned Claude processes (no TTY)
claudekill() {
  local orphans=$(ps -eo pid=,tty=,comm= | grep -E "claude$" | awk '$2 == "??" {print $1}')
  if [[ -z "$orphans" ]]; then
    echo "No orphaned Claude processes found"
    return 0
  fi
  # Convert newlines to commas for ps -p (trim trailing comma)
  local pids_csv="${orphans//$'\n'/,}"
  pids_csv="${pids_csv%,}"
  echo "Orphaned Claude processes:"
  ps -o pid=,tty=,time=,lstart= -p "$pids_csv" 2>/dev/null
  echo ""
  read -q "REPLY?Kill these processes? [y/N] "
  echo ""
  [[ "$REPLY" == "y" ]] && echo "$orphans" | xargs kill -9 && echo "Killed"
}

addclaude() { # Copy starter CLAUDE.md template to current directory # ➜ addclaude
  [[ -f CLAUDE.md ]] && echo "CLAUDE.md already exists" && return 1
  cp ~/.templates/CLAUDE.md . && echo "Copied CLAUDE.md template — fill in project details"
}

memories() { # Browse Claude memory files across projects # ➜ memories search prisma
  local claude_dir="$HOME/.claude/projects"
  local c_blue=$'\e[34m' c_dim=$'\e[2m' c_clear=$'\e[0m'

  _memories_list() {
    local idx=0
    for f in "$claude_dir"/*/memory/*.md(N); do
      idx=$((idx + 1))
      local project="${f:h:h:t}"
      project="${project/#-Users-brew-/}"
      project="${project//-//}"
      local filename="${f:t}"
      printf "%s${c_dim}%3d.${c_clear} ${c_blue}%-30s${c_clear} %s\n" "" "$idx" "$project" "$filename"
    done
    [[ $idx -eq 0 ]] && echo "No memory files found"
  }

  _memories_file_at() {
    local target=$1 idx=0
    for f in "$claude_dir"/*/memory/*.md(N); do
      idx=$((idx + 1))
      [[ $idx -eq $target ]] && echo "$f" && return
    done
  }

  case "$1" in
    search)
      [[ -z "$2" ]] && echo "Usage: memories search <term>" && return 1
      grep --color=always -rni "$2" "$claude_dir"/*/memory/*.md 2>/dev/null | while IFS= read -r line; do
        local file="${line%%:*}"
        local rest="${line#*:}"
        local project="${file:h:h:t}"
        project="${project/#-Users-brew-/}"
        project="${project//-//}"
        local filename="${file:t}"
        printf "${c_blue}%-30s${c_clear} ${c_dim}%s:${c_clear}%s\n" "$project" "$filename" "$rest"
      done
      ;;
    ""|list)
      _memories_list
      ;;
    *)
      [[ "$1" =~ ^[0-9]+$ ]] || { echo "Usage: memories [list|search <term>|<N>]"; return 1; }
      local file=$(_memories_file_at "$1")
      [[ -z "$file" ]] && echo "No file at index $1" && return 1
      command -v glow &>/dev/null && glow "$file" || cat "$file"
      ;;
  esac
}

skills() { printf '%s\n' ~/.claude/skills/*(N:t); }
commands() { printf '%s\n' ~/.claude/commands/*(N:t:r); }
hooks() { printf '%s\n' ~/.claude/hooks/*(N:t:r); }
agents() { printf '%s\n' ~/.claude/agents/*(N:t:r); }

drift() {
  local macfair="$HOME/macfair/files/claude"
  local deployed="$HOME/.claude"
  local c_red=$'\e[31m'
  local c_clear=$'\e[0m'
  local known_pattern="^(gsd|voicemode|context-usage)"

  local cmd="$1"
  case "$cmd" in
    rm|mv|cat) _drift_action "$@"; return ;;
    "") ;;
    *) echo "Usage: drift [rm|mv|cat <type> <name>]"; return 1 ;;
  esac

  local found=false
  local type dirs
  for type dirs in \
    skills  "$macfair/skills|$deployed/skills|false" \
    commands "$macfair/commands|$deployed/commands|true" \
    hooks   "$macfair/hooks|$deployed/hooks|true" \
    agents  "$macfair/agents|$deployed/agents|true"; do

    local managed_dir="${dirs%%|*}" rest="${dirs#*|}"
    local deployed_dir="${rest%%|*}" strip_ext="${rest#*|}"
    [[ -d "$deployed_dir" ]] || continue

    local -a managed_items deployed_items untracked
    managed_items=() deployed_items=() untracked=()
    if [[ -d "$managed_dir" ]]; then
      [[ "$strip_ext" == "true" ]] \
        && managed_items=(${(f)"$(ls "$managed_dir" 2>/dev/null | sed 's/\.[^.]*$//')"}) \
        || managed_items=(${(f)"$(ls "$managed_dir" 2>/dev/null)"})
    fi
    [[ "$strip_ext" == "true" ]] \
      && deployed_items=(${(f)"$(ls "$deployed_dir" 2>/dev/null | sed 's/\.[^.]*$//')"}) \
      || deployed_items=(${(f)"$(ls "$deployed_dir" 2>/dev/null)"})

    for item in "${deployed_items[@]}"; do
      [[ -z "$item" ]] && continue
      (( ${managed_items[(Ie)$item]} )) && continue
      [[ "$item" =~ $known_pattern ]] && continue
      untracked+=("$item")
    done

    if [[ ${#untracked[@]} -gt 0 ]]; then
      found=true
      echo "${c_red}${type}:${c_clear}"
      printf '  %s\n' "${untracked[@]}"
      echo ""
    fi
  done

  $found || echo "No drift"
}

_drift_action() {
  local cmd="$1" type="$2" name="$3"
  local macfair="$HOME/macfair/files/claude"
  local deployed="$HOME/.claude"

  [[ -z "$type" || -z "$name" ]] && { echo "Usage: drift $cmd <type> <name>"; return 1; }
  [[ "$type" =~ ^(skills|commands|hooks|agents)$ ]] || { echo "Type must be: skills, commands, hooks, agents"; return 1; }

  local src
  if [[ "$type" == "skills" ]]; then
    src="$deployed/$type/$name"
  else
    src=$(ls "$deployed/$type/$name".* 2>/dev/null | head -1)
    [[ -z "$src" ]] && src="$deployed/$type/$name"
  fi
  [[ -e "$src" ]] || { echo "Not found: $src"; return 1; }

  case "$cmd" in
    cat)
      local file="$src"
      [[ -d "$src" ]] && file="$src/SKILL.md"
      [[ -f "$file" ]] || { echo "No readable file at $file"; return 1; }
      command -v glow &>/dev/null && glow "$file" || cat "$file"
      ;;
    rm)
      echo "Remove: $src"
      read -q "REPLY?Confirm? [y/N] " && echo "" && rm -r "$src" && echo "Removed" || echo ""
      ;;
    mv)
      local dest="$macfair/$type/$(basename "$src")"
      [[ -e "$dest" ]] && { echo "Already exists in macfair: $dest"; return 1; }
      echo "Move: $src -> $dest"
      read -q "REPLY?Confirm? [y/N] " && echo "" && mv "$src" "$dest" && echo "Moved to macfair" || echo ""
      ;;
  esac
}

_drift_complete() {
  local -a subcommands types
  subcommands=('cat:View contents' 'rm:Remove item' 'mv:Move to macfair')
  types=(skills commands hooks agents)

  if (( CURRENT == 2 )); then
    _describe 'action' subcommands
  elif (( CURRENT == 3 )); then
    _describe 'type' types
  elif (( CURRENT == 4 )); then
    local type="$words[3]"
    local dir="$HOME/.claude/$type"
    [[ -d "$dir" ]] || return
    local -a items
    items=(${(f)"$(ls "$dir" 2>/dev/null)"})
    [[ ${#items} -gt 0 ]] && _describe 'item' items
  fi
}
compdef _drift_complete drift 2>/dev/null
