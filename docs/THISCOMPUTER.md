# THISCOMPUTER

Sets up the host machine, ready to run the other roles

## What it does

* Creates and populates the inventory file (hosts)
* Creates and populates the host_vars/localhost.yml file
* Creates and populates a host_vars directory and vars file for hostname of current machine
* Sets up passwordless sudo for current user

## How To Use

```bash
$ make thiscomputer
```

### Details

`make thiscomputer` defaults the hostname to the current hostname. If selecting something different it will replace the current entry in the inventory file rather than appending.

`host_vars/localhost.yml` is only created if it doesn't already exists. Once it is created, it is never modified by `make thiscomputer`

A vars.yml file inside a hostname based directory in host_vars will be recreated anytime `make thiscomputer` is run. But any yml files in the same directory will be untouched. If a hostname is changed, old hostname directories remaining in the host_vars directory are no longer used

`make thiscomputer` always asks for a sudo password, even if passwordless sudo has been set up. It is the only rule for which this is the case


Read more in the main [README.md](../README.md)
