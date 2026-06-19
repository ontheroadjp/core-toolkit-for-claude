# Configuration

## Registering Hooks

Add the following to `~/.claude/settings.json` to activate Claude Code hooks. `install.sh` does this automatically if `jq` is available.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/auto-approve-readonly.sh"
        }]
      },
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/guard-destructive-cmd.sh"
        }]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/log-access-prompt.sh"
        }]
      },
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/tmux-agent-status.sh 🔵"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/log-access-tool.sh"
        }]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/tmux-agent-status.sh 🟠"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/log-token-usage.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/log-access-stop.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/cleanup-session.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/tmux-agent-status.sh ⚪" }
        ]
      }
    ]
  }
}
```

For Codex CLI, the same event structure is registered in `~/.codex/hooks.json`, using `~/.codex/hooks/*.sh` paths. After installation, review and trust those hooks with `/hooks`.

## Hook Reference

### auto-approve-readonly.sh

Eliminates permission prompts for safe, read-only tool calls.

- Auto-approves the `Read` tool (all inputs)
- Auto-approves read-only `Bash` commands: `git status/log/diff`, `ls`, `cat`, `grep`, `fd`, `curl` (no file download), `npm` (no install), `pytest`, and more
- Auto-approves session-scoped writes listed in the current `session-approved` file
- Compound commands (`&&`, `||`, `;`, `|`) are split — approved only if every segment is safe
- Write redirections (`>`) pass through to normal permission flow

### guard-destructive-cmd.sh

Blocks or delegates dangerous commands before Claude executes them.

- **Level 0 (immediate block):** `rm -rf` on system dirs, `dd`/`mkfs`, fork bombs, `git filter-branch`
- **Level 1 (hand off to user):** `git push --force`, `git reset --hard`, `git clean -fd`, `git branch -D`

### log-token-usage.sh

Appends token usage to `logs/token-usage/YYYY-MM.log` at the end of every session.

```
[2026-05-23 20:54:56] session=abc123  input=1411  output=445336  cache_read=80565208  total=1539424  cost_usd=0.0412
```

### log-access-*.sh

Records the user prompt, file access order, and modified files for `/work` sessions.

- `log-access-prompt.sh`: saves the current user prompt
- `log-access-tool.sh`: tracks Read/Glob/Grep/Edit/Write by workflow phase
- `log-access-stop.sh`: writes the pending access log at session stop

### cleanup-session.sh

Deletes the current session's approval file under `${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/sessions/<session-id>/session-approved` so approvals do not carry over or mix across concurrent sessions.

### tmux-agent-status.sh

Displays real-time AI agent status as an emoji prefix on the current tmux window title. Silently exits when not running inside tmux.

| Event | Emoji | Meaning |
|---|---|---|
| `UserPromptSubmit` | 🔵 | Executing |
| `Notification` | 🟠 | Permission / input needed |
| `Stop` | ⚪ | Idle |

To also show ⚪ at startup (before any hook fires), add shell wrapper functions to `~/.zshrc`:

```bash
claude() { bash ~/.claude/hooks/tmux-agent-status.sh ⚪; command claude "$@"; }
codex()  { bash ~/.claude/hooks/tmux-agent-status.sh ⚪; command codex  "$@"; }
```

## Status Line

After running `./setup_statusline.sh`, the Claude Code status bar shows:

```
CTX:35% | 5h:12%(>23:00) | 7d:41%(>06/15 23:00)
```

- **CTX** — context window usage
- **5h** — 5-hour rate limit usage and reset time
- **7d** — 7-day rate limit usage reset datetime

Rate limit data is only available for Claude.ai Pro/Max subscribers.
