---
name: triage-issues
description: Execute the repository triage-issues workflow by loading and following commands/triage-issues.md exactly. Use this when the user requests /triage-issues behavior.
---

# Triage-Issues Skill

## Source Of Truth

`~/.codex/commands/triage-issues.md` is the single authoritative definition of the triage-issues workflow.

## Required Behavior

1. Read `commands/triage-issues.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/triage-issues.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/triage-issues.md`.

## Scope Guard

- Do not edit `commands/triage-issues.md` from this skill.
- If the file is missing or unreadable, report that you cannot run triage-issues workflow until it is restored.
- Do not perform any GitHub issue operation (close, edit, comment, label) without explicit user confirmation.
