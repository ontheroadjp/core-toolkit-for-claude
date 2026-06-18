---
layout: home

hero:
  name: "Core Toolkit"
  text: "for Claude"
  tagline: 从实现到文档同步和 PR 发布的结构化 AI 驱动开发工作流。
  image:
    src: /hero.png
    alt: Core Toolkit for Claude
  actions:
    - theme: brand
      text: 快速开始
      link: /zh/guide/
    - theme: alt
      text: 在 GitHub 上查看
      link: https://github.com/ontheroadjp/core-toolkit-for-claude

features:
  - icon: <i class="fa-solid fa-code-branch"></i>
    title: /work
    details: 所有任务的主入口。门控检查 → 调查 → 自动路由到 patch 或 task 流程。
    link: /zh/guide/
  - icon: <i class="fa-solid fa-file-circle-plus"></i>
    title: /triage-issues
    details: 审查并分类 open issue，将它们整理到可通过 /work #N 开始的状态。
    link: /zh/guide/
  - icon: <i class="fa-solid fa-rotate"></i>
    title: /docs-sync
    details: 以 git diff 为事实，最小化更新文档，然后发布草稿 PR。
    link: /zh/developer/
  - icon: <i class="fa-solid fa-code-pull-request"></i>
    title: /review-resolve
    details: 获取 PR 审查评论，交互式地处理或拒绝每条评论。
    link: /zh/guide/
  - icon: <i class="fa-solid fa-book"></i>
    title: /codex-review
    details: 使用 Codex CLI 审查 PR、发布结果，并在要求变更时交接给 /review-resolve。
    link: /zh/developer/specification
  - icon: <i class="fa-solid fa-shield-halved"></i>
    title: Hooks
    details: 自动批准只读命令、防护破坏性操作、记录访问日志并跟踪 token 使用量。
    link: /zh/guide/configuration
---
