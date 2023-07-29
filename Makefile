tldr:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
fix:
	echo 'export PATH="'$$(python3 -m site --user-base)'/bin:$$PATH"' >> ~/.zshrc
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
	ansible-galaxy collection install -r requirements.yml
thiscomputer:
	ansible-playbook thiscomputer.yml --ask-become-pass -e "hostname=`hostname`"
userkeys:
	ansible-playbook keys/keys.yml -i hosts
rootkeys:
	ansible-playbook keys/root.yml -i hosts  -e "ansible_user=root"
remote_login:
	ansible-playbook remote_login.yml -i hosts -e "ansible_user=root"
help:
	cat README.md
setup:
	ansible-playbook setup.yml -i hosts --tags "setup"
terminal:
	ansible-playbook setup.yml -i hosts --tags "terminal"
install:
	ansible-playbook setup.yml -i hosts --tags "install"
debian:
	ansible-playbook setup.yml -i hosts --tags "debian"
nginx:
	ansible-playbook setup.yml -i hosts --tags "nginx"
rails:
	ansible-playbook setup.yml -i hosts --tags "rails"
vscode:
	ansible-playbook setup.yml -i hosts --tags "vscode"
aliases:
	ansible-playbook setup.yml -i hosts --tags "aliases"
desktop:
	ansible-playbook setup.yml -i hosts --tags "desktop"
slim:
	@echo setting up cutdown version with no rails or elasticsearch
	ansible-playbook setup.yml -i hosts --skip-tags rails,elastic
debug:
	ansible-playbook setup.yml -i hosts --tags "whoami" -vv
newsite:
	ansible-playbook newsite.yml -i hosts
newcomputer:
	ansible-playbook newcomputer.yml -i hosts
deploy_key:
	gh secret set DEPLOY_KEY < ~/.ssh/kawajevo/deploy_rsa
add_package:
	ansible-playbook addpackage.yml -i hosts
