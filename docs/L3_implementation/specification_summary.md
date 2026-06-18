# Specification Summary

## 対象

このサマリは、`commands/`、`skills/`、`hooks/`、`templates/`、`partials/`、`site/`、CI の現在の実体を、確認できた範囲で整理する。

根拠: `rg --files -uu`, `docs/.ai/repo.profile.json`

## Command Specifications

### `/work` (`commands/work.md`)

全作業の通常入口。G-0 で main へ checkout し、現在の hook セッションに対応する `${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/sessions/<session-id>/session-approved` を削除して前回の承認状態をクリアする。その後 `docs/.ai/repo.profile.json` を確認し、workspace 差分の扱いをユーザーに選ばせ、現状調査後に task または patch へ委譲する。

ルーティングは issue 起点かどうか、次に docs 変更が必要かで決まる。docs 変更が必要なら `commands/task.md`、不要なら `commands/patch.md` を Read して進む。

非 main ブランチからの再開（case B scenario 2: コミットあり・ワークスペースクリーン）では、Phase 2 直接開始ではなく Phase 1 Step 2 から開始し session-approved を再作成する。

根拠: `commands/work.md:7-120`

### `/task` (`commands/task.md`)

`/work` から呼ばれる docs 変更を伴う実装 flow。issue がなければ `commands/new-issue.md` Step 1-5 を使って作成し、プラン策定とユーザー許可後に実装する。実装後は `partials/git-commit.md` に従って commit し、draft PR を作成し、`/docs-sync` を自動実行する。

根拠: `commands/task.md:1-15`, `commands/task.md:42-154`

### `/patch` (`commands/patch.md`)

`/work` から呼ばれる docs 変更不要の軽微修正 flow。プラン確認後に `patch/<slug>` branch で変更・commit し、ユーザーへ fast-forward merge 手順を報告する。前提が崩れた場合は issue draft を作り task flow へ移行する。

根拠: `commands/patch.md:1-95`

### `/docs-sync` (`commands/docs-sync.md`)

PR branch 上で `git diff main...HEAD` を事実として docs と README を最小更新する。PR 存在確認、draft 状態確認、HARD STOP 判定、更新、commit/push、draft PR ready 化を行う。L0 は通常更新しない。

根拠: `commands/docs-sync.md:1-165`

### `/init-docs` (`commands/init-docs.md`)

repo 再観測、`docs/.ai/repo.profile.json` 生成、L0-L3 docs 生成、整合性検証、README scaffold 確認、CLAUDE.md 更新、ユーザー確認後の branch/commit/draft PR 作成を定義する。

根拠: `commands/init-docs.md:1-317`

### `/triage-issues` (`commands/triage-issues.md`)

open issue が溜まったタイミングで実行するスタンドアロンのトリアージ入口。`gh issue list` で全 open issue を取得し、`docs/.ai/repo.profile.json` および `docs/L3_implementation/specification_summary.md` と照合して stale / inconsistent / duplicated / unclear / ready の 5 カテゴリに分類する。分類結果をユーザーに提示し、issue ごとに推奨アクション（close / comment / edit / label / skip）を「理由 + 推奨アクション」付きで提示してユーザー承認後のみ実行する。`/work`・`/task`・`/new-issue`・`/review-resolve` とは独立しており、既存コマンドの振る舞いは変更しない。

根拠: `commands/triage-issues.md:1-187`

### `/new-issue` (`commands/new-issue.md`)

実装を伴わず、rough idea から issue draft を作成して `gh issue create` する任意 pre-`/work` flow。scope 分割はユーザー選択必須で、issue 本文は `~/.config/claude-code-kit/templates/issue.md` を使う。

根拠: `commands/new-issue.md:1-129`

### `/review-resolve` (`commands/review-resolve.md`)

PR 番号を受け取り、PR branch に checkout し、inline review comment・CHANGES_REQUESTED/COMMENTED/APPROVED 状態の review body comment を取得する。いずれも存在しない場合は「レビューコメントはありません」と報告して終了する。コメントごとにユーザーが対応・反対返信・理由返信・skip を選び、対応する場合は実装・commit・push・返信まで行う。

根拠: `commands/review-resolve.md:1-177`

### `/codex-review` (`commands/codex-review.md`)

PR 番号を受け取り、PR ブランチに checkout し、`codex review --base <base>` でレビューを実行する。結果を一時ファイルに保存して ANSI コードを除去し、内容を判定して問題なし / 問題ありを決定する。`CODEX_REVIEW_TOKEN` 環境変数は必須で、未設定の場合は `~/.claude/settings.local.json` への設定方法を案内してエラー終了する。設定されている場合は `gh pr review --approve` または `--request-changes` を提出する。問題ありの場合は完了報告後に `/review-resolve #<PR番号>` を自動実行する。

根拠: `commands/codex-review.md:1-155`

### `/coding-*` (`commands/coding-*.md`)

`coding-general` は言語非依存の原則を定義し、`coding-py`、`coding-js`、`coding-ts` はそれぞれ言語固有ルールを追加する。`coding-ts` は `coding-general` と `coding-js` を先に参照する。

根拠: `commands/coding-general.md:1-3`, `commands/coding-py.md:1-4`, `commands/coding-js.md:1-4`, `commands/coding-ts.md:1-12`

## Skills

`skills/*/SKILL.md` は Codex 用の wrapper で、対応する `commands/*.md` を Source of Truth として読む。`coding-py` / `coding-js` / `coding-ts` は general など依存する command も読む構造を持つ。現存する skill wrapper は 13 件で、`commands/` にある各 command と対応する。

根拠: `skills/init-docs/SKILL.md:1-14`, `skills/coding-ts/SKILL.md`, `skills/` 実体一覧

## Hooks

### `hooks/auto-approve-readonly.sh`

PreToolUse hook。Read は常に承認する。`session-approved` は `${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/sessions/<session-id>/session-approved` を既定パスとし、payload の `session_id`、`CLAUDE_CODE_KIT_SESSION_ID`、`CLAUDE_CODE_KIT_SESSION_DIR`、`CLAUDE_CODE_KIT_SESSION_APPROVED_FILE`、`CLAUDE_CODE_KIT_STATE_HOME` で現在セッションの承認ファイルを解決する。Write は現在セッションの `session-approved` 自体への書き込みをスコープガードで保護し、初回書き込み時は session directory を作成する。session-listed パスへの Write/Edit は承認する。Bash は `hooks/lib/approval-safety.sh` の破壊的操作判定を最初に実行し、該当する場合は JSON block decision を返す。その後、read-only whitelist、runtime version check、curl HTTP request、npm non-install operation、pytest、session-approved git/gh write 操作を承認する。

根拠: `hooks/auto-approve-readonly.sh:14-17`, `hooks/auto-approve-readonly.sh:202-273`, `hooks/lib/approval-safety.sh:1-87`

### `hooks/lib/approval-safety.sh`

PreToolUse hook で共有する Bash safety helper。system directory 破壊、block device 操作、fork bomb、history rewrite、force push、hard reset、checkout/restore dot、clean、branch -D、stash drop/clear を破壊的操作として検出し、JSON block decision を生成する。

根拠: `hooks/lib/approval-safety.sh:1-87`

### `hooks/guard-destructive-cmd.sh`

PreToolUse Bash guard の互換 wrapper。Bash 以外は何も出力せず終了する。Bash の場合は `hooks/lib/approval-safety.sh` を読み込み、破壊的操作に該当する場合のみ JSON block decision を返す。平文 stdout は出力しない。

根拠: `hooks/guard-destructive-cmd.sh:1-25`, `hooks/lib/approval-safety.sh:1-87`

### `hooks/cleanup-session.sh`

Stop hook。現在の hook セッションに対応する `session-approved` を削除し、空になった session directory のみ削除する。別セッションの承認ファイルは削除しない。

根拠: `hooks/cleanup-session.sh:1-7`

### access / token log hooks

`log-access-prompt.sh`、`log-access-tool.sh`、`log-access-stop.sh` はユーザー指示、tool access、modified files を session file / pending file / monthly log に記録する。`log-token-usage.sh` は transcript usage を集計して token usage log に追記する。

根拠: `hooks/log-access-prompt.sh`, `hooks/log-access-tool.sh`, `hooks/log-access-stop.sh`, `hooks/log-token-usage.sh`

## Templates and Partials

`templates/issue.md` は issue draft、`templates/pr.md` は PR body、`templates/readme.md` は README scaffold の template である。commands は installed path として `~/.config/claude-code-kit/templates/*.md` を参照する。

`partials/git-commit.md` は commit 手順の共通部品で、staged diff 取得、個人情報等のチェック、Conventional Commits message 作成、commit 実行を定義する。

根拠: `templates/issue.md:1-25`, `templates/pr.md:1-32`, `commands/task.md:131-138`, `partials/git-commit.md:1-80`

## Tests

`tests/hooks/test-approval-hooks.sh` は PreToolUse hook の shell verification である。破壊的 Bash block、session-approved があっても破壊的操作を block すること、read-only approval、session-approved approval、write-effect / ambiguous command の prompt fallback、`guard-destructive-cmd.sh` の JSON block output を検証する。

根拠: `tests/hooks/test-approval-hooks.sh:1-75`

## Install and Status Line

`install.sh` は `commands/*.md` を `~/.claude/commands/` と `~/.codex/commands/`、`hooks/*.sh` を `~/.claude/hooks/` と `~/.codex/hooks/`、`skills/*/` を `~/.codex/skills/` に symlink する。その後 `jq` があれば `~/.claude/settings.json` と `~/.codex/hooks.json` に hook entries を追加する。Codex hooks は `/hooks` で review/trust してから利用する前提で案内する。

`setup_statusline.sh` は `scripts/statusline.sh` を `~/.claude/statusline.sh` に symlink し、settings に `statusLine` を追加する。`scripts/statusline.sh` は stdin JSON から context / five-hour / seven-day rate limit を抽出して表示する。

根拠: `install.sh:15-149`, `setup_statusline.sh:6-55`, `scripts/statusline.sh:10-83`

## VitePress Site and CI

`site/package.json` は `docs:dev`, `docs:build`, `docs:preview` を定義する。dependencies は `@fortawesome/fontawesome-free`、devDependencies は `vitepress`。lock file では `@fortawesome/fontawesome-free` 6.7.2 と `vitepress` 1.6.4 が解決される。

`site/.vitepress/config.mts` は VitePress の `locales` オプションで多言語対応（i18n）を定義する。`root`（英語 / en-US）、`ja`（日本語 / ja-JP）、`zh`（中国語簡体字 / zh-CN）の 3 ロケールを持ち、各ロケールに nav・sidebar・footer を個別に定義する。コンテンツは `site/`（英語）、`site/ja/`（日本語）、`site/zh/`（中国語）に配置される。日本語版の concept・policy・specification ページは `docs/L0_concept/` および `docs/L3_implementation/specification_summary.md` を `@include` で参照する。

`.github/workflows/deploy.yml` は main push と `workflow_dispatch` を trigger とし、Node.js 24 で `site/` に対して `npm ci` と `npm run docs:build` を実行し、`site/.vitepress/dist` を GitHub Pages に deploy する。

根拠: `site/package.json:1-14`, `site/package-lock.json:765-766`, `site/package-lock.json:2486-2487`, `site/.vitepress/config.mts:1-183`, `.github/workflows/deploy.yml:1-53`

## 未確認事項

現時点で仕様サマリに混在させた未確認事項はない。
