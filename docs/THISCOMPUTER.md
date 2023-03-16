# THISCOMPUTER

Sets up the host machine, ready to run the other roles

## What it does

* Creates and populates the inventory file (hosts)
* Creates and populates the host_vars/localhost.yml file
* Creates and populates a host_vars directory and vars file for hostname of current machine
* Sets up passwordless sudo for current user

## How To Use

```bash
$ make thiscomputer
```

## Example run

```bash
 make thiscomputer
$(python3 -m site --user-base)/bin/ansible-playbook thiscomputer.yml --ask-become-pass -e "hostname=`hostname`"
BECOME password:
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
How you want to refer to this machine [tavernier]: kelso

PLAY [setup this machine] *************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [get the username running the deploy] ********************************************************************************************
changed: [localhost]

TASK [Create main vars yml for localhost] *********************************************************************************************
changed: [localhost]

TASK [Create vars folder for this hostname] *******************************************************************************************
changed: [localhost]

TASK [Create main vars yml for target] ************************************************************************************************
changed: [localhost]

TASK [Create main vars yml for target] ************************************************************************************************
changed: [localhost]

TASK [Add target to inventory file when debian.] **************************************************************************************
skipping: [localhost]

TASK [Add target to inventory file when darwin.] **************************************************************************************
changed: [localhost]

TASK [setup passwordless sudo] ********************************************************************************************************

TASK [sudo : create sudoers] **********************************************************************************************************
skipping: [localhost]

TASK [sudo : create sudoers] **********************************************************************************************************
ok: [localhost]

TASK [sudo : add users to sudoers] ****************************************************************************************************
skipping: [localhost]

TASK [sudo : add users to sudoers] ****************************************************************************************************
ok: [localhost]

TASK [sudo : Add the to_sudo] *********************************************************************************************************
skipping: [localhost]

TASK [Set a hostname] *****************************************************************************************************************
changed: [localhost]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=10   changed=7    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
```

## Results

```
# hosts
[macbook]
kelso.localhost

[debian]

[unused]
```

The hostname here defaults to the current hostname. If selecting something different it will replace the current entry in the inventory file rather than appending. No need to add the localhost, ansible adds that automatically. Rerunning the make rule to change the hostname will replace the existing entry, it won't append

```
# host_vars/localhost.yml
users:
root:
```

The localhost file is only created if it doesnt exist. Subsequent runs of this rule will no longer modify this file so changes can be made to it if necessary

```
# host_vars/kelso.localhost/vars.yml
ansible_connection: local
```

This vars file is created in a directory named after the specified hostname. This is recreated from scratch if the command is rerun with the same hostname. Don't add to or edit anything in this file as it will be overwritten if the command is re-reun. You can however add vars that won't be lost by creating new yaml files in this directory. Those will never be overwritten. If `make thiscomputer` is run again with a different hostname, this directory will continue to exist but will no longer be used or referenced.

Read more in the main [README.md](../README.md)
