#################################################################################
# GLOBALS                                                                       #
#################################################################################

PYTHON_INTERPRETER = python
BASH ?= bash

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Release a new version
.PHONY: release
release:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION argument required."; \
		echo "Usage: make release VERSION=<version>"; \
		exit 1; \
	fi
	$(BASH) ./prepare_release.sh $(VERSION)
 

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
