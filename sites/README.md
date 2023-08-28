# Sites

Sets up nginx and certbot for a url so it is ready to deploy to

## What it does

- Adds nginx.conf for named server
- Runs letsencrypt's Cerbot to certify thte url

## Detail

This projet is a both a folder in the parent [macfair](https://github.com/cerioc/macfair) repo, and a repo in its own right.

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

Inside the sites folder, whidh is a repo in its own right, with its own .gitignore, many more files are present, files unique to specific sites. These are files generated from the `macfair` repo, with the `make newsite` command.

Existing entries can be run via their entry in the Makefile eg `make rhyl.io37.ch`. New entries should be created with `make newsite`

Server should already be created via `make newcomputer` and `make debian` from the top level Makefile. Domain or subdomain should be resolveable correctly. This can be done with the `godaddy` command if the domain or subdomain is already owned. Otherwise, go buy it!

## How To Use

```bash
$ make rhyl.io37.ch
```

# Example runs

```bash
 make rhyl.io37.ch
ansible-playbook rhyl.io37.ch.yml -i ../hosts

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [register email] *****************************************************************************************************************
changed: [localhost]

TASK [debug] **************************************************************************************************************************

PLAY [debian] *************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [rhyl.io37.ch]

TASK [lookup subdomain ip] ************************************************************************************************************
changed: [rhyl.io37.ch]

TASK [Copy nginx conf] ****************************************************************************************************************
changed: [rhyl.io37.ch]

TASK [Creates directory] **************************************************************************************************************
changed: [rhyl.io37.ch]

TASK [certify] ************************************************************************************************************************
changed: [rhyl.io37.ch]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rhyl.io37.ch               : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```bash
make newsite
ansible-playbook ../newsite.yml -i ../hosts
What is your app_name? - supply full url if you know it: dox.io37.ch

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

# Results

Creates the following nginx.conf file

```bash
# /etc/nginx/conf.d/rhyl.io37.ch.conf
server {
    server_name rhyl.io37.ch;
    location = /favicon.ico {
      alias /var/www/html/favicon.ico;
    }
    root /var/www/html/rhyl.io37.ch;
    index index.html;
    include snippets/errors.conf;
    add_header Content-Security-Policy "font-src 'self' https://rsms.me  https://*.gstatic.com data:; frame-src 'se
lf'; connect-src 'self' https://apis.google.com; object-src 'none'; img-src 'self' https://*.ggpht.com https://*.go
ogleapis.com https://*.gstatic.com data:; script-src 'self' 'unsafe-eval' 'unsafe-inline' https://d3js.org https://
*.googleapis.com; style-src 'self' https://rsms.me https://*.googleapis.com 'unsafe-inline';form-action 'self'; bas
e-uri 'self';default-src 'self';frame-ancestors 'self'";

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/rhyl.io37.ch/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/rhyl.io37.ch/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = rhyl.io37.ch) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name rhyl.io37.ch;
    listen 80;
    return 404; # managed by Certbot


}
```

With 404 and 403 pages working as followd

![404](../docs/404.png){:height="36px" width="36px"}

![403](../docs/403.png "403")

# NEXT STEPS

Deploy a site to the URL
