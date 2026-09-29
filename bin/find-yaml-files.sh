#!/usr/bin/env bash
# By Pytel
# This script finds all YAML files in the repository, excluding certain directories.

set -euo pipefail

# This script finds all YAML files in the repository, excluding certain directories.
if [[ "${1:-}" == "--print0" ]]; then
	find . \( -path './.ansible' -o -path './.venv' \) -prune -o \
		-type f \( -name '*.yml' -o -name '*.yaml' \) -print0
	exit 0
fi

# If no arguments are provided, print usage and exit with an error code.
if [[ "$#" -ne 0 ]]; then
	printf 'Usage: %s [--print0]\n' "$0" >&2
	exit 2
fi

# Find all YAML files in the repository, excluding certain directories, and print their paths.
find . \( -path './.ansible' -o -path './.venv' \) -prune -o \
	-type f \( -name '*.yml' -o -name '*.yaml' \)
