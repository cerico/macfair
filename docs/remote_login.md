# REMOTE_LOGIN PLAYBOOK

## What it does

* Adds a new user on target machine
* Adds the new user to the sudoers list for passwordless use

## Pre-requisites

`make newcomputer` should have been run before this step. You can read about that [here](/docs/newcomputer.md)
`make rootkeys` should also have been run before this step to ensure it doesn't keep prompting for a password. You can read more about that [here](/docs/rootkeys.md)

## How To Use

```bash
# install the packages
$ make install

# Run the app
$ make remote_login
```

This will useradd the user specifed in the `make newcomputer` step on the new machine, using the var file shown below created by that step. It will add the user to the sudoers so file for passwordless sudo

<pre>
# host_vars/rhyl.io37.ch/vars.yml
ansible_user: "alison"
to_sudo:
  - alison
</pre>

## Example run

```bash
make remote_login
$(python3 -m site --user-base)/bin/ansible-playbook remote_login.yml -i hosts -e "ansible_user=root"
Enter a password for user that will sudo:
confirm Enter a password for user that will sudo:

PLAY [Setup remote login] *************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [rhyl.io37.ch]


TASK [sudo : Create the sudoers] ******************************************************************************************************
changed: [rhyl.io37.ch]

TASK [sudo : add users to sudoers] ****************************************************************************************************
changed: [rhyl.io37.ch] => (item=alison)

TASK [sudo : Add the to_sudo] *********************************************************************************************************
changed: [rhyl.io37.ch] => (item=alison)

TASK [afterwards : display post install message] **************************************************************************************
skipping: [localhost]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
rhyl.io37.ch               : ok=13   changed=6    unreachable=0    failed=0    skipped=5    rescued=0    ignored=2
```

# NEXT STEPS

Now we can run the `make userkeys` rule. You can read more about that [here](/docs/userkeys.md)
