# 配置

## 在 settings.json 中注册 Hooks

将以下内容添加到 `~/.claude/settings.json` 以激活 hooks。如果 `jq` 可用，`install.sh` 会自动完成此配置。

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
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/log-token-usage.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/log-access-stop.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/cleanup-session.sh" }
        ]
      }
    ]
  }
}
```

## Hook 参考

### auto-approve-readonly.sh

消除安全的只读工具调用的权限提示。

- 自动批准 `Read` 工具（所有输入）
- 自动批准只读 `Bash` 命令：`git status/log/diff`、`ls`、`cat`、`grep`、`fd`、`curl`（无文件下载）、`npm`（无安装）、`pytest` 等
- 复合命令（`&&`、`||`、`;`、`|`）会被拆分——只有每个部分都安全才会批准
- 写入重定向（`>`）按正常权限流程处理

### guard-destructive-cmd.sh

在 Claude 执行危险命令之前阻止或委托给用户。

- **Level 0（立即阻止）：** 对系统目录执行 `rm -rf`、`dd`/`mkfs`、fork bomb、`git filter-branch`
- **Level 1（交给用户）：** `git push --force`、`git reset --hard`、`git clean -fd`、`git branch -D`

### log-token-usage.sh

在每次会话结束时将 token 使用量追加到 `logs/token-usage/YYYY-MM.log`。

```
[2026-05-23 20:54:56] session=abc123  input=1411  output=445336  cache_read=80565208  total=1539424  cost_usd=0.0412
```

### log-access-*.sh

记录 `/work` 会话的用户提示、文件访问顺序和修改文件。

- `log-access-prompt.sh`：保存当前用户提示
- `log-access-tool.sh`：按工作流阶段跟踪 Read/Glob/Grep/Edit/Write
- `log-access-stop.sh`：在会话停止时写入待处理的访问日志

### cleanup-session.sh

在会话结束时删除 `${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/sessions/<session-id>/session-approved` 下当前会话的批准文件，防止批准权限延续到下一个会话或在并发会话之间混用。

## 状态栏

运行 `./setup_statusline.sh` 后，Claude Code 状态栏将显示：

```
CTX:35% | 5h:12%(>23:00) | 7d:41%(>06/15 23:00)
```

- **CTX** — 上下文窗口使用率
- **5h** — 5小时速率限制使用率和重置时间
- **7d** — 7天速率限制重置日期时间

速率限制数据仅对 Claude.ai Pro/Max 订阅者可用。
