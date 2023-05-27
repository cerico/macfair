_list_domains () {
  curl -X 'GET' \
    'https://api.godaddy.com/v1/domains' \
    -H 'accept: application/json' \
    -H "Authorization: sso-key $key" | jq -c '.[] | select( .status == "ACTIVE" ) ' | jq
}

_move_domain () {
  echo "Coming soon, currently only able to move subdomains"
}

_move_subdomain () {
  subdomain=`echo $1 | cut -d'.' -f 1`
  if [[ ${#subdomain} -lt 2 ]]; then
    echo "subdomain too short"
    return
  fi
  domain=`echo $1 | cut -d'.' -f 2-`
  ip=$2
  echo $domain
  echo $subdomain
  echo $ip
  curl -X 'PUT' \
  "https://api.godaddy.com/v1/domains/$domain/records/A/$subdomain" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: sso-key $key" \
  -d '[
  {
    "data": "'"${ip}"'",
    "port": 65535,
    "priority": 0,
    "protocol": "string",
    "service": "string",
    "ttl": 10800,
    "type": "A",
    "weight": 0
  }
]'
}

_add_subdomain () {
  subdomain=`echo $1 | cut -d'.' -f 1`
  if [[ ${#subdomain} -lt 2 ]]; then
    echo "subdomain too short"
    return
  fi
  domain=`echo $1 | cut -d'.' -f 2-`
  ip=$2
  curl -X "PATCH" \
  "https://api.godaddy.com/v1/domains/$domain/records" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: sso-key $key" \
  -d '[
  {
    "data": "'"${ip}"'",
    "name": "'"${subdomain}"'",
    "port": 65535,
    "priority": 0,
    "protocol": "string",
    "service": "string",
    "ttl": 10800,
    "type": "A",
    "weight": 0
  }
]'
}

godaddy () { # manage or list godaddy domains # ➜ godaddy macfair.io37.ch
  ip=
  key=`godaddysecrets`
  if [[ $key != *:* ]]; then
    echo "Add the following to ~.zsh/tokens\n\ngodaddysecrets () {\n  echo secrets:inthisformat\n}"
    return
  fi
  if [[ $# -eq 0 ]] ; then
    _list_domains
    return
  fi
  fields=`echo $1 | awk -F '.' '{print NF}'`
  if [[ $fields -eq 3 ]]; then
    actions=("Add $1" "Move $1" "List domains")
  else
    actions=("Move domain" "List domains")
  fi
  PS3='Select domain: '
  select action in "${actions[@]}"; do
    case $action in
      "Add $1")
          PS3='Select ip: '
          select ip in "${ip_addresses[@]}"
	        if [[ " ${ip_addresses[@]} " =~ " ${ip} " ]];
	        then
		        echo "adding $1 to $address"
            _add_subdomain $1 $ip
            break
	        else
		        echo "Please select a valid ip address"
            break
	        fi
        break
        ;;
      "Move $1")
          PS3='Select ip: '
          select ip in "${ip_addresses[@]}"
	        if [[ " ${ip_addresses[@]} " =~ " ${ip} " ]];
	        then
		        echo "moving $1 to $ip"
            _move_subdomain $1 $ip
            break
	        else
		        echo "Please select a valid ip address"
            break
	        fi
        break
        ;;
      "Move domain")
        _move_domain
        break
        ;;
      "List domains")
        _list_domains
        break
        ;;
    esac
  done
}
