linear.io37.ch:
	if ! ansible -m ping linear.io37.ch -i ../hosts; then ansible-playbook vars.yml -i ../hosts -e "site=linear.io37.ch"; fi
	ansible-playbook linear.io37.ch.yml -i ../hosts
