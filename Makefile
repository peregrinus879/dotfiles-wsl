# Maintenance automation for EyrWSL. Run from the repo root on the WSL machine.
# The package list here is the single source of truth for the stow command sets.

SHELL := /bin/bash
PACKAGES := bash btop editorconfig fastfetch git nvim starship tmux yazi
EYRAGENTS_REPO ?= ../eyragents

.PHONY: help require-wsl stow unstow dry-run restow stow-all verify test clean lint wt-diff wt-push refs

help:
	@echo "Targets:"
	@echo "  stow      Stow all packages into ~"
	@echo "  unstow    Remove all package symlinks"
	@echo "  dry-run   Preview stow actions without making changes"
	@echo "  restow    Re-stow after repo content changes"
	@echo "  stow-all  Stow EyrAgents' opencode package first, then all packages here"
	@echo "  verify    Check the WSL host, deployment, owned configs, and fixtures"
	@echo "  test      Run fail-closed deployment and verifier fixtures"
	@echo "  clean     Preflight all endpoints, then remove managed links only"
	@echo "  lint      ShellCheck over Bash config, scripts, and tests"
	@echo "  wt-diff   Diff tracked Windows Terminal settings against the deployed file"
	@echo "  wt-push   Back up changed settings and deploy the tracked Windows Terminal file"
	@echo "  refs      Fast-forward the reference clones under ~/Projects/quarry to their current upstream default branches"

require-wsl:
	@kernel="$$(uname -r)"; [[ "$${kernel,,}" == *microsoft* ]] || { echo "FAIL: WSL is required for this target"; exit 1; }

stow: require-wsl
	stow -v -t ~ $(PACKAGES)

unstow: require-wsl
	stow -D -v -t ~ $(PACKAGES)

dry-run:
	stow -v -n -t ~ $(PACKAGES)

restow: require-wsl
	stow -R -v -t ~ $(PACKAGES)

stow-all: require-wsl
	@[[ -d "$(EYRAGENTS_REPO)" ]] || { echo "error: $(EYRAGENTS_REPO) not found; clone EyrAgents or set EYRAGENTS_REPO"; exit 1; }
	cd "$(EYRAGENTS_REPO)" && stow -v -t ~ opencode
	stow -v -t ~ $(PACKAGES)

verify:
	@VERIFY_MODE=full VERIFY_REPO='$(CURDIR)' VERIFY_HOME='$(HOME)' \
	  VERIFY_PACKAGES='$(PACKAGES)' bash scripts/verify.sh
	@$(MAKE) --no-print-directory test

test:
	@set -e; for test in tests/*.sh; do EYRWSL_PACKAGES='$(PACKAGES)' bash "$$test"; done

clean: require-wsl
	@EYRAGENTS_REPO="$(EYRAGENTS_REPO)" EYRWSL_PACKAGES='$(PACKAGES)' bash scripts/prepare-stow.sh
	@echo "note: run 'make stow-all' next so shared EyrAgents OpenCode entries stay linked"

lint:
	shellcheck -s bash bash/.bashrc bash/.config/bash/envs bash/.config/bash/shell \
	  bash/.config/bash/aliases bash/.config/bash/init bash/.config/bash/functions/* \
	  scripts/*.sh tests/*.sh
	@echo "ok:   shellcheck clean"

wt-diff:
	scripts/wt-diff.sh

wt-push: require-wsl
	scripts/wt-diff.sh --push

# omasync step 1. Repoints a moved GitHub remote, then fast-forwards each clone
# to its upstream default branch; a clone it cannot update fails the run.
refs:
	@bash scripts/update-references.sh
