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

* [make update](docs/update.mdx)
* [make thiscomputer](docs/thiscomputer.mdx)
* [make newcomputer](docs/newcomputer.mdx)
* [make rootkeys](docs/rootkeys.mdx)
* [make remote_login](docs/remote_login.mdx)
* [make userkeys](docs/userkeys.mdx)
* [make setup](docs/setup.mdx)
* [make debian](docs/debian.mdx)
* [make install](docs/install.mdx)
* [make aliases](docs/aliases.mdx)
* [make terminal](docs/terminal.mdx)
* [make vscode](docs/vscode.mdx)
* [make rails](docs/rails.mdx)
* [make nginx](docs/nginx.mdx)
* [make desktop](docs/desktop.mdx)
* [make elastic](docs/elastic.mdx)
* [make newsite](docs/newsite.mdx)
* [make debug](docs/debug.mdx)
* [make help](docs/help.mdx)
