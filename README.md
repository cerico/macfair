# Macfair

<a href="https://github.com/cerico/macfair/actions/workflows/publish.yml">
    <img src="https://github.com/cerico/macfair/actions/workflows/publish.yml/badge.svg" alt="Version" class="badge-image">
</a>

Sets up your Mac (and any debian targets) from scratch via Ansible. A replacement for dotfiles. With Ansible being idempotent, each command is only run if actually required

## TLDR

To set up and run all the roles, run the following

```
make ansible
make thiscomputer
make setup
```

Or to set up specific roles, run individually eg

```
make ansible
make thiscomputer
make install
make terminal
make rails
```

# Roles

* [make ansible](docs/ansible.md)
* [make thiscomputer](docs/thiscomputer.md)
* [make newcomputer](docs/newcomputer.md)
* [make rootkeys](docs/rootkeys.md)
* [make remote_login](docs/remote_login.md)
* [make userkeys](docs/userkeys.md)
* [make setup](docs/setup.md)
* [make debian](docs/debian.md)
* [make install](docs/install.md)
* [make functions](docs/functions.md)
* [make terminal](docs/terminal.md)
* [make vscode](docs/vscode.md)
* [make rails](docs/rails.md)
* [make nginx](docs/nginx.md)
* [make desktop](docs/desktop.md)
* [make elastic](docs/elastic.md)
* [make newsite](docs/newsite.md)
* [make debug](docs/debug.md)
* [make help](docs/help.md)
