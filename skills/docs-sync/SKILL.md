---
name: docs-sync
description: Execute the repository docs-sync workflow by loading and following commands/docs-sync.md exactly. Use this when the user requests /docs-sync behavior.
---

# Docs-Sync Skill

## Source Of Truth

`~/.codex/commands/docs-sync.md` is the single authoritative definition of the docs-sync workflow.

## Required Behavior

1. Read `commands/docs-sync.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/docs-sync.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/docs-sync.md`.

## Scope Guard

- Do not edit `commands/docs-sync.md` from this skill.
- If the file is missing or unreadable, report that you cannot run docs-sync workflow until it is restored.
