ANSIBLE=$$(python3 -m site --user-base)/bin/
COMMIT_FILE = .git/.commit-msg-template
keys:
	${ANSIBLE}ansible-playbook keys.yml -i hosts
help:
	cat README.md
version:
	echo "release: `npm pkg get version`" > group_vars/all/vars.yml
vars:
	cp hosts.example hosts
	sed -i "" -e s/`grep -w macbook hosts -A 2 | tail -1 hosts`/`hostname`/g hosts
	cp host_vars/example.yml host_vars/`hostname`.yml
	echo "users:" > host_vars/localhost.yml
	echo "  - { username: `whoami`@`hostname`, userkey: ~/.ssh/id_rsa.pub }" >> host_vars/localhost.yml
prepare: vars keys
setup: ansible
	${ANSIBLE}ansible-playbook setup.yml -i hosts --ask-become-pass
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "install" --ask-become-pass
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "terminal" --ask-become-pass
elastic:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "elastic"
debian:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "debian"
webserver:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "webserver"
rails:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "rails"
vscode:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "vscode"
aliases: version
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "aliases"
desktop:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "desktop"
slim: ansible
	@echo setting up cutdown version with no rails or elasticsearch
	${ANSIBLE}ansible-playbook setup.yml -i hosts --skip-tags rails,elastic --ask-become-pass
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
pi:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "pi" --ask-become-pass
ansible:
	python3 -m pip install --user ansible
	#${ANSIBLE}ansible-galaxy install -r requirements.yml - uncomment if necessary but think not needed anymore
debug:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "whoami" -vv
up2date:
	@zsh bin/up2date.sh
