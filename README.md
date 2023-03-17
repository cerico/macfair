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

* [make update](docs/UPDATE.md)
* [make thiscomputer](docs/THISCOMPUTER.md)
* [make newcomputer](docs/NEWCOMPUTER.md)
* [make rootkeys](docs/ROOTKEYS.md)
* [make remote_login](docs/REMOTE_LOGIN.md)
* [make userkeys](docs/USERKEYS.md)
* [make setup](docs/SETUP.md)
* [make debian](docs/DEBIAN.md)
* [make install](docs/INSTALL.md)
* [make aliases](docs/ALIASES.md)
* [make terminal](docs/TERMINAL.md)
* [make vscode](docs/VSCODE.md)
* [make rails](docs/RAILS.md)
* [make nginx](docs/NGINX.md)
* [make desktop](docs/DESKTOP.md)
* [make elastic](docs/ELASTIC.md)
* [make newsite](docs/NEWSITE.md)
* [make debug](docs/DEBUG.md)
* [make help](docs/HELP.md)
