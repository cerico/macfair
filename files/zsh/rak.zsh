rak () {
	if [[ $# -eq 0 ]]
	then
		echo "Switching to space 1..."
		sw 1
		echo "Creating rak windows in space 1..."
		rak coffee
		rak liege
		rak daegu
		rak celje
		osascript -e "
		tell application \"Finder\"
			set screenBounds to bounds of window of desktop
		end tell
		tell application \"iTerm2\"
			set windowList to every window
			set windowCount to count of windowList
			if windowCount > 6 then set windowCount to 6
			if windowCount > 0 then
				set screenWidth to item 3 of screenBounds
				set screenHeight to item 4 of screenBounds
				set menuBarHeight to 24
				set titleBarHeight to 28
				set horizontalGap to 8
				set availableHeight to screenHeight - menuBarHeight
				set totalGapWidth to horizontalGap * 2
				set windowWidth to (screenWidth - totalGapWidth) / 3
				set windowHeight to (availableHeight - titleBarHeight) / 2
				repeat with i from 1 to windowCount
					set col to ((i - 1) mod 3)
					set row to (i - 1) div 3
					set x1 to (col * windowWidth) + (col * horizontalGap)
					set y1 to menuBarHeight + (row * (windowHeight + titleBarHeight))
					set x2 to x1 + windowWidth
					set y2 to y1 + windowHeight
					set bounds of window i to {x1, y1, x2, y2}
				end repeat
			end if
		end tell"
		return
	fi
	if [[ "$1" == "-a" ]]
	then
		echo "Switching to space 1..."
		sw 1
		echo "Creating all rak windows in space 1..."
		rak coffee
		rak liege
		rak daegu
		rak celje
		for dir in "$HOME/rak"/*
		do
			if [[ -d "$dir" ]]
			then
				local dirname=$(basename "$dir")
				case "$dirname" in
					("01-coffee"|"02-daegu"|"03-celje"|"04-liege")  ;;
					(*) rak "$dirname" ;;
				esac
			fi
		done
		osascript -e "
		tell application \"Finder\"
			set screenBounds to bounds of window of desktop
		end tell
		tell application \"iTerm2\"
			set windowList to every window
			set windowCount to count of windowList
			if windowCount > 6 then set windowCount to 6
			if windowCount > 0 then
				set screenWidth to item 3 of screenBounds
				set screenHeight to item 4 of screenBounds
				set menuBarHeight to 24
				set titleBarHeight to 28
				set horizontalGap to 8
				set availableHeight to screenHeight - menuBarHeight
				set totalGapWidth to horizontalGap * 2
				set windowWidth to (screenWidth - totalGapWidth) / 3
				set windowHeight to (availableHeight - titleBarHeight) / 2
				repeat with i from 1 to windowCount
					set col to ((i - 1) mod 3)
					set row to (i - 1) div 3
					set x1 to (col * windowWidth) + (col * horizontalGap)
					set y1 to menuBarHeight + (row * (windowHeight + titleBarHeight))
					set x2 to x1 + windowWidth
					set y2 to y1 + windowHeight
					set bounds of window i to {x1, y1, x2, y2}
				end repeat
			end if
		end tell"
		return
	fi
	local name="$1"
	local marker_file="/tmp/iterm_window_$name"
	local default_dir
	case "$name" in
		("coffee") default_dir="$HOME/rak/01-coffee"  ;;
		("liege") default_dir="$HOME/rak/04-liege"  ;;
		("daegu") default_dir="$HOME/rak/02-daegu"  ;;
		("celje") default_dir="$HOME/rak/03-celje"  ;;
		(*) default_dir="$HOME/rak/$name"  ;;
	esac
	if [[ -f "$marker_file" ]]
	then
		local window_id=$(cat "$marker_file")
		if osascript -e "tell application \"iTerm\" to select (first window whose id is $window_id)" 2> /dev/null
		then
			echo "Switched to existing $name window"
			return
		else
			rm "$marker_file"
		fi
	fi
	echo "Creating new $name window in $default_dir"
	local new_window_id=$(osascript -e "
      tell application \"iTerm\"
          create window with default profile
          tell current session of current window
              write text \"cd '$default_dir' && clear\"
          end tell
          tell current session of current window
              write text \"title '$name' && clear\"
          end tell
          return id of current window
      end tell")
	echo "$new_window_id" > "$marker_file"
}

hum () { # rak function that switches to space 2 first
	# First switch to space 2 using enhanced sw function
	echo "Switching to space 2..."
	sw 2
	echo "Creating hum windows in space 2..."
	
	if [[ $# -eq 0 ]]
	then
		hum ciglane
		hum tuzla
		hum strasbourg
		hum karlsruhe
		osascript -e "
		tell application \"Finder\"
			set screenBounds to bounds of window of desktop
		end tell
		tell application \"iTerm2\"
			set windowList to every window
			set windowCount to count of windowList
			if windowCount > 6 then set windowCount to 6
			if windowCount > 0 then
				set screenWidth to item 3 of screenBounds
				set screenHeight to item 4 of screenBounds
				set menuBarHeight to 24
				set titleBarHeight to 28
				set horizontalGap to 8
				set availableHeight to screenHeight - menuBarHeight
				set totalGapWidth to horizontalGap * 2
				set windowWidth to (screenWidth - totalGapWidth) / 3
				set windowHeight to (availableHeight - titleBarHeight) / 2
				repeat with i from 1 to windowCount
					set col to ((i - 1) mod 3)
					set row to (i - 1) div 3
					set x1 to (col * windowWidth) + (col * horizontalGap)
					set y1 to menuBarHeight + (row * (windowHeight + titleBarHeight))
					set x2 to x1 + windowWidth
					set y2 to y1 + windowHeight
					set bounds of window i to {x1, y1, x2, y2}
				end repeat
			end if
		end tell"
		return
	fi
	local name="$1"
	local marker_file="/tmp/iterm_hum_window_$name"
	local default_dir
	case "$name" in
		("ciglane") default_dir="$HOME/hummm/ciglane"  ;;
		("tuzla") default_dir="$HOME/hummm/tuzla"  ;;
		("strasbourg") default_dir="$HOME/hummm/strasbourg"  ;;
		("karlsruhe") default_dir="$HOME/hummm/karlsruhe"  ;;
		(*) default_dir="$HOME/hummm/$name"  ;;
	esac
	if [[ -f "$marker_file" ]]
	then
		local window_id=$(cat "$marker_file")
		if osascript -e "tell application \"iTerm\" to select (first window whose id is $window_id)" 2> /dev/null
		then
			echo "Switched to existing $name window"
			return
		else
			rm "$marker_file"
		fi
	fi
	echo "Creating new $name window in $default_dir"
	local new_window_id=$(osascript -e "
      tell application \"iTerm\"
          create window with default profile
          tell current session of current window
              write text \"cd '$default_dir' && clear\"
          end tell
          tell current session of current window
              write text \"title '$name' && clear\"
          end tell
          return id of current window
      end tell")
	echo "$new_window_id" > "$marker_file"
}