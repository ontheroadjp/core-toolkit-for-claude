# Operation Model

## 通常作業フロー

`/review-resolve` 以外の実装作業は `/work` から開始する。`/work` は main へ切り替え、`docs/.ai/repo.profile.json` を確認し、workspace 差分の扱いを決め、現状調査後に task または patch へ委譲する。

根拠: `commands/work.md:7-119`

## ルーティング

判定は「この変更の結果として `docs/*` に追加・変更・削除が必要か」で行う。

- issue 起点、または docs 変更が必要な場合: `commands/task.md` を Read し task flow を実行する。
- issue なし、かつ docs 変更が不要な場合: `commands/patch.md` を Read し patch flow を実行する。

根拠: `commands/work.md:61-92`

## task flow

`task.md` は docs 変更を伴う実装専用で、issue 確認または自動生成、現状調査補完、プラン策定、ユーザー許可、実装、commit、draft PR 作成、`/docs-sync` 実行へ進む。task flow は `docs/*` を直接変更しない。

根拠: `commands/task.md:1-15`, `commands/task.md:42-154`

## patch flow

`patch.md` は docs 変更を伴わない軽微な修正専用で、issue/PR を不要とする。作業ブランチ上で commit し、ユーザーが main へ fast-forward merge する。docs 変更やスコープ拡大が判明した場合は task flow にエスカレーションする。

根拠: `commands/patch.md:1-8`, `commands/patch.md:38-69`, `commands/patch.md:73-95`

## docs-sync flow

`docs-sync.md` は main 以外の PR ブランチで実行され、PR の draft 状態確認、`git diff main...HEAD --name-only`、HARD STOP 判定、docs/README の最小更新、commit/push、draft PR の ready 化を行う。

根拠: `commands/docs-sync.md:13-35`, `commands/docs-sync.md:39-160`

## init-docs flow

`init-docs.md` は repo 再観測、local tooling 観測、repo profile 生成、L0-L3 docs 生成、整合性検証、README scaffold 確認、CLAUDE.md / AGENTS.md 更新を行い、最後にユーザー確認後だけ commit と draft PR 作成へ進む。

local tooling 観測では `gh`、`node`、`npm`、Node.js runtime manager hints を確認し、環境依存の注意を `CLAUDE.md` に出力する。`AGENTS.md` は原則として `CLAUDE.md` への symlink として作成する。

根拠: `commands/init-docs.md:21-370`

## review-resolve flow

`review-resolve.md` は PR 番号を受け取り、PR branch へ checkout し、inline comment と review body comment を取得し、コメントごとに対応・反対返信・理由返信・skip を選ぶ。対応時は commit/push/reply まで行う。

根拠: `commands/review-resolve.md:1-175`

## codex-review flow

`codex-review.md` は PR 番号を受け取り、PR branch へ checkout して `codex review --base origin/<baseRefName>` を実行する。レビュー結果を一時ファイルに保存し、`CODEX_REVIEW_TOKEN` が設定されている場合だけ `gh pr review --approve` または `--request-changes` を提出する。問題ありの場合は `/review-resolve #<PR番号>` を続けて実行する。

根拠: `commands/codex-review.md:1-155`

## triage-issues flow

`triage-issues.md` は open issue を取得し、repo profile と仕様サマリに照らして stale / inconsistent / duplicated / unclear / ready に分類する。close / comment / edit / label などの issue 操作はユーザー承認後のみ実行する。

根拠: `commands/triage-issues.md:1-187`

## ローカル・CI コマンド

| コマンド | 用途 | 根拠 |
|---|---|---|
| `./install.sh` | commands/hooks/skills symlink と Claude/Codex hook settings 登録 | `install.sh:15-146` |
| `./setup_statusline.sh` | statusline symlink と settings 登録 | `setup_statusline.sh:6-55` |
| `cd site && npm ci` | CI と同じ lockfile-based install | `.github/workflows/deploy.yml:31-33` |
| `cd site && npm run docs:dev` | VitePress dev server | `site/package.json:4-8` |
| `cd site && npm run docs:build` | VitePress build。CI でも実行 | `site/package.json:4-8`, `.github/workflows/deploy.yml:35-37` |
| `cd site && npm run docs:preview` | built site preview | `site/package.json:4-8` |

## CI/CD

`.github/workflows/deploy.yml` は main push と manual dispatch で実行される。build job は Node.js 24 を setup し、`site/` で `npm ci` と `npm run docs:build` を実行し、`site/.vitepress/dist` を Pages artifact として upload する。deploy job は `actions/deploy-pages@v4` で GitHub Pages に deploy する。

根拠: `.github/workflows/deploy.yml:1-53`

詳細: `docs/L2_development/cicd.md`

## 未確認事項

自動テスト用の dedicated test command は確認できない。site build が CI 上の主要検証である。根拠: `site/package.json:4-8`, `.github/workflows/deploy.yml:31-37`
