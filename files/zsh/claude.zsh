# Claude Code helpers

# Remove any old aliases to allow function definitions
unalias claude clauden claudev claudevn claudep claudevp 2>/dev/null

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
  command claude "$@"
  local ret=$?
  _claude_unlock
  return $ret
}

claude() { _claude_run --permission-mode plan "$@"; }
clauden() { _claude_run "$@"; }
claudev() { _claude_run --permission-mode plan --append-system-prompt "Always respond using the mcp__voicemode__converse tool to speak your responses aloud." "$@"; }
claudevn() { _claude_run --append-system-prompt "Always respond using the mcp__voicemode__converse tool to speak your responses aloud." "$@"; }

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

skills() { printf '%s\n' ~/.claude/skills/*(N:t); }
commands() { printf '%s\n' ~/.claude/commands/*(N:t:r); }
hooks() { printf '%s\n' ~/.claude/hooks/*(N:t:r); }
agents() { printf '%s\n' ~/.claude/agents/*(N:t:r); }
