---
layout: home

hero:
  name: "Core Toolkit"
  text: "for Claude"
  tagline: 実装からドキュメント同期・PR 公開まで、構造化された AI 駆動開発ワークフロー。
  image:
    src: /hero.png
    alt: Core Toolkit for Claude
  actions:
    - theme: brand
      text: はじめる
      link: /ja/guide/
    - theme: alt
      text: GitHub で見る
      link: https://github.com/ontheroadjp/core-toolkit-for-claude

features:
  - icon: <i class="fa-solid fa-code-branch"></i>
    title: /work
    details: 全タスクのメインエントリポイント。ゲート確認 → 調査 → patch フローまたは task フローへ自動ルーティング。
    link: /ja/guide/
  - icon: <i class="fa-solid fa-file-circle-plus"></i>
    title: /triage-issues
    details: open issue を分類・整理し、/work #N で着手できる状態へ整える。
    link: /ja/guide/
  - icon: <i class="fa-solid fa-rotate"></i>
    title: /docs-sync
    details: git diff を事実として docs を最小更新し、ドラフト PR を公開する。
    link: /ja/developer/
  - icon: <i class="fa-solid fa-code-pull-request"></i>
    title: /review-resolve
    details: PR レビューコメントを取得し、各コメントへの対応・却下をインタラクティブに進める。
    link: /ja/guide/
  - icon: <i class="fa-solid fa-book"></i>
    title: /codex-review
    details: Codex CLI で PR をレビューし、結果を投稿。変更要求時は /review-resolve へ引き継ぐ。
    link: /ja/developer/specification
  - icon: <i class="fa-solid fa-shield-halved"></i>
    title: Hooks
    details: 読み取り専用コマンドの自動承認、破壊的操作のガード、アクセスログ、トークン使用量の記録。
    link: /ja/guide/configuration
---
