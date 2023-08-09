# FUNCTIONS ROLE

## What it does

* Sets up zsh functions
* Sets up .gitconfig and git functions

## How To Use

```bash
$ make functions
```

Is also run automatically by both `make setup` and `make debian`

By default runs on all targets, example run below shows role executing on both mac target (kelso.localhost) and debian target (rhyl.io37.ch)

## Example run

```bash
make functions
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "functions"

PLAY [Before everything] **************************************************************************************************************

TASK [Print version] ******************************************************************************************************************
ok: [localhost] => {
    "macfair_version.stdout": "\"0.21.10\""
}

PLAY [Setup MacBook and debian] *******************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [functions : Copy zshrc] ***********************************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : Create zsh directory] *************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Copy functions] *********************************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : Copy darwin] **********************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Copy git functions] *****************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Add darwin to path.] **************************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : create empty tokens file only if one doesnt already exist] ************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : create trial file for new functions if one doesnt already exist] *******************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : copy js help file] ****************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Register ansible location] ********************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : Add ansible to path.] *************************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : register rbenv exists] ************************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Conditionally Copy zsh rails] *****************************************************************************************
skipping: [rhyl.io37.ch]
ok: [kelso.localhost]

TASK [functions : Conditionally Add rails to zshrc.] ************************************************************************************
skipping: [rhyl.io37.ch]
changed: [kelso.localhost]

TASK [functions : Copy zshrc] ***********************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Create zsh directory] *************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy functions] *********************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy debian] **********************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy git functions] *****************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Add debian to path.] **************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Register ansible location] ********************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Add ansible to path.] *************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : collect server info] **************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : copy motd] ************************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Add motd to path.] ****************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : register motd.sh exists] **********************************************************************************************
skipping: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [functions : Conditionally Add motd to path.] **************************************************************************************
skipping: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [functions : create empty tokens file only if one doesnt already exist] ************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : create trial file for new functions if one doesnt already exist] *******************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : copy js help file] ****************************************************************************************************
skipping: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : register rbenv exists] ************************************************************************************************
skipping: [kelso.localhost]
ok: [rhyl.io37.ch]

TASK [functions : Conditionally Copy zsh rails] *****************************************************************************************
skipping: [kelso.localhost]
skipping: [rhyl.io37.ch]

TASK [functions : Conditionally Add rails to zshrc.] ************************************************************************************
skipping: [kelso.localhost]
skipping: [rhyl.io37.ch]

TASK [functions : Copy gitconfig] *******************************************************************************************************
ok: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Create git hooks directory] *******************************************************************************************
ok: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy global pre-commit hook] ******************************************************************************************
ok: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy global commit-msg hook] ******************************************************************************************
ok: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : create blank template commit file] ************************************************************************************
changed: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : Copy godaddy file] ****************************************************************************************************
ok: [kelso.localhost]
changed: [rhyl.io37.ch]

TASK [functions : print role name] ******************************************************************************************************
ok: [kelso.localhost]
ok: [rhyl.io37.ch]

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=38   changed=13   unreachable=0    failed=0    skipped=19   rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
rhyl.io37.ch               : ok=39   changed=25   unreachable=0    failed=0    skipped=18   rescued=0    ignored=2
```
