ANSIBLE=$$(python3 -m site --user-base)/bin/
setup:
	python3 -m pip install --user ansible
	${ANSIBLE}ansible-galaxy install -r requirements.yml
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
mini:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "mini" --ask-become-pass
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
