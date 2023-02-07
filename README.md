# Macfair

Sets up your Mac (and RaspberryPi or Debian box) from scratch via Ansible. A replacement for dotfiles. With Ansible being idempotent, each command is only run if actually required

## TLDR

```
make prepare
make setup
```

### make prepare

 - Copies the example hostfile to hosts and adds your hostname
 - Copies the example host_vars yaml to a file named after hostname
 - Copies ssh keys where necessary

This prepares the macbook ready to be built. If running ansible on the target machine there's no more to do here. 

If running ansible on a different machine, change ansible_connection from local to ssh in the newly created host_vars yml and add the hostname of the macbook to `/etc/hosts` on the machine running ansible. Then run the make keys step.

### make keys
This step is only for building machines other than the macbook. A sample raspberry pi configuration is included. Any machines will need to be added to `/etc/hosts`. Users are added to the host_vars yaml created in tbe make prepare step in the format of the example users - userkey is an optional parameter if specifying an ssh key other than `~/.ssh/id_rsa.pub`. Make key will copy the keys to target machines users for passwordless access


### make setup

`make setup` by default setups the macbook and a raspberry pi if present. it an be run from either machine. The setup.yml defines which roles are execiuted on the macbook, which roles are executed on the raspberry pi, and which on both. Each role can also be executed individually.

## Roles

`make setup` runs all the roles, but each can be run individiually as follows

### whoami

This isn't run directly, but all roles run it to establish

 - the username of the user running the playbook
 - the brew user

The brew uesr is configured to make sure than on a multi-user system brew ownership stays consistent under one user, but can be used by other users

### install

Installs all core packages on both macbook and debian raspberry pi. Can be run separately via `make install`. Add packages via `roles/install/tasks/darwin.yml` and `roles/install/tasks/debian.yml`

### aliases

Configures zsh and copies across any new aliases or paths. Can be run separately via `make aliases`

### terminal

Configures ohmyzsh and follows on from previous role. Can be run separately via `make terminal`. Likely to merge with above role

### rails

installs ruby, rbenv, and rails. Can be run separately via `make rails`

### vscode

Setup vscode with extensions, themes, snippets. Can be rjun separately via `make vscode`


### desktop

Mac only role. configures gui elements, wallpapers, dock etc. Can be run separately via `make desktop`

### elastic

Mac only role currently, installs and sets up elasticsearch. Can be run separately via `make elastic`

### slim

Same as `mske setup` but skips the rails and elasticroles for a quicker playbook. Is run as `make slim`

### update

Upgrades ansible. Run via `make update`

### ansible

Installs ansible if its missing. Run via `make ansible`

### help

Print this out, run via `make help`







## Installs and configures

- Ansible
- Node
- Yarn
- Ruby on Rails
- gh
- jq
- tree
- zsh
- vscode
- iterm
- alfred
- vagrant
- redis
- postgres
- elasticsearch
- netlify-cli
- vercel

# Partial setup

`make setup` will run through the entire process of setting up your mac. Each time you want to update something, its ok to do this again - ansible being idempotent means it will skip steps it doesn't need to redo. However, modularizing the setup means we don't need to do that, we can just run one section, eg `make zsh` or `make vscode`, this is much quicker. 

Each partial command is listed in the Makefile, with a corresponding role - zsh, vscode, rails, databases etc

# TODO

[ ] Split the roles out further
[ ] Add a more minimal user
