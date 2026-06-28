# templates/

issue・PR・README の Markdown テンプレートを置くディレクトリ。

## 仕組み

コマンド仕様（`commands/*.md`）は installed path である `~/.config/claude-code-kit/templates/*.md` を参照する。
このディレクトリを `~/.config/claude-code-kit/templates/` へ手動で symlink しておく必要がある。

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/core-toolkit-for-claude/templates ~/.config/claude-code-kit/templates
```

## ファイル一覧

| ファイル | 用途 | 使用コマンド |
|---|---|---|
| `issue.md` | GitHub issue のドラフトテンプレート | `/task`（Step 2）、`/new-issue`（Step 4）、`/patch`（エスカレーション時） |
| `pr.md` | GitHub PR 本文のテンプレート | `/task`（Phase 2）、`/git-pr` |
| `readme.md` | 新規リポジトリの README scaffold | `/init-docs`（Phase 6） |

## 各テンプレートの構成

### issue.md

```
## Overview      — 何を・なぜ（1〜2文）
## Background    — 背景・制約・問題
## Scope         — 変更対象の初期見積
## Done Criteria — 完了を判断できる条件（検証可能であること）
```

`/patch` からエスカレーションする場合のみ、以下のセクションを追加する:

```
## Changes Already Made in /patch   — コミット済みの変更
## Additional Scope                 — docs 変更が必要になった理由
```

### pr.md

PR 本文の標準構成を定義する。`/task` Phase 2 で実際の値を埋めて使用する。
PR のタイトル・本文は **英語** で記述する。

### readme.md

新規リポジトリの README.md scaffold。`/init-docs` が初期化時に参照する。
