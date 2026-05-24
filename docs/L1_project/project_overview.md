# Project Overview

## このリポジトリの実態

- Claude Code 向けのカスタムスラッシュコマンド仕様（Markdown）と補助スクリプト（Bash）のリポジトリ。
  - 根拠: `commands/*.md`, `hooks/*.sh` の存在を直接確認
- コマンドは `~/.claude/commands/` へのシンボリックリンクで AI に供給される。
  - 根拠: `README.md:30-40`
- `CLAUDE.md` は `~/.claude/CLAUDE.md` にリンクされ、全セッションで自動ロードされる。
  - 根拠: `README.md:42-48`
- `repo.profile.json` と `docs/` が AI 運用の基盤情報として機能する。
  - 根拠: `commands/init-docs.md:24`（G-1 ゲート）

## アクティブコマンド（4本）

- `commands/task.md` → `/task`: 全ファイル変更のエントリポイント。docs 変更要否でルーティング判定し、patch フローまたは task フローを実行。issue 自動生成・コミット・ドラフト PR 作成・/docs-sync 自動実行まで担う。
  - 根拠: `commands/task.md:1-9`, `commands/task.md:37-50`（ルーティング）, `commands/task.md:61-73`（patch フロー）
- `commands/patch.md` → `/patch`: docs 変更を伴わない軽微な修正専用。issue/PR 不要。branch + commit → ユーザーが main へ ff-merge。
  - 根拠: `commands/patch.md:1-8`
- `commands/docs-sync.md` → `/docs-sync`: git diff を事実として docs/* および README.md を最小更新し、ドラフト PR を公開する。
  - 根拠: `commands/docs-sync.md:1-10`
- `commands/init-docs.md` → `/init-docs`: リポジトリ実態の全体観測と設計ドキュメント再構築。重い初期化コマンド。
  - 根拠: `commands/init-docs.md:1-8`

## テンプレート

- `commands/templates/issue.md`: issue 本文テンプレート（task.md および patch.md エスカレーション時に使用）。
  - 根拠: `commands/templates/issue.md:3`
- `commands/templates/pr.md`: PR 本文テンプレート（task.md Phase 2 で使用）。
  - 根拠: `commands/templates/pr.md:3`

## hooks

- `hooks/log-token-usage.sh`: Claude Code Stop hook。セッション終了時に JSONL トランスクリプトを読み取り、全ターンの token usage（input / output / cache_read / cache_create）を集計して `~/.claude/token-usage.log` に追記する。セッション名（`/rename` で設定）と推定コスト（`cost_usd`）も記録する。
  - 根拠: `hooks/log-token-usage.sh`

## 技術スタック

- ドキュメント形式: Markdown（`.md`）— コマンド仕様
- スクリプト: Bash（`.sh`）— hooks のみ
- 実行ランタイム: なし（Markdown 仕様は AI エージェントが解釈して実行）
- 外部 CLI 依存: `git`, `gh`, `jq`
  - 根拠: `commands/task.md:105-109`, `commands/docs-sync.md:各所`, `hooks/log-token-usage.sh:5`
