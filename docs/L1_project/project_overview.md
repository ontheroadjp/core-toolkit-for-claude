# Project Overview

## このリポジトリの実態

- Claude Code 向けのカスタムスラッシュコマンド仕様（Markdown）のリポジトリ。
  - 根拠: `task.md:1`, `patch.md:1`, `docs-sync.md:1`, `init-docs.md:1`
- コマンドは `~/.claude/commands/` へのシンボリックリンクで AI に供給される。
  - 根拠: `~/.claude/commands/` 内の各ファイルがリポジトリルート直下の実体へのシンボリックリンクとして存在することを確認済み
- `repo.profile.json` と `docs/` が AI 運用の基盤情報として機能する。
  - 根拠: `init-docs.md:24` (G-1 ゲート)

## アクティブコマンド（4本）

- `task.md`: ドキュメント変更を伴う実装の主コマンド。ルーティング判定後に patch フローまたは task フローを実行。issue 自動生成・WIP コミット・ドラフト PR 作成まで担う。
  - 根拠: `task.md:1-9`, `task.md:37-86` (patch フロー), `task.md:115-183` (task フロー)
- `patch.md`: ドキュメント変更を伴わない軽微な修正専用。issue/PR 不要。branch + commit → ユーザーが main へマージ。
  - 根拠: `patch.md:1-8`
- `docs-sync.md`: git diff を事実としてドキュメントを最小更新し、ドラフト PR を公開する。
  - 根拠: `docs-sync.md:1-10`
- `init-docs.md`: リポジトリ実態の全体把握と設計ドキュメント再構築。重い初期化コマンド。
  - 根拠: `init-docs.md:1-8`

## テンプレート

- `templates/issue.md`: issue 本文テンプレート（task.md および patch.md エスカレーション時に使用）。
  - 根拠: `templates/issue.md:3`
- `templates/pr.md`: PR 本文テンプレート（task.md Phase 2 で使用）。
  - 根拠: `templates/pr.md:3`

## 技術スタック

- ドキュメント形式: Markdown（`.md`）
  - 根拠: 全コマンドファイルが `.md` 形式で存在することを確認
- 実行ランタイム・言語: なし（Markdown 仕様のみ。AI エージェントが解釈して実行する）
- 外部 CLI 依存: `git`, `gh`（コマンド仕様内に使用が明示されている）
  - 根拠: `task.md:105-109`, `patch.md:58-62`, `docs-sync.md:各所`

## legacy/ について

- 過去のコマンド仕様 14 ファイルが `legacy/` に保存されている（廃止・統合済み）。
  - 根拠: `legacy/` ディレクトリ内のファイル一覧を直接確認
  - 保存ファイル: AGENTS.md, README.md, create-test.md, docs-sync.md, fix.md, git-clean.md, init-git.md, init-test.md, issue.md, own-task.md, performance.md, refactor.md, security.md, test-balance.md
