# DESKTOP ROLE

# What it does

* Copies wallpapers and sets default wallpaper
* Sets up dock

## How To Use

```bash
$ make desktop
```

Is also run automatically as part of `make macbook`

Only runs on targets in the macbook group

# Example run

```bash
 make desktop
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "desktop"

PLAY [Before everything] **************************************************************************************************************

TASK [desktop : Create wallpapers directory.] *****************************************************************************************
ok: [kelso.localhost]

TASK [desktop : Copy wallpapers] ******************************************************************************************************
ok: [kelso.localhost] => (item=wallpapers/bluetiled.png)
ok: [kelso.localhost] => (item=wallpapers/greentiled.png)
ok: [kelso.localhost] => (item=wallpapers/oaktiled.png)

TASK [desktop : wallpaper] ************************************************************************************************************
changed: [kelso.localhost]

TASK [desktop : Remove superfluous from dock] *****************************************************************************************
changed: [kelso.localhost] => (item=Mail)
changed: [kelso.localhost] => (item=TV)
changed: [kelso.localhost] => (item=News)
changed: [kelso.localhost] => (item=Music)
changed: [kelso.localhost] => (item=Podcasts)
changed: [kelso.localhost] => (item=Calendar)
changed: [kelso.localhost] => (item=Launchpad)
changed: [kelso.localhost] => (item=Contacts)
changed: [kelso.localhost] => (item=Maps)
changed: [kelso.localhost] => (item=Photos)
changed: [kelso.localhost] => (item=Messages)
changed: [kelso.localhost] => (item=FaceTime)
changed: [kelso.localhost] => (item=Notes)
changed: [kelso.localhost] => (item=Reminders)
changed: [kelso.localhost] => (item=App Store)
changed: [kelso.localhost] => (item=System Preferences)

TASK [desktop : Check if items in dock exist] *****************************************************************************************
changed: [kelso.localhost] => (item={'name': 'iTerm', 'path': '/Users/brew/Applications/iTerm.app'})
changed: [kelso.localhost] => (item={'name': 'Visual Studio Code', 'path': '/Users/brew/Applications/Visual Studio Code.app'})
changed: [kelso.localhost] => (item={'name': 'Firefox', 'path': '/Users/brew/Applications/Firefox.app'})

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=23   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Read more in the main [README.md](../README.md)
