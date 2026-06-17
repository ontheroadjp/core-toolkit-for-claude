# 开发者文档

本节涵盖面向贡献者和高级用户的内部设计、工作流路由逻辑和命令规范。

## 设计原则

- **`git diff` 是事实** — AI 摘要仅作为辅助信息
- **文档变更隔离** — `/task` 不触碰 `docs/*`；只有 `/docs-sync` 负责文档变更
- **最小化更新** — `/docs-sync` 只更新发生变化的部分，不进行全面重写
- **HARD STOP 升级** — 当 `/docs-sync` 无法推断变更时，停止并要求运行 `/init-docs`
- **仅符号链接** — `~/.claude/` 不存放实体文件；所有内容都链接回本仓库

## 工作流架构

```
/work（入口）
  │
  ├── G-0：确保在 main 分支
  ├── G-1：验证 docs/.ai/repo.profile.json 存在
  ├── G-2：工作区干净检查（必要时 stash）
  │
  ├── 提到 issue？→ /task 流程
  │
  └── 需要文档变更？
       ├── 是 → /task 流程（issue → 实现 → 草稿 PR → /docs-sync）
       └── 否 → /patch 流程（分支 → 提交 → 用户 ff-merge）
```

## 仓库结构

```
hooks/              # Claude Code hook 脚本（PreToolUse、Stop 等）
commands/           # 斜杠命令 Markdown 文件
partials/           # 共享流程片段（非斜杠命令）
templates/          # issue.md、pr.md、readme.md 脚手架
docs/               # 设计文档（L0–L3）
  .ai/
    repo.profile.json   # 机器可读的仓库配置文件
  L0_concept/           # WHY 层——产品概念和方针
  L1_project/           # 项目概述
  L2_development/       # 开发和运维模型
  L3_implementation/    # 实现规范
scripts/            # 实用脚本（状态栏等）
skills/             # Codex CLI skill 封装器
```

## 章节

- [规范摘要](./specification) — 详细的各命令和 hook 规范
