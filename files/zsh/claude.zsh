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

# Show all Claude processes with status
claudeps() {
  echo "PID\t%CPU\tMEM\tSTATE\tSTARTED\tDIR"
  echo "---\t----\t---\t-----\t-------\t---"
  ps -eo pid=,tty=,%cpu=,%mem=,state=,lstart=,comm= | grep -E "claude$" | while read pid tty cpu mem state lstart1 lstart2 lstart3 lstart4 lstart5 comm; do
    # Format: "Mon Jan 25 10:57:00 2025" -> "Jan 25 10:57"
    local started="${lstart2} ${lstart3} ${lstart4:0:5}"
    # Determine status from TTY and state
    # S = sleeping, R = running, S+ = foreground sleep
    local proc_state="$state"
    [[ "$tty" == "??" ]] && proc_state="ORPHAN"
    # Get working directory (shorten home to ~)
    local cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | grep ^n | cut -c2- | sed "s|^${HOME}|~|")
    [[ -z "$cwd" ]] && cwd="-"
    # Truncate long paths
    [[ ${#cwd} -gt 20 ]] && cwd="…${cwd: -19}"
    echo "${pid}\t${cpu}\t${mem}%\t${proc_state}\t${started}\t${cwd}"
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
