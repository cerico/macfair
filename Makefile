ANSIBLE=$$(python3 -m site --user-base)/bin/
setup:
	python3 -m pip install --user ansible
	${ANSIBLE}ansible-galaxy install -r requirements.yml
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --ask-become-pass
install:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "initialize" --ask-become-pass
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "caskapps" --ask-become-pass
terminal:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "terminal"
dev:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "webdev"
databases:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "databases"
elastic:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "elastic"
zsh:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "zsh" --ask-become-pass
rails:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "rails"
vscode:
	${ANSIBLE}ansible-playbook setup.yml -i hosts -l local --tags "vscode"
update:
	python3 -m pip install --upgrade pip
	python3 -m pip install --user ansible
