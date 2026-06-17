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
    title: /new-issue
    details: 将模糊的想法转化为规范的 GitHub issue。/work 的可选前置步骤。
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
    title: /task & /patch
    details: 针对有无文档变更的实现的委托流程。
    link: /zh/developer/specification
  - icon: <i class="fa-solid fa-shield-halved"></i>
    title: Hooks
    details: 自动批准只读命令、防护破坏性操作、记录 token 使用量。
    link: /zh/guide/configuration
---
