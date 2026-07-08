# MIGRATION.md - one-time WSL machine migration

Temporary runbook for migrating the live WSL machine from the old
`dotfiles-arch` baseline + overlay model to this self-contained repo.
Run once on the WSL machine, then delete this file (final step).

Rules for this migration:

- Do everything in **one terminal session**. Between unstow and re-stow,
  `~/.bashrc` is dangling; if a shell breaks, `bash --norc` still works.
- **Do not pull `dotfiles-arch`** on this machine. Its packages are being
  removed upstream; the unstow step needs the old checkout as-is.
- Unstow the **old layouts before pulling this repo**, because `stow -D`
  needs the old package names (`bash-wsl`, `nvim-wsl`) that no longer
  exist after the pull.

## 0. Check whether repo auto-refresh is active, then disable it

The old `bash-wsl` overlay may or may not have been stowed on this
machine. If it was, shells auto-fast-forward any clean repo under
`~/Projects/repos` on `cd`; left on, that would pull this repo before
step 2's unstow and delete the old package dirs that `stow -D` needs.

Check first, before any `cd` into a repo:

```bash
ls -l ~/.config/bash-overlays/enable-repo-auto-refresh 2>/dev/null || echo "bash-wsl not applied"
```

- **Symlink exists**: the overlay is active. Disable it for this session.
- **`bash-wsl not applied`**: auto-refresh was never enabled here; the
  race cannot happen, and `bash-wsl` in step 2's unstow is a harmless
  no-op. The export below still costs nothing.

```bash
export REPO_AUTO_REFRESH=0
```

If the repo already fast-forwarded before the unstow (step 2 reports
`bash-wsl`/`nvim-wsl` missing), recover by checking out the last
pre-restructure commit, unstowing from it, then returning to main:

```bash
git -C ~/Projects/repos/dotfiles/dotfiles-wsl checkout 72abe94
# run step 2, then:
git -C ~/Projects/repos/dotfiles/dotfiles-wsl checkout main
```

## 1. Back up the git identity

If `~/.config/git` is a tree-folded symlink, `config.local` physically
lives inside the arch clone and would vanish with it.

```bash
cp ~/.config/git/config.local ~/config.local.backup
ls -ld ~/.config/git
```

## 2. Unstow the old layouts (before any pull)

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -D -v -t ~ bash-wsl nvim-wsl opencode-wsl
cd ~/Projects/repos/dotfiles/dotfiles-arch
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

## 3. Pull this repo

```bash
git -C ~/Projects/repos/dotfiles/dotfiles-wsl pull
```

## 4. Restore the git identity into a real directory

```bash
mkdir -p ~/.config/git
cp ~/config.local.backup ~/.config/git/config.local
```

## 5. Stow the new package set

The nvim package now tracks the vault plugin specs. If this machine has
vault-stowed or local copies, remove them first or stow will report
conflicts (dangling vault symlinks are expected here, since the vault's
`nvim-vault` package was removed upstream and the deletion synced):

```bash
rm -f ~/.config/nvim/lua/plugins/obsidian.lua ~/.config/nvim/lua/plugins/render-markdown.lua
sudo pacman -S --needed python
```

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
make dry-run    # resolve any reported conflicts first (see README section 8)
make stow-all   # stows dotfiles-ai's opencode package first, then all packages here
```

## 6. Verify

```bash
make verify
make lint
```

Then the functional checks: start a fresh shell (Bash, Starship, Tmux load
cleanly), open `nvim` once (plugins install, Miasma loads, clipboard
round-trips with Windows), and confirm `miasma` is selectable in OpenCode
via `/theme`.

If the vault is synced to this machine, open a vault note and confirm
obsidian.nvim loads from the newly stowed specs (`<leader>oo` opens the
note switcher; the slug and promote bindings need `python` from step 5).

## 7. Fix the Miasma reference clone

The old clone tracks `xero/miasma.nvim`; the canonical fork is the one
Omarchy uses.

```bash
rm -rf ~/Projects/repos/references/miasma.nvim
git clone https://github.com/OldJobobo/miasma.nvim.git ~/Projects/repos/references/miasma.nvim
```

## 8. Clean up

Only after step 4 is confirmed (`test -f ~/.config/git/config.local`):

```bash
rm -rf ~/Projects/repos/dotfiles/dotfiles-arch
rm ~/config.local.backup
```

## 9. Delete this runbook

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
git rm MIGRATION.md
git commit -m "chore: remove completed migration runbook"
```
