# Project Overview

## このリポジトリの実態

- Claude Code 向けのカスタムスラッシュコマンド仕様（Markdown）と補助スクリプト（Bash）のリポジトリ。
  - 根拠: `commands/*.md`, `hooks/*.sh` の存在を直接確認
- コマンドは `~/.claude/commands/` へのシンボリックリンクで AI に供給される。
  - 根拠: `README.md:40-46`
- `CLAUDE.md` は `~/.claude/CLAUDE.md` にリンクされ、全セッションで自動ロードされる。
  - 根拠: `README.md:51-56`
- `repo.profile.json` と `docs/` が AI 運用の基盤情報として機能する。
  - 根拠: `commands/init-docs.md:21-26`（G-1 ゲート）

## アクティブコマンド（7本）

- `commands/work.md` → `/work`: 全作業のメインエントリポイント。ゲート確認・ワークスペース管理・現状調査・ルーティング判定を行い、task.md または patch.md を Read して委譲する。
  - 根拠: `commands/work.md:1-4`
- `commands/task.md` → `/task`: docs 変更を伴う実装専用。work.md から Read 経由で呼ばれる。issue 確認/自動生成・実装・コミット・ドラフト PR 作成・/docs-sync 自動実行まで担う。
  - 根拠: `commands/task.md:1-9`
- `commands/patch.md` → `/patch`: docs 変更を伴わない軽微な修正専用。work.md から Read 経由で呼ばれる。issue/PR 不要。branch + commit → ユーザーが main へ ff-merge。
  - 根拠: `commands/patch.md:1-8`
- `commands/docs-sync.md` → `/docs-sync`: git diff を事実として docs/* および README.md を最小更新し、ドラフト PR を公開する。
  - 根拠: `commands/docs-sync.md:1-10`
- `commands/init-docs.md` → `/init-docs`: リポジトリ実態の全体観測と設計ドキュメント再構築。重い初期化コマンド。
  - 根拠: `commands/init-docs.md:1-8`
- `commands/review-resolve.md` → `/review-resolve`: PR レビューコメント対応専用のエントリポイント。`/work` を経由せず自己完結（checkout → 実装 → commit → push → 返信）。
  - 根拠: `commands/review-resolve.md:1-6`
- `commands/new-issue.md` → `/new-issue`: 漠然としたアイデアから 1 件または複数件の整形された issue を生成する任意の pre-`/work` エントリポイント。実装は行わない。
  - 根拠: `commands/new-issue.md:1-9`

## テンプレート

- `commands/templates/issue.md`: issue 本文テンプレート（task.md および patch.md エスカレーション時に使用）。
  - 根拠: `commands/templates/issue.md:3`
- `commands/templates/pr.md`: PR 本文テンプレート（task.md Phase 2 で使用）。
  - 根拠: `commands/templates/pr.md:3`

## hooks（6本）

- `hooks/guard-destructive-cmd.sh`: PreToolUse hook。Bash ツール実行前に発火し、Lv0 コマンドを即座にブロック、Lv1 コマンドをユーザー手動実行へ委譲する。
  - 根拠: `hooks/guard-destructive-cmd.sh`
- `hooks/log-token-usage.sh`: Stop hook。セッション終了時に JSONL トランスクリプトを読み取り、全ターンの token usage（input / output / cache_read / cache_create）を集計して `{repo}/logs/token-usage/YYYY-MM.log` に追記する。セッション名（`/rename` で設定）と推定コスト（`cost_usd`）も記録する。
  - 根拠: `hooks/log-token-usage.sh`
- `hooks/log-access-prompt.sh`: UserPromptSubmit hook。ユーザー指示を `/tmp/claude-access-sessions/{session_id}.prompt` に保存する。新セッション開始時に孤立 pending ファイルをフラッシュする。
  - 根拠: `hooks/log-access-prompt.sh`
- `hooks/log-access-tool.sh`: PostToolUse hook。Read/Glob/Grep/Edit/Write を捕捉し、コマンドファイルの読み込みでフェーズを切り替えながらアクセス先を `/tmp/claude-access-sessions/{session_id}.json` に蓄積する。
  - 根拠: `hooks/log-access-tool.sh`
- `hooks/log-access-stop.sh`: Stop hook。セッション中に `/work` が呼ばれた場合のみ、フェーズ別アクセスログを pending ファイルに書き出す（main log へのフラッシュは次回 `/work` 開始時または新セッション開始時）。
  - 根拠: `hooks/log-access-stop.sh`
- `hooks/notify-slack.sh`: Notification hook（permission prompt 等）および Stop hook（応答完了後の入力待ち）。`CLAUDE_CODE_WAIT_NOTIFY_SLACK_WEBHOOK_URL` 環境変数で指定された Slack Incoming Webhook にメッセージを POST する（未設定なら silently exit）。
  - 根拠: `hooks/notify-slack.sh`

## skills（7本）

Codex 向けのスキルエントリポイント。各 `skills/*/SKILL.md` が対応する `commands/*.md` を Source Of Truth として Read して実行する薄いラッパー。
- `skills/work/SKILL.md`, `skills/task/SKILL.md`, `skills/patch/SKILL.md`, `skills/docs-sync/SKILL.md`, `skills/init-docs/SKILL.md`, `skills/new-issue/SKILL.md`, `skills/review-resolve/SKILL.md`
- 根拠: `skills/*/SKILL.md`（各ファイルの Source Of Truth 宣言）

## 技術スタック

- ドキュメント形式: Markdown（`.md`）— コマンド仕様
- スクリプト: Bash（`.sh`）— hooks および utility scripts
- 実行ランタイム: なし（Markdown 仕様は AI エージェントが解釈して実行）
- 外部 CLI 依存: `git`, `gh`, `jq`, `curl`
  - 根拠: `commands/task.md`（github 操作節）, `hooks/log-token-usage.sh:5`, `hooks/notify-slack.sh`（curl 使用）
