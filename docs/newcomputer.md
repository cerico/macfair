# NEWCOMPUTER PLAYBOOK

Sets up another machine, typically a debian computer such as a VPS or raspberry pi.

## What it does

* Adds new computer to the inventory file
* Adds the new user for the new computer to the host_vars/localhost.yml file
* Adds the root user for the new computer to the host_vars/localhost.yml file
* Creates and populates a host_vars directory and vars file for hostname of new machine
* Sets up passwordless sudo for current user

## How To Use

```bash
$ make newcomputer
```

## Example run

```bash
$  make newcomputer
$(python3 -m site --user-base)/bin/ansible-playbook newcomputer.yml -i hosts
What is the hostname of the new target?: rhyl.io37.ch
What is the username of the default user? [deploy]: alison
Which group to add to in inventory? [debian]:

PLAY [Setup a new machine] **************************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [localhost]

TASK [Create vars folder for new target] ************************************************************************
ok: [localhost]

TASK [Create main vars yml for target] **************************************************************************
ok: [localhost]

TASK [Add target to inventory file.] ****************************************************************************
ok: [localhost]

TASK [Add ansible user to ssh list.] ****************************************************************************
changed: [localhost]

TASK [Add root user to ssh list.] *******************************************************************************
changed: [localhost]

PLAY RECAP ******************************************************************************************************
localhost                  : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Results

<pre>
# hosts
[macbook]
tavernier.localhost

<b>[debian]
rhyl.io37.ch</b>

[unused]
wilson
</pre>

The hostname of the new computer is added to the debian group by defailt, or the macbook group if specifed. If anything else is specified it is added to the unused group

<pre>
# host_vars/localhost.yml
host_vars/localhost.yml
users:
  <b>- { username: alison@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }</b>
root:
  <b>- { username: root@rhyl.io37.ch, userkey: ~/.ssh/id_rsa.pub }</b>
</pre>

The ansbile and root users are both added to the existing localhost.yml

<pre>
# host_vars/rhyl.io37.ch/vars.yml
host_vars/rhyl.io37.ch/vars.yml
ansible_user: "alison"
to_sudo:
  - alison
</pre>

This vars file is created in a directory named after the specified hostname. This is recreated from scratch if the command is rerun with the same hostname. Don't add to or edit anything in this file as it will be overwritten if the command is re-reun. You can however add vars that won't be lost by creating new yaml files in this directory. Those will never be overwritten

# NEXT STEPS

Now we can run the `make rootkeys` rule. You can read more about that [here](/docs/rootkeys.md)
