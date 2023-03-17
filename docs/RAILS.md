# RAILS ROLE

## What it does

* Installs rbenv
* Clones rbenv vars
* Adds rbenv to zshrc
* Install bundler v2
* Installs Ruby
* Installs Ruby on Rails 6
* Installs Ruby on Rauls 7

## How To Use

```bash
$ make rails
```

# Example run

```bash
make rails
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "rails"

PLAY [Before everything] **************************************************************************************************************

TASK [rails : Clone Rbenv] ************************************************************************************************************
changed: [kelso.localhost]

TASK [rails : Clone rbenv build] ******************************************************************************************************
changed: [kelso.localhost]

TASK [rails : Copy zsh rails] *********************************************************************************************************
ok: [kelso.localhost]

TASK [rails : Add Rbenv to .zshrc] ****************************************************************************************************
ok: [kelso.localhost]

TASK [rails : Clone rbenv vars] *******************************************************************************************************
changed: [kelso.localhost]

TASK [rails : check ruby 2.7.4 is installed for system] *******************************************************************************
fatal: [kelso.localhost]: FAILED! => {"changed": false, "cmd": "~brew/.rbenv/bin/rbenv versions | grep 2.7.4", "delta": "0:00:02.370849", "end": "2023-03-17 04:46:34.551887", "msg": "non-zero return code", "rc": 1, "start": "2023-03-17 04:46:32.181038", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

TASK [rails : rbenv install ruby] *****************************************************************************************************
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC POLL on kelso.localhost: jid=99186174529.18214 started=1 finished=0
ASYNC OK on kelso.localhost: jid=99186174529.18214
changed: [kelso.localhost]

TASK [rails : check if current system ruby version is 2.7.4] **************************************************************************
fatal: [kelso.localhost]: FAILED! => {"changed": false, "cmd": "~brew/.rbenv/bin/rbenv version | cut -d ' ' -f 1 | grep -Fx '2.7.4'", "delta": "0:00:00.093507", "end": "2023-03-17 04:53:04.055171", "msg": "non-zero return code", "rc": 1, "start": "2023-03-17 04:53:03.961664", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

TASK [rails : rbenv set global ruby version and rehash] *******************************************************************************
changed: [kelso.localhost]

TASK [rails : install bundler v2] *****************************************************************************************************
changed: [kelso.localhost]

TASK [rails : install rails 7] ********************************************************************************************************
changed: [kelso.localhost]

TASK [rails : install rails 6] ********************************************************************************************************
changed: [kelso.localhost]

TASK [rails : rehash] *****************************************************************************************************************
changed: [kelso.localhost]

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=31   changed=14   unreachable=0    failed=0    skipped=0    rescued=0    ignored=2
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
