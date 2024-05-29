export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

unalias brew 2>/dev/null
brewser=$(stat -f "%Su" $(which brew))
alias brew='sudo -Hu '$brewser' brew'

batt () {
  [[ $1 = "clear" ]] && echo -n > ~/.batt
  if (pmset -g batt | grep Internal | grep estimate > /dev/null); then
    batt=$(pmset -g batt | grep Internal |awk -F' ' '{print $3,$4}' | tr -d \;)
  else
    batt=$(pmset -g batt | grep Internal |awk -F' ' '{print $3,$4,$5,$6}' | tr -d \;)
  fi
  last=`tail -n 1 ~/.batt | awk -F " " '{ print $3}'`
  this=`echo $batt | awk -F " " '{ print $2}'`
  date=`date "+%H:%M"`
  cat ~/.batt
  echo $date $batt
  [[ $last = 'charged' ]] && [[ $this = 'charged' ]] && return
  [[ $1 = "cron" ]] && echo $date $batt >> ~/.batt
}

dfh () {
  [[ $1 = "clear" ]] && echo -n > ~/.dfh
  dfh=`df -h | head -2 | tail -1 | awk -F " " '{print $4}'`
  date=`date "+%H:%M"`
  last=`tail -n 1 ~/.dfh | awk -F " " '{ print $2}'`
  [[ -f ~/.dfh ]] && cat ~/.dfh
  echo $date $dfh
  [[ $last = $dfh ]] && return
  [[ $1 = "cron" ]] && echo $date $dfh >> ~/.dfh
}

nfy () {
  netlify sites:list | grep url
}

themes() {
  grep Name ~/Library/Application\ Support/iTerm2/DynamicProfiles/iterm.json | awk -F' ' '{print $3}' | awk -F'"' '{print $2}'
}

wallpaper () {
   if [[ $# -eq 0 ]] ; then
		 echo "Available wallpapers:"
		 ls $HOME/wallpapers | grep .png | awk -F "." '{ print $1 }'
		 return
	 fi
	if [[ -f $HOME/wallpapers/$1.png ]] ; then
    osascript -e 'set desktopImage to POSIX file "'$HOME/wallpapers/$1.png'"
    tell application "Finder"
      set desktop picture to desktopImage
    end tell'
		return
	fi
	echo "Wallpaper not found"
	echo "Available wallpapers:"
	ls $HOME/wallpapers | grep .png | awk -F "." '{ print $1 }'
}

AdminQuestion () {
	echo -ne "
Will $1 be an admin user?
$(ColorGreen '1)') Yes
$(ColorGreen '2)') No
$(ColorCyan 'Choose an option:') "
	read a
	array=(1 Yes yes Y y)
	[[ ${array[*]} =~ $a ]] && admin=yes || admin=no
}

newuseroutput () {
  echo -ne "
$(ColorGreen '1)') Lock screen and sign in as $1, accepting all defaults
$(ColorGreen '2)') Lock screen and sign back in here as `whoami` and run \"prepare\" from terminal
$(ColorGreen '3)') Lock screen and sign back in as $1, cd to ~/macfair and type \"make help\" for next steps
"
}

newuser () {
	if [[ $# -eq 1 ]]
	then
		username=$1
		displayName=$1
                echo -ne "Specify password to be used for $1
$(ColorGreen Password): "
		read password
		AdminQuestion $1
		highestUID=$( dscl . -list /Users UniqueID | /usr/bin/awk '$2>m {m=$2} END { print m }' )
		nextUID=$(( highestUID+1 ))
		sudo /usr/bin/dscl . create "/Users/$username"
		sudo /usr/bin/dscl . create "/Users/$username" UserShell /bin/zsh
		sudo /usr/bin/dscl . create "/Users/$username" RealName "$displayName"
		sudo /usr/bin/dscl . create "/Users/$username" UniqueID "$nextUID"
		sudo /usr/bin/dscl . create "/Users/$username" PrimaryGroupID 20
		sudo /usr/bin/dscl . passwd "/Users/$username" "$password"
		if [[ "$admin" = "yes" ]]
		then
			sudo /usr/bin/dscl . append /Groups/admin GroupMembership "$username"
		fi
		newuseroutput $1
	else
		echo Please specify user to be created
	fi
}

prepare () {
	if [[ $# -eq 1 ]]
	then
		sudo cp -r ~/.ssh /Users/$1/.ssh
		sudo chown -R $1 /Users/$1/.ssh
		sudo cp ~/.gitconfig /Users/$1/.gitconfig
		sudo git -c core.sshCommand="ssh -i ~/.ssh/id_rsa" clone git@github.com:cerico/macfair /Users/$1/macfair
		sudo chown -R $1 /Users/$1/macfair
	else
		echo Please specify user to be prepared
	fi
}

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
