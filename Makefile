ANSIBLE_PLAYBOOK := $$HOME/.pyvenv-ansible/bin/ansible-playbook
ANSIBLE_GALAXY := $$HOME/.pyvenv-ansible/bin/ansible-galaxy
tldr:
	@echo TLDR Quickstart
	@echo ---------------
	@echo "make ansible ➜ installs and sets up ansible"
	@echo "make thiscomputer ➜ Prepares this machine"
	@echo "make setup ➜ Runs all available roles"
	@echo "make commands ➜ Lists all available commands"
	@echo ""
	@echo Roles
	@echo -----
	@grep '^ANSIBLE_TAGS' makefiles/roles.mk | cut -d '=' -f 2 | tr ' ' '\n' | grep -v '^$$' | sort | sed 's/^/make /'
commands:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
	@echo ""
	@echo Roles
	@echo -----
	@grep '^ANSIBLE_TAGS' makefiles/roles.mk | cut -d '=' -f 2 | tr ' ' '\n' | grep -v '^$$' | sort | sed 's/^/make /'
ansible:
	python3 -m venv ~/.pyvenv-ansible
	source ~/.pyvenv-ansible/bin/activate && python3 -m pip install --upgrade pip
	source ~/.pyvenv-ansible/bin/activate && python3 -m pip install ansible passlib
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
setup:
	$(ANSIBLE_PLAYBOOK) setup.yml -i hosts --tags "setup"
slim:
	@echo setting up cutdown version with no rails or elasticsearch
	$(ANSIBLE_PLAYBOOK) setup.yml -i hosts --skip-tags rails,elastic
debug:
	$(ANSIBLE_PLAYBOOK) setup.yml -i hosts --tags "whoami" -vv
newsite:
	$(ANSIBLE_PLAYBOOK) newsite.yml -i hosts
newcomputer:
	$(ANSIBLE_PLAYBOOK) newcomputer.yml -i hosts
deploy_key:
	gh secret set DEPLOY_KEY < ~/.ssh/kawajevo/deploy_rsa
add_package:
	$(ANSIBLE_PLAYBOOK) addpackage.yml -i hosts
vault:
	$(dir $(ANSIBLE_PLAYBOOK))ansible-vault edit group_vars/all/vault.yml
claudepod:
	podman build -t claudepod -f files/claude/Containerfile .
upgrade:
	$(ANSIBLE_PLAYBOOK) upgrade.yml -i hosts
%:
	@$(MAKE) commands
include makefiles/*.mk
