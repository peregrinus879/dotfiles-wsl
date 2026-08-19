# Maintenance automation for EyrWSL. Run from the repo root on the WSL machine.
# The package list here is the single source of truth for the stow command sets.

SHELL := /bin/bash
PACKAGES := bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
AI_REPO := ../eyragents

# Twin files are byte-identical with EyrArcHy, synced manually; verify
# fails on drift so the copies cannot silently diverge. Paths are repo-relative
# and identical in both repos.
SIBLING := $(HOME)/Projects/eyrie/eyrarchy
TWIN_SPECS := nvim/.config/nvim/lua/plugins/obsidian.lua \
  nvim/.config/nvim/lua/plugins/render-markdown.lua \
  bash/.config/bash/functions/tdw \
  bash/.config/bash/functions/hdw \
  yazi/.config/yazi/yazi.toml

.PHONY: help require-wsl stow unstow dry-run restow stow-all verify test clean migrate-nvim lint wt-diff wt-pull wt-push

help:
	@echo "Targets:"
	@echo "  stow      Stow all packages into ~"
	@echo "  unstow    Remove all package symlinks"
	@echo "  dry-run   Preview stow actions without making changes"
	@echo "  restow    Re-stow after repo content changes"
	@echo "  stow-all  Stow EyrAgents' opencode package first, then all packages here"
	@echo "  verify    Check deployment, syntax, twins, and guarded-preparation fixtures"
	@echo "  test      Run guarded deployment fixture tests"
	@echo "  clean     Preflight all endpoints, then remove managed links only"
	@echo "  migrate-nvim  Back up known starter files and stow managed Neovim config"
	@echo "  lint      ShellCheck over the bash package and scripts (.shellcheckrc holds the disable list)"
	@echo "  wt-diff   Diff tracked Windows Terminal settings against the deployed file"
	@echo "  wt-pull   Atomically copy deployed Windows Terminal settings into the repo"
	@echo "  wt-push   Back up and deploy tracked Windows Terminal settings"

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
	@[[ -d $(AI_REPO) ]] || { echo "error: $(AI_REPO) not found; clone EyrAgents next to this repo"; exit 1; }
	cd $(AI_REPO) && stow -v -t ~ opencode
	stow -v -t ~ $(PACKAGES)

# Symlink pairs are derived from the package files git sees (tracked plus
# untracked): stripping the leading package name maps each file to its stow
# target, so every package file is checked, including one being added in the
# working tree. Stow may tree-fold a parent directory (e.g. ~/.config/yazi)
# into a single directory symlink, so per-file "test -L" checks false-negative.
# Compare resolved paths instead: linked is linked, folded or not.
# Fail closed: a missing verifier binary must fail the run, not skip a check.
# A missing sibling clone skips the twin checks; an existing clone missing a
# twin file is drift and fails.
verify:
	@for tool in readlink cmp find jq luac git python3; do \
	  command -v "$$tool" > /dev/null || { echo "FAIL: required verifier '$$tool' is missing"; exit 1; }; \
	done
	@fail=0; \
	for src in $$(git ls-files --cached --others --exclude-standard -- $(PACKAGES)); do \
	  target="$$HOME/$${src#*/}"; \
	  if [[ "$$(readlink -f "$$target")" == "$$(readlink -f "$$src")" ]]; then \
	    echo "ok:   $$target resolves into the repo"; \
	  else \
	    echo "FAIL: $$target does not resolve into the repo"; fail=1; \
	  fi; \
	done; \
	if [[ -f ~/.config/git/config.local ]]; then echo "ok:   ~/.config/git/config.local"; else echo "FAIL: missing ~/.config/git/config.local"; fail=1; fi; \
	for f in bash/.bashrc bash/.config/bash/* bash/.config/bash/functions/*; do \
	  [[ -f "$$f" ]] || continue; \
	  if bash -n "$$f"; then echo "ok:   bash -n $$f"; else echo "FAIL: bash -n $$f"; fail=1; fi; \
	done; \
	for f in $$(find nvim -name '*.lua'); do \
	  if luac -p "$$f" > /dev/null; then echo "ok:   luac -p $$f"; else echo "FAIL: luac -p $$f"; fail=1; fi; \
	done; \
	if python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],"rb"))' yazi/.config/yazi/yazi.toml 2> /dev/null; then \
	  echo "ok:   yazi.toml parses as TOML"; \
	else \
	  echo "FAIL: yazi.toml is not valid TOML"; fail=1; \
	fi; \
	for f in nvim/.config/nvim/init.lua nvim/.config/nvim/lua/config/lazy.lua \
	  nvim/.config/nvim/lua/config/autocmds.lua nvim/.config/nvim/lua/config/keymaps.lua \
	  nvim/.config/nvim/.neoconf.json nvim/.config/nvim/stylua.toml nvim/.config/nvim/lazy-lock.json; do \
	  if [[ -f $$f ]]; then echo "ok:   $$f is tracked bootstrap content"; \
	  else echo "FAIL: missing Neovim bootstrap file: $$f"; fail=1; fi; \
	done; \
	if jq -e 'type == "object" and length > 0 and has("LazyVim") and has("gruvbox.nvim")' \
	  nvim/.config/nvim/lazy-lock.json > /dev/null; then \
	  echo "ok:   lazy-lock.json pins LazyVim and Gruvbox"; \
	else echo "FAIL: lazy-lock.json is invalid"; fail=1; fi; \
	if [[ ! -d "$(SIBLING)" ]]; then \
	  echo "note: EyrArcHy clone not found, skipped twin checks"; \
	else \
	  for f in $(TWIN_SPECS); do \
	    twin="$(SIBLING)/$$f"; \
	    if [[ ! -e "$$twin" ]]; then echo "FAIL: twin missing in EyrArcHy: $$f"; fail=1; \
	    elif cmp -s "$$f" "$$twin"; then echo "ok:   $$f matches the EyrArcHy twin"; \
	    else echo "FAIL: $$f drifted from the EyrArcHy twin"; fail=1; fi; \
	  done; \
	fi; \
	exit $$fail
	@for test in tests/*.sh; do bash "$$test"; done

test:
	@for test in tests/*.sh; do bash "$$test"; done

clean: require-wsl
	@bash scripts/prepare-stow.sh
	@echo "note: run 'make stow-all' next so shared EyrAgents OpenCode entries stay linked"

migrate-nvim: require-wsl
	@bash scripts/migrate-nvim-starter.sh

lint:
	shellcheck -s bash bash/.bashrc bash/.config/bash/envs bash/.config/bash/shell \
	  bash/.config/bash/aliases bash/.config/bash/init bash/.config/bash/functions/* \
	  scripts/*.sh tests/*.sh
	@echo "ok:   shellcheck clean"

wt-diff:
	scripts/wt-diff.sh

wt-pull: require-wsl
	scripts/wt-diff.sh --pull

wt-push: require-wsl
	scripts/wt-diff.sh --push
