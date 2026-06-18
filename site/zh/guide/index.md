# 用户指南

**Core Toolkit for Claude** 是一套面向 [Claude Code](https://claude.ai/code) 和 Codex CLI 的命令规范、Codex skill、hooks 和模板，提供结构化的 AI 驱动开发工作流——从实现到文档同步、PR 发布、issue 分诊和审查响应。

## 命令列表

| 命令 | 用途 |
|---|---|
| `/work` | 所有开发任务的**主入口**。门控检查 → 调查 → 自动路由到 patch 或 task 流程。 |
| `/triage-issues` | 独立工作流，用于审查 open issue、分类 stale/unclear/ready 等状态，并整理到可通过 `/work #N` 开始的状态。 |
| `/new-issue` | 可选的 `/work` 前置步骤。将模糊的想法转化为规范的 GitHub issue。不执行实现。 |
| `/review-resolve` | 获取 PR 审查评论，交互式地处理或拒绝每条评论。 |
| `/codex-review` | 使用 Codex CLI 审查 PR，发布 approve 或 change request，并在要求变更时调用 `/review-resolve`。 |
| `/patch` | *（由 /work 委托）* 无文档变更的轻量修复。分支 + 提交 → 用户 ff-merge。 |
| `/task` | *（由 /work 委托）* 带文档变更的实现。issue → 实现 → 草稿 PR → `/docs-sync`。 |
| `/docs-sync` | 以 `git diff` 为事实，最小化更新 `docs/*`，然后发布草稿 PR。 |
| `/init-docs` | 完整重新观测和重建项目设计文档。在 `/docs-sync` 遇到 HARD STOP 时运行。 |

## 典型工作流

```
/new-issue（可选）
  └── 模糊想法 → 规范 issue → 用户运行 /work #N

/triage-issues
  └── open issue → stale/unclear/ready 分类 → 经用户批准的清理

/work（主入口）
  ├── 无需文档变更 → patch 流程：分支 → 提交 → 用户合并
  └── 需要文档变更 → task 流程：issue → 实现 → 草稿 PR → /docs-sync → PR 发布

/codex-review #N
  └── Codex CLI review → approve 或要求变更 → 必要时进入 /review-resolve

/review-resolve #N
  └── PR 审查评论 → 交互式处理/拒绝 → 发布回复
```

实现工作从 `/work` 开始。PR 审查评论响应直接使用 `/review-resolve #N`，当任务是准备 issue 时才在 `/work` 之前使用 `/new-issue` 或 `/triage-issues`。

## 下一步

- [安装](./installation) — 设置符号链接和 hooks
- [配置](./configuration) — 配置 hooks 和 settings.json
