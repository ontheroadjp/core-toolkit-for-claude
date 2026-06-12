---
name: coding-py
description: Apply Python-specific coding conventions (ruff, mypy strict, pytest) on top of coding-general principles. Use this when the user invokes /coding-py or asks to follow Python coding standards.
---

# Coding Python Skill

## Source Of Truth

`commands/coding-py.md` is the single authoritative definition of the Python coding conventions.

## Required Behavior

1. Read `commands/coding-general.md` and apply those principles.
2. Read `commands/coding-py.md` and apply the Python-specific rules on top.
3. Do not reinterpret, omit, or extend the rules unless the source files explicitly instruct you to do so.
4. If any instruction conflicts with your assumptions, follow the source files.

## Scope Guard

- Do not edit `commands/coding-py.md` or `commands/coding-general.md` from this skill.
- If either file is missing or unreadable, report that you cannot run the coding-py workflow until it is restored.
