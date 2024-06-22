typeset -A scaffolds
scaffolds=(
  [rails]=_rails
  [html]=_html
  [astro]=_astreact
  [solid]=_solid
  [angular]=_angular
  [vite]=_vite
  [tldr]=_list_scaffolds
	)

volz () { # scaffold application # ➜ volz rails busmap
  local option="${1:-tldr}"
  [[ ! $scaffolds[$1] ]] && option=tldr
  $scaffolds[$option] "${@:2}"
}

_vite () {
  if [ ! $1 ]
    then
    _list_scaffolds vite
    return
  fi
  npm create vite@latest $1 -- --template react-ts
  cd $1
  npm install
  _setupgit
}

_angular () {
  if [ ! $1 ]
    then
    _list_scaffolds angular
    return
  fi
  ng new $1 --style=scss --ssr=false
  cd $1
  _setupgit
}

_rails () {
  if [ ! $1 ]
    then
    _list_scaffolds rails
    return
  fi
  rails new "$1" --database=postgresql -j esbuild "${@:2}"
  cd "$1"
  bundle install
  yarn
  rails db:create
  rails db:migrate
  _setupgit
}

_list_scaffolds () {
  echo "Available scaffolds:"
  if [ $1 ]
    then
    echo "  volz $1 appname"
    return
  fi
  for key in "${(@k)scaffolds}"; do
    echo "  $key"
  done
}

_setupgit () {
  mkdir -p .github/workflows
  cp ~/.zsh/templates/github-actions/release.yml .github/workflows
  git init
  git add .
  git commit -m "feat: initialized repo"
}

_cssjs () {
  local file="${1:-index.html}"
  echo -e ".container {\n    background: currentColor;\n}" > styles.css
  echo -e "document.addEventListener('DOMContentLoaded', function() {\n    console.log('Document ready!');\n});" > script.js
  sed -i '' '/<\/head>/i\
<link rel="stylesheet" type="text/css" href="styles.css">
' $file
  sed -i '' '/<\/body>/i\
<script src="script.js"></script>
' $file
}

_html () {
  if [ ! $1 ]
    then
    _list_scaffolds html
    return
  fi
  mkdir $1 && cd $1
  cp ~/.zsh/templates/html index.html
  _cssjs
  _setupgit
}

_astreact () {
  if [ ! $1 ]
    then
    _list_scaffolds astro
    return
  fi
  yarn create astro "$1" --typescript strict --template minimal --git --install --skip-houston
  cd "$1"
  npx astro add react -y
  _setupgit
}

_solid () {
  if [ ! $1 ]
    then
    _list_scaffolds solid
    return
  fi
  yarn create solid --project-name $1 --solid-start
  cd $1
  yarn
  _setupgit
}
