# ROOTKEYS PLAYBOOK

## What it does

* Copies root ssh keys

## Pre-requisites

`make newcomputer` should have been run before this step. You can read about that [here](NEWCOMPUTER.md)

## How To Use

```bash
# install the packages
$ make rootkeys
```

This will ssh-copy-id any keys found in the root section of `host_vars/localhost.yml` previously created by the `make newcomputer` step, eg

<pre>
# host_vars/localhost.yml
users:
  - { username: alison@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }
root:
  <b>- { username: root@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }</b>
</pre>

This file can be modified, if for example you want to use a different ssh key then a different location can be specified here.

# Example run

```bash
 make rootkeys
$(python3 -m site --user-base)/bin/ansible-playbook keys/root.yml -i hosts  -e "ansible_user=root"

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [debug] **************************************************************************************************************************
ok: [localhost] => {
    "root": [
        {
            "userkey": "~/.ssh/id_rsa.pub",
            "username": "root@rhyl.io37.ch"
        }
    ]
}

TASK [Set up ssh key login for user] **************************************************************************************************
The authenticity of host 'rhyl.io37.ch (95.179.170.144)' can't be established.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
root@rhyl.io37.ch's password:
changed: [localhost] => (item={'username': 'root@rhyl.io37.ch', 'userkey': '~/.ssh/id_rsa.pub'})

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

# NEXT STEPS

Now we can run the `make remote_login` rule. You can read more about that [here](REMOTE_LOGIN.md)
