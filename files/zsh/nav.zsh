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

cpr() { # Set terminal profile for directory # ➜ cpr coffee
  if [[ -z "$1" ]]; then
    local current="$ITERM_PROFILE"
    grep '"Name"' ~/Library/Application\ Support/iTerm2/DynamicProfiles/*.json(N) 2>/dev/null | \
      sed 's/.*"Name" *: *"\([^"]*\)".*/\1/' | \
      while read -r name; do
        [[ "$name" == "$current" ]] && echo -e "\e[32m${name}\e[0m" || echo "$name"
      done
    return
  fi
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

_format_repo_line() {
  local repo="$1" pad_width="${2:-60}"
  local display files branch commits branch_display icon files_display

  display="${repo/#$HOME/~}"

  # Non-git directories: just show path
  if [[ ! -d "$repo/.git" ]]; then
    local visible_len=${#display}
    local padding=$((pad_width - visible_len))
    (( padding < 1 )) && padding=1
    local pad=$(printf '%*s' "$padding" '')
    printf "%s%s%7s %7s\n" "$display" "$pad" "" ""
    return
  fi

  files=$(git -C "$repo" status --porcelain 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')
  branch=$(git -C "$repo" branch --show-current 2>/dev/null)
  [[ -z "$branch" ]] && branch="?"

  commits=""
  local default=$(git -C "$repo" rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [[ -z "$default" || "$default" == "HEAD" ]] && default=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  [[ -z "$default" ]] && default=$(git -C "$repo" branch -l main master 2>/dev/null | head -1 | tr -d '* ')
  [[ -z "$default" ]] && default="main"
  if [[ "$branch" != "$default" && "$branch" != "?" ]]; then
    commits=$(git -C "$repo" rev-list --count "${default}..HEAD" 2>/dev/null)
  fi

  # Truncate branch if over 18 chars
  branch_display="$branch"
  (( ${#branch_display} > 18 )) && branch_display="${branch_display:0:17}…"

  # Truncate path if needed (leave room for branch)
  local max_path=$((pad_width - 10 - ${#branch_display}))
  (( max_path < 20 )) && max_path=20
  if (( ${#display} > max_path )); then
    local reponame="${display##*/}"
    local prefix="${display%/*}"
    local avail=$((max_path - ${#reponame} - 2))
    (( avail < 3 )) && avail=3
    display="${prefix:0:$avail}…/${reponame}"
  fi

  # Determine status icon: ✗ dirty, ✓ clean with commits, space for clean main
  icon=" "
  if [[ "$files" != "0" ]]; then
    icon=$'\e[33m'"✗"$'\e[0m'
  elif [[ -n "$commits" && "$commits" != "0" ]]; then
    icon=$'\e[32m'"✓"$'\e[0m'
  fi

  # Display files as blank if 0
  files_display="$files"
  [[ "$files" == "0" ]] && files_display=""

  # Style: blue parens, red branch
  local visible_len=$((${#display} + ${#branch_display} + 5))  # " () X"
  local padding=$((pad_width - visible_len))
  (( padding < 1 )) && padding=1
  local pad=$(printf '%*s' "$padding" '')

  # Display commits as blank if 0
  local commits_display="$commits"
  [[ "$commits" == "0" ]] && commits_display=""

  printf "%s "$'\e[34m'"("$'\e[31m'"%s"$'\e[34m'")"$'\e[0m'" %s%s%7s %7s\n" \
    "$display" "$branch_display" "$icon" "$pad" "$commits_display" "$files_display"
}

dh() { # Directory history # ➜ dh
  [[ ! -f "$DIR_HISTORY_FILE" ]] && echo "No directory history yet" && return

  if [[ $1 =~ ^[0-9]+$ ]]; then
    local dir=$(sed -n "${1}p" "$DIR_HISTORY_FILE")
    [[ -z "$dir" ]] && echo "No entry $1" && return
    cd "$dir"
    return
  fi

  local count=20
  if [[ $1 == "-l" && -n "$2" ]]; then
    [[ ! "$2" =~ ^[0-9]+$ ]] && { echo "Error: -l expects a positive integer" >&2; return 1; }
    count="$2"
  fi

  printf "%60s %7s %7s\n" "" "commits" "changed"
  local i=0
  head -n "$count" "$DIR_HISTORY_FILE" | while read -r repo; do
    ((i++))
    printf "%2d. " "$i"
    _format_repo_line "$repo" 57
  done
}
