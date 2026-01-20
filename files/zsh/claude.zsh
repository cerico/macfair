# Claude Code helpers

# Remove any old aliases to allow function definitions
unalias claude claudep claudev claudevp 2>/dev/null

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

claude() { _claude_run "$@"; }
claudep() { _claude_run --permission-mode plan "$@"; }
claudev() { _claude_run --append-system-prompt "Always respond using the mcp__voicemode__converse tool to speak your responses aloud." "$@"; }
claudevp() { _claude_run --permission-mode plan --append-system-prompt "Always respond using the mcp__voicemode__converse tool to speak your responses aloud." "$@"; }

claudewright() {
  claude mcp add playwright npx @playwright/mcp@latest
}
