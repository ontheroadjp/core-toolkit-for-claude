---
name: new-issue
description: Execute the repository new-issue workflow by loading and following commands/new-issue.md exactly. Use this when the user requests /new-issue behavior.
---

# New-Issue Skill

## Source Of Truth

`~/.codex/commands/new-issue.md` is the single authoritative definition of the new-issue workflow.

## Required Behavior

1. Read `commands/new-issue.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/new-issue.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/new-issue.md`.

## Scope Guard

- Do not edit `commands/new-issue.md` from this skill.
- If the file is missing or unreadable, report that you cannot run new-issue workflow until it is restored.
