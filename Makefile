ANSIBLE=$$(python3 -m site --user-base)/bin/
setup: ansible
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --ask-become-pass
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "initialize" --ask-become-pass
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "terminal" --ask-become-pass
elastic:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "elastic"
rails:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "rails"
vscode:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "vscode"
desktop:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "desktop"
slim: ansible
	@echo setting up cutdown version with no rails or elasticsearch
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --skip-tags rails,elastic --ask-become-pass
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
ansible:
	python3 -m pip install --user ansible
