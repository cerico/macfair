# Ansible tag targets - auto-generated from ANSIBLE_TAGS list
# To add a new target, just add the tag name to ANSIBLE_TAGS

ANSIBLE_TAGS := terminal install debian nginx rails vscode functions claude keepalive diskspace desktop ruben agent

define ansible_tag
.PHONY: $(1)
$(1):
	$$(ANSIBLE_PLAYBOOK) setup.yml -i hosts --tags "$(1)"
endef

$(foreach tag,$(ANSIBLE_TAGS),$(eval $(call ansible_tag,$(tag))))
