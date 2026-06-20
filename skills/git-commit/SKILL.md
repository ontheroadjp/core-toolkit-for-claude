---
name: git-commit
description: Execute the git-commit workflow by loading and following commands/git-commit.md exactly. Use this when the user requests /git-commit behavior.
---

# Git Commit Skill

## Source Of Truth

`~/.codex/commands/git-commit.md` is the single authoritative definition of the git-commit workflow.

## Required Behavior

1. Read `commands/git-commit.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/git-commit.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/git-commit.md`.

## Scope Guard

- Do not edit `commands/git-commit.md` from this skill.
- If the file is missing or unreadable, report that you cannot run git-commit workflow until it is restored.
