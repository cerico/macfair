venlo.io37.ch:
	if ! ansible -m ping venlo.io37.ch -i ../hosts; then ansible-playbook vars.yml -i ../hosts -e "site=venlo.io37.ch"; fi
	ansible-playbook venlo.io37.ch.yml -i ../hosts
