# Directory navigation and history

export MARKPATH=$HOME/.marks
export DIR_HISTORY_FILE="$HOME/.dir_history"

alias j=jump

# Directory changes

up() {
  cd ..
}

back() {
  cd -
}

cdrepo() {
  cd `upsearch .git`
}

mcd() {
  mkdir -p "$1"
  cd "$1"
}

# Override cd to set window title
cd() {
  builtin cd "$@" && {
    print -Pn "\e]2;$(basename "$PWD")\a"
  }
}

# Set initial window title when shell starts
if [[ -z "$_window_title_set" ]]; then
  print -Pn "\e]2;$(basename "$PWD")\a"
  _window_title_set=1
fi

# Marks system

jump() {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

mark() {
  mkdir -p "$MARKPATH"; ln -s "$PWD" "$MARKPATH/$1"
}

unmark() {
  rm -f "$MARKPATH/$1"
}

marks() {
  ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

unmarkall() {
  for mark in "$MARKPATH"/*; do
    [[ -L "$mark" ]] && rm -f "$mark"
  done
}

_completemarks() {
  reply=($(ls "$MARKPATH"))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

# Terminal profile per directory

cpr() { # Set terminal profile for directory # ➜ cpr dark
  echo -e "\033]50;SetProfile=$1\a"
  echo $1 > "$PWD/.terminal-profile"
}

# Directory change hook

chpwd() {
  _git_sync
  [[ -f .terminal-profile ]] && cpr "$(cat .terminal-profile)"
  _track_directory
}

# Directory history

_track_directory() {
  [[ ! -d ".git" ]] && return
  local current="$PWD"
  local temp=$(mktemp) || return
  echo "$current" > "$temp"
  [[ -f "$DIR_HISTORY_FILE" ]] && grep -v "^${current}$" "$DIR_HISTORY_FILE" >> "$temp"
  head -100 "$temp" > "${DIR_HISTORY_FILE}.new" && mv "${DIR_HISTORY_FILE}.new" "$DIR_HISTORY_FILE"
  rm -f "$temp"
}

dh() { # Directory history: list or cd # ➜ dh 3 (cd) | dh -l 5 (list 5)
  [[ ! -f "$DIR_HISTORY_FILE" ]] && echo "No directory history yet" && return
  if [[ $1 == "-l" ]]; then
    local count=${2:-20}
    head -n "$count" "$DIR_HISTORY_FILE" | sed "s|$HOME|~|" | nl -w2 -s'. '
  elif [[ $1 =~ ^[0-9]+$ ]]; then
    local dir=$(sed -n "${1}p" "$DIR_HISTORY_FILE")
    [[ -z "$dir" ]] && echo "No entry $1" && return
    cd "$dir"
  else
    head -n 20 "$DIR_HISTORY_FILE" | sed "s|$HOME|~|" | nl -w2 -s'. '
  fi
}
