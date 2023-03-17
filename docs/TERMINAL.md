# TERMINAL ROLE

## What it does

* Installs oh-my-zsh
* Changes user shell to zsh
* Creates iterm profiles

## How To Use

```bash
$ make terminal
```

Is also run automatically by both `make setup` and `make debian`

By default runs on all targets, example run below shows role executing on both mac target (kelso.localhost) and debian target (rhyl.io37.ch)

## Example run

```bash
 make terminal
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "terminal"

PLAY [Before everything] **************************************************************************************************************

TASK [Print version] ******************************************************************************************************************
ok: [localhost] => {
    "macfair_version.stdout": "\"0.21.10\""
}

PLAY [Setup MacBook and debian] *******************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [terminal : Cloning oh-my-zsh] ***************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : Copy zsh theme] ******************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : Copy zsh theme ii] ***************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : change user shell to zsh] ********************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : Create iterm preferences by opening] *********************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [terminal : register iterm location] *********************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : copy iterm profiles] *************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [terminal : set default iterm profile] *******************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [terminal : install package] *****************************************************************************************************
skipping: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [terminal : Cloning oh-my-zsh] ***************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : Copy zsh theme] ******************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : Copy zsh theme ii] ***************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : change user shell to zsh] ********************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : source zshrc] ********************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : set default iterm profile] *******************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [terminal : print role name] *****************************************************************************************************
ok: [kelso.localhost]
ok: [rhyl.io37.ch]

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=26   changed=6    unreachable=0    failed=0    skipped=7    rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
rhyl.io37.ch               : ok=23   changed=10   unreachable=0    failed=0    skipped=10   rescued=0    ignored=2
```
