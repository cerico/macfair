# Ralph Wiggum - Autonomous Claude Code loops
# https://ghuntley.com/ralph/
#
# Ticket-based workflow: tmp/tickets/*.md → tmp/tickets/done/
# Or custom prompt: ralph.md in project or ~/.claude/ralph.md
#
# SAFETY: On macOS, Ralph ONLY runs in a podman container.
# On Linux, runs directly (assumes server/CI environment).

RALPH_IMAGE="${RALPH_IMAGE:-node:20}"
RALPH_MAX="${RALPH_MAX:-15}"
RALPH_LOCKFILE=".ralph.lock"
RALPH_UID="${RALPH_UID:-$(id -u)}"
RALPH_GID="${RALPH_GID:-$(id -g)}"

# Check if we're on macOS
_ralph_is_mac() {
  [[ "$(uname)" == "Darwin" ]]
}

# Run claude command - container on Mac, direct on Linux
_ralph_claude() {
  local prompt_file="$1"

  # Read prompt content on host (works for any path)
  local prompt_content
  prompt_content=$(cat "$prompt_file") || { echo "Failed to read prompt: $prompt_file"; return 1; }

  if _ralph_is_mac; then
    # Pass content directly - avoids path mapping issues
    _ralph_container_with_env "RALPH_PROMPT=$prompt_content" \
      sh -c 'claude --print --dangerously-skip-permissions "$RALPH_PROMPT"'
  else
    claude --print --dangerously-skip-permissions "$prompt_content"
  fi
}

# Resolve prompt: local ralph.md → global ~/.claude/ralph.md
_ralph_resolve_prompt() {
  local prompt="${RALPH_PROMPT:-ralph.md}"
  [[ -f "$prompt" ]] && { echo "$prompt"; return 0; }
  [[ -f "$HOME/.claude/ralph.md" ]] && { echo "$HOME/.claude/ralph.md"; return 0; }
  return 1
}

# Ensure ticket directories exist
_ralph_ensure_dirs() {
  [[ -d "tmp/tickets/done" ]] || mkdir -p tmp/tickets/done || { echo "Failed to create tmp/tickets/done"; return 1; }
}

# Count tickets safely (handles zsh NOMATCH)
_ralph_ticket_count() {
  setopt localoptions null_glob
  local tickets=(tmp/tickets/*.md)
  echo "${#tickets[@]}"
}

# Get first ticket safely
_ralph_first_ticket() {
  setopt localoptions null_glob
  local tickets=(tmp/tickets/*.md)
  [[ ${#tickets[@]} -gt 0 ]] && echo "${tickets[1]}"
}

# Count done tickets safely
_ralph_done_count() {
  setopt localoptions null_glob
  local tickets=(tmp/tickets/done/*.md)
  echo "${#tickets[@]}"
}

# List pending tickets (up to N)
_ralph_list_tickets() {
  setopt localoptions null_glob
  local limit="${1:-5}"
  local tickets=(tmp/tickets/*.md)
  local count=0
  for ticket in "${tickets[@]}"; do
    [[ $count -ge $limit ]] && break
    echo "    - $(basename "$ticket")"
    ((count++))
  done
}

# Get branch name from first ticket
_ralph_branch_from_ticket() {
  local ticket=$(_ralph_first_ticket)
  [[ -z "$ticket" ]] && return 1
  basename "$ticket" .md
}

# Check if on main/master
_ralph_on_main() {
  local branch=$(git branch --show-current 2>/dev/null)
  [[ "$branch" == "main" || "$branch" == "master" ]]
}

# Ensure we're on correct branch for ticket work
_ralph_ensure_branch() {
  local mode="${1:-batch}"  # batch or per-ticket

  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Not a git repository"
    return 1
  fi

  if _ralph_on_main; then
    local branch=$(_ralph_branch_from_ticket)
    [[ -z "$branch" ]] && { echo "No tickets in tmp/tickets/"; return 1; }
    echo "Creating branch: $branch"
    git checkout -b "$branch" || { echo "Failed to create branch $branch (may already exist)"; return 1; }
  else
    echo "Using existing branch: $(git branch --show-current)"
  fi
}

# Lock management
_ralph_lock() {
  if [[ -f "$RALPH_LOCKFILE" ]]; then
    local lock_pid=$(cat "$RALPH_LOCKFILE" 2>/dev/null)
    if [[ "$lock_pid" =~ ^[0-9]+$ ]] && kill -0 "$lock_pid" 2>/dev/null; then
      echo "❌ Ralph already running in this directory (PID: $lock_pid)"
      echo "   If stale, run: ralph unlock"
      return 1
    fi
    echo "⚠️  Removing stale lock (PID $lock_pid no longer running)"
    rm -f "$RALPH_LOCKFILE"
  fi
  echo $$ > "$RALPH_LOCKFILE"
  trap '_ralph_unlock' EXIT INT TERM
  return 0
}

_ralph_unlock() {
  [[ -f "$RALPH_LOCKFILE" ]] && [[ "$(cat "$RALPH_LOCKFILE" 2>/dev/null)" == "$$" ]] && rm -f "$RALPH_LOCKFILE"
  trap - EXIT INT TERM
}

ralph() {
  local cmd="${1:-help}"
  shift 2>/dev/null

  case "$cmd" in
    help|--help|-h)
      cat <<'EOF'
Usage: ralph <command> [options]

Commands:
  run        Batch mode: one branch, work all tickets
  tickets    Per-ticket mode: each ticket gets own branch
  yolo       Run infinite loop (Ctrl+C to stop)
  status     Check prompt/tickets/branch status
  unlock     Remove stale lockfile

Setup (macOS - requires podman container):
  setup      Create global volumes (one-time)
  install    Install claude-code to volume (one-time)
  login      Authenticate Claude (one-time)
  shell      Interactive shell in container
  nuke       Delete global volumes (all projects!)

Options:
  RALPH_MAX=N     Max iterations (default: 15)
  RALPH_PROMPT=X  Prompt file (default: ralph.md → ~/.claude/ralph.md)

Workflow:
  1. Create tickets in tmp/tickets/
  2. On macOS: ralph setup && ralph install && ralph login (first time)
  3. Run `ralph run` (creates branch from first ticket name)
  4. Ralph works through tickets, moves to done/, commits each

Safety: On macOS, Ralph runs in a podman container. On Linux, runs directly.
EOF
      ;;

    setup)
      command -v podman >/dev/null 2>&1 || { echo "Install podman: brew install podman"; return 1; }
      podman machine list 2>/dev/null | grep -q "Currently running" || {
        echo "Starting podman machine..."
        podman machine init 2>/dev/null || true
        podman machine start
      }
      podman volume exists ralph-claude-config 2>/dev/null || {
        echo "Creating global auth volume..."
        podman volume create ralph-claude-config
      }
      podman volume exists ralph-claude-npm 2>/dev/null || {
        echo "Creating global npm volume..."
        podman volume create ralph-claude-npm
      }
      echo "✅ Ready. Run 'ralph install' then 'ralph login'."
      ;;

    install)
      echo "Installing claude-code (persists in volume)..."
      _ralph_container npm install -g @anthropic-ai/claude-code
      echo "✅ Installed. Run 'ralph login' to authenticate."
      ;;

    login)
      echo "Copy the URL, open in browser, authenticate, paste code back."
      echo ""
      _ralph_container claude login
      ;;

    shell)
      _ralph_container bash
      ;;

    run)
      local max="${RALPH_MAX:-15}"
      for arg in "$@"; do
        [[ "$arg" == MAX=* ]] && max="${arg#MAX=}"
        [[ "$arg" == RALPH_MAX=* ]] && max="${arg#RALPH_MAX=}"
      done

      # On Mac, verify podman is ready
      if _ralph_is_mac; then
        _ralph_container true 2>/dev/null || { echo "Run 'ralph setup && ralph install && ralph login' first"; return 1; }
      fi

      local prompt=$(_ralph_resolve_prompt)
      [[ -z "$prompt" ]] && { echo "No prompt found. Create ralph.md or set RALPH_PROMPT"; return 1; }

      _ralph_ensure_dirs || return 1
      _ralph_ensure_branch batch || return 1
      _ralph_lock || return 1

      local ticket_count=$(_ralph_ticket_count)
      [[ "$ticket_count" -eq 0 ]] && { echo "No tickets in tmp/tickets/"; _ralph_unlock; return 1; }
      [[ $ticket_count -lt $max ]] && max=$ticket_count

      echo "Ralph: $max iterations max"
      echo "Prompt: $prompt"
      _ralph_is_mac && echo "Mode: container (podman)" || echo "Mode: direct (linux)"
      echo ""

      local iteration=0
      while [[ $iteration -lt $max ]]; do
        ((iteration++))
        local remaining=$(_ralph_ticket_count)
        [[ "$remaining" -eq 0 ]] && { echo "All tickets completed!"; break; }

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  RALPH ITERATION $iteration / $max ($remaining tickets)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        _ralph_claude "$prompt"
      done
      echo ""
      [[ "$iteration" -ge "$max" ]] && echo "Reached $max iterations."
      _ralph_unlock
      ;;

    tickets)
      local max="${RALPH_MAX:-15}"
      for arg in "$@"; do
        [[ "$arg" == MAX=* ]] && max="${arg#MAX=}"
        [[ "$arg" == RALPH_MAX=* ]] && max="${arg#RALPH_MAX=}"
      done

      # On Mac, verify podman is ready
      if _ralph_is_mac; then
        _ralph_container true 2>/dev/null || { echo "Run 'ralph setup && ralph install && ralph login' first"; return 1; }
      fi

      local prompt=$(_ralph_resolve_prompt)
      [[ -z "$prompt" ]] && { echo "No prompt found. Create ralph.md or set RALPH_PROMPT"; return 1; }

      _ralph_ensure_dirs || return 1
      _ralph_lock || return 1

      local ticket_count=$(_ralph_ticket_count)
      [[ "$ticket_count" -eq 0 ]] && { echo "No tickets in tmp/tickets/"; _ralph_unlock; return 1; }
      [[ $ticket_count -lt $max ]] && max=$ticket_count

      echo "Per-ticket mode: each ticket gets its own branch"
      echo "Prompt: $prompt"
      _ralph_is_mac && echo "Mode: container (podman)" || echo "Mode: direct (linux)"
      echo ""

      local iteration=0
      while [[ $iteration -lt $max ]]; do
        local ticket=$(_ralph_first_ticket)
        [[ -z "$ticket" ]] && { echo "All tickets completed!"; break; }

        local branch=$(basename "$ticket" .md)

        # Switch to main and create new branch for this ticket
        if ! _ralph_on_main; then
          git checkout main 2>/dev/null || git checkout master
        fi
        git checkout -b "$branch" || { echo "Failed to create branch $branch"; _ralph_unlock; return 1; }

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  TICKET: $branch"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Work until this ticket is done or max iterations
        local ticket_iterations=0
        while [[ -f "$ticket" ]] && [[ $ticket_iterations -lt $max ]]; do
          ((iteration++))
          ((ticket_iterations++))
          _ralph_claude "$prompt"
        done
      done

      _ralph_unlock
      ;;

    yolo)
      # On Mac, verify podman is ready
      if _ralph_is_mac; then
        _ralph_container true 2>/dev/null || { echo "Run 'ralph setup && ralph install && ralph login' first"; return 1; }
      fi

      local prompt=$(_ralph_resolve_prompt)
      [[ -z "$prompt" ]] && { echo "No prompt found. Create ralph.md or set RALPH_PROMPT"; return 1; }

      _ralph_ensure_dirs || return 1
      _ralph_ensure_branch batch || return 1
      _ralph_lock || return 1

      echo "YOLO mode (Ctrl+C to stop)"
      echo "Prompt: $prompt"
      _ralph_is_mac && echo "Mode: container (podman)" || echo "Mode: direct (linux)"
      echo ""

      local iteration=0
      while :; do
        local remaining=$(_ralph_ticket_count)
        [[ "$remaining" -eq 0 ]] && { echo "All tickets completed!"; break; }

        ((iteration++))
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  RALPH ITERATION $iteration (YOLO) - $remaining tickets"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        _ralph_claude "$prompt"
      done
      _ralph_unlock
      ;;

    unlock)
      if [[ -f "$RALPH_LOCKFILE" ]]; then
        rm -f "$RALPH_LOCKFILE"
        echo "Lock removed."
      else
        echo "No lockfile found."
      fi
      ;;

    status)
      _ralph_ensure_dirs
      echo "Prompt:"
      local prompt=$(_ralph_resolve_prompt)
      [[ -n "$prompt" ]] && echo "  $prompt" || echo "  Not found (create ralph.md)"
      echo ""
      echo "Branch:"
      if git rev-parse --git-dir &>/dev/null; then
        local branch=$(git branch --show-current 2>/dev/null)
        echo "  $branch"
        _ralph_on_main && echo "  (will create branch from first ticket on run)"
      else
        echo "  Not a git repository"
      fi
      echo ""
      echo "Tickets:"
      local pending=$(_ralph_ticket_count)
      local done=$(_ralph_done_count)
      echo "  Pending: $pending"
      echo "  Done: $done"
      [[ "$pending" -gt 0 ]] && _ralph_list_tickets 5
      echo ""
      echo "Lock:"
      if [[ -f "$RALPH_LOCKFILE" ]]; then
        local lock_pid=$(cat "$RALPH_LOCKFILE" 2>/dev/null)
        if kill -0 "$lock_pid" 2>/dev/null; then
          echo "  Locked (PID: $lock_pid running)"
        else
          echo "  Stale lock (PID: $lock_pid not running, run: ralph unlock)"
        fi
      else
        echo "  Not locked"
      fi
      ;;

    nuke)
      echo "⚠️  This deletes auth and packages for ALL projects using Ralph."
      read -q "confirm?Are you sure? [y/N] " || { echo ""; return 1; }
      echo ""
      podman volume rm ralph-claude-config ralph-claude-npm 2>/dev/null || true
      echo "Nuked. Run 'ralph setup && ralph install && ralph login' to reconfigure."
      ;;

    *)
      echo "Unknown command: $cmd"
      echo "Run 'ralph help' for usage."
      return 1
      ;;
  esac
}

# Internal: run command in ralph container (for podman mode)
_ralph_container() {
  _ralph_container_with_env "" "$@"
}

# Internal: run command in ralph container with extra env var
_ralph_container_with_env() {
  local extra_env="$1"
  shift

  command -v podman >/dev/null 2>&1 || { echo "Podman not installed. Run: brew install podman"; return 1; }
  podman machine list 2>/dev/null | grep -q "Currently running" || { echo "Podman machine not running. Run: ralph setup"; return 1; }
  podman volume exists ralph-claude-config 2>/dev/null || { echo "Volumes not created. Run: ralph setup"; return 1; }

  # Check for required Claude config files (created by make claude)
  local missing=()
  [[ ! -d ~/.claude/skills ]] && missing+=(skills/)
  [[ ! -d ~/.claude/commands ]] && missing+=(commands/)
  [[ ! -f ~/.claude/settings.json ]] && missing+=(settings.json)
  [[ ! -f ~/.claude/CLAUDE.md ]] && missing+=(CLAUDE.md)
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing Claude config: ${missing[*]}"
    echo "Run: make claude (in macfair repo)"
    return 1
  fi

  local env_args=()
  [[ -n "$extra_env" ]] && env_args=(-e "$extra_env")

  local ralph_md_mount=()
  [[ -f ~/.claude/ralph.md ]] && ralph_md_mount=(-v ~/.claude/ralph.md:/home/node/.claude/ralph.md:ro)

  local tty_flags="-i"
  [[ -t 0 ]] && tty_flags="-it"

  podman run $tty_flags --rm \
    --user "$RALPH_UID:$RALPH_GID" \
    -v ralph-claude-config:/home/node/.claude \
    -v ralph-claude-npm:/home/node/.npm-global \
    -v ~/.gitconfig:/home/node/.gitconfig:ro \
    -v ~/.claude:/host-claude:ro \
    -v ~/.claude/skills:/home/node/.claude/skills:ro \
    -v ~/.claude/commands:/home/node/.claude/commands:ro \
    -v ~/.claude/settings.json:/home/node/.claude/settings.json:ro \
    -v ~/.claude/CLAUDE.md:/home/node/.claude/CLAUDE.md:ro \
    "${ralph_md_mount[@]}" \
    -v "$(pwd)":/work:Z \
    -w /work \
    -e HOME=/home/node \
    -e NPM_CONFIG_PREFIX=/home/node/.npm-global \
    -e PATH=/home/node/.npm-global/bin:/usr/local/bin:/usr/bin:/bin \
    "${env_args[@]}" \
    "$RALPH_IMAGE" \
    "$@"
}

# Completion
_ralph() {
  local commands="run tickets yolo status unlock setup install login shell nuke help"
  _arguments "1:command:($commands)"
}
compdef _ralph ralph 2>/dev/null
