# 方针

## 技术选型方针

- 命令规范以 Markdown 管理。AI 读取 `commands/*.md` 并执行，不引入其他 DSL。
- Codex skill 放置在 `skills/*/SKILL.md` 中，作为读取对应 `commands/*.md`（事实来源）的薄封装器。
- Claude Code hooks 和辅助工具以 Bash 实现。
- 公开站点以 `site/` 下的 VitePress 和 npm 管理。

## 安全方针

- 破坏性 Bash 操作由 `hooks/guard-destructive-cmd.sh` 分为 Lv0/Lv1。Lv0 立即阻止，Lv1 委托给用户手动执行而非 AI 自动执行。
- 只有只读操作和会话已批准的操作由 `hooks/auto-approve-readonly.sh` 自动批准。
- 会话批准在 Stop hook 时删除，不延续到下一个会话。
- 提交前从 diff 中确认个人信息、IP 地址、域名和绝对路径。

## 运维与性能方针

- hooks 不过度干扰 Claude Code 的正常操作。实现中存在日志写入失败时继续处理的逻辑。
- VitePress 站点在 CI 中以 `site/` 为工作目录执行 `npm ci` 和 `npm run docs:build`，并部署到 GitHub Pages。
- `scripts/statusline.sh` 使用 `jq` 和 `bc` 显示上下文使用率。

## 禁止事项

| 禁止事项 | 原因 |
|---|---|
| 在 `~/.claude/` 下放置实体文件 | 破坏仅符号链接原则和唯一事实来源 |
| 在 `/task` 中直接更新 `docs/*` | 文档同步是 `/docs-sync` 的职责 |
| 在 `/docs-sync` 中常规更新 L0 | L0 是决策记录，不是 git diff 追踪对象 |
| 使用 `git add -A` / `git add .` | 容易意外提交非预期文件 |
| AI 自动执行 `git push --force` 等不可逆 git 操作 | 可能破坏共享历史或未追踪的变更 |

## 一致性方针

`install.sh` 向 settings 注册的 hook 仅限于当前 `hooks/` 下实际存在的脚本。不注册不存在的 hook。
