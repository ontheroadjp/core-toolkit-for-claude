# templates/README.md — L3 per-file doc

## 目的・役割

`templates/` ディレクトリの目的・各テンプレートファイルの構成・使用コマンドとのマッピングを説明するドキュメント。

## 動作の概要

- `issue.md`・`pr.md`・`readme.md` の構成と用途を説明
- 参照する際の installed path（`~/.config/claude-code-kit/templates/`）と symlink 設定手順を記載
- `issue.md` のエスカレーション専用セクションについて言及

## 重要な設計判断

- PR タイトル・本文は英語必須という制約を明示（commands/task.md に由来）
- テンプレートは `~/.config/claude-code-kit/templates/` を installed path として参照するため、symlink が必須

## 統合ポイント

- 使用コマンド: `/task`（Step 2, Phase 2）、`/new-issue`（Step 4）、`/git-pr`、`/init-docs`
- 関連: `templates/issue.md`、`templates/pr.md`、`templates/readme.md`

根拠: `templates/README.md:1-50`, `templates/issue.md:1-25`
