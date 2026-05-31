---
name: patch
description: Execute the repository patch workflow by loading and following commands/patch.md exactly. Use this when the user requests /patch behavior.
---

# Patch Skill

## Source Of Truth

`~/.codex/commands/patch.md` is the single authoritative definition of the patch workflow.

## Required Behavior

1. Read `commands/patch.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/patch.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/patch.md`.

## Scope Guard

- Do not edit `commands/patch.md` from this skill.
- If the file is missing or unreadable, report that you cannot run patch workflow until it is restored.
