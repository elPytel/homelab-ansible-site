
SHELL := /bin/bash
PYTHON_REQUIREMENTS := requirements.txt
ANSIBLE_REQUIREMENTS := requirements.yml

RED	:= $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
PURPLE := $(shell printf '\033[0;35m')
CYAN   := $(shell printf '\033[0;36m')
BOLD   := $(shell printf '\033[1m')
RESET  := $(shell printf '\033[0m')

.PHONY: yamllint ansible-lint ansible-playbook-syntax-check lint setup setup-venv setup-galaxy clean clean-all help

all: lint

install: 
	sudo apt install -y yamllint ansible-lint

YAMLLINT := Run yamllint on all YAML files in the repository
yamllint:
	@printf "$(YELLOW)Running yamllint...$(RESET)\n"
	@find . \( -path './.ansible' -o -path './.venv' \) -prune -o \
		-type f \( -name '*.yml' -o -name '*.yaml' \) -print0 | \
		xargs -0 -r yamllint

ANSIBLE-LINT := Run ansible-lint on all Ansible playbooks in the repository
ansible-lint:
	@printf "$(YELLOW)Running ansible-lint...$(RESET)\n"
	@ansible-lint . --exclude .ansible

ANSIBLE-PLAYBOOK-SYNTAX-CHECK := Check the syntax of all Ansible playbooks in the repository
ansible-playbook-syntax-check:
	@printf "$(YELLOW)Running ansible-playbook syntax check...$(RESET)\n"
	@find site.yml playbooks -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 | \
	while IFS= read -r -d '' file; do \
		echo "Checking $$file"; \
		ansible-playbook --syntax-check "$$file" || exit 1; \
	done

LINT := Run all linting checks (yamllint, ansible-lint, and ansible-playbook syntax check)
lint: yamllint ansible-lint ansible-playbook-syntax-check
	@printf "$(GREEN)All linting checks passed.$(RESET)\n"

SETUP-VENV := setup-venv - Set up the virtual environment and install Python dependencies.
.venv/.setup-complete: $(PYTHON_REQUIREMENTS) bin/setup-venv
	@printf "$(YELLOW)Setting up the virtual environment...$(RESET)\n"
	@bin/setup-venv
	@touch $@

SETUP-GALAXY := setup-galaxy - Install Ansible roles and collections.
.ansible/.setup-complete: .venv/.setup-complete $(ANSIBLE_REQUIREMENTS) bin/setup-galaxy
	@printf "$(YELLOW)Installing Ansible roles and collections...$(RESET)\n"
	@bin/setup-galaxy
	@touch $@

SETUP := Download and install dependencies, set up virtual environment, and prepare the development environment.
setup: .ansible/.setup-complete
	@printf "$(GREEN)Setup complete.$(RESET)\n"

output2human_readable:
	@printf "$(YELLOW)Converting $(REPORT_DIR)/ansible_output.json to human-readable format...$(RESET)\n"
	@python3 scripts/output2human_readable.py $(REPORT_DIR)/ansible_output.json

$(REPORT_DIR):
	@mkdir -p $@

play.update_lobsang: | $(REPORT_DIR)
	@printf "$(YELLOW)Running playbook: ${BLUE}update_lobsang.yml$(RESET)...\n"
	@ANSIBLE_STDOUT_CALLBACK=json ansible-playbook playbooks/update_lobsang.yml --check > $(REPORT_DIR)/ansible_output.json
	@ansible-playbook playbooks/update_lobsang.yml --check

CLEAN := Clean build artifacts.
clean:
	@printf "$(YELLOW)Cleaning up...$(RESET)\n"
	@rm -rf $(REPORT_DIR)

CLEAN-ALL := Clean all build artifacts and dependencies.
clean-all: clean
	@printf "$(YELLOW)Cleaning up virtual environment...$(RESET)\n"
	@rm -rf .venv
	@printf "$(YELLOW)Cleaning up Ansible cache...$(RESET)\n"
	@rm -rf .ansible

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all:                   Run all linting checks."
	@echo "  yamllint:              $(YAMLLINT)"
	@echo "  ansible-lint:          $(ANSIBLE-LINT)"
	@echo "  ansible-playbook-syntax-check: $(ANSIBLE-PLAYBOOK-SYNTAX-CHECK)"
	@echo "  lint:                  $(LINT)"
	@echo "  setup:                 $(SETUP)"
	@echo "  output2human_readable: Convert Ansible JSON output to human-readable format."
	@echo "  play.update_lobsang:   Run the update_lobsang.yml playbook and save the output to a JSON file."
	@echo "  clean:                 $(CLEAN)"
	@echo "  clean-all:             $(CLEAN-ALL)"