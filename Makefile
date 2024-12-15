ANSIBLE_PLAYBOOK := $$HOME/.pyvenv-ansible/bin/ansible-playbook
ANSIBLE_GALAXY := $$HOME/.pyvenv-ansible/bin/ansible-galaxy
tldr:
	@echo TLDR Quickstart
	@echo ---------------
	@echo "make ansible ➜ installs and sets up ansible"
	@echo "make thiscomputer ➜ Prepares this machine"
	@echo "make all ➜ Runs all available rules"
	@echo "make commands  ➜ Lists all available rules"
commands:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
ansible:
	python3 -m venv ~/.pyvenv-ansible
	source ~/.pyvenv-ansible/bin/activate && python3 -m pip install --upgrade pip
	source ~/.pyvenv-ansible/bin/activate && python3 -m pip install ansible
	$(ANSIBLE_GALAXY) collection install -r requirements.yml
thiscomputer:
	$(ANSIBLE_PLAYBOOK) thiscomputer.yml --ask-become-pass -e "hostname=`hostname`"
userkeys:
	$(ANSIBLE_PLAYBOOK) keys/keys.yml -i hosts
rootkeys:
	$(ANSIBLE_PLAYBOOK) keys/root.yml -i hosts  -e "ansible_user=root"
remote_login:
	$(ANSIBLE_PLAYBOOK) remote_login.yml -i hosts -e "ansible_user=root"
help:
	cat README.md
all:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "all"
terminal:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "terminal"
install:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "install"
debian:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "debian"
nginx:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "nginx"
rails:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "rails"
elixir:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "elixir"
vscode:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "vscode"
functions:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "functions"
keepalive:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "keepalive"
desktop:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "desktop"
slim:
	@echo setting up cutdown version with no rails or elasticsearch
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --skip-tags rails,elastic
debug:
	$(ANSIBLE_PLAYBOOK) main.yml -i hosts --tags "whoami" -vv
newsite:
	$(ANSIBLE_PLAYBOOK) newsite.yml -i hosts
newcomputer:
	$(ANSIBLE_PLAYBOOK) newcomputer.yml -i hosts
deploy_key:
	gh secret set DEPLOY_KEY < ~/.ssh/kawajevo/deploy_rsa
add_package:
	$(ANSIBLE_PLAYBOOK) addpackage.yml -i hosts
%:
	@$(MAKE) commands
