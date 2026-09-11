
SHELL := /bin/bash
REPORT_DIR := reports

RED    := $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
PURPLE := $(shell printf '\033[0;35m')
CYAN   := $(shell printf '\033[0;36m')
BOLD   := $(shell printf '\033[1m')
RESET  := $(shell printf '\033[0m')

.PHONY: yamllint ansible-lint ansible-playbook-syntax-check lint activate-venv deactivate-venv

yamllint:
	@printf "$(YELLOW)Running yamllint...$(RESET)\n"
	@find . \( -path './.ansible' -o -path './.venv' \) -prune -o \
		-type f \( -name '*.yml' -o -name '*.yaml' \) -print0 | \
		xargs -0 -r yamllint

# Run ansible-lint on all Ansible playbooks in the repository
ansible-lint:
	@printf "$(YELLOW)Running ansible-lint...$(RESET)\n"
	@ansible-lint . --exclude .ansible

# Check the syntax of all Ansible playbooks in the repository
ansible-playbook-syntax-check:
	@printf "$(YELLOW)Running ansible-playbook syntax check...$(RESET)\n"
	@find site.yml playbooks -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 | \
	while IFS= read -r -d '' file; do \
		echo "Checking $$file"; \
		ansible-playbook --syntax-check "$$file" || exit 1; \
	done

lint: yamllint ansible-lint ansible-playbook-syntax-check
	@printf "$(GREEN)All linting checks passed.$(RESET)\n"