# DEBUG / WHOAMI ROLE

The whoami role runs before any of the other roles, and exists to register some facts and variable necessary in other roles

## How To Use

```bash
$ make debug
```

It can also be run as a standalone role, as shown above. This is simply the whoami role but with extra logging

# Example run

```bash
make debug
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "whoami" -vv
PLAYBOOK: setup.yml *******************************************************************************************************************
5 plays in setup.yml

PLAY [Before everything] **************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
task path: /Users/brew/macfair/setup.yml:2
ok: [localhost]

TASK [Get version] ********************************************************************************************************************
task path: /Users/brew/macfair/setup.yml:6
changed: [localhost] => {"changed": true, "cmd": ["npm", "pkg", "get", "version"], "delta": "0:00:00.941948", "end": "2023-03-16 22:41:07.591252", "msg": "", "rc": 0, "start": "2023-03-16 22:41:06.649304", "stderr": "", "stderr_lines": [], "stdout": "\"0.21.10\"", "stdout_lines": ["\"0.21.10\""]}

TASK [Print version] ******************************************************************************************************************
task path: /Users/brew/macfair/setup.yml:10
ok: [localhost] => {
    "macfair_version.stdout": "\"0.21.10\""
}

PLAY [Setup MacBook and debian] *******************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
task path: /Users/brew/macfair/setup.yml:13
ok: [kelso.localhost]

TASK [whoami : get the username running the deploy] ***********************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:2
changed: [kelso.localhost] => {"changed": true, "cmd": ["whoami"], "delta": "0:00:00.011874", "end": "2023-03-16 22:41:08.842306", "msg": "", "rc": 0, "start": "2023-03-16 22:41:08.830432", "stderr": "", "stderr_lines": [], "stdout": "brew", "stdout_lines": ["brew"]}

TASK [whoami : debug] *****************************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:7
ok: [kelso.localhost] => {
    "macbook_user.stdout": "brew"
}

TASK [whoami : get git email] *********************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:9
changed: [kelso.localhost] => {"changed": true, "cmd": ["git", "config", "--get", "user.email"], "delta": "0:00:00.034272", "end": "2023-03-16 22:41:09.256662", "msg": "", "rc": 0, "start": "2023-03-16 22:41:09.222390", "stderr": "", "stderr_lines": [], "stdout": "garethrobertlee@gmail.com", "stdout_lines": ["garethrobertlee@gmail.com"]}

TASK [whoami : debug] *****************************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:15
ok: [kelso.localhost] => {
    "git_email.stdout": "garethrobertlee@gmail.com"
}

TASK [whoami : get git name] **********************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:17
changed: [kelso.localhost] => {"changed": true, "cmd": ["git", "config", "--get", "user.name"], "delta": "0:00:00.011233", "end": "2023-03-16 22:41:09.644046", "msg": "", "rc": 0, "start": "2023-03-16 22:41:09.632813", "stderr": "", "stderr_lines": [], "stdout": "cerico", "stdout_lines": ["cerico"]}

TASK [whoami : debug] *****************************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:23
ok: [kelso.localhost] => {
    "git_name.stdout": "cerico"
}

TASK [whoami : get the brew users name] ***********************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:25
changed: [kelso.localhost] => {"changed": true, "cmd": ["stat", "-f", "%Su", "/usr/local/bin/brew"], "delta": "0:00:00.008716", "end": "2023-03-16 22:41:10.034313", "msg": "", "rc": 0, "start": "2023-03-16 22:41:10.025597", "stderr": "", "stderr_lines": [], "stdout": "brew", "stdout_lines": ["brew"]}

TASK [whoami : debug] *****************************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:31
ok: [kelso.localhost] => {
    "brew_user.stdout": "brew"
}

TASK [whoami : print role name] *******************************************************************************************************
task path: /Users/brew/macfair/roles/whoami/tasks/main.yml:34
ok: [kelso.localhost] => {"ansible_facts": {"parent_role_name": "whoami"}, "changed": false}

skipping: [localhost] => {}

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=14   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

```

