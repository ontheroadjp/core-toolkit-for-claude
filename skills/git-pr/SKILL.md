---
name: git-pr
description: Execute the git-pr workflow by loading and following commands/git-pr.md exactly. Use this when the user requests /git-pr behavior.
---

# Git PR Skill

## Source Of Truth

`~/.codex/commands/git-pr.md` is the single authoritative definition of the git-pr workflow.

## Required Behavior

1. Read `commands/git-pr.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/git-pr.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/git-pr.md`.

## Scope Guard

- Do not edit `commands/git-pr.md` from this skill.
- If the file is missing or unreadable, report that you cannot run git-pr workflow until it is restored.
