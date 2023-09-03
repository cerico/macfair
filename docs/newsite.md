# NEWSITE ROLE

Prepares nginx and yaml files needed for configuration of a new site. THe role writes to a separate location, outside of macfair. By default this is a directory on the same level as wherever you have macfair installed, but can also be set to any location my modifying the `host_vars/localhomst.yml` as follows

```bash
☁  kelso:macfair ➜ (main) ✗ grep sites_dir host_vars/localhost.yml
sites_dir: "~/apps/live"
```

The new files will be written to the target location, after cloning the sites repo. By default this will be `git@github.com/cerico/nginx-files.git` but can also be set to a different repo if preferred, via the `nginx_repo` variable in `host_vars/localhost.yml` as follows

```bash
☁  kelso:macfair ➜ (main) ✗ grep nginx_repo host_vars/localhost.yml
nginx_repo: "git@github/username/reponame.git"
```

## What it does

- Creates a named nginx.conf file in `files`
- Creates a named ansbile role for new site
- Adds a named entry to the Makefile in `Makefile`
- Adds an entry to ansible hosts file in `hosts`

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

Now we can run the newly created role in the Makefile of the sites repo. `cd ../sites` or cd into wherever the specified location in `host_vars/localhost.yml` is, and run `make` with followed by the url of the site you added when prompted in `make newsite`. For more details, check the [README](https://github.com/cerico/nginx-files/blob/main/README.md) in the sites repo.

```bash

```
