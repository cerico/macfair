macfairloc=$(cat ~/.macfair/location 2>/dev/null || echo "$HOME/macfair")

changes_since_last () {
  cd $macfairloc
  PASSED_VERSION=$1
  VERSION=$(git log | grep chore | grep release | head -1 | awk -F " " '{print $2}')
  PREVIOUS_VERSION=$(git log | grep chore | grep release | head -2 | tail -1 | awk -F " " '{print $2}')
  [[ $1 ]] && COMPARED_VERSION=v$PASSED_VERSION || COMPARED_VERSION=$PREVIOUS_VERSION
  CHANGES=$(git log --pretty="- %s" $VERSION...$COMPARED_VERSION)
  [[ $VERSION != $COMPARED_VERSION ]] && printf "# 🌊 Release notes $(ColorCyan $VERSION)\n\n## Changes\n$CHANGES\n\n## Metadata\nThis version -------- $(ColorCyan $VERSION)\nPrevious version ---- $COMPARED_VERSION\nTotal commits -------$(echo "$CHANGES" | wc -l)\n"
  cd - > /dev/null
}

also_available_to_install () {
  local x=$(yq '.[].roles | map(select(.tags[]  == "info"))[].role' "$macfairloc/setup.yml")
  local list=""
  local message=""
  while IFS= read -r line; do
    local y=$(echo "$line" | tr -d '"')
    if ! grep -q "$y" ~/.macfair/version; then
      list="${list}mf $y\n"
      message="\nRun following to install uninstalled roles\n-------------"
    fi
  done <<< "$x"
  [[ "$message" ]] && echo "$message" && echo "$list"
}

macfair () {
  local v=$(npm --prefix "$macfairloc" pkg get version | tr -d '"')
  echo ""
  echo "Current Available Version: $(ColorCyan "$v")"
  echo -------------
  sort -k2r ~/.macfair/version
  echo ""
  if ! grep -qw -- "$v" ~/.macfair/version; then
    echo "Run following to update roles to latest version"
    echo -------------
    while read -r line; do
      local x=$(echo "$line" | awk -F ' ' '{print $2}')
      local y=$(echo "$line" | awk -F ':' '{print $1}')
      [[ "$x" != "$v" ]] && echo "mf $y"
    done < <(sort -k2r ~/.macfair/version)
  else
    echo "All installed roles up to date."
  fi
  also_available_to_install
  [[ $1 ]] && v=$(grep -w "$1" ~/.macfair/version | awk -F ': ' '{print $2}') || unset v
  changes_since_last "$v"
}

mf () {
  if [[ $1 = "-v" ]] ; then
    cat ~/.macfair/version
  else
    make -f $macfairloc/Makefile $1 -C $macfairloc
  fi
}
