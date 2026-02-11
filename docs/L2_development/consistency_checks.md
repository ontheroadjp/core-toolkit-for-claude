# Consistency Checks

このファイルは `init-docs` の Phase 2.5 実行結果を記録する。

## 2.5-1 docs -> 実体検証

- 本 docs で参照した主要パスは実在する。
  - `init-docs.md`, `docs-sync.md`, `task.md`, `fix.md`, `init-git.md`, `init-test.md`, `issue.md`, `own-task.md`, `git-clean.md`, `test-balance.md`, `repo.profile.json`, `AGENTS.md`
- `main/app/server` 形式の実装エントリは未確認として分離した。
  - 根拠: `init-docs.md:102`, `init-docs.md:110`

## 2.5-2 repo.profile.json <-> docs 突合

- `repo.profile.json.doc_roots` は `docs/L1_project`, `docs/L2_development`, `docs/L3_implementation` で、docs 実構造と一致。
  - 根拠: `repo.profile.json`
- `repo.profile.json.commands` は空であり、本 docs 側でも repo 実行コマンドを断定していない。
  - 根拠: `repo.profile.json`
- docs 内で扱っている `git` / `gh` / `npm` 等は「仕様中に登場する外部CLI」として記述し、repo 固有 commands としては登録していない。
  - 根拠: `init-git.md:14`, `init-git.md:15`, `init-test.md:76`, `init-test.md:109`

## 2.5-3 CI 整合性

- `.github/workflows/**/*.yml` は未観測（ファイル未確認）。
- したがって CI との一致は「未確認」とし、CI 手順の断定は行っていない。
  - 根拠: CI 定義ファイル不在（要再観測）

## 2.5-4 根拠表記

- 断定文には可能な範囲で `ファイル:行` を記載済み。
  - 根拠要求: `init-docs.md:142`, `init-docs.md:146`, `init-docs.md:152`

## 2.5-5 未確認事項

- CI 定義の有無と実行手順
  - 理由: `.github/workflows` が未観測
  - 確定に必要: `.github/workflows/**/*.yml`
- 実行ランタイム/言語スタック
  - 理由: `package.json`, `pyproject.toml`, `Makefile` 等の実体が未観測
  - 確定に必要: 実行定義ファイルの追加または検出

## 2.5-6 判定

- `init-docs` Done Criteria に対し、現時点は「部分完了」。
  - 理由: CI 整合性を確認できる定義ファイルが未確認。
  - 根拠: `init-docs.md:163`, `init-docs.md:169`, `init-docs.md:173`
