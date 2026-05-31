---
name: review-resolve
description: Execute the repository review-resolve workflow by loading and following commands/review-resolve.md exactly. Use this when the user requests /review-resolve behavior — fetching PR review comments and guiding interactive resolution.
---

# Review-Resolve Skill

## Source Of Truth

`~/.codex/commands/review-resolve.md` is the single authoritative definition of the review-resolve workflow.

## Required Behavior

1. Read `commands/review-resolve.md`.
2. Execute that workflow exactly as written.
3. Do not reinterpret, simplify, or merge it with other workflows unless `commands/review-resolve.md` explicitly instructs you to do so.
4. If any instruction conflicts with your assumptions, follow `commands/review-resolve.md`.

## Scope Guard

- Do not edit `commands/review-resolve.md` from this skill.
- If the file is missing or unreadable, report that you cannot run review-resolve workflow until it is restored.
