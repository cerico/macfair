ANSIBLE=$$(python3 -m site --user-base)/bin/
thistarget:
	${ANSIBLE}ansible-playbook thistarget.yml
userkeys:
	${ANSIBLE}ansible-playbook keys/keys.yml -i hosts
rootkeys:
	${ANSIBLE}ansible-playbook keys/root.yml -i hosts  -e "ansible_user=root"
remote_login:
	${ANSIBLE}ansible-playbook remote_login.yml -i hosts -e "ansible_user=root"
help:
	cat README.md
version:
	echo "release: `npm pkg get version`" > group_vars/all/vars.yml
setup: ansible
	${ANSIBLE}ansible-playbook setup.yml -i hosts
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "install"
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "terminal"
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
aliases: version
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "aliases"
desktop:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "desktop"
slim: ansible
	@echo setting up cutdown version with no rails or elasticsearch
	${ANSIBLE}ansible-playbook setup.yml -i hosts --skip-tags rails,elastic
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
ansible:
	python3 -m pip install --user ansible
	#${ANSIBLE}ansible-galaxy install -r requirements.yml - uncomment if necessary but think not needed anymore
debug:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "whoami" -vv
up2date:
	@zsh bin/up2date.sh
newsite:
	${ANSIBLE}ansible-playbook newsite.yml -i hosts
newtarget:
	${ANSIBLE}ansible-playbook newtarget.yml -i hosts
