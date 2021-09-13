setup:
	pip3 install ansible --user
	~/Library/Python/3.8/bin/ansible-galaxy install -r requirements.yml
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --ask-become-pass
