# Ansible Task Quality

Check for Ansible best practices and common issues.

## Patterns to Find

- Using `shell`/`command` when a proper module exists
- Missing idempotency (no `creates`, `removes`, `force: no`)
- String concatenation instead of `path_join` filter
- Hyphens in variable names (use underscores)
- Missing `become: yes` for privileged operations
- Deprecated modules
- `ignore_errors: yes` without justification
- Hardcoded paths instead of variables
- Missing `mode` on file/copy/template tasks
- Using `command` for things that need shell features

## Examples

```yaml
# BAD - using shell when module exists
- name: Create directory
  shell: mkdir -p /opt/myapp

# GOOD - use file module
- name: Create directory
  file:
    path: /opt/myapp
    state: directory
    mode: '0755'
```

```yaml
# BAD - not idempotent
- name: Download file
  command: curl -O https://example.com/file.tar.gz

# GOOD - idempotent with creates
- name: Download file
  get_url:
    url: https://example.com/file.tar.gz
    dest: /tmp/file.tar.gz
    mode: '0644'
```

```yaml
# BAD - string concatenation for paths
- name: Copy config
  copy:
    src: config.yml
    dest: "{{ home_dir }}/{{ app_name }}/config.yml"

# GOOD - use path_join filter
- name: Copy config
  copy:
    src: config.yml
    dest: "{{ [home_dir, app_name, 'config.yml'] | path_join }}"
```

```yaml
# BAD - hyphens in variable names
vars:
  my-app-name: foo

# GOOD - underscores in variable names
vars:
  my_app_name: foo
```

```yaml
# BAD - missing become for privileged operation
- name: Install package
  apt:
    name: nginx

# GOOD - explicit privilege escalation
- name: Install package
  become: yes
  apt:
    name: nginx
```

```yaml
# BAD - ignore_errors without reason
- name: Do something
  command: might_fail
  ignore_errors: yes

# GOOD - handle expected failures explicitly
- name: Check if service exists
  command: systemctl status myservice
  register: service_check
  failed_when: false
  changed_when: false

- name: Start service if exists
  service:
    name: myservice
    state: started
  when: service_check.rc == 0
```

```yaml
# BAD - missing mode on file operations
- name: Copy script
  copy:
    src: script.sh
    dest: /usr/local/bin/script.sh

# GOOD - explicit mode
- name: Copy script
  copy:
    src: script.sh
    dest: /usr/local/bin/script.sh
    mode: '0755'
```

```yaml
# BAD - command when shell features needed
- name: Run with pipe
  command: cat file.txt | grep pattern

# GOOD - use shell for pipes/redirects
- name: Run with pipe
  shell: cat file.txt | grep pattern
  args:
    executable: /bin/bash
```
