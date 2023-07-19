supas () { # List supabase applications
  num=10
  f=".env"
  arrVar=()
  echo Finding $(ColorCyan $num) most recent directories containing $(ColorGreen $f) with $(ColorGreen SUPABASE_PROJECT_NAME)
  echo ---
  for i in `find . -name $f | grep -v node_modules | awk -F "/$f" '{print $1}'`
  do
  b=$(date -r $(ls -t $i/.* | head -n 1 | sed s/://g) "+%Y-%m-%d")
  grep SUPABASE $i/.env > /dev/null && arrVar+=($b" "$(ColorGreen ${i#./})" $(grep SUPABASE_PROJECT_NAME $i/.env |awk -F "=" '{print $2}')")
  done
  array=($arrVar); printf '%s\n' "${(o)array[@]}" | sort -r | head -n $num
  echo ""
  echo $(ColorCyan ${#arrVar[@]}) total
}

supa () { # Populate env file with named supabase credentials # ➜ supa plock285
  supas=`grep SUPABASE_PROJECT_NAME ~/.zsh/tokens |awk -F "=" '{print $2}'`
  if [[ $1 ]] && [[ ${supas[*]} =~ (^|[[:space:]])$1($|[[:space:]]) ]]
    then
    echo "Populating env file with...\n"
    $1 >> .env
    cat .env
  else
    echo "Available supabases"
    echo $(ColorCyan $supas)
    echo "warning: this will populate your .env!"
  fi
}
