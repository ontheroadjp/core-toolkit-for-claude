# templates/

issue・PR・README の Markdown テンプレートを置くディレクトリ。

## 仕組み

template の実体はこのディレクトリに保持する。コマンド仕様（`commands/*.md`）は実行 agent に応じた installed path を参照する。

- Claude Code: `<target-repository>/.claude/templates/*.md`
- Codex CLI: `<target-repository>/.codex/templates/*.md`

通常は対象 repository root で `./install.sh` を実行し、選択した agent の installed path に symlink を作成する。手動設定は不要である。

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
