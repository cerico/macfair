# Directory navigation and history

export MARKPATH=$HOME/.marks
export DIR_HISTORY_FILE="$HOME/.dir_history"
MARK_LIMIT=20

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

tcd() {
  cd "$HOME/${1:-.}"
}

# Marks system

jump() {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

mark() {
  [[ -z "$1" ]] && echo "Usage: mark <name>" && return 1
  mkdir -p "$MARKPATH"
  local files=($MARKPATH/*(N)); local count=$#files
  (( count >= MARK_LIMIT )) && echo "$MARK_LIMIT marks max. Remove one first: marks" && return 1
  ln -s "$PWD" "$MARKPATH/$1"
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

# Move wrapper: update marks when directories move

mv() {
  local _args=()
  for arg in "$@"; do
    [[ "$arg" != -* ]] && _args+=("$arg")
  done

  # Resolve source paths before the move (while they still exist)
  local -a _srcs_abs=()
  if (( ${#_args} >= 2 )) && [[ -d "$MARKPATH" ]]; then
    for src in "${_args[@]:0:$((${#_args} - 1))}"; do
      [[ "$src" != /* ]] && src="$PWD/$src"
      _srcs_abs+=("${src:A}")
    done
  fi

  # Use git mv for tracked files, plain mv otherwise
  if [[ "${_args[1]}" != -* ]] && git rev-parse --is-inside-work-tree &>/dev/null \
    && { git ls-files --error-unmatch "${_args[1]}" &>/dev/null || { [[ -d "${_args[1]}" ]] && git ls-files -- "${_args[1]}/" | read -r; }; }; then
    git mv "$@" 2>/dev/null || command mv "$@" || return $?
  else
    command mv "$@" || return $?
  fi

  (( ${#_srcs_abs} == 0 )) && return
  local _dst="${_args[-1]}"
  [[ "$_dst" != /* ]] && _dst="$PWD/$_dst"

  for mark in "$MARKPATH"/*(N); do
    [[ ! -L "$mark" ]] && continue
    local target=$(readlink "$mark")
    for _src in "${_srcs_abs[@]}"; do
      [[ "$target" != "$_src" && "$target" != "$_src"/* ]] && continue
      local new_target
      [[ -d "$_dst" ]] && new_target="${_dst}/${_src:t}${target#$_src}" || new_target="${_dst}${target#$_src}"
      ln -sf "$new_target" "$mark"
      echo "mark '${mark:t}' → ${new_target/#$HOME/\~}"
      break
    done
  done
}

# Terminal color themes (WezTerm OSC sequences)

typeset -gA _wez_themes
_wez_themes=(
  coffee   "#23262e #ffca28 #ee5d43 #23262e #f0266f #8fd46d #ffe66d #0321d7 #ee5d43 #03d6b8 #c74ded #292e38 #f92672 #8fd46d #ffe66d #03d6b8 #ee5d43 #03d6b8 #c74ded"
  daegu    "#1d1f28 #fdfdfd #c574dd #282a36 #f37f97 #5adecd #f2a272 #8897f4 #c574dd #79e6f3 #fdfdfd #414458 #ff4971 #18e3c8 #ff8037 #556fff #b043d1 #3fdcee #bebec1"
  liege    "#334789 #ffffff #fad000 #000000 #d90429 #3ad900 #ffe700 #6943ff #ff2c70 #00c5c7 #c7c7c7 #686868 #f92a1c #43d426 #f1d000 #6871ff #ff77ff #79e8fb #ffffff"
  sea      "#09141b #deb88d #fca02f #17384c #d15123 #027c9b #fca02f #1e4950 #68d4f1 #50a3b5 #deb88d #434b53 #d48678 #628d98 #fdd39f #1bbcdd #bbe3ee #87acb4 #fee4ce"
  kawa     "#b70d4b #ffffff #fad000 #000000 #d90429 #3ad900 #ffe700 #6943ff #ff2c70 #00c5c7 #c7c7c7 #686868 #f92a1c #43d426 #f1d000 #6871ff #ff77ff #79e8fb #ffffff"
  asda     "#2f2d76 #ffffff #fad000 #000000 #ff757d #3dd605 #ffe700 #6943ff #f02d6c #00c5c7 #c7c7c7 #686868 #ff757d #75ff8a #f1d000 #6871ff #ff77ff #75ffe9 #ffffff"
  forest   "#161e16 #d6e7d6 #7cbd7c #223122 #d45f5f #7cbd7c #caca6e #6e95b1 #b195b1 #6eb195 #d6e7d6 #293b29 #fe7272 #95e383 #f2f284 #6e95b1 #b195b1 #6eb195 #ffffff"
  sunset   "#291217 #ffdead #ff9966 #492028 #ff6666 #f4d03f #ffc107 #b080a7 #ff94b1 #f2be69 #ffdead #572630 #ff7a7a #fffa4b #ffe808 #d39ac8 #ffb1d4 #f2be69 #ffffd0"
  midnight "#0a0a14 #c0d1e9 #6699ff #141428 #dc322f #27ae60 #f3c227 #2877f0 #9370db #3498db #c0d1e9 #181830 #ff3c38 #2ed173 #ffe92e #308fff #b086ff #3498db #e7fbff"
  cherry   "#1e0f14 #ffe0f0 #f080a8 #3c1e28 #db6193 #add69e #f5deb3 #ad81a8 #db7093 #8fbcbb #ffe0f0 #482430 #ff86b0 #d0ffbe #ffffd7 #d09bca #ff86b0 #8fbcbb #ffffff"
  private  "#b70d4b #ffffff #fad000 #000000 #d90429 #3ad900 #ffe700 #6943ff #ff2c70 #00c5c7 #c7c7c7 #686868 #f92a1c #43d426 #f1d000 #6871ff #ff77ff #79e8fb #ffffff"
)

_wez_apply_theme() {
  local name="$1"
  local colors=(${=_wez_themes[$name]})
  [[ ${#colors} -ne 19 ]] && return 1

  local bg="${colors[1]}" fg="${colors[2]}" cursor="${colors[3]}"

  printf '\033]11;%s\a' "$bg"
  printf '\033]10;%s\a' "$fg"
  printf '\033]12;%s\a' "$cursor"

  local i
  for i in {0..15}; do
    printf '\033]4;%d;%s\a' "$i" "${colors[$((i + 4))]}"
  done

  export __WEZTERM_THEME="$name"
}

cpr() { # Set terminal color theme # ➜ cpr coffee
  if [[ -z "$1" ]]; then
    local name
    for name in ${(ko)_wez_themes}; do
      [[ "$name" == "$__WEZTERM_THEME" ]] && echo -e "\e[32m${name}\e[0m" || echo "$name"
    done
    return
  fi
  _wez_apply_theme "$1" && echo "$1" > "$PWD/.terminal-profile"
  if [[ "$1" == "private" ]]; then
    _wez_private=1
  elif (( _wez_private )); then
    _wez_private=0
  fi
}

# Directory change hook

chpwd() {
  _git_sync
  local profile
  if [[ -f .terminal-profile ]]; then
    profile=$(cat .terminal-profile)
    if [[ "$profile" == "private" ]]; then
      _wez_private=1
    elif (( _wez_private )); then
      _wez_private=0
      _wez_apply_theme "$profile"
    else
      _wez_apply_theme "$profile"
    fi
  fi
  if (( _wez_private )); then
    _wez_apply_theme private
  else
    _track_directory
  fi
}

# Directory history

_track_directory() {
  local current="$PWD"
  [[ "$current" == "$HOME" ]] && return
  local temp=$(mktemp) || return
  echo "$current" > "$temp"
  [[ -f "$DIR_HISTORY_FILE" ]] && grep -v "^${current}$" "$DIR_HISTORY_FILE" >> "$temp"
  head -100 "$temp" > "${DIR_HISTORY_FILE}.new" && command mv "${DIR_HISTORY_FILE}.new" "$DIR_HISTORY_FILE"
  rm -f "$temp"
}

_format_repo_line() {
  local repo="$1" pad_width="${2:-60}"
  local display files branch commits branch_display icon files_display

  display="${repo/#$HOME/~}"

  # Prefix: ◆ for Makefile projects, space otherwise
  local prefix=" "
  [[ -f "$repo/Makefile" ]] && prefix=$'\e[36m'"◆"$'\e[0m'

  # Non-git directories
  if [[ ! -d "$repo/.git" ]]; then
    local visible_len=$((${#display} + 2))  # prefix + space
    local padding=$((pad_width - visible_len))
    (( padding < 1 )) && padding=1
    local pad=$(printf '%*s' "$padding" '')
    printf "%s %s%s%7s %7s\n" "$prefix" "$display" "$pad" "" ""
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
  local visible_len=$((${#display} + ${#branch_display} + 7))  # "P path (branch) X"
  local padding=$((pad_width - visible_len))
  (( padding < 1 )) && padding=1
  local pad=$(printf '%*s' "$padding" '')

  # Display commits as blank if 0
  local commits_display="$commits"
  [[ "$commits" == "0" ]] && commits_display=""

  printf "%s %s "$'\e[34m'"("$'\e[31m'"%s"$'\e[34m'")"$'\e[0m'" %s%s%7s %7s\n" \
    "$prefix" "$display" "$branch_display" "$icon" "$pad" "$commits_display" "$files_display"
}

dh() { # Directory history # ➜ dh
  [[ ! -f "$DIR_HISTORY_FILE" ]] && echo "No directory history yet" && return

  if [[ $1 == "-d" || $1 == "delete" ]]; then
    shift
    [[ $# -eq 0 ]] && { echo "Usage: dh -d <number> [number...]" >&2; return 1; }
    local -A seen=()
    local lines_to_delete=()
    for n in "$@"; do
      [[ ! "$n" =~ ^[1-9][0-9]*$ ]] && { echo "Invalid line number: $n" >&2; return 1; }
      (( seen[$n] )) && continue
      seen[$n]=1
      lines_to_delete+=("$n")
    done
    local sorted=($(printf '%s\n' "${lines_to_delete[@]}" | sort -rn))
    local tmp="${DIR_HISTORY_FILE}.tmp"
    cp "$DIR_HISTORY_FILE" "$tmp"
    for n in "${sorted[@]}"; do
      sed -i '' "${n}d" "$tmp" || { rm -f "$tmp"; echo "Failed to delete line $n" >&2; return 1; }
    done
    mv "$tmp" "$DIR_HISTORY_FILE"
    echo "Removed ${#sorted[@]} entries"
    return
  fi

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

  printf "%62s %7s %7s\n" "" "commits" "changed"
  local i=0
  head -n "$count" "$DIR_HISTORY_FILE" | while read -r repo; do
    ((i++))
    printf "%2d. " "$i"
    _format_repo_line "$repo" 57
  done
}

# Apply theme on shell startup
_wez_private=0
if [[ -f .terminal-profile ]]; then
  _startup_profile=$(cat .terminal-profile)
  [[ "$_startup_profile" == "private" ]] && _wez_private=1
  _wez_apply_theme "$_startup_profile"
else
  _wez_apply_theme coffee
fi
