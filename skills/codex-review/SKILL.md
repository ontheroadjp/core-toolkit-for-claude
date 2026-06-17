---
name: codex-review
description: Review a GitHub PR using the Codex CLI non-interactively, post the result as a PR comment, and report the comment URL. Use this when the user requests /codex-review behavior.
---

# Codex Review Skill

## Source Of Truth

`~/.codex/commands/codex-review.md` is the single authoritative definition of the codex-review workflow.

## Required Behavior

1. Read `commands/codex-review.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/codex-review.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/codex-review.md`.

## Scope Guard

- Do not edit `commands/codex-review.md` from this skill.
- If the file is missing or unreadable, report that you cannot run codex-review workflow until it is restored.
