# Macfair

[![Version](https://github.com/cerico/macfair/actions/workflows/publish.yml/badge.svg)](https://github.com/cerico/macfair/actions/workflows/publish.yml)


Sets up your Mac (and any debian targets) from scratch via Ansible. A replacement for dotfiles. With Ansible being idempotent, each command is only run if actually required

## TLDR

To set up and run all the roles, run the following

```
make update
make thiscomputer
make setup
```

Or to set up specific roles, run individually eg

```
make update
make thiscomputer
make install
make terminal
make rails
```

# Roles

### make install

Read more [here](docs/INSTALL.md)

### make thiscomputer

Read more [here](docs/THISCOMPUTER.md)

### make setup

Runs the install, aliases, terminal, rails, vscode, desktop, and elastic roles

### make newcomputer

Read more [here](docs/NEWCOMPUTER.md)

### make rootkeys

Read more [here](docs/ROOTKEYS.md)

### make remote_login

Read more [here](docs/REMOTE_LOGIN.md)

### make userkeys

Read more [here](docs/USERKEYS.md)

### make debian

Runs the install, aliases, terminal, and nginx roles. This runs on targets add to the debian group in the `make newcomputer` step

### make install

Installs packages

### make aliases

Sets up the zsh/aliases files

### make terminal

Sets up zsh

### make rails

Sets up Ruby on Rails

### make vscode

Sets up vscode complete with extensions and themes

### make desktop

Sets up dock and extensionsr. Runs on mac only

### make elastic

Install elasticsearch

### make nginx

Install and setsup nginx. Runs on debian only

### make debug

debugs all the above!

### make help

Print this out, run via `make help`

### make newsite

Sets up nginx and certbot for a new site. Site doesn't need to be created yet, but domain/subdomain should be pointing to the correct ip first.

