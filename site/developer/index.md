# Developer Documentation

This section covers the internal design, workflow routing logic, and command specifications for contributors and advanced users.

## Design Principles

- **`git diff` is truth** — AI summaries are supplementary only
- **Docs changes are isolated** — `/task` never touches `docs/*`; only `/docs-sync` does
- **Minimal updates** — `/docs-sync` updates only what changed, never rewrites wholesale
- **HARD STOP escalation** — when `/docs-sync` cannot reason about a change, it stops and requires `/init-docs`
- **Symlink-only** — `~/.claude/` holds no real files; everything symlinks back to this repository

## Workflow Architecture

```
/work (entry point)
  │
  ├── G-0: Ensure on main branch
  ├── G-1: Verify docs/.ai/repo.profile.json exists
  ├── G-2: Workspace clean check (stash if needed)
  │
  ├── issue mentioned? → /task flow
  │
  └── docs change needed?
       ├── YES → /task flow (issue → implement → draft PR → /docs-sync)
       └── NO  → /patch flow (branch → commit → user ff-merge)
```

## Repository Structure

```
hooks/              # Claude Code hook scripts (PreToolUse, Stop, etc.)
commands/           # Slash command Markdown files
partials/           # Shared procedure partials (not slash commands)
templates/          # issue.md, pr.md, readme.md scaffolds
docs/               # Design documentation (L0–L3)
  .ai/
    repo.profile.json   # Machine-readable repo profile
  L0_concept/           # WHY layer — product concept and policy
  L1_project/           # Project overview
  L2_development/       # Development and operation model
  L3_implementation/    # Implementation specifications
scripts/            # Utility scripts (status line, etc.)
skills/             # Codex CLI skill wrappers
```

## Sections

- [Specification Summary](./specification) — detailed per-command and per-hook specifications
