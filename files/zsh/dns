dnsvpn() { # Override OpenVPN dns servers
  local="dhcp-option DNS 127.0.0.1"
  quad9="dhcp-option DNS 9.9.9.9"
  brewser=`stat -f "%Su" /usr/local/bin/brew`
  files="/Users/$brewser/Library/Application Support/OpenVPN Connect/profiles"
  cd $files
  for i in `ls`
  do
    grep -qxF $local $i || echo $local >> $i
    grep -qxF $quad9 $i || echo $quad9 >> $i
  done
  cd - > /dev/null
}

dnslocal () { # Add local domain for dns # ➜ dnsmasq raspberry.pi 192.168.1.102
  if [[ $# -gt 1 ]] ; then
    file="/usr/local/etc/dnsmasq.conf"
    domain=`grep -n address=/.$1/ $file`
    ip=$2
    line=`echo $(echo $domain | cut -d ":" -f 1)`
    if [[ ${#line} -gt 1 ]] ; then
      sed -i "" -e "$line"d $file
    fi
    echo "address=/.$1/$2" >> $file
  fi
  sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  test $1 && nslookup $1
}
