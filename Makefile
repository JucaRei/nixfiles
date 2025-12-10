MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

check:
	nix flake check --extra-experimental-features nix-command --extra-experimental-features flakes

fmt:
	nix fmt

clean:
	rm -f result

update:
	nix flake update

build:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes .#

shell:
	nix develop --extra-experimental-features nix-command --extra-experimental-features flakes

# Alias for check
.PHONY: test
test: check

# Help target
help:
	@echo "Available targets:"
	@echo "  check  - Check flake for errors"
	@echo "  test   - Alias for check"
	@echo "  fmt    - Format Nix files"
	@echo "  update - Update flake inputs"
	@echo "  build  - Build the flake"
	@echo "  shell  - Enter development shell"
	@echo "  clean  - Clean build artifacts"
	@echo "  help   - Show this help message (default)"

.PHONY: check test fmt clean update build shell help
