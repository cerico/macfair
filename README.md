# Macfair

Sets up your Mac from scratch via Ansible. A replacement for dotfiles. With Ansible being idempotent, each command is only run if actually required

## TLDR

```
make setup
```

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

