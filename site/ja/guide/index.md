# ユーザーガイド

**Core Toolkit for Claude** は [Claude Code](https://claude.ai/code) と Codex CLI 向けのコマンド仕様、Codex skill、hooks、テンプレート集です。実装からドキュメント同期・PR 公開、issue トリアージ、レビュー対応まで、構造化された AI 駆動開発ワークフローを提供します。

## コマンド一覧

| コマンド | 目的 |
|---|---|
| `/work` | 全開発タスクの**メインエントリポイント**。ゲート確認 → 調査 → patch フローまたは task フローへ自動ルーティング。 |
| `/triage-issues` | open issue を確認し、stale / unclear / ready などへ分類して `/work #N` で着手できる状態へ整えるスタンドアロン workflow。 |
| `/new-issue` | 任意の `/work` 前段ステップ。漠然としたアイデアを整形された GitHub issue に変換。実装は行わない。 |
| `/review-resolve` | PR レビューコメントを取得し、各コメントへの対応・却下をインタラクティブに進める。 |
| `/codex-review` | Codex CLI で PR をレビューし、approve または change request を投稿。変更要求時は `/review-resolve` を呼び出す。 |
| `/patch` | *(/work から委譲)* ドキュメント変更不要の軽微修正。ブランチ + コミット → ユーザーが ff-merge。 |
| `/task` | *(/work から委譲)* ドキュメント変更を伴う実装。issue → 実装 → ドラフト PR → `/docs-sync`。 |
| `/docs-sync` | `git diff` を事実として `docs/*` を最小更新し、ドラフト PR を公開する。 |
| `/init-docs` | プロジェクト設計ドキュメントの全再観測・再構築。`/docs-sync` が HARD STOP した際に実行。 |

## 典型的なワークフロー

```
/new-issue (任意)
  └── 漠然としたアイデア → 整形された issue → ユーザーが /work #N を実行

/triage-issues
  └── open issue → stale/unclear/ready 分類 → ユーザー承認済みの整理

/work (メインエントリ)
  ├── docs 変更不要 → patch フロー: ブランチ → コミット → ユーザーがマージ
  └── docs 変更あり → task フロー: issue → 実装 → ドラフト PR → /docs-sync → PR 公開

/codex-review #N
  └── Codex CLI review → approve または変更要求 → 必要に応じて /review-resolve

/review-resolve #N
  └── PR レビューコメント → インタラクティブに対応・却下 → 返信投稿
```

実装作業は `/work` から始めます。PR レビューコメント対応は `/review-resolve #N` を直接使い、issue 整理が目的の場合のみ `/new-issue` または `/triage-issues` を `/work` の前に使います。

## 次のステップ

- [インストール](./installation) — シンボリックリンクと hooks のセットアップ
- [設定](./configuration) — hooks と settings.json の設定
