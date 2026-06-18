# User Guide

**Core Toolkit for Claude** is a collection of command specifications, Codex skills, hooks, and templates for [Claude Code](https://claude.ai/code) and Codex CLI. It provides a structured AI-driven development workflow — from implementation through documentation sync, PR publication, issue triage, and review response.

## Commands

| Command | Purpose |
|---|---|
| `/work` | **Main entry point** for all development tasks. Gates → investigates → routes to patch flow or task flow automatically. |
| `/triage-issues` | Standalone workflow for reviewing open issues, classifying stale or unclear work, and preparing issues for `/work #N`. |
| `/new-issue` | Optional pre-`/work` entry point. Turns a rough idea into one or more well-formed GitHub issues. Does not implement. |
| `/review-resolve` | Fetches PR review comments and guides the user through addressing or declining each one interactively. |
| `/codex-review` | Reviews a PR with Codex CLI, posts an approval or change request, and invokes `/review-resolve` when changes are requested. |
| `/patch` | *(delegated by /work)* Lightweight fixes without documentation changes. Branch + commit → user ff-merges. |
| `/task` | *(delegated by /work)* Implementation with docs changes. Issue → implement → draft PR → `/docs-sync`. |
| `/docs-sync` | Syncs `docs/*` to match implementation changes using `git diff` as truth, then publishes the draft PR. |
| `/init-docs` | Full re-observation and reconstruction of project design docs. Run when `/docs-sync` hits a HARD STOP. |

## Typical Workflow

```
/new-issue (optional)
  └── rough idea → 1 or N well-formed issues → user runs /work #N

/triage-issues
  └── open issues → stale/unclear/ready classification → user-approved cleanup

/work (main entry)
  ├── docs not required → patch flow: branch → commit → user merges
  └── docs required     → task flow:  issue → implement → draft PR → /docs-sync → PR published

/codex-review #N
  └── Codex CLI review → approve or request changes → /review-resolve when needed

/review-resolve #N
  └── PR review comments → addressed/declined interactively → reply posted
```

Start implementation work with `/work`. Use `/review-resolve #N` directly for PR review comments, and optionally use `/new-issue` or `/triage-issues` before `/work` when issue preparation is the task.

## Next Steps

- [Installation](./installation) — set up symlinks and hooks
- [Configuration](./configuration) — configure hooks and settings
