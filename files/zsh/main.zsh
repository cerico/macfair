export MARKPATH=$HOME/.marks
alias sedi='sed -i "" -e'

functions () {
  if [[ $1 ]]
  then
    [ -f ~/.zsh/$1.zsh ] && f=$1 || f="_trialling"
    echo $(ColorCyan ${f:u})
    echo $(ColorCyan -------------)
    grep '^[[:alpha:]].*{' ~/.zsh/$f.zsh | tr -cd '[:alnum:]# ➜."_\n' | sort | awk -F"#" '{printf "\033[0;38m%-10s\t\033[1;36m%-54s\t\033[0;32m%s\n", $1, $2, $3}'
  else
  for i in $(ls ~/.zsh/*.zsh | grep -v trialling)
    do
      j=$(basename $i .zsh)
      echo $(ColorCyan ${j:u})
      echo $(ColorCyan -------------)
      grep '^[[:alpha:]].*{' ~/.zsh/$j.zsh | tr -cd '[:alnum:]# ➜"._\n' | sort | awk -F"#" '{printf "\033[0;38m%-10s\t\033[1;36m%-54s\t\033[0;32m%s\n", $1, $2, $3}'
      echo ""
    done
  fi
}

alphnum () {
	tr -cd '[:alnum:]\n'
}

trim () {
  awk '{$1=$1;print}'
}

aud () {
  yt-dlp -xiwc $1
}

help() {
  if [[ $# -eq 0 ]] ; then
    node $HOME/.zsh/help.js
    return
  fi
  node $HOME/.zsh/help.js $1
}

upsearch () { # Search for file traversing up directory tree
  slashes=${PWD//[^\/]/}
  directory="$PWD"
  for (( n=${#slashes}; n>0; --n ))
  do
    test -e "$directory/$1" && echo "$directory" && return "hello"
    directory="$directory/.."
  done
}

m () { # Execute nearest Makefile up directory tree
  mf=`upsearch Makefile`
  if [[ ${#mf} -gt 0 ]] ; then
    cd $mf
    make $1
  else
    echo No Makefile found. Nothing to do
  fi
}

viz () {
  [[ -n $1 ]] && a=$1.zsh || a=_trialling.zsh
  vi ~/.zsh/$a
}

cdrepo () {
	cd `upsearch .git`
}

todo () {
	if [ -f "TODO.md" ]
	then
		y=`date "+%d %B %Y"`
		sed -i "" -e "1s/.*/$y/" TODO.md
	else
		date "+%d %B %Y" > TODO.md
	fi
  vi TODO.md
}

isym () { # Make symbolic link in any order # ➜ isym cats dogs
	if [[ -f $1 ]]
	then
		ln -s $1 $2
	else
		ln -s $2 $1
	fi
}

back() {
  cd -
}

install() {
  if [ -f "package-lock.json" ]
    then
    echo "installing via npm"
    npm i
  elif  [ -f "yarn.lock" ]
    then
    echo "installing via yarn"
    yarn
  else
    echo "no yarn or npm found"
  fi
}

cleanup(){
  find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}

discogs() {
  y=`echo $1 | awk -F'/' '{print $5}'`
  mkdir -p ~/Downloads/discogs/$y
  cd ~/Downloads/discogs/$y
  youtube-dl -xiwc $1
}

sourcez () {
  source ~/.zshrc
}

ds () {
  du -sm * | sort -n
}

jump () {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

mark () {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

unmark () {
    rm -if "$MARKPATH/$1"
}
marks () {
    ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

unmarkall () {
  for i in `marks  | awk -F" " '{print $2}'`
  do
  unmark $i
  done
}

_completemarks () {
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

mcd () {
  mkdir -p "$1"
  cd "$1"
}

start () {
  [[ -n $1 ]] && port=$1 || port=9000
  ui_port=$((port + 1))
  [[ -f index.html ]] && type="--files" || type="--directory"
  browser-sync start --server $type "*.*" --port $port --ui-port $ui_port
}

awks () {
  echo awk -F\' \' \'{print \$2}\'
}

cpr () {
  echo -e "\033]50;SetProfile=$1\a"
}

vsc () { # list or switch vscode themes # ➜ vsc sunlight
  theme=~/.vscode/themes/$1.json
  if test -f "$theme"
  then
    mkdir -p .vscode
    cp $theme .vscode/settings.json
  else
    echo "Available themes"
    echo "----------------"
    ls -G ~/.vscode/themes/ | awk -F'.json' '{print $1}'
  fi
}

hist () {
  history | grep -i $1
}

geo () {
  curl -H 'User-Agent: keycdn-tools:https://google.com' 'https://tools.keycdn.com/geo.json?host='$1
}
city () { # find city of an ip address # ➜ city 23.5.4.1
  geo $1 | jq -r '.data.geo.city'
}
region () {
  geo $1 | jq -r '.data.geo.region_name'
}
isp () {
  geo $1 | jq -r '.data.geo.isp'
}

_format_dir_path () {
  echo $1 | awk '{sub(/\/[^\/]*$/, ""); print}' | awk -F'\\./' '{if ($2 == "") print "."; else print $2}'
}

_most_recent_in () {
  [[ $1 ]] && local term=$1 || local term=.
  [[ -f $term ]] && dir=$(dirname "$term") || dir=$term/..

  if [ $(uname) = 'Darwin' ]; then
    find $dir -type f -exec stat -f "%Sm" -t "%Y-%m-%d" {} + | sort -r | head -n 1
  else
    find $dir -type f -exec stat --format="%y" {} + | sort -r | head -n 1 | cut -d' ' -f1
  fi
}

recent () { # Find n most recent directories containing named file # ➜ recent 12 astro.config.mjs
  [[ $1 = [1-9]* ]] && num=$1 || num=10
  [[ $1 = [.[:alpha:]]* ]] && f=$1 || f='.git'
  [[ $2 = [1-9]* ]] && num=$2
  [[ $2 = [.[:alpha:]]* ]] && f=$2
  local tmpfile=$(mktemp)
  echo Finding $(ColorCyan $num) most recent directories containing $(ColorGreen $f)
  echo ---
  find . -maxdepth 5  -not -path '*node_modules*' -name $f -print 2>/dev/null | while read -r dir; do
    local mod_date=$(_most_recent_in $dir)
    local clean_dir=$(_format_dir_path $dir)
    echo "$mod_date $clean_dir" >> "$tmpfile"
  done
  sort -r "$tmpfile" | head -n $num
  echo ""
  echo "$(ColorCyan $(wc -l < "$tmpfile")) total"
  rm "$tmpfile"
}

gits () {
  [[ $1 ]] && recent $1 .git || recent 10 .git
}

makefiles () {
  [[ $1 ]] && recent $1 Makefile || recent 10 Makefile
}

astros () {
  [[ $1 ]] && recent $1 astro.config.mjs || recent 10 astro.config.mjs
}

readmes () {
  [[ -n $1 ]] && recent $1 README.md || recent 10 README.md
}

apps () {
  if [[ $1 = "cron" ]]
    then
    cd ~
    date > .apps
    echo "----------------" >> .apps
    echo Astro: `astros | tail -n 1` >> .apps
    echo Git: `gits | tail -n 1` >> .apps
    echo Makefile: `makefiles | tail -n 1` >> .apps
    echo Supabase: `supas | tail -n 1` >> .apps
    cd - > /dev/null
  fi
  cat ~/.apps
}

killport () { # Kill process running on port # ➜ killport 2960
  [ ! $1 ] && return
  process=$(lsof -i :$1 | grep LISTEN | awk -F' ' '{print $2}')
  if [[ $process ]]
    then
    echo "killing process $process on $1"
    kill -9 $process
    return
  fi
  echo "nothing running on $1"
}

addmake () {
  [[ -f Makefile ]] && return
  echo "tldr:" > Makefile
  echo "\t@echo Available commands" >> Makefile
	echo "\t@echo ------------------" >> Makefile
	echo "\t@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'" >> Makefile
}

addtomake () { # Add target to makefile # ➜ addtomake start
  [[ -n $1 ]] && target=$1 || read "target?Enter target: "
  if [[ -e $target ]]
    then
    echo "Error: A file or directory named '$target' already exists." && return 1
  fi
  if grep -q "^$target:" Makefile
    then
    echo "Error: Target '$target' already exists in the Makefile." && return 1
  fi
  read "recipe?Enter recipe: "
  echo "$target:\n\t$recipe" >> Makefile
}

mi () { # List all Makefile targets or get info in target # ➜ mi start
  if [[ ! -f Makefile ]]
    then
    echo "Error: No Makefile found in the current directory. Add with ➜ addmake" && return 1
  fi
  if [[ -n $1 ]]
    then
    local command=$1
    local output=$(awk -v cmd="$command" '$1 == cmd ":" {p=1} p; /^\t/{p=0}' Makefile)
    [[ -n "$output" ]] && echo "$output" || echo "Target not found. Add with ➜ addtomake $command"
  else
    echo "Available commands:"
    echo "-------------------"
    grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
  fi
}

scripts () {
  [[ -f package.json ]] && jq .scripts package.json || echo "package.json not round. To create run ➜ npm init"
}
