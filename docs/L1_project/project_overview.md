# Project Overview

## このリポジトリの実態

- 本リポジトリは、Slash Command 用の仕様 Markdown 群で構成される。
  - 根拠: `init-docs.md:1`, `docs-sync.md:1`, `init-git.md:1`, `task.md:1`
- `/init-docs` を基点に、`repo.profile.json` と docs の整合を取る運用が定義されている。
  - 根拠: `init-docs.md:11`, `init-docs.md:17`, `init-docs.md:46`, `init-docs.md:65`, `init-docs.md:75`
- `/docs-sync` は差分追随専用で、全体再構築の代替ではない。
  - 根拠: `docs-sync.md:7`, `docs-sync.md:8`, `docs-sync.md:29`, `docs-sync.md:30`

## 主要機能（コマンド仕様）

- タスク実行フロー（実装・docs追随・取り込み）: `task.md`
  - 根拠: `task.md:10`, `task.md:14`, `task.md:18`, `task.md:63`
- バグ修正フロー: `fix.md`
  - 根拠: `fix.md:1`, `fix.md:22`, `fix.md:47`
- テスト基盤初期化: `init-test.md`
  - 根拠: `init-test.md:1`, `init-test.md:5`, `init-test.md:36`, `init-test.md:47`
- テスト投資バランス診断: `test-balance.md`
  - 根拠: `test-balance.md:5`, `test-balance.md:38`, `test-balance.md:149`, `test-balance.md:203`
- Git 初期化・整備: `init-git.md`, `git-clean.md`, `own-task.md`
  - 根拠: `init-git.md:3`, `init-git.md:50`, `git-clean.md:3`, `git-clean.md:19`, `own-task.md:3`, `own-task.md:31`
- Issue 起票補助: `issue.md`
  - 根拠: `issue.md:4`, `issue.md:31`, `issue.md:51`

## 技術スタック（確定できる範囲）

- ドキュメント形式: Markdown（`.md`）
  - 根拠: `init-docs.md:1`, `docs-sync.md:1`, `task.md:1`（同様のトップレベルファイル）
- 実装言語・ランタイム: 未確認（現時点でソースコード/設定ファイルが観測されない）
  - 確定に必要: `package.json`, `pyproject.toml`, `Makefile`, `go.mod` 等の実在

## 主要依存関係（仕様上の外部CLI）

- `git` と `gh` を前提にするコマンド仕様が存在する。
  - 根拠: `init-git.md:14`, `init-git.md:15`, `init-git.md:20`, `init-git.md:21`, `task.md:39`, `issue.md:53`
- `npm/pnpm/yarn/pytest` などは `init-test` の観測対象として記述されるが、採用は観測ベースで確定する仕様。
  - 根拠: `init-test.md:76`, `init-test.md:78`, `init-test.md:83`, `init-test.md:109`, `init-test.md:118`
