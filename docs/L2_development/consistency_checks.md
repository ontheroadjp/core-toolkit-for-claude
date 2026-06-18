# Consistency Checks

このファイルは `/init-docs` Phase 4 の整合性検証結果を記録する。

最終実行: 2026-06-18（CI / VitePress site / command 一覧 / skill 一覧 / hooks 実体を再観測し、repo profile と L0-L3 docs を再検証）

## 4-1. docs -> 実体 の検証

### 参照パス

| パス | 実在 | 根拠 |
|---|---|---|
| `commands/work.md` | yes | `rg --files -uu` |
| `commands/task.md` | yes | `rg --files -uu` |
| `commands/patch.md` | yes | `rg --files -uu` |
| `commands/docs-sync.md` | yes | `rg --files -uu` |
| `commands/init-docs.md` | yes | `rg --files -uu` |
| `commands/review-resolve.md` | yes | `rg --files -uu` |
| `commands/codex-review.md` | yes | `rg --files -uu` |
| `commands/triage-issues.md` | yes | `rg --files -uu` |
| `commands/new-issue.md` | yes | `rg --files -uu` |
| `commands/coding-general.md` | yes | `rg --files -uu` |
| `commands/coding-py.md` | yes | `rg --files -uu` |
| `commands/coding-js.md` | yes | `rg --files -uu` |
| `commands/coding-ts.md` | yes | `rg --files -uu` |
| `templates/issue.md` | yes | `templates/issue.md:1-25` |
| `templates/pr.md` | yes | `templates/pr.md:1-32` |
| `templates/readme.md` | yes | `rg --files -uu` |
| `partials/git-commit.md` | yes | `partials/git-commit.md:1-15` |
| `hooks/auto-approve-readonly.sh` | yes | `hooks/auto-approve-readonly.sh:1-181` |
| `hooks/cleanup-session.sh` | yes | `hooks/cleanup-session.sh:1-7` |
| `hooks/guard-destructive-cmd.sh` | yes | `hooks/guard-destructive-cmd.sh:1-128` |
| `hooks/log-access-prompt.sh` | yes | `rg --files -uu` |
| `hooks/log-access-stop.sh` | yes | `rg --files -uu` |
| `hooks/log-access-tool.sh` | yes | `rg --files -uu` |
| `hooks/log-token-usage.sh` | yes | `rg --files -uu` |
| `site/package.json` | yes | `site/package.json:1-14` |
| `site/package-lock.json` | yes | `rg --files -uu site` |
| `site/.vitepress/config.mts` | yes | `site/.vitepress/config.mts:1-78` |
| `.github/workflows/deploy.yml` | yes | `.github/workflows/deploy.yml:1-53` |
| `docs/.ai/repo.profile.json` | yes | this run |
| `docs/L0_concept/concept.md` | yes | this run |
| `docs/L0_concept/policy.md` | yes | this run |
| `docs/L1_project/project_overview.md` | yes | this run |
| `docs/L1_project/repository_structure.md` | yes | this run |
| `docs/L2_development/operation_model.md` | yes | this run |
| `docs/L2_development/consistency_checks.md` | yes | this run |
| `docs/L2_development/cicd.md` | yes | this run |
| `docs/L3_implementation/specification_summary.md` | yes | this run |

### コマンド

| コマンド | 実体 | 根拠 |
|---|---|---|
| `./install.sh` | executable script in repo root | `install.sh:1-149` |
| `./setup_statusline.sh` | executable script in repo root | `setup_statusline.sh:1-57` |
| `cd site && npm ci` | CI install command in `site/` | `.github/workflows/deploy.yml:31-33` |
| `cd site && npm run docs:dev` | npm script | `site/package.json:4-8` |
| `cd site && npm run docs:build` | npm script and CI command | `site/package.json:4-8`, `.github/workflows/deploy.yml:35-37` |
| `cd site && npm run docs:preview` | npm script | `site/package.json:4-8` |
| `npm ci` | CI install step in `site/` | `.github/workflows/deploy.yml:31-33` |

## 4-2. repo.profile.json <-> docs の突合

- `doc_roots` は現存する L0-L3 directory と一致する。根拠: `docs/.ai/repo.profile.json`, `docs/` 実体一覧
- `commands` は operation_model のローカル・CI コマンド表で説明済み。根拠: `docs/L2_development/operation_model.md`
- `active_commands` は project_overview と specification_summary で説明済み。根拠: `docs/L1_project/project_overview.md`, `docs/L3_implementation/specification_summary.md`
- `templates` は `templates/*.md` として docs/site docs に記述済み。根拠: `templates/issue.md:1-25`, `templates/pr.md:1-32`, `site/guide/installation.md`
- `hooks` は現存 7 本に一致する。`install.sh` の Claude settings 登録と Codex hooks.json 登録も現存 hook のみを登録する。根拠: `hooks/` 実体一覧, `install.sh:119-146`
- `primary_docs.investigation` と `primary_docs.structure` は実在する。根拠: `docs/L3_implementation/specification_summary.md`, `docs/L1_project/repository_structure.md`

## 4-3. CI 定義との整合性

CI は存在する。`.github/workflows/deploy.yml` は main push と workflow_dispatch で実行され、Node.js 24、npm cache、`site/package-lock.json`、`site/` working directory、`npm ci`、`npm run docs:build`、GitHub Pages artifact upload/deploy を定義する。専用 docs として `docs/L2_development/cicd.md` を生成済み。

根拠: `.github/workflows/deploy.yml:1-53`

## 4-4. 根拠表記

断定的な仕様説明には `path:line` または実体一覧・設定ファイル名を根拠として記載した。wildcard しか示せない箇所は、該当領域が同一構造を持つことを `rg --files -uu` の観測結果として扱った。

## 4-5. 未確認事項

| 項目 | 状態 | 次に見るべきファイル |
|---|---|---|
| dedicated test command | `site/package.json` に test script がないため、site build を CI 上の主要検証として扱う | `site/package.json` |

## 4-6. Done Criteria 判定

| 条件 | 判定 | 理由 |
|---|---|---|
| docs に記載された事実が実体と矛盾していない | yes | command / skill / hook / CI / site paths を再観測し、存在確認済み |
| repo.profile.json と docs が相互に説明可能 | yes | commands / active_commands / hooks / templates / site / CI を docs に反映 |
| CI 定義と docs の手順が一致している | yes | `npm ci` と `npm run docs:build` を operation_model と repo profile に反映 |
| 未確認事項が明示的に分離されている | yes | dedicated test command の不在のみ記録 |

判定: 完了。
