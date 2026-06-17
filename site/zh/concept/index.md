# 设计概念

## 目的

本仓库以 Markdown 命令规范、Codex skill 封装器、Claude Code hooks、通用模板和 VitePress 站点的形式，集中管理 Claude Code 和 Codex CLI 的 AI 驱动开发工作流。

## 解决的问题

抑制由于 AI 工作开始模糊而导致的文档更新遗漏、issue/PR 追踪遗漏、审查评论响应的个人依赖、破坏性 git 操作以及会话批准的延续问题。

为此，`/work` 负责门控检查、现状调查和基于文档变更需求的路由；`/task` 负责带 issue 和 PR 的实现；`/patch` 负责轻量修复；`/docs-sync` 负责基于 git diff 的文档同步；`/review-resolve` 负责 PR 审查评论响应。

## 目标用户

面向使用 Claude Code 或 Codex CLI、希望以可重现的流程推进实现、文档同步、PR 创建和审查响应的开发者。

## 设计约束

- `~/.claude/` 下仅使用符号链接，以本仓库为唯一事实来源。
- 工作入口限于 `/review-resolve`、`/work` 和可选的 `/new-issue`。
- 将文档变更需求作为单一问题处理。
- 文档同步以 `git diff` 为事实。
- L0 不通过 `/docs-sync` 更新；在重新观测设计方针时由 `/init-docs` 更新。
