# Common errors

```sh
$(python3 -m site --user-base)/bin/ansible-playbook thiscomputer.yml --ask-become-pass
/bin/sh: /Users/deepmind/Library/Python/3.11/bin/ansible-playbook: No such file or directory
make: *** [thiscomputer] Error 127
```

Macfair can't find ansible. To fix run the following

`make upgrade`

```sh
sh$(python3 -m site --user-base)/bin/ansible-galaxy collection install -r requirements.yml
/bin/sh: /Users/deepmind/Library/Python/3.11/bin/ansible-galaxy: No such file or directory
make: *** [thiscomputer] Error 127
```

Macfair can't find ansible. To fix run the following

`make upgrade`

```sh
ok: [localhost] => {
    "msg": [
        "Host file not set up yet. To set it up run the following",
        "make thiscomputer"
    ]
}
```

Inventory file and vars haven't been setup yet. To fix run the following

`make thiscomputer`
