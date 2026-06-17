# Configuration

## Registering Hooks in settings.json

Add the following to `~/.claude/settings.json` to activate the hooks. `install.sh` does this automatically if `jq` is available.

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
    "Notification": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/notify-slack.sh"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/log-token-usage.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/notify-slack.sh" }
        ]
      }
    ]
  }
}
```

## Hook Reference

### auto-approve-readonly.sh

Eliminates permission prompts for safe, read-only tool calls.

- Auto-approves the `Read` tool (all inputs)
- Auto-approves read-only `Bash` commands: `git status/log/diff`, `ls`, `cat`, `grep`, `fd`, `curl` (no file download), `npm` (no install), `pytest`, and more
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

### notify-slack.sh

Posts to Slack when Claude Code is waiting for user input or finishes a response.

Set the webhook URL in your shell profile:

```bash
export CLAUDE_CODE_KIT_WAIT_NOTIFY_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"
```

If the variable is unset or empty, the hook exits silently. Network failures never block Claude (`curl --max-time 5`).

## Status Line

After running `./setup_statusline.sh`, the Claude Code status bar shows:

```
CTX:35% | 5h:12%(>23:00) | 7d:41%(>06/15 23:00)
```

- **CTX** — context window usage
- **5h** — 5-hour rate limit usage and reset time
- **7d** — 7-day rate limit usage and reset datetime

Rate limit data is only available for Claude.ai Pro/Max subscribers.
