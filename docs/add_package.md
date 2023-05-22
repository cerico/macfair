# ADD_PACKAGE PLAYBOOK

This Ansible playbook provides a multiple-choice menu for selecting a host_vars file and adding an optional package to it. The playbook prompts the user for an optional package name and then presents a menu of available host_vars files to choose from. Once a file is selected, the playbook adds the optional package to the chosen host_vars file.

## What it does

* Adds new optional package to the specified host_vars/'hostname'/vars.yml file

## How To Use

```bash
$ make add_package
```

## Example run

```bash
$  make add_package
ansible_user: "deploy"
$(python3 -m site --user-base)/bin/ansible-playbook addpackage.yml -i hosts
What is the optional package you want to add? [docker]:

PLAY [Multiple Choice Menu] **********************************************************************************************

TASK [Get host variable filenames] ***************************************************************************************
ok: [localhost]

TASK [Create multiple-choice menu] ***************************************************************************************
ok: [localhost]

TASK [Display menu] ******************************************************************************************************
[Display menu]
Select a host variable file: ['chester.pi', 'kelso.localhost', 'macfair.io37.ch']:
chester.pi
ok: [localhost]

TASK [Process selection] *************************************************************************************************
ok: [localhost] => {
    "menu_selection.user_input": "chester.pi"
}

TASK [Add target to inventory file when debian.] *************************************************************************
changed: [localhost]

TASK [Add new package to host vars.] *************************************************************************************
changed: [localhost]

PLAY RECAP ***************************************************************************************************************
localhost                  : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

## Results

The package is added to the `optional` section of the specified hostname's vars.yml in host_vars. If the `optional` section isn't present then it is also created first.

<pre>
# host_vars/chester.pi/vars.yml
ansible_user: "deploy"
to_sudo:
  - deploy
optional:
 - docker
</pre>

The optional package option can then be used as a conditional anywhere in any playbook or role as a `when` condition as follows

```yml
when: hostvars[inventory_hostname].optional is defined and "docker" in hostvars[inventory_hostname].optional
```

Read more in the main [README.md](../README.md)
