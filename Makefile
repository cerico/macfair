ANSIBLE=$$(python3 -m site --user-base)/bin/
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
	${ANSIBLE}ansible-galaxy collection install -r requirements.yml
thiscomputer:
	${ANSIBLE}ansible-playbook thiscomputer.yml --ask-become-pass -e "hostname=`hostname`"
userkeys:
	${ANSIBLE}ansible-playbook keys/keys.yml -i hosts
rootkeys:
	${ANSIBLE}ansible-playbook keys/root.yml -i hosts  -e "ansible_user=root"
remote_login:
	${ANSIBLE}ansible-playbook remote_login.yml -i hosts -e "ansible_user=root"
help:
	cat README.md
setup:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "setup"
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "terminal"
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "install"
elastic:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "elastic"
debian:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "debian"
nginx:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "nginx"
rails:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "rails"
vscode:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "vscode"
aliases:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "aliases"
desktop:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "desktop"
slim:
	@echo setting up cutdown version with no rails or elasticsearch
	${ANSIBLE}ansible-playbook setup.yml -i hosts --skip-tags rails,elastic
debug:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "whoami" -vv
newsite:
	${ANSIBLE}ansible-playbook newsite.yml -i hosts
newcomputer:
	${ANSIBLE}ansible-playbook newcomputer.yml -i hosts
