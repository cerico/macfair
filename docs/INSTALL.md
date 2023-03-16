# INSTALL PLAYBOOK

## Mac Installs
* vercel
* netlify-cli
* railway
* jmespath
* passlib
* youtube-dl
* gh
* jq
* wget
* gcc
* openssl
* cmake
* git
* git-lfs
* moreutils
* findutils
* gnupg
* grep
* screen
* pigz
* tree
* ffmpeg
* shared-mime-info
* nginx
* graphviz
* node
* yarn
* zsh
* zsh-completions
* zsh-autosuggestions
* zsh-syntax-highlighting
* direnv
* watch
* nmap
* htop
* tmux
* postgresql
* redis
* hpedrorodrigues/tools/dockutil
* vlc
* firefox
* alfred
* iterm2
* vagrant
* vagrant-manager
* virtualbox
* tunnelblick
* slack
* visual-studio-code
* brave-browser
* google-chrome
* chromim

## Debian installs

* git
* gh
* jq
* nginx
* firefox-esr
* snapd
* figlet
* snap
* code
* node
* certbot


## How To Use

```bash
$ make install
```

Is also run automatically by both `make macbook` and `make debian`

By default runs on all targets, example run below shows role executing on both mac target (kelso.localhost) and debian target (rhyl.io37.ch)

## Example run

```bash
make install
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "install"

PLAY [before everything] **************************************************************************************************************

TASK [debug] **************************************************************************************************************************
ok: [localhost] => {
    "macfair_version.stdout": "\"0.21.9\""
}

PLAY [Setup MacBook and debian] *******************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [kelso.localhost]

TASK [install : install homebrew taps] ************************************************************************************************
ok: [kelso.localhost] => (item=homebrew/services)
ok: [kelso.localhost] => (item=homebrew/cask)

TASK [install : install core packages] ************************************************************************************************
ok: [kelso.localhost]

TASK [install : Create directory for installed caskapps] ******************************************************************************
ok: [kelso.localhost]

TASK [install : install cask apps] ****************************************************************************************************
ok: [kelso.localhost] => (item=hpedrorodrigues/tools/dockutil)
ok: [kelso.localhost] => (item=vlc)
ok: [kelso.localhost] => (item=firefox)
ok: [kelso.localhost] => (item=alfred)
ok: [kelso.localhost] => (item=iterm2)
ok: [kelso.localhost] => (item=vagrant)
ok: [kelso.localhost] => (item=vagrant-manager)
ok: [kelso.localhost] => (item=virtualbox)
ok: [kelso.localhost] => (item=tunnelblick)
ok: [kelso.localhost] => (item=slack)
ok: [kelso.localhost] => (item=visual-studio-code)
ok: [kelso.localhost] => (item=brave-browser)
ok: [kelso.localhost] => (item=google-chrome)
ok: [kelso.localhost] => (item=chromium)

TASK [install : Copy zshenv] **********************************************************************************************************
ok: [kelso.localhost]

TASK [install : source zshenv so we get /usr/local/bin for npm] ***********************************************************************
changed: [kelso.localhost]

TASK [install : Install vercel, netlify] **********************************************************************************************
ok: [kelso.localhost] => (item=vercel)
ok: [kelso.localhost] => (item=netlify-cli)
ok: [kelso.localhost] => (item=railway)

TASK [install : pip installs] *********************************************************************************************************
ok: [kelso.localhost] => (item=jmespath)
ok: [kelso.localhost] => (item=passlib)

TASK [install : link node] ************************************************************************************************************
changed: [kelso.localhost]

TASK [install : print role name] ******************************************************************************************************
ok: [kelso.localhost]

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=51   changed=12   unreachable=0    failed=0    skipped=34   rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
