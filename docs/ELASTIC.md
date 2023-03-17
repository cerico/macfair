# ELASTIC ROLE

# What it does

Installs ElasticSearch

## How To Use

```bash
$ make elastic
```

Is also run automatically as part of both `make macbook` and `make debian`

Runs on both macbook and debian targets

# Example run

```bash
 make elastic
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "desktop"

PLAY [Before everything] **************************************************************************************************************

TASK [elastic : download elastic] *****************************************************************************************************
changed: [kelso.localhost]

TASK [elastic : install elastic] ******************************************************************************************************
changed: [kelso.localhost]

TASK [elastic : remove tar] ***********************************************************************************************************
changed: [kelso.localhost]

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=21   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Read more in the main [README.md](../README.md)
