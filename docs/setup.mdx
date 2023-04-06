# SETUP PLAYBOOK

## What it does

* Runs the Install role
* Runs the Terminal role
* Runs the Aliases role
* Runs the Rails role
* Runs the Vscode role
* Runs the Desktop role
* Runs the Elastic role



## How To Use

```bash
$ make setup
```

This only executes on hosts in the macbook group in the inventory file (hosts), and runs all roles tagged with setup - install, aliases, terminal, rails, and vscode on both macbook and debian targets, and desktop and elastic roles only on targets in the macbook group.

```yml
# setup.yml
- name: Setup MacBook and debian
  hosts: [macbook, debian]
  roles:
    - { role: whoami, tags: always }
    - { role: install, tags: [install, setup] }
    - { role: aliases, tags: [aliases, install, setup] }
    - { role: terminal, tags: [terminal, setup] }
    - { role: rails, tags: [rails, setup] }
    - { role: vscode, tags: [vscode, setup] }

- name: Setup macbook
  hosts: macbook
  roles:
    - { role: desktop, tags: [desktop, setup] }
    - { role: elastic, tags: [elastic, setup] }
```

Each of these roles can be run individually with their own make command, or collectively as `make debian`, where each role is executed sequentially. For more on each you can read here

* [INSTALL.md](/docs/install.md)
* [TERMINAL.md](/docs/terminal.md)
* [ALIASES.md](/docs/aliases.md)
* [RAILS.md](/docs/rails.md)
* [VSCODE.md](/docs/vscode.md)
* [DESKTOP.md](/docs/desktop.md)
* [ELASTIC.md](/docs/elastic.md)
