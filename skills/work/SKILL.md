---
name: work
description: Execute the repository work workflow by loading and following commands/work.md exactly. Use this when the user requests /work behavior.
---

# Work Skill

## Source Of Truth

`~/.codex/commands/work.md` is the single authoritative definition of the work workflow.

## Required Behavior

1. Read `commands/work.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/work.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/work.md`.

## Scope Guard

- Do not edit `commands/work.md` from this skill.
- If the file is missing or unreadable, report that you cannot run work workflow until it is restored.
