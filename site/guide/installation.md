# Installation

> **Symlink-only principle:** All files placed under `~/.claude/` must be symlinks pointing to this repository — never actual file copies. This repo is the single source of truth; `~/.claude/` is just a reference point.

## Quick Install

The fastest way to set everything up:

```bash
git clone https://github.com/ontheroadjp/core-toolkit-for-claude.git
cd core-toolkit-for-claude
./install.sh
```

This creates symlinks for:
- `commands/*.md` → `~/.claude/commands/` and `~/.codex/commands/`
- `hooks/*.sh` → `~/.claude/hooks/`
- `skills/*/` → `~/.codex/skills/`

Target directories are created automatically.

## Manual Setup

### Step 0: Symlink the shared templates (required)

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/core-toolkit-for-claude/templates \
      ~/.config/claude-code-kit/templates
```

Templates are stored in `~/.config/claude-code-kit/templates/` so both Claude Code and Codex CLI can reference them from a single location.

### Step 1: Symlink the commands (global — all repos)

```bash
ln -s /path/to/core-toolkit-for-claude/commands/work.md            ~/.claude/commands/work.md
ln -s /path/to/core-toolkit-for-claude/commands/task.md            ~/.claude/commands/task.md
ln -s /path/to/core-toolkit-for-claude/commands/patch.md           ~/.claude/commands/patch.md
ln -s /path/to/core-toolkit-for-claude/commands/docs-sync.md       ~/.claude/commands/docs-sync.md
ln -s /path/to/core-toolkit-for-claude/commands/init-docs.md       ~/.claude/commands/init-docs.md
ln -s /path/to/core-toolkit-for-claude/commands/review-resolve.md  ~/.claude/commands/review-resolve.md
ln -s /path/to/core-toolkit-for-claude/commands/new-issue.md       ~/.claude/commands/new-issue.md
```

The commands are now available as `/work`, `/task`, `/patch`, `/docs-sync`, `/init-docs`, `/review-resolve`, and `/new-issue` in any Claude Code session.

### Step 2: Symlink CLAUDE.md (global — all repos)

```bash
ln -s /path/to/core-toolkit-for-claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Claude Code auto-loads `~/.claude/CLAUDE.md` in every session, so the AI operating instructions apply to all repositories automatically. If a repo needs different instructions, place a local `CLAUDE.md` in its root — local takes precedence over global.

### Step 3: Symlink the hooks (optional)

```bash
mkdir -p ~/.claude/hooks
ln -s /path/to/core-toolkit-for-claude/hooks/auto-approve-readonly.sh \
      ~/.claude/hooks/auto-approve-readonly.sh
ln -s /path/to/core-toolkit-for-claude/hooks/guard-destructive-cmd.sh \
      ~/.claude/hooks/guard-destructive-cmd.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-token-usage.sh \
      ~/.claude/hooks/log-token-usage.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-prompt.sh \
      ~/.claude/hooks/log-access-prompt.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-tool.sh \
      ~/.claude/hooks/log-access-tool.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-stop.sh \
      ~/.claude/hooks/log-access-stop.sh
ln -s /path/to/core-toolkit-for-claude/hooks/cleanup-session.sh \
      ~/.claude/hooks/cleanup-session.sh
```

See [Configuration](./configuration) for registering hooks in `~/.claude/settings.json`.

### Step 4: Status line (optional)

Displays context usage and rate limits in the Claude Code status bar:

```bash
./setup_statusline.sh
```

Restart Claude Code to apply.

## Requirements

- [Claude Code](https://claude.ai/code) installed
- Git and gh CLI installed and authenticated
- jq installed
