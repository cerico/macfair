export MARKPATH=$HOME/.marks
alias sedi='sed -i "" -e'

command_not_found_handler () {
  if [ -f Makefile ] && grep -q "^$1:" Makefile; then
    local rule=$(echo $1 | awk -F ":" '{print $1}')
    make $rule
    return 0
  fi
  if [[ -f package.json ]] && jq .scripts package.json | grep -q "\"$1\":"; then
    npm run $1
    return 0
  fi
  echo "zsh: command not found: $1"
  return 127  # Return an exit status indicating command not found
}

functions () {
  if [[ $1 ]] && [ -f ~/.zsh/$1.zsh ]
  then
    # [ -f ~/.zsh/$1.zsh ] && local f=$1
    echo $(ColorCyan ${1:u})
    echo $(ColorCyan -------------)
    grep '^[[:alpha:]].*{' ~/.zsh/$1.zsh | tr -cd '[:alnum:]# ➜."_\n' | sort | awk -F"#" '{printf "\033[0;38m%-10s\t\033[1;36m%-54s\t\033[0;32m%s\n", $1, $2, $3}'
   elif grep "^$1.*{" ~/.zsh/*.zsh > /dev/null; then
     grep "^$1.*{" ~/.zsh/*.zsh | awk -F":" '{print $2}' | tr -cd '[:alnum:]# ➜."_\n' | sort | awk -F"#" '{printf "\033[0;38m%-10s\t\033[1;36m%-54s\t\033[0;32m%s\n", $1, $2, $3}'
    echo ""
    whichz $1
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
  yt-dlp -xiwc -o "%(title)s.%(ext)s" "$1"
}

vid () {
  yt-dlp -o "%(title)s.%(ext)s" "$1"
}

help() {
  if [[ $# -eq 0 ]] ; then
    node $HOME/.zsh/help.js
    return
  fi
  node $HOME/.zsh/help.js $1
}

killp () {
  [[ ! $1 ]] && return
  local p=$(lsof -i :$1 | grep LISTEN | awk -F' ' '{print $2}')
  [[ ! $p ]] && return
  echo killing $p on $1
  kill -9 $p
}

large () { # find files over certain size in Mb # ➜ large 600
  s=${1:-500}M
  echo "searching for files over $s in size"
  sudo find . -type f -size +$s -exec du -h {} \;
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

viz () { # edit zsh function # ➜ viz addtomake
  [[ ! $1 ]] && vi ~/.zsh/_trialling.zsh && return
  local result=$(grep -n "^$1[[:space:]]*()[[:space:]]*{" ~/.zsh/*.zsh)
  local func=$(echo "$result" | awk -F':' '{print $1}')
  local line=$(echo "$result" | awk -F':' '{print $2}')
  if [[ $func ]]; then
    echo "$(ColorGreen $1) found in $(ColorCyan $func)"
    vi +$line $func
    return
  fi
  local file=$(ls ~/.zsh/$1.zsh)
  [[ $file ]] && vi ~/.zsh/$1.zsh || vi ~/.zsh/_trialling.zsh
}

whichz () {
  [[ ! $1 ]] && return
  local result=$(grep -n "^$1.*{" ~/.zsh/*.zsh)
  local func=$(echo "$result" | awk -F':' '{print $1}')
  [[ ! $func ]] && return
  which $1
  [[ $? != 0 ]] && return
  echo ""
  echo "$(ColorGreen $1) found in $(ColorCyan $func)"
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
  if [[ -f Makefile ]] && grep -q '^start:' Makefile;
    then
    make start
    return
  fi
  local port=${1:-9000}
  local ui_port=$((port + 1))
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
  local theme_file="$1"
  local theme=~/.vscode/themes/$theme_file.json
  local settings=~/Library/Application\ Support/Code/User/settings.json
  if test -f "$theme"
  then
    mkdir -p .vscode
    sed '$d' "$settings" > .vscode/settings.json
    tail -n +2 "$theme" >> .vscode/settings.json
    echo "Settings updated with $theme_file theme and saved to .vscode/settings.json"
  else
    echo "Available themes:"
    echo "-----------------"
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
  [[ $1 =~ ^[[:digit:]]+$ ]] && num=$1 || num=10
  [[ $1 =~ [^[:digit:]]+ ]] && f=$1 || f='.git'
  [[ $2 =~ ^[[:digit:]]+$ ]] && num=$2
  [[ $2 =~ [^[:digit:]]+ ]] && f=$2
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

checkport () {
  [ ! $1 ] && return
  lsof -i :$1
}

addmake () {
  if [[ ! -f Makefile ]];
    then
    cp ~/.templates/Makefile .
  fi
  if [[ ! $1 ]];
    then
    make
    return
  fi
  local target=$1 || read "target?Enter target: "
  if [[ -e $target ]]
    then
    echo "Error: A file or directory named '$target' already exists." && return 1
  fi
  if grep -q "^$target:" Makefile
    then
    echo "Error: Target '$target' already exists in the Makefile." && return 1
  fi
  [[ -n $2 ]] && local recipe=$2 || read "recipe?Enter recipe: "
  echo "$target:\n\t$recipe" >> Makefile
  echo "\nSuccess: Target '$target' added to Makefile\n"
  make
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

_delete_temp_page () {
    echo "Stopping web server..."
    echo "Removing $1"
    [ -f $1 ] && rm $1

    trap - INT
}

pics () {
  IFS=$'\n'
  local template="$HOME/.zsh/templates/html"
  local page="000.html"
  local list=(**/*.[jp]*g)
  trap '_delete_temp_page $page' INT
  sed '$d' $template | sed '$d' > $page
  for i in "${list[@]}"
    do
    echo "<img src=\"./$i\">"  >> $page
    done
  tail -n 2 $template >> $page
   _webserver $page
}

html () {
  IFS=$'\n'
  local template="$HOME/.zsh/templates/html"
  local page="000.html"
  local list=(${1:+**/}*.html(N))
  trap '_delete_temp_page $page' INT
  sed '$d' $template | sed '$d' > $page
  for i in "${list[@]}"
    do
    url=$(echo "$i" | sed 's/ /%20/g')
    echo "<div><a href=\"./$url\">$i</a></div>" >> $page
    done
  tail -n 2 $template >> $page
  _webserver $page
}

_webserver () {
   browser-sync start --server --startPath "$page" --port 6375 --browser "safari"
}

env () {
  if [ $1 ] && [ -f src ]
    then
    echo "Required in env...\n"
    grep -r 'import\.meta\.env\.' src | grep -o '\.[^.]*$' | awk -F'[^_a-zA-Z]+' '{print $2"="}'
    grep -r 'process\.env\.' src | grep -o '\.[^.]*$' | awk -F'[^_a-zA-Z]+' '{print $2"="}'
  else
    [ -f .env ] && cat .env || touch .env && cat .env
  fi
}

venv () {
  vi .env
}
