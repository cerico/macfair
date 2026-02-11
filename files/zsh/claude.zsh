# Claude Code helpers

# Remove any old aliases to allow function definitions
unalias claude clauden claudev claudevn claudep claudevp claudex claudepod 2>/dev/null

CLAUDE_LOCKFILE=".claude-session.lock"

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
  [[ -f .planning/STATE.md ]] && flags+=("go")
  _claude_run "${flags[@]}"
}

claude() {
  [[ $# -eq 0 ]] && { _claude_maybe_gsd --permission-mode plan; return; }
  _claude_run --permission-mode plan "$@"
}
clauden() {
  [[ $# -eq 0 ]] && { _claude_maybe_gsd; return; }
  _claude_run "$@"
}
claudev() {
  local voice='Always respond using the mcp__voicemode__converse tool to speak your responses aloud.'
  [[ $# -eq 0 ]] && { _claude_maybe_gsd --permission-mode plan --append-system-prompt "$voice"; return; }
  _claude_run --permission-mode plan --append-system-prompt "$voice" "$@"
}
claudevn() {
  local voice='Always respond using the mcp__voicemode__converse tool to speak your responses aloud.'
  [[ $# -eq 0 ]] && { _claude_maybe_gsd --append-system-prompt "$voice"; return; }
  _claude_run --append-system-prompt "$voice" "$@"
}
claudex() {
  command -v podman &>/dev/null || { echo "claudex requires Podman"; return 1; }
  podman run --rm -it \
    -v "$(pwd):/work" \
    -v "$HOME/.claude:/home/claude/.claude:ro" \
    -w /work \
    claudepod \
    claude --dangerously-skip-permissions "$@"
}

claudewright() {
  claude mcp add playwright npx @playwright/mcp@latest
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
    osascript <<EOF
tell application "iTerm2"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if tty of s ends with "$tty" then
          select t
          tell w to select
          activate
          return
        end if
      end repeat
    end repeat
  end repeat
end tell
EOF
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

    local -a managed_items deployed_items
    if [[ -d "$managed_dir" ]]; then
      [[ "$strip_ext" == "true" ]] \
        && managed_items=(${(f)"$(ls "$managed_dir" 2>/dev/null | sed 's/\.[^.]*$//')"}) \
        || managed_items=(${(f)"$(ls "$managed_dir" 2>/dev/null)"})
    fi
    [[ "$strip_ext" == "true" ]] \
      && deployed_items=(${(f)"$(ls "$deployed_dir" 2>/dev/null | sed 's/\.[^.]*$//')"}) \
      || deployed_items=(${(f)"$(ls "$deployed_dir" 2>/dev/null)"})

    local -a untracked
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
