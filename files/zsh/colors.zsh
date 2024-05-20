green='\e[32m'
blue='\e[34m'
cyan='\e[36m'
clear='\e[0m'

ColorGreen(){
  echo -ne $green$1$clear
}
ColorBlue(){
  echo -ne $blue$1$clear
}

ColorCyan(){
  echo -ne $cyan$1$clear
}

peacock () {
    declare -A colors=(
    [yellow]='#f6ef32'
    [white]='#faf0d4'
    [green]='#42b883'
    [pink]='#FF757D'
    [red]='#e3664a'
  )

  local color="${colors[$1]}"
  if [ ! $color ];
    then
    echo "available colors"
    for key in "${(k)colors[@]}"; do
      echo "$key"
    done
    return
  fi

  if [ ! $1 ]
    then
    echo "please provide a color"
    return
  fi
  if [ ! -f .vscode/settings.json ]
    then
    mkdir -p .vscode
    cp ~/Library/Application\ Support/Code/User/settings.json .vscode/settings.json
  else
    cp .vscode/settings.json .vscode/origsettings.json
  fi

  echo "changing peacock color to $color"
  local replace=$(grep  "peacock.color" .vscode/settings.json | awk -F"\"" '{print $4}')
  if [ $replace ]
    then
    sed -i "" -e s/$replace/$color/g .vscode/settings.json
  else
     sed -i "" -e '2i\
  "peacock.color": "#gggggg",' .vscode/settings.json
    sed -i "" -e s/#gggggg/$color/g .vscode/settings.json
  fi
  code .
}
