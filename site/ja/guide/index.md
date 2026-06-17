# ユーザーガイド

**Core Toolkit for Claude** は [Claude Code](https://claude.ai/code) 向けのカスタムスラッシュコマンド集です。実装からドキュメント同期・PR 公開まで、構造化された AI 駆動開発ワークフローを提供します。

## コマンド一覧

| コマンド | 目的 |
|---|---|
| `/work` | 全開発タスクの**メインエントリポイント**。ゲート確認 → 調査 → patch フローまたは task フローへ自動ルーティング。 |
| `/new-issue` | 任意の `/work` 前段ステップ。漠然としたアイデアを整形された GitHub issue に変換。実装は行わない。 |
| `/review-resolve` | PR レビューコメントを取得し、各コメントへの対応・却下をインタラクティブに進める。 |
| `/patch` | *(/work から委譲)* ドキュメント変更不要の軽微修正。ブランチ + コミット → ユーザーが ff-merge。 |
| `/task` | *(/work から委譲)* ドキュメント変更を伴う実装。issue → 実装 → ドラフト PR → `/docs-sync`。 |
| `/docs-sync` | `git diff` を事実として `docs/*` を最小更新し、ドラフト PR を公開する。 |
| `/init-docs` | プロジェクト設計ドキュメントの全再観測・再構築。`/docs-sync` が HARD STOP した際に実行。 |

## 典型的なワークフロー

```
/new-issue (任意)
  └── 漠然としたアイデア → 整形された issue → ユーザーが /work #N を実行

/work (メインエントリ)
  ├── docs 変更不要 → patch フロー: ブランチ → コミット → ユーザーがマージ
  └── docs 変更あり → task フロー: issue → 実装 → ドラフト PR → /docs-sync → PR 公開

/review-resolve #N
  └── PR レビューコメント → インタラクティブに対応・却下 → 返信投稿
```

セッションは常に `/work` から始めてください。何をしたいかを尋ねて、適切なフローへ自動ルーティングします。

## 次のステップ

- [インストール](./installation) — シンボリックリンクと hooks のセットアップ
- [設定](./configuration) — hooks と settings.json の設定
