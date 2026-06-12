# claude-code-kit

A collection of custom slash commands for [Claude Code](https://claude.ai/code) that provide a structured AI-driven development workflow — from implementation through documentation sync and PR publication.

## Features

| Command | Purpose |
|---|---|
| `/work` | **Main entry point** for all development tasks. Gates → investigates → routes to patch flow or task flow automatically. |
| `/new-issue` | Optional pre-`/work` entry point. Turns a rough idea into one or more well-formed GitHub issues. Does not implement. |
| `/review-resolve` | Fetches PR review comments and guides the user through addressing or declining each one interactively. |
| `/patch` | *(delegated by /work)* Lightweight fixes without documentation changes. Branch + commit → user ff-merges. |
| `/task` | *(delegated by /work)* Implementation with docs changes. Issue → implement → draft PR → `/docs-sync`. |
| `/docs-sync` | Syncs `docs/*` to match implementation changes using `git diff` as truth, then publishes the draft PR. |
| `/init-docs` | Full re-observation and reconstruction of project design docs. Run when `/docs-sync` hits a HARD STOP. |

## Installation

> **Symlink-only principle:** All files placed under `~/.claude/` must be symlinks pointing to this repository — never actual file copies. This repo is the single source of truth; `~/.claude/` is just a reference point.

### Quick install (commands + hooks + skills)

```bash
./install.sh
```

Creates symlinks for `commands/*.md` → `~/.claude/commands/`, `hooks/*.sh` → `~/.claude/hooks/`, and `skills/*/` → `~/.codex/skills/`. Target directories are created automatically.

### 0. Symlink the shared templates (required by all tools)

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/claude-code-kit/commands/templates ~/.config/claude-code-kit/templates
```

Templates are stored in `~/.config/claude-code-kit/templates/` so both Claude Code and Codex CLI can reference them from a single location.

### 1. Symlink the commands (global — all repos)

```bash
ln -s /path/to/claude-code-kit/commands/work.md            ~/.claude/commands/work.md
ln -s /path/to/claude-code-kit/commands/task.md            ~/.claude/commands/task.md
ln -s /path/to/claude-code-kit/commands/patch.md           ~/.claude/commands/patch.md
ln -s /path/to/claude-code-kit/commands/docs-sync.md       ~/.claude/commands/docs-sync.md
ln -s /path/to/claude-code-kit/commands/init-docs.md       ~/.claude/commands/init-docs.md
ln -s /path/to/claude-code-kit/commands/review-resolve.md   ~/.claude/commands/review-resolve.md
ln -s /path/to/claude-code-kit/commands/new-issue.md        ~/.claude/commands/new-issue.md
ln -s /path/to/claude-code-kit/commands/coding-general.md   ~/.claude/commands/coding-general.md
ln -s /path/to/claude-code-kit/commands/coding-py.md        ~/.claude/commands/coding-py.md
```

The commands are now available as `/work`, `/task`, `/patch`, `/docs-sync`, `/init-docs`, `/review-resolve`, `/new-issue`, `/coding-general`, and `/coding-py` in any Claude Code session.

### 2. Symlink CLAUDE.md (global — all repos)

```bash
ln -s /path/to/claude-code-kit/CLAUDE.md ~/.claude/CLAUDE.md
```

Claude Code auto-loads `~/.claude/CLAUDE.md` in every session, so the AI operating instructions apply to all repositories automatically. If a repo needs different instructions, place a local `CLAUDE.md` in its root — local takes precedence over global.

### 3. Symlink the hooks (optional)

```bash
mkdir -p ~/.claude/hooks
ln -s /path/to/claude-code-kit/hooks/guard-destructive-cmd.sh ~/.claude/hooks/guard-destructive-cmd.sh
ln -s /path/to/claude-code-kit/hooks/log-token-usage.sh       ~/.claude/hooks/log-token-usage.sh
ln -s /path/to/claude-code-kit/hooks/log-access-prompt.sh     ~/.claude/hooks/log-access-prompt.sh
ln -s /path/to/claude-code-kit/hooks/log-access-tool.sh       ~/.claude/hooks/log-access-tool.sh
ln -s /path/to/claude-code-kit/hooks/log-access-stop.sh       ~/.claude/hooks/log-access-stop.sh
ln -s /path/to/claude-code-kit/hooks/notify-slack.sh          ~/.claude/hooks/notify-slack.sh
```

Then add the following to `~/.claude/settings.json`:

```json
"hooks": {
    "PreToolUse": [
        { "matcher": "Bash", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/guard-destructive-cmd.sh" }] }
    ],
    "UserPromptSubmit": [
        { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/log-access-prompt.sh" }] }
    ],
    "PostToolUse": [
        { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/log-access-tool.sh" }] }
    ],
    "Notification": [
        { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/notify-slack.sh" }] }
    ],
    "Stop": [
        {
            "matcher": "",
            "hooks": [
                { "type": "command", "command": "bash ~/.claude/hooks/log-token-usage.sh" },
                { "type": "command", "command": "bash ~/.claude/hooks/log-access-stop.sh" },
                { "type": "command", "command": "bash ~/.claude/hooks/notify-slack.sh" }
            ]
        }
    ]
}
```

**Token usage hook** — at the end of every session, token usage is appended to `logs/token-usage/YYYY-MM.log` in this repository:

```
[2026-05-23 20:54:56] session=abc123  input=  1411  output=445336  cache_read=80565208  cache_create=1092677  total=1539424
```

**Slack input-wait notification hook** — sends a Slack message when Claude Code is waiting for user input. Set the webhook URL in your shell profile:

```bash
export CLAUDE_CODE_WAIT_NOTIFY_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"
```

- Registered for the `Notification` hook (permission prompts) and `Stop` hook (end-of-response idle)
- If the variable is unset or empty, the script exits silently — no notification is sent
- Requires `curl` and `jq`; works on macOS and Linux
- Network failures never block Claude (`curl --max-time 5`, errors swallowed)

**File access log hooks** — when `/work` is invoked, the files accessed in each command phase are appended to `logs/access/YYYY-MM.log` in this repository:

```
---
[日時]
2026.05.24 15.30

[ユーザーからの指示内容]
hooks のみで work/task/patch のファイルアクセスをログに記録したい

[アクセスサマリ]
総アクセス数: 6
重複アクセス:
  - ~/dev/.../hooks/log-access-tool.sh (2回)

[フェーズ別アクセス順序]
[work] 3件
  #1  Read  ~/.claude/commands/work.md
  #2  Read  ~/dev/.../docs/.ai/repo.profile.json
  #3  Glob  hooks/*.sh

[task] 3件
  #4  Read  ~/.claude/commands/task.md
  #5  Read  ~/dev/.../hooks/log-access-tool.sh
  #6  Read  ~/dev/.../hooks/log-access-tool.sh

[修正したファイル]
  - ~/dev/.../hooks/log-access-tool.sh

[トークン使用量]
  input:       12345
  output:       3210
  cache_read:   8901  (cache_ratio: 72.1%)
  total:        15555
  cost_usd:     0.0412
```

### 4. Status line (optional)

Displays context usage, 5-hour rate limit, and 7-day rate limit with reset times in the Claude Code status bar.

```bash
./setup_statusline.sh
```

Creates `~/.claude/statusline.sh` as a symlink to `scripts/statusline.sh` and adds the `statusLine` entry to `~/.claude/settings.json`. Requires `jq`. Restart Claude Code to apply.

```
CTX:35% | 5h:12%(>23:00) | 7d:41%(>06/15 23:00)
```

- **CTX** — context window usage (cyan)
- **5h** — 5-hour rate limit usage and reset time (yellow)
- **7d** — 7-day rate limit usage and reset datetime (magenta)

Rate limit data is only available for Claude.ai Pro/Max subscribers after the first API response in a session.

### Codex CLI (optional)

After completing Steps 0–2 above, symlink for Codex CLI:

```bash
ln -s /path/to/claude-code-kit/commands/task.md       ~/.codex/prompts/task.md
ln -s /path/to/claude-code-kit/commands/patch.md      ~/.codex/prompts/patch.md
ln -s /path/to/claude-code-kit/commands/docs-sync.md  ~/.codex/prompts/docs-sync.md
ln -s /path/to/claude-code-kit/commands/init-docs.md  ~/.codex/prompts/init-docs.md
ln -s /path/to/claude-code-kit/commands/new-issue.md  ~/.codex/prompts/new-issue.md
ln -s /path/to/claude-code-kit/AGENTS.md              ~/.codex/AGENTS.md
```

Skills are symlinked to `~/.codex/skills/` by `./install.sh` (run once).

## Usage

```
/new-issue (optional)
  └── rough idea → 1 or N well-formed issues (with split rationale) → user runs /work #N

/work (main entry)
  ├── docs not required → patch flow: branch → commit → user merges
  └── docs required     → task flow:  issue → implement → draft PR → /docs-sync → PR published

/review-resolve #N
  └── PR review comments → addressed/declined interactively → reply posted
```

Start every session with `/work` — it asks what you want to do and routes to the appropriate flow automatically. Use `/new-issue` first only when you want to shape a vague idea into well-formed issues before implementation. Use `/review-resolve` for handling PR review comments.

## Design Principles

- **`git diff` is truth** — AI summaries are supplementary only
- **Docs changes are isolated** — `/task` never touches `docs/*`; only `/docs-sync` does
- **Minimal updates** — `/docs-sync` updates only what changed, never rewrites wholesale
- **HARD STOP escalation** — when `/docs-sync` cannot reason about a change, it stops and requires `/init-docs`
- **Symlink-only** — `~/.claude/` holds no real files; everything symlinks back here

## Repository Structure

```
hooks/
  guard-destructive-cmd.sh  # PreToolUse/Bash — blocks Lv0 commands; Lv1 hands off to user for manual execution
  log-token-usage.sh        # Stop — logs token usage per session to logs/token-usage/YYYY-MM.log
  log-access-prompt.sh      # UserPromptSubmit — saves user instruction for session correlation
  log-access-tool.sh        # PostToolUse — tracks Read/Glob/Grep/Edit/Write by command phase
  log-access-stop.sh        # Stop — appends phase-based access log to logs/access/YYYY-MM.log
  notify-slack.sh           # Notification + Stop — posts to Slack when Claude waits for user input
logs/
  .gitkeep              # directory tracked; log files are gitignored
commands/
  work.md            # Main entry point — gates → investigates → routes to patch or task flow
  task.md            # Delegated by /work — implementation with docs changes (issue → PR → /docs-sync)
  patch.md           # Delegated by /work — lightweight fix flow (no docs changes)
  docs-sync.md       # Documentation sync and PR publication
  init-docs.md       # Full docs reconstruction
  review-resolve.md  # Interactive PR review comment resolution
  new-issue.md       # Optional pre-/work entry — idea-to-issue with split support
  templates/
    issue.md       # GitHub issue template
    pr.md          # Pull request template
    readme.md      # README.md scaffold template
partials/
  git-commit.md    # Shared commit procedure — Read by commands/* at commit time (not a slash command)
docs/
  .ai/
    repo.profile.json       # Machine-readable repo profile
  L0_concept/               # Product concept and design policy (WHY layer)
  L1_project/               # Project overview docs
  L2_development/           # Development and operation docs
  L3_implementation/        # Implementation specification docs
scripts/
  statusline.sh             # Claude Code status line — displays context + rate limit usage
setup_statusline.sh         # Installer — symlinks statusline.sh and updates settings.json
CLAUDE.md                   # AI operating instructions (auto-loaded by Claude Code)
```

## License

MIT
