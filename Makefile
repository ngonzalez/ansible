# Install ansible, test this repository, set up the node and deploy.
# e.g. make deploy TAGS=nginx-stream,app-stream
# The admin repository forwards its ansible-*, setup and deploy targets here.

INVENTORY ?= inventory.yaml
TAGS ?=

PLAYBOOK = ansible-playbook -i $(INVENTORY)

.DEFAULT_GOAL := help

help: ## List the targets
	@echo "ansible: make <target> [VAR=value]"
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t/' | expand -t 10 | sed 's/^/  /'
	@echo "  setup, deploy: TAGS=<tags from make tags, comma-separated>, or nothing for everything"
	@echo "  (a plain make setup includes the kube role: it rebuilds the cluster)"
	@echo "  dry-run: TAGS=<setup tags, e.g. firewall>"
.PHONY: help

install: ## Install ansible and ansible-lint (requirements.txt) with pyenv
	@pyenv install -s $$(cat .python-version) && python -m pip install -q -r requirements.txt && ansible --version | head -1
.PHONY: install

ping: ## Check that ansible reaches the node
	@ansible -i $(INVENTORY) all -m ping
.PHONY: ping

facts: ## Show the facts ansible gathers on the node
	@ansible -i $(INVENTORY) all -m ansible.builtin.setup
.PHONY: facts

tags: ## List the TAGS that setup and deploy accept
	@for p in setup deploy; do \
		printf '%-8s' "$$p:"; $(PLAYBOOK) $$p.yml --list-tags 2>/dev/null | sed -n 's/.*TASK TAGS: \[\(.*\)\]/\1/p' | tr -d ' ' | tr ',' '\n' | grep -vxE 'always|never' | paste -sd' ' -; done
.PHONY: tags

test: ## Test: syntax, lint, role tests (no node needed)
	@$(PLAYBOOK) setup.yml deploy.yml --syntax-check
	@ansible-lint
	@for t in tests/*.yml; do ansible-playbook "$$t" || exit 1; done
.PHONY: test

dry-run: ## Show what setup.yml would change on the node (--check --diff)
	@$(PLAYBOOK) setup.yml --check --diff $(if $(TAGS),--tags $(TAGS))
.PHONY: dry-run

# The kube role (tag kubernetes) runs `kubeadm reset -f` before `kubeadm init`:
# a plain `make setup` rebuilds the cluster, and everything must be redeployed
setup: ## Configure the node with setup.yml (all roles, or TAGS)
	@$(PLAYBOOK) setup.yml --diff $(if $(filter-out all,$(TAGS)),--tags $(TAGS))
.PHONY: setup

deploy: ## Deploy to the cluster with deploy.yml (all projects, or TAGS)
	@$(PLAYBOOK) deploy.yml --diff $(if $(filter-out all,$(TAGS)),--tags $(TAGS))
.PHONY: deploy
