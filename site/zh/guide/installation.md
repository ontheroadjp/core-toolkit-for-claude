# 安装

> **仅符号链接原则：** `~/.claude/` 下的所有文件必须是指向本仓库的符号链接——不能是实际的文件副本。本仓库是唯一的事实来源；`~/.claude/` 只是一个参考点。

## 快速安装

最快的设置方式：

```bash
git clone https://github.com/ontheroadjp/core-toolkit-for-claude.git
cd core-toolkit-for-claude
./install.sh
```

这将创建以下符号链接：
- `commands/*.md` → `~/.claude/commands/` 和 `~/.codex/commands/`
- `hooks/*.sh` → `~/.claude/hooks/`
- `skills/*/` → `~/.codex/skills/`

目标目录会自动创建。

## 手动设置

### Step 0：创建共享模板的符号链接（必须）

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/core-toolkit-for-claude/templates \
      ~/.config/claude-code-kit/templates
```

模板存储在 `~/.config/claude-code-kit/templates/`，使 Claude Code 和 Codex CLI 都能从单一位置引用它们。

### Step 1：创建命令的符号链接（全局——所有仓库）

```bash
ln -s /path/to/core-toolkit-for-claude/commands/work.md            ~/.claude/commands/work.md
ln -s /path/to/core-toolkit-for-claude/commands/task.md            ~/.claude/commands/task.md
ln -s /path/to/core-toolkit-for-claude/commands/patch.md           ~/.claude/commands/patch.md
ln -s /path/to/core-toolkit-for-claude/commands/docs-sync.md       ~/.claude/commands/docs-sync.md
ln -s /path/to/core-toolkit-for-claude/commands/init-docs.md       ~/.claude/commands/init-docs.md
ln -s /path/to/core-toolkit-for-claude/commands/review-resolve.md  ~/.claude/commands/review-resolve.md
ln -s /path/to/core-toolkit-for-claude/commands/new-issue.md       ~/.claude/commands/new-issue.md
```

这些命令现在可以在任何 Claude Code 会话中以 `/work`、`/task`、`/patch`、`/docs-sync`、`/init-docs`、`/review-resolve` 和 `/new-issue` 的形式使用。

### Step 2：创建 CLAUDE.md 的符号链接（全局——所有仓库）

```bash
ln -s /path/to/core-toolkit-for-claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Claude Code 会在每个会话中自动加载 `~/.claude/CLAUDE.md`，因此 AI 操作指令会自动应用到所有仓库。如果某个仓库需要不同的指令，在其根目录放置一个本地 `CLAUDE.md`——本地优先于全局。

### Step 3：创建 hooks 的符号链接（可选）

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

请参阅[配置](./configuration)了解如何在 `~/.claude/settings.json` 中注册 hooks。

### Step 4：状态栏（可选）

在 Claude Code 状态栏中显示上下文使用率和速率限制：

```bash
./setup_statusline.sh
```

重启 Claude Code 以应用。

## 要求

- 已安装 [Claude Code](https://claude.ai/code)
- 已安装并认证 Git 和 gh CLI
- 已安装 jq
