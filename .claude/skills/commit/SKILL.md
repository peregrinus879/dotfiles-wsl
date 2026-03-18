---
name: commit
description: Commit conventions for this project. Conventional commits, atomic changes, staging, imperative mood, co-author line.
---

# Commit Conventions

## Format

```
<type>: <subject>

[optional body]

Co-Authored-By: Claude <current model> <noreply@anthropic.com>
```

## Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `style:` - Formatting, whitespace (no code change)
- `test:` - Adding or correcting tests
- `chore:` - Maintenance tasks

## Staging

- Stage specific files by name (`git add <file>`). Do not use `git add -A` or `git add .`.
- Review staged changes (`git diff --cached`) before committing.
- Never stage sensitive files (.env, credentials, private keys).

## Rules

- Atomic: one complete, self-contained change per commit
- Separate commits by type
- Subject: imperative mood, concise (50 chars), lowercase
- Body: when the change needs context (explain why, not what)
- Co-Author: always append with current model name
- Push: user handles manually (SSH passphrase required). Do not push.
