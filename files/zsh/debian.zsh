export PATH="/snap/bin:$PATH"

dokn () {  # Setup new dokku app with postgres and letsencrypt ➜ dokn tuzla
    local email="cityguessr@skiff.com"
    local domain="ol14.cc"
    dokku apps:create $1
    dokku postgres:create $1db
    dokku postgres:link $1db $1
    dokku domains:set $1 $1.$domain
    dokku letsencrypt:set $1 email $email
    dokku letsencrypt:enable $1
    dokku letsencrypt:auto-renew
}

bump () { # Increase swap space otherwise dokku struggles with memory
    sudo install -o root -g root -m 0600 /dev/null /swapfile
    sudo dd if=/dev/zero of=/swapfile bs=1k count=2048k
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile       swap    swap    auto      0       0" | sudo tee -a /etc/fstab
    sudo sysctl -w vm.swappiness=10
    echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
}

dokp () {  # Add ports to dokku app ➜ dokp tuzla 2560
    if [ "$#" -lt 2 ]; then
        echo "Usage: ports appname port, eg dokp tuzla 2560"
        return 1
    fi
    dokku ports:add $1 http:80:$2
    dokku ports:add $1 https:443:$2
}
