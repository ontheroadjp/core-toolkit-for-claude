# core-toolkit-for-claude

A structured AI-driven development workflow toolkit for Claude Code and Codex CLI. It packages slash-command specifications, Codex skills, Claude/Codex hook scripts, shared templates, and a VitePress documentation site.

## Features

| Command | Purpose |
|---|---|
| `/work` | Main entry point for development tasks. Gates, investigates, then routes to patch or task flow. |
| `/triage-issues` | Standalone entry point for reviewing and cleaning up open issues so they are ready for `/work #N`. |
| `/new-issue` | Optional pre-`/work` entry point. Turns a rough idea into one or more GitHub issues. |
| `/review-resolve` | Handles PR review comments interactively without going through `/work`. |
| `/codex-review` | Reviews a PR using the Codex CLI non-interactively, posts the result as a PR approval or change request (requires `CODEX_REVIEW_TOKEN`), and auto-invokes `/review-resolve` when changes are requested. |
| `/patch` | Delegated by `/work` for lightweight fixes without docs changes. |
| `/task` | Delegated by `/work` for implementation that requires docs changes. |
| `/docs-sync` | Syncs `docs/*` and README from `git diff`, then publishes the draft PR. |
| `/init-docs` | Re-observes the repository and reconstructs project design docs. |
| `/coding-general` | Language-independent coding principles. |
| `/coding-py` | Python-specific coding conventions. |
| `/coding-js` | JavaScript-specific coding conventions. |
| `/coding-ts` | TypeScript-specific coding conventions. |

## Installation

> Symlink-only principle: files placed under `~/.claude/` should be symlinks pointing to this repository. This repository is the single source of truth.

### Quick Install

```bash
./install.sh
```

`install.sh` creates target directories and symlinks:

- `commands/*.md` -> `~/.claude/commands/`
- `commands/*.md` -> `~/.codex/commands/`
- `hooks/*.sh` -> `~/.claude/hooks/`
- `hooks/*.sh` -> `~/.codex/hooks/`
- `skills/*/` -> `~/.codex/skills/`

It also updates `~/.claude/settings.json` and `~/.codex/hooks.json` when `jq` is available. Codex users should review and trust registered hooks with `/hooks` before relying on them.

### Templates

Commands reference templates through `~/.config/claude-code-kit/templates/`. Link the repository template directory there:

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/core-toolkit-for-claude/templates ~/.config/claude-code-kit/templates
```

### Claude Global Instructions

```bash
ln -s /path/to/core-toolkit-for-claude/CLAUDE.md ~/.claude/CLAUDE.md
```

### Status Line

```bash
./setup_statusline.sh
```

This links `scripts/statusline.sh` to `~/.claude/statusline.sh` and adds a `statusLine` entry to `~/.claude/settings.json` when `jq` is available.

## Usage

```text
/new-issue (optional)
  rough idea -> issue draft(s) -> user runs /work #N

/work (main entry)
  docs not required -> patch flow: branch -> commit -> user ff-merges
  docs required     -> task flow: issue -> implement -> draft PR -> /docs-sync

/review-resolve #N
  PR review comments -> address/reply/skip interactively -> commit/push/reply as needed
```

Site commands are under `site/`:

```bash
cd site && npm run docs:dev
cd site && npm run docs:build
cd site && npm run docs:preview
```

CI runs `npm ci` and `npm run docs:build` in `site/` on push to `main` and on manual workflow dispatch.

## Design Principles

- `git diff` is truth for docs sync; PR text is supplemental.
- `/task` does not edit `docs/*`; `/docs-sync` handles implementation-driven docs updates.
- `/docs-sync` makes minimal updates and escalates to `/init-docs` when the structure can no longer be explained locally.
- `~/.claude/` is symlink-only; this repository remains the source of truth.
- Workspace cleanup uses stash; destructive git operations require explicit human control.

## Repository Structure

```text
.github/workflows/deploy.yml  GitHub Actions for VitePress -> GitHub Pages
commands/                     Markdown command specifications
hooks/                        Claude Code / Codex hook scripts and shared helpers
partials/                     Shared command fragments, currently git commit flow
skills/                       Codex skill wrappers around commands/*.md
templates/                    Issue, PR, and README templates
docs/                         /init-docs generated L0-L3 design docs
site/                         VitePress documentation site
scripts/                      status line and token usage utilities
tests/                        verification scripts for hooks and workflows
install.sh                    symlink installer for commands/hooks/skills
setup_statusline.sh           status line installer
CLAUDE.md                     Claude Code AI operating guidance
AGENTS.md                     Codex CLI AI operating guidance
```

## License

MIT
