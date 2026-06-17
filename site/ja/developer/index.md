# 開発者向けドキュメント

このセクションは、コントリビューターや上級ユーザー向けの内部設計・ワークフロールーティングロジック・コマンド仕様を解説します。

## 設計原則

- **`git diff` が事実** — AI の要約は補助情報にとどめる
- **docs 変更を分離** — `/task` は `docs/*` を変更しない。変更するのは `/docs-sync` のみ
- **最小更新** — `/docs-sync` は変更された箇所のみ更新し、全面的な書き直しは行わない
- **HARD STOP エスカレーション** — `/docs-sync` が変更を説明できない場合は停止し、`/init-docs` を要求する
- **symlink-only** — `~/.claude/` には実体ファイルを置かず、全てこのリポジトリへのシンボリックリンクとする

## ワークフローアーキテクチャ

```
/work (エントリポイント)
  │
  ├── G-0: main ブランチへの切り替え確認
  ├── G-1: docs/.ai/repo.profile.json の存在確認
  ├── G-2: ワークスペースクリーン確認（必要に応じて stash）
  │
  ├── issue が指定されている場合 → /task フロー
  │
  └── docs 変更が必要か？
       ├── YES → /task フロー（issue → 実装 → ドラフト PR → /docs-sync）
       └── NO  → /patch フロー（ブランチ → コミット → ユーザーが ff-merge）
```

## リポジトリ構造

```
hooks/              # Claude Code hook スクリプト（PreToolUse、Stop など）
commands/           # スラッシュコマンド Markdown ファイル
partials/           # 共通手順パーシャル（スラッシュコマンドではない）
templates/          # issue.md、pr.md、readme.md スキャフォールド
docs/               # 設計ドキュメント（L0〜L3）
  .ai/
    repo.profile.json   # 機械可読なリポジトリプロファイル
  L0_concept/           # WHY レイヤー — プロダクトコンセプトとポリシー
  L1_project/           # プロジェクト概要
  L2_development/       # 開発・運用モデル
  L3_implementation/    # 実装仕様
scripts/            # ユーティリティスクリプト（ステータスラインなど）
skills/             # Codex CLI スキルラッパー
```

## セクション

- [仕様サマリ](./specification) — コマンドおよび hook の詳細仕様
