# USERKEYS PLAYBOOK

## What it does

* Uses ssh-copy-id to copy ssh keys for specified non-root users
* Turns off password acces on per-user basis once key is copied across

## Pre-requisites

`make remote_login` should have been run before this step. You can read about that [here](/docs/remote_login.md)

## How To Use

```bash
$ make userkeys
```

This will ssh-copy-id any keys found in the user section of `host_vars/localhost.yml` previously created by the `make newcomputer` step, eg

<pre>
# host_vars/localhost.yml
users:
  <b>- { username: alison@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }</b>
root:
  - { username: root@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }
</pre>

## Example run

```bash
make userkeys
$(python3 -m site --user-base)/bin/ansible-playbook keys/keys.yml -i hosts

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [debug] **************************************************************************************************************************
ok: [localhost] => {
    "users": [
        {
            "userkey": "~/.ssh/id_rsa.pub",
            "username": "alison@rhyl.io37.ch"
        }
    ]
}

TASK [Set up ssh key login for user] **************************************************************************************************
alison@rhyl.io37.ch's password:
changed: [localhost] => (item={'username': 'alison@rhyl.io37.ch', 'userkey': '~/.ssh/id_rsa.pub'})

PLAY [debian] *************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [rhyl.io37.ch]

TASK [debug] **************************************************************************************************************************
ok: [rhyl.io37.ch] => {
    "hostvars['localhost']['users']": [
        {
            "userkey": "~/.ssh/id_rsa.pub",
            "username": "alison@rhyl.io37.ch"
        }
    ]
}

TASK [create sshd rules file if doesnt exist] *****************************************************************************************
changed: [rhyl.io37.ch]

TASK [add lines to sshd rules file] ***************************************************************************************************
changed: [rhyl.io37.ch] => (item={'username': 'alison@rhyl.io37.ch', 'userkey': '~/.ssh/id_rsa.pub'})

TASK [Restart ssh] ********************************************************************************************************************
changed: [rhyl.io37.ch]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rhyl.io37.ch               : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

# NEXT STEPS

Now we can run the `make debian` rule. You can read more about that [here](/docs/debian.md)
