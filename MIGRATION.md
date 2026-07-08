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
