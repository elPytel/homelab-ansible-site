
SHELL := /bin/bash
PYTHON_REQUIREMENTS  := requirements.txt
ANSIBLE_REQUIREMENTS := requirements.yml

RED	   := $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
PURPLE := $(shell printf '\033[0;35m')
CYAN   := $(shell printf '\033[0;36m')
BOLD   := $(shell printf '\033[1m')
RESET  := $(shell printf '\033[0m')

.PHONY: yaml-lint ansible-lint ansible-playbook-syntax-check lint setup setup-venv setup-galaxy clean clean-all help

ALL := Run all linting checks (yamllint, ansible-lint, and ansible-playbook syntax check)
all: lint

INSTALL := Install required packages
install: 
	sudo apt install -y yamllint
	@touch install

YAML-LINT := Run yamllint on all YAML files in the repository
yaml-lint:
	@printf "$(YELLOW)Running yamllint...$(RESET)\n"
	@bin/find-yaml-files.sh --print0 | xargs -0 -r yamllint

ANSIBLE-LINT := Run ansible-lint on all Ansible playbooks in the repository
ansible-lint:
	@printf "$(YELLOW)Running ansible-lint...$(RESET)\n"
	@ansible-lint || echo "Try running 'make auto-fix-syntax' to automatically fix syntax issues in Ansible playbooks."

ANSIBLE-PLAYBOOK-SYNTAX-CHECK := Check the syntax of all Ansible playbooks in the repository
ansible-playbook-syntax-check:
	@printf "$(YELLOW)Running ansible-playbook syntax check...$(RESET)\n"
	@while IFS= read -r -d '' file; do \
		printf "$(YELLOW)Checking $$file...$(RESET)"; \
		ansible-playbook --syntax-check "$$file" || exit 1; \
		printf "$(GREEN)Syntax check passed for $$file.$(RESET) \n\n"; \
	done < <(bin/find-yaml-files.sh --print0 site.yml playbooks)

LINT := Run all linting checks (yaml-lint, ansible-lint, and ansible-playbook syntax check)
lint: yaml-lint ansible-lint ansible-playbook-syntax-check
	@printf "$(GREEN)All linting checks passed.$(RESET)\n"

AUTO-FIX-SYNTAX := Automatically fix syntax issues in Ansible playbooks using ansible-lint
auto-fix-syntax:
	@printf "$(YELLOW)Automatically fixing syntax issues in Ansible playbooks...$(RESET)\n"
	@ansible-lint . --exclude .ansible --fix

ensure-jq:
	@command -v jq >/dev/null 2>&1 && { \
		printf "$(GREEN)jq is already installed.$(RESET)\n"; \
	} || { \
		printf "$(YELLOW)jq is not installed. Installing jq...$(RESET)\n"; \
		bin/ensure-jq; \
	}

VAULT-PASS:=Generate .vault_pass file for Ansible Vault.
.vault_pass:
	@printf "$(YELLOW)Generating .vault_pass file...$(RESET)\n"
	@bin/generate_vault_pass.sh

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
	@echo ""
	@echo "Targets:"
	@echo "  all:                   $(ALL)"
	@echo "  install:               $(INSTALL)"
	@echo "  yaml-lint:             $(YAML-LINT)"
	@echo "  ansible-lint:          $(ANSIBLE-LINT)"
	@echo "  ansible-playbook-syntax-check: $(ANSIBLE-PLAYBOOK-SYNTAX-CHECK)"
	@echo "  lint:                  $(LINT)"
	@echo "  setup:                 $(SETUP)"
	@echo "  clean:                 $(CLEAN)"
	@echo "  clean-all:             $(CLEAN-ALL)"