# NEWSITE ROLE

Prepares ngins and yaml files needed for configuration of a new site

## What it does

* Creates a named nginx.conf file in `sites/files`
* Creates a named ansbile role for new site in `sites`
* Adds a named entry to the Makefile in `sites/Makefile`

## How To Use

```bash
$ make newsite
```

# Example run

```bash
 make newsite
$(python3 -m site --user-base)/bin/ansible-playbook newsite.yml -i hosts
What is your app_name? - supply full url if you know it: rhyl.io37.ch

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [Create main yml] ****************************************************************************************************************
changed: [localhost]

TASK [Create nginx template] **********************************************************************************************************
changed: [localhost]

TASK [append to makefile.] ************************************************************************************************************
changed: [localhost]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

# NEXT STEPS

Now we can run the newly created role in `sites/Makefile. You can read more about that [here](/sites/README.md)
