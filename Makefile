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

.PHONY: help stow unstow dry-run restow stow-all verify clean lint wt-diff wt-pull

help:
	@echo "Targets:"
	@echo "  stow      Stow all packages into ~"
	@echo "  unstow    Remove all package symlinks"
	@echo "  dry-run   Preview stow actions without making changes"
	@echo "  restow    Re-stow after repo content changes"
	@echo "  stow-all  Stow EyrAgents' opencode package first, then all packages here"
	@echo "  verify    Check symlinks, git identity, shell/Lua syntax, TOML validity, and twin-file sync"
	@echo "  clean     Remove files that would conflict with stow (README Prepare steps)"
	@echo "  lint      ShellCheck over the bash package and scripts (.shellcheckrc holds the disable list)"
	@echo "  wt-diff   Diff tracked Windows Terminal settings against the deployed file"
	@echo "  wt-pull   Copy the deployed Windows Terminal settings into the repo for review"

stow:
	stow -v -t ~ $(PACKAGES)

unstow:
	stow -D -v -t ~ $(PACKAGES)

dry-run:
	stow -v -n -t ~ $(PACKAGES)

restow:
	stow -R -v -t ~ $(PACKAGES)

stow-all:
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
	@for tool in readlink cmp find luac git python3; do \
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

clean:
	-rm -f ~/.config/bash ~/.config/btop ~/.config/fastfetch ~/.config/git \
	  ~/.config/nvim/after ~/.config/tmux ~/.config/yazi
	@if [[ -L ~/.config/opencode ]]; then rm -f ~/.config/opencode; fi
	mkdir -p ~/.config/opencode
	@if [[ -L ~/.config/opencode/themes ]]; then rm -f ~/.config/opencode/themes; fi
	mkdir -p ~/.config/opencode/themes
	-rm -f ~/.bashrc ~/.inputrc ~/.editorconfig
	-rm -f ~/.config/git/config ~/.config/git/ignore
	-rm -f ~/.config/starship.toml
	-rm -f ~/.config/tmux/tmux.conf
	-rm -f ~/.config/fastfetch/config.jsonc
	-rm -f ~/.config/btop/btop.conf ~/.config/btop/themes/miasma.theme
	-rm -f ~/.config/yazi/yazi.toml ~/.config/yazi/theme.toml
	-rm -f ~/.config/nvim/lazyvim.json
	-rm -f ~/.config/nvim/lua/config/options.lua
	-rm -f ~/.config/nvim/lua/plugins/example.lua
	-rm -f ~/.config/nvim/lua/plugins/colorscheme.lua
	-rm -f ~/.config/nvim/lua/plugins/disable-news-alert.lua
	-rm -f ~/.config/nvim/lua/plugins/snacks-animated-scrolling-off.lua
	-rm -f ~/.config/nvim/lua/plugins/obsidian.lua
	-rm -f ~/.config/nvim/lua/plugins/render-markdown.lua
	-rm -f ~/.config/nvim/after/plugin/transparency.lua
	-rm -f ~/.config/opencode/themes/miasma.json
	@echo "note: run 'make stow-all' next so shared EyrAgents opencode entries stay linked"

lint:
	shellcheck -s bash bash/.bashrc bash/.config/bash/envs bash/.config/bash/shell \
	  bash/.config/bash/aliases bash/.config/bash/init bash/.config/bash/functions/* \
	  scripts/wt-diff.sh
	@echo "ok:   shellcheck clean"

wt-diff:
	scripts/wt-diff.sh

wt-pull:
	scripts/wt-diff.sh --pull
