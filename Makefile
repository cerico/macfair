setup:
	pip3 install ansible --user
	~/Library/Python/3.8/bin/ansible-galaxy install -r requirements.yml
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --ask-become-pass
install:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "initialize" --ask-become-pass
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "caskapps" --ask-become-pass
terminal:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "terminal"
dev:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "webdev"
databases:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "databases"
elastic:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "elastic"
zsh:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "zsh" --ask-become-pass
rails:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "rails"
picfair:
	~/Library/Python/3.8/bin/ansible-playbook setup.yml -i hosts -l local --tags "fleetnation"
