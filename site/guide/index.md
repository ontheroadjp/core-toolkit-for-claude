# User Guide

**Core Toolkit for Claude** is a collection of custom slash commands for [Claude Code](https://claude.ai/code) that provide a structured AI-driven development workflow — from implementation through documentation sync and PR publication.

## Commands

| Command | Purpose |
|---|---|
| `/work` | **Main entry point** for all development tasks. Gates → investigates → routes to patch flow or task flow automatically. |
| `/new-issue` | Optional pre-`/work` entry point. Turns a rough idea into one or more well-formed GitHub issues. Does not implement. |
| `/review-resolve` | Fetches PR review comments and guides the user through addressing or declining each one interactively. |
| `/patch` | *(delegated by /work)* Lightweight fixes without documentation changes. Branch + commit → user ff-merges. |
| `/task` | *(delegated by /work)* Implementation with docs changes. Issue → implement → draft PR → `/docs-sync`. |
| `/docs-sync` | Syncs `docs/*` to match implementation changes using `git diff` as truth, then publishes the draft PR. |
| `/init-docs` | Full re-observation and reconstruction of project design docs. Run when `/docs-sync` hits a HARD STOP. |

## Typical Workflow

```
/new-issue (optional)
  └── rough idea → 1 or N well-formed issues → user runs /work #N

/work (main entry)
  ├── docs not required → patch flow: branch → commit → user merges
  └── docs required     → task flow:  issue → implement → draft PR → /docs-sync → PR published

/review-resolve #N
  └── PR review comments → addressed/declined interactively → reply posted
```

Start every session with `/work` — it asks what you want to do and routes to the appropriate flow automatically.

## Next Steps

- [Installation](./installation) — set up symlinks and hooks
- [Configuration](./configuration) — configure hooks and settings
