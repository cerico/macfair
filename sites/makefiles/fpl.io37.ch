fpl.io37.ch:
	if ! ansible -m ping fpl.io37.ch -i ../hosts; then ansible-playbook vars.yml -i ../hosts -e "site=fpl.io37.ch"; fi
	ansible-playbook fpl.io37.ch.yml -i ../hosts
