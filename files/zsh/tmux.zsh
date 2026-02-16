# tmux utilities

_tmux_layout() {
  local session="$1" layout="${2:-dev}"
  case "$layout" in
    dev)
      tmux split-window -h -t "$session" -p 30
      tmux split-window -v -t "$session"
      tmux select-pane -t "$session:1.1"
      ;;
    half)
      tmux split-window -h -t "$session" -p 50
      tmux select-pane -t "$session:1.1"
      ;;
    single) ;;
  esac
}

tx() {
  local name="${${1:-${PWD##*/}}//[.:]/_}" layout="${2:-dev}"
  if tmux has-session -t "$name" 2>/dev/null; then
    tmux attach -t "$name"
    return
  fi
  tmux new-session -d -s "$name" -c "$PWD"
  _tmux_layout "$name" "$layout"
  tmux attach -t "$name"
}

tls() { tmux list-sessions 2>/dev/null || echo "No sessions"; }

tkill() {
  [[ -z "$1" ]] && { echo "Usage: tkill <session>"; return 1; }
  tmux kill-session -t "$1" 2>/dev/null && echo "Killed $1" || echo "No session: $1"
}
