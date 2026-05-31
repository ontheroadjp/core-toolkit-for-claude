---
name: init-docs
description: Execute the repository init-docs workflow by loading and following commands/init-docs.md exactly. Use this when the user requests /init-docs behavior.
---

# Init-Docs Skill

## Source Of Truth

`~/.codex/commands/init-docs.md` is the single authoritative definition of the init-docs workflow.

## Required Behavior

1. Read `commands/init-docs.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/init-docs.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/init-docs.md`.

## Scope Guard

- Do not edit `commands/init-docs.md` from this skill.
- If the file is missing or unreadable, report that you cannot run init-docs workflow until it is restored.
