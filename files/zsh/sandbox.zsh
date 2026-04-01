SANDBOX_VM="claude-sandbox"
SANDBOX_TEMPLATE="$HOME/macfair/files/lima/claude.yaml"

_sandbox_running() {
  limactl list --json 2>/dev/null | jq -e --arg name "$SANDBOX_VM" 'select(.name == $name and .status == "Running")' &>/dev/null
}

_sandbox_exists() {
  limactl list --json 2>/dev/null | jq -e --arg name "$SANDBOX_VM" 'select(.name == $name)' &>/dev/null
}

_sandbox_copy_gitignored() {
  local main_root
  main_root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/\.git$||')
  [[ -z "$main_root" || "$main_root" == "$PWD" ]] && return

  for item in .env .env.local .claude; do
    [[ -e "$PWD/$item" && ! -L "$PWD/$item" ]] && continue
    [[ -L "$PWD/$item" ]] && rm -f "$PWD/$item"
    [[ -e "$main_root/$item" ]] && cp -a "$main_root/$item" "$PWD/$item" && echo "Copied $item from main repo"
  done
}

_sandbox_ensure() {
  [[ "$PWD" != "$HOME/worktrees/"* ]] && { echo "sandbox requires a worktree — use wt first"; return 1; }
  _sandbox_copy_gitignored
  if ! _sandbox_exists; then
    echo "Creating sandbox VM (first time, takes a few minutes)..."
    limactl create --name "$SANDBOX_VM" \
      --mount "$HOME/worktrees:w" \
      --mount "$HOME/.claude:r" \
      "$SANDBOX_TEMPLATE" || return 1
  fi
  if ! _sandbox_running; then
    echo "Starting sandbox VM..."
    limactl start "$SANDBOX_VM" || return 1
  fi
}

sandbox() {
  local cmd="${1:-claude}"
  shift 2>/dev/null

  case "$cmd" in
    claude)
      _sandbox_ensure || return 1
      limactl shell --workdir "$(pwd)" "$SANDBOX_VM" claude --dangerously-skip-permissions "$@"
      ;;
    shell)
      _sandbox_ensure || return 1
      limactl shell --workdir "$(pwd)" "$SANDBOX_VM" "$@"
      ;;
    start)
      _sandbox_ensure
      ;;
    stop)
      _sandbox_running && limactl stop "$SANDBOX_VM" || echo "Not running"
      ;;
    status)
      limactl list "$SANDBOX_VM" 2>/dev/null || echo "No sandbox VM"
      ;;
    destroy)
      if limactl delete --force "$SANDBOX_VM" 2>/dev/null; then
        echo "Sandbox destroyed"
      else
        echo "No sandbox VM to destroy" >&2
        return 1
      fi
      ;;
    help)
      cat <<'EOF'
Usage: sandbox [command]

Commands:
  claude     Run Claude with full permissions in sandbox (default)
  shell      Drop into sandbox shell
  start      Start sandbox VM without running anything
  stop       Stop sandbox VM
  status     Show sandbox VM status
  destroy    Delete sandbox VM entirely
EOF
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      return 1
      ;;
  esac
}

_sandbox() {
  local commands="claude shell start stop status destroy help"
  _arguments "1:command:($commands)"
}
compdef _sandbox sandbox 2>/dev/null
