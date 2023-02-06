ANSIBLE=$$(python3 -m site --user-base)/bin/
COMMIT_FILE = .git/.commit-msg-template
keys:
	ansible-playbook keys.yml -i hosts
help:
	cat README.md
prepare:
	cp hosts.example hosts
	sed -i "" -e s/`grep -w macbook hosts -A 2 | tail -1 hosts`/`hostname`/g hosts
	cp host_vars/example.yml host_vars/`hostname`.yml
setup: ansible
	${ANSIBLE}ansible-playbook setup.yml -i hosts --ask-become-pass
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "install" --ask-become-pass
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "terminal" --ask-become-pass
elastic:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "elastic"
rails:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "rails"
vscode:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "vscode"
git:
	${ANSIBLE}ansible-playbook setup.yml -i hosts --tags "git"
aliases:
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

patch: patch-message pr
minor: minor-message pr
major: major-message pr
patch-message:
	echo fix:  > $(COMMIT_FILE)
minor-message:
	echo feat:  > $(COMMIT_FILE)
major-message:
	echo feat!:  > $(COMMIT_FILE)
ifneq ("$(wildcard $(COMMIT_FILE))","")
pr:
	git rebase origin/main
	git reset origin/main
	git add .
	git commit
	git push -f
	gh pr create --fill
	echo fix: >  $(COMMIT_FILE)
else
pr:
	@echo run \"make patch\" , \"make minor\", or \"make major\" to create conventional commits before creating PR
endif
