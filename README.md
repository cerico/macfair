# Macfair

Sets up your Mac (and any debian targets) from scratch via Ansible. A replacement for dotfiles. With Ansible being idempotent, each command is only run if actually required

## TLDR

To set up and run all the roles, run the following

```
make update
make thistarget
make setup
```

Or to set up specific roles, run individually eg

```
make update
make thistarget
make install
make terminal
make rails
```

# Roles

### make update

Updates ansible and any ansible-galaxy collections as listed in requirements.yml

### make thistarget

Sets up the host machine's inventory file and host_vars. This only needs to be run once to set up ansible correctly

### make setup

Runs the install, aliases, terminal, rails, vscode, desktop, and elastic roles

### make newtarget

Sets up another machine in the inventory file, typically a debian server such as a VPS or Raspberry PI. Also creates host_vars for the new machine

### make rootkeys

Uses ssh-copy-id to copy root ssh keys to other machines, based on root users specified in host_vars/localhost.yml previously created with `make newtarget`

### make remote_login

Creates a user on remote machine and adds to sudoers. This uses a user previously added to host_vars/localhost.yml by `make newtarget`

### make userkeys

Uses ssh-copy-id to copy ssh keys to other machines. This is for the non-root ansible user previously created in the `make remote_login` step

### make debian

Runs the install, aliases, terminal, and nginx roles. This runs on targets add to the debian group in the `make newtarget` step

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

