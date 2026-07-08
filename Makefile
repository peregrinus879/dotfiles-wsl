# Maintenance automation for dotfiles-wsl. Run from the repo root on the WSL machine.
# The package list here is the single source of truth for the stow command sets.

SHELL := /bin/bash
PACKAGES := bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
AI_REPO := ../dotfiles-ai

.PHONY: help stow unstow dry-run restow stow-all verify clean lint wt-diff wt-pull

help:
	@echo "Targets:"
	@echo "  stow      Stow all packages into ~"
	@echo "  unstow    Remove all package symlinks"
	@echo "  dry-run   Preview stow actions without making changes"
	@echo "  restow    Re-stow after repo content changes"
	@echo "  stow-all  Stow dotfiles-ai's opencode package first, then all packages here"
	@echo "  verify    Check symlinks, git identity, and shell/Lua syntax"
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
	@[[ -d $(AI_REPO) ]] || { echo "error: $(AI_REPO) not found; clone dotfiles-ai next to this repo"; exit 1; }
	cd $(AI_REPO) && stow -v -t ~ opencode
	stow -v -t ~ $(PACKAGES)

verify:
	@fail=0; \
	for link in ~/.bashrc ~/.config/starship.toml ~/.config/nvim/lua/config/options.lua ~/.config/opencode/themes/miasma.json; do \
	  if [[ -L "$$link" ]]; then echo "ok:   symlink $$link"; else echo "FAIL: missing symlink $$link"; fail=1; fi; \
	done; \
	if [[ -f ~/.config/git/config.local ]]; then echo "ok:   ~/.config/git/config.local"; else echo "FAIL: missing ~/.config/git/config.local"; fail=1; fi; \
	for f in bash/.bashrc bash/.config/bash/* bash/.config/bash/functions/*; do \
	  [[ -f "$$f" ]] || continue; \
	  if bash -n "$$f"; then echo "ok:   bash -n $$f"; else echo "FAIL: bash -n $$f"; fail=1; fi; \
	done; \
	if command -v luac > /dev/null; then \
	  for f in $$(find nvim -name '*.lua'); do \
	    if luac -p "$$f" > /dev/null; then echo "ok:   luac -p $$f"; else echo "FAIL: luac -p $$f"; fail=1; fi; \
	  done; \
	else echo "note: luac not found, skipping Lua syntax checks"; fi; \
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
	@echo "note: run 'make stow-all' next so shared dotfiles-ai opencode entries stay linked"

lint:
	shellcheck -s bash bash/.bashrc bash/.config/bash/envs bash/.config/bash/shell \
	  bash/.config/bash/aliases bash/.config/bash/init bash/.config/bash/functions/* \
	  scripts/wt-diff.sh
	@echo "ok:   shellcheck clean"

wt-diff:
	scripts/wt-diff.sh

wt-pull:
	scripts/wt-diff.sh --pull
