---
name: task
description: Execute the repository task workflow by loading and following commands/task.md exactly. Use this when the user requests /task behavior.
---

# Task Skill

## Source Of Truth

`~/.codex/commands/task.md` is the single authoritative definition of the task workflow.

## Required Behavior

1. Read `commands/task.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/task.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/task.md`.

## Scope Guard

- Do not edit `commands/task.md` from this skill.
- If the file is missing or unreadable, report that you cannot run task workflow until it is restored.
