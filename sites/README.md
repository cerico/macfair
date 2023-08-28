# Sites

Sets up nginx and certbot for a url so it is ready to deploy to

## What it does

- Adds nginx.conf for named server
- Runs letsencrypt's Cerbot to certify thte url

## Detail

This project is a both a folder in the parent [macfair](https://github.com/cerioc/macfair) repo, and a repo in its own right.

```bash
➜ (main) git ls-files sites
sites/Makefile
sites/README.md
sites/ansible.cfg
sites/files/.gitkeep
sites/makefiles/ping
sites/vars.yml
```

Viewed from inside the macfair repo, due to the parent .gitignore only files central to the application are present

```bash
➜ (main) cd sites
➜ (main) git ls-files
Makefile
README.md
ansible.cfg
files/.gitkeep
files/fpl.io37.ch.nginx.conf
files/linear.io37.ch.nginx.conf
files/venlo.io37.ch.nginx.conf
fpl.io37.ch.yml
linear.io37.ch.yml
makefiles/fpl.io37.ch
makefiles/linear.io37.ch
makefiles/ping
makefiles/venlo.io37.ch
vars.yml
venlo.io37.ch.yml
```

Inside the sites folder, which is a repo in its own right, with its own .gitignore, more files are present, files unique to specific sites. These are files generated from the `macfair` repo, with the `make newsite` command.

## How To Use

```bash
➜ (main) make sites
make fpl.io37.ch
make linear.io37.ch
make venlo.io37.ch
```

`make sites` will list available sites. If cloned as part of the Macfair repo, this will be blank until you run `make newsite` to add a new entry. If cloned as the standalone repo, it will list my sites, previously created via the macfair repo

# Example runs

```bash
make fpl.io37.ch
ansible-playbook fpl.io37.ch.yml -i hosts

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [register email] *****************************************************************************************************************
changed: [localhost]

TASK [debug] **************************************************************************************************************************

PLAY [debian] *************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [fpl.io37.ch]

TASK [lookup subdomain ip] ************************************************************************************************************
changed: [fpl.io37.ch]

TASK [Copy nginx conf] ****************************************************************************************************************
changed: [fpl.io37.ch]

TASK [Creates directory] **************************************************************************************************************
changed: [fpl.io37.ch]

TASK [certify] ************************************************************************************************************************
changed: [fpl.io37.ch]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
fpl.io37.ch               : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Results

Once this is run, the url is setup with nginx and certbot, and the folder, `/var/www/fpl.io37.ch` in this case, is created. This is where the site will be deployed to. If there are configuration changes to be made, the `make` command can be run again, and it will update the nginx.conf file, and running certbot again if necessary.

With 404 and 403 pages working as followd

![404](../docs/404.png "404")

![403](../docs/403.png "403")

# NEXT STEPS
