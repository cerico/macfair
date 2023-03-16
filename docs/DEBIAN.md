# DEBIAN PLAYBOOK

## What it does

* Runs the install role
* Runs the terminal role
* Runs the aliases role
* Runs the nginx role

## How To Use

```bash
$ make debian
```

This only executes on hosts in the debian group in the inventory file (hosts). It executes the install, terminal, aliases, and nginx roles, as seen below

```yml
# setup.yml
- name: Setup debian machines
  hosts: [debian]
  roles:
    - { role: install, tags: debian }
    - { role: terminal, tags: debian }
    - { role: aliases, tags: debian }
    - { role: nginx, tags: [debian, nginx] }
```

Each of these roles can be run individually with their own make command, or collectively as `make debian`, where each role is executed sequentially. For more on each you can read here

* [INSTALL.md](INSTALL.md)
* [TERMINAL.md](TERMINAL.md)
* [ALIASES.md](ALIASES.md)
* [NGINX.md](NGINX.md)
