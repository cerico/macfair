# Timezone switching based on day of week
autotz() {
  local current_day=$(/bin/date +%u)  # 1=Monday, 7=Sunday
  local current_tz=$(sudo /usr/sbin/systemsetup -gettimezone 2>/dev/null | awk '{print $3}')

  # Weekend: Saturday (6) and Sunday (7) = Europe/Sarajevo
  # Weekdays: Monday-Friday (1-5) = Europe/London
  if [[ $current_day -eq 6 || $current_day -eq 7 ]]; then
    local target_tz="Europe/Sarajevo"
  else
    local target_tz="Europe/London"
  fi

  # Only change if different from current
  if [[ "$current_tz" != "$target_tz" ]]; then
    echo "Switching timezone from $current_tz to $target_tz (day $current_day)"
    sudo /usr/sbin/systemsetup -settimezone "$target_tz" 2>&1 | grep -v "### Error:-99"
  fi
}

# Manual timezone switching function
settz() {
  case "$1" in
    "sarajevo"|"weekend"|"bih")
      sudo /usr/sbin/systemsetup -settimezone "Europe/Sarajevo" 2>&1 | grep -v "### Error:-99"
      echo "Timezone set to Europe/Sarajevo"
      ;;
    "london"|"weekday"|"uk")
      sudo /usr/sbin/systemsetup -settimezone "Europe/London" 2>&1 | grep -v "### Error:-99"
      echo "Timezone set to Europe/London"
      ;;
    *)
      echo "Usage: settz [sarajevo|london]"
      echo "Current timezone: $(sudo /usr/sbin/systemsetup -gettimezone 2>/dev/null | awk '{print $3}')"
      ;;
  esac
}
