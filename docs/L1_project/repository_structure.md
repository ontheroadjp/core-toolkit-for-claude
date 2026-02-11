# Repository Structure

## 現在のディレクトリ構造（観測結果）

- ルート直下にコマンド仕様 Markdown が配置されている。
  - 根拠ファイル: `create-test.md`, `docs-sync.md`, `fix.md`, `git-clean.md`, `init-docs.md`, `init-git.md`, `init-test.md`, `issue.md`, `own-task.md`, `task.md`, `test-balance.md`
- `docs/` は `/init-docs` 実行で生成される想定。
  - 根拠: `init-docs.md:65`, `init-docs.md:66`, `init-docs.md:67`, `init-docs.md:68`

## 責務分割

- `L1`: プロジェクトの構成・責務を説明
- `L2`: 運用手順と整合ルールを説明
- `L3`: 実装仕様サマリを説明

上記3層構造は `/init-docs` が要求する docs 出力構造に一致する。
- 根拠: `init-docs.md:65`, `init-docs.md:66`, `init-docs.md:67`, `init-docs.md:68`

## エントリポイント

- Slash Command 定義ファイル自体が運用エントリ。
  - 根拠: `task.md:1`, `fix.md:1`, `init-docs.md:1`, `docs-sync.md:1`, `init-git.md:1`, `init-test.md:1`, `issue.md:1`, `own-task.md:1`, `git-clean.md:1`, `test-balance.md:1`
- アプリケーションの `main/app/server` 実装エントリは未確認。
  - 確定に必要: `src/main.*`, `app/*`, `server.*` などの実ファイル
