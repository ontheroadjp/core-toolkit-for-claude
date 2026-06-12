# Repository Structure

## 現在のディレクトリ構造（観測結果）

```
claude-code-kit/
├── CLAUDE.md                        # AI 運用起点。Claude Code が全セッションで自動ロード
├── AGENTS.md                        # Codex 向け AI 運用指示
├── README.md                        # 人間向けドキュメント。インストール手順・コマンド一覧
├── install.sh                       # symlink 一括作成スクリプト（commands → ~/.claude/commands/, hooks → ~/.claude/hooks/, skills → ~/.codex/skills/）
├── .gitignore                       # .DS_Store, .claude/, logs/ を除外
├── commands/                        # アクティブコマンド仕様（Markdown）
│   ├── work.md                      # メインエントリポイント: ゲート確認・調査・ルーティング判定
│   ├── task.md                      # task フロー専用（work.md から委譲）: issue → 実装 → ドラフト PR
│   ├── patch.md                     # patch フロー専用（work.md から委譲）: 軽微修正
│   ├── docs-sync.md                 # ドキュメント同期 + ドラフト PR 公開
│   ├── init-docs.md                 # ドキュメント全体再構築
│   ├── review-resolve.md            # PR レビューコメント対話的解決
│   ├── new-issue.md                 # 任意の pre-/work エントリ: アイデアから issue 生成
│   ├── coding-general.md            # 言語非依存コーディング原則
│   ├── coding-py.md                 # Python 固有コーディング規約（coding-general の上位）
│   ├── coding-js.md                 # JavaScript 固有コーディング規約（coding-general の上位）
│   └── templates/
│       ├── issue.md                 # GitHub issue 本文テンプレート
│       ├── pr.md                    # GitHub PR 本文テンプレート
│       └── readme.md                # README.md scaffold テンプレート
├── partials/                        # commands/* から Read 経由で参照される共通部品
│   └── git-commit.md                # コミット手順（diff 取得・前チェック・メッセージ生成）
├── hooks/                           # Claude Code hook スクリプト群
│   ├── guard-destructive-cmd.sh     # PreToolUse/Bash: Lv0 即時ブロック・Lv1 ユーザー手動委譲
│   ├── log-token-usage.sh           # Stop: token usage・セッション名・コストをログ記録
│   ├── log-access-prompt.sh         # UserPromptSubmit: ユーザー指示をセッション一時ファイルに保存
│   ├── log-access-tool.sh           # PostToolUse: Read/Glob/Grep/Edit/Write をフェーズ別に追跡
│   ├── log-access-stop.sh           # Stop: フェーズ別アクセスログを pending ファイルに書き出し
│   └── notify-slack.sh              # Notification + Stop: 入力待ち時に Slack へ通知
├── logs/                            # ログ出力先（内容は .gitignore 対象、.gitkeep のみ追跡）
│   ├── access/                      # フェーズ別ファイルアクセスログ（YYYY-MM.log）
│   └── token-usage/                 # token usage ログ（YYYY-MM.log）
├── scripts/                         # 手動実行スクリプト群
│   └── show-token-usage.sh          # token-usage.log を複数モードで表示・集計
├── skills/                          # Codex 向けスキルラッパー
│   ├── work/SKILL.md
│   ├── task/SKILL.md
│   ├── patch/SKILL.md
│   ├── docs-sync/SKILL.md
│   ├── init-docs/SKILL.md
│   ├── new-issue/SKILL.md
│   ├── review-resolve/SKILL.md
│   ├── coding-general/SKILL.md
│   ├── coding-py/SKILL.md
│   └── coding-js/SKILL.md
├── templates/                       # （現在未使用 / README scaffold 等を格納予定）
└── docs/                            # 設計ドキュメント（/init-docs が生成・/docs-sync が更新）
    ├── .ai/
    │   └── repo.profile.json        # AI 運用の機械可読プロファイル
    ├── L0_concept/                  # プロダクトコンセプト・設計ポリシー（WHY 層）
    │   ├── concept.md               # 目的・解決する問題・対象ユーザー・設計上の制約
    │   └── policy.md                # 技術選定・セキュリティ・パフォーマンス・禁止事項
    ├── L1_project/                  # プロジェクト全体像
    │   ├── project_overview.md
    │   └── repository_structure.md  # このファイル
    ├── L2_development/              # 開発・運用手順
    │   ├── operation_model.md
    │   └── consistency_checks.md
    └── L3_implementation/           # 実装仕様サマリ
        └── specification_summary.md
```

根拠: 2026-06-11 時点のディレクトリ実体を直接確認（`ls` コマンドで全ファイル列挙）。

## 各ディレクトリ・ファイルの責務

### `CLAUDE.md`
Claude Code が全セッションで自動ロードする AI 運用指示ファイル。以下を定義する:
- アクティブコマンドの一覧と使い分けルール（ワークフロー入り口は `/review-resolve` / `/work` / 任意の `/new-issue` の 3 つ）
- ルーティング判定の単一質問（docs/* 変更要否）
- task フローのコミット形式（Conventional Commits）
- ワークスペースの扱い方（stash 優先、破壊的操作禁止）
- このリポジトリ自体への操作ルール
- 根拠: `CLAUDE.md:1-69`

### `commands/`
Claude Code のカスタムスラッシュコマンド仕様（Markdown）。`~/.claude/commands/` へのシンボリックリンクでグローバルデプロイされる。**Claude はこの経路のみを使用する。**
- 根拠: `README.md:40-46`, `~/.claude/commands/` 内 symlink 実体確認済み

| ファイル | スラッシュコマンド | 役割 |
|---|---|---|
| `work.md` | `/work` | **メインエントリポイント**。ゲート確認・調査・ルーティング判定を行い task.md または patch.md へ委譲 |
| `task.md` | `/task` | docs 変更を伴う実装専用。work.md から Read 経由で呼ばれる |
| `patch.md` | `/patch` | docs 変更不要な軽微修正。work.md から Read 経由で呼ばれる |
| `docs-sync.md` | `/docs-sync` | git diff を事実として docs・README.md を最小更新。ドラフト PR を公開 |
| `init-docs.md` | `/init-docs` | リポジトリ実態の全体観測とドキュメント再構築 |
| `review-resolve.md` | `/review-resolve` | PR レビューコメントを取得し、対応・返信をユーザーが対話的に選択 |
| `new-issue.md` | `/new-issue` | 任意の pre-`/work` エントリ。アイデアから 1 件または N 件の整形 issue を生成（分割方針はユーザーが 3 択で決定） |
| `coding-general.md` | `/coding-general` | 言語非依存コーディング原則 SSOT。言語固有コマンドの基盤として参照される |
| `coding-py.md` | `/coding-py` | Python 固有コーディング規約（ruff / mypy strict / pytest）。`coding-general` の上位 |
| `coding-js.md` | `/coding-js` | JavaScript 固有コーディング規約（Biome / Vitest）。`coding-general` の上位 |

### `commands/templates/`
issue・PR 本文のテンプレート。コマンドから `~/.config/claude-code-kit/templates/` として参照される（Claude / Codex 共通パス）。
- 根拠: `commands/task.md`（issue 生成節）, `commands/patch.md`（エスカレーション節）

### `partials/`
`commands/*.md` から Read 経由でのみ参照される共通テキスト部品。スラッシュコマンドとしては登録されない（Claude Code のコマンド検出は `commands/` 配下のみを対象とするため、`partials/` 配下のファイルは自動的にコマンド化されない）。複数のコマンドで重複していた手順を一箇所に集約し、保守時の修正漏れを防ぐことを目的とする。

| ファイル | 役割 | 呼び出し元 |
|---|---|---|
| `git-commit.md` | ステージ済み diff の取得、コミット前チェック（個人情報・IP・ドメイン・絶対パス）、Conventional Commits 形式のメッセージ生成、コミット実行 | `commands/task.md`, `commands/patch.md`, `commands/docs-sync.md`, `commands/review-resolve.md` |

- 根拠: `partials/git-commit.md:1-3`（スラッシュコマンドではない旨を明示）

### `skills/`
Codex 向けのスキルエントリポイント。各サブディレクトリに `SKILL.md` を持ち、対応する `commands/*.md` を読んで実行するラッパーとして機能する。
**Claude では使用しない**（`~/.claude/skills/` への symlink は張らない）。Codex がスキルとして直接参照する。`install.sh` によって `~/.codex/skills/` 配下へ symlink される。
- 根拠: `skills/*/SKILL.md`（各スキルの Source Of Truth 宣言）, `docs/.ai/repo.profile.json`（deploy.skills.target）

### `hooks/`
Claude Code の hook スクリプト群。`~/.claude/hooks/` へのシンボリックリンクでデプロイされ、`~/.claude/settings.json` から呼び出される。
- `guard-destructive-cmd.sh`: PreToolUse hook。Bash ツール実行前に発火。Lv0（即座ブロック）/ Lv1（ユーザー手動実行へ委譲）の 2 段階でガードする
- `log-token-usage.sh`: Stop hook。JSONL トランスクリプトを読み取り、token usage・セッション名・推定コスト（`cost_usd`）を集計して `{repo}/logs/token-usage/YYYY-MM.log` に追記する
- `log-access-prompt.sh`: UserPromptSubmit hook。ユーザー指示を `/tmp/claude-access-sessions/{session_id}.prompt` に保存する
- `log-access-tool.sh`: PostToolUse hook。Read/Glob/Grep/Edit/Write を捕捉し、work.md・task.md・patch.md・docs-sync.md・init-docs.md の読み込みでフェーズを切り替えながらアクセス先を `/tmp/claude-access-sessions/{session_id}.json` に蓄積する
- `log-access-stop.sh`: Stop hook。セッション中に `/work` が呼ばれた場合のみ、フェーズ別アクセスログを pending ファイルに書き出す
- `notify-slack.sh`: Notification hook（permission prompt 等）および Stop hook（応答完了後の入力待ち）。`CLAUDE_CODE_KIT_WAIT_NOTIFY_SLACK_WEBHOOK_URL` 環境変数で指定された Slack Incoming Webhook にメッセージを POST する（未設定なら silently exit）
- 根拠: `hooks/*.sh`（各ファイルの実装）

### `scripts/`
手動実行スクリプト群。hook が出力したログを分析・表示するツールを置く。
- `show-token-usage.sh`: `{repo}/logs/token-usage/YYYY-MM.log` を読み取り、複数モードで表示・集計する（`--sum` / `--model` / `--cost` / `--project` / `--time` / `--anomaly`）
- 根拠: `scripts/show-token-usage.sh`

### `docs/`
`/init-docs` が生成し `/docs-sync` が追随する設計ドキュメント群。4層構造で責務を分割する。
- `L0`: プロダクトコンセプト・設計ポリシー（WHY 層）。`/docs-sync` では更新しない
- `L1`: プロジェクト全体像（構成・コマンド概要）
- `L2`: 開発・運用手順（フロー・整合ルール）
- `L3`: 実装仕様サマリ（コマンド別仕様要約）
- 根拠: `commands/init-docs.md`（Phase 3 ドキュメント生成定義）

### `docs/.ai/repo.profile.json`
AI 運用の機械可読プロファイル。アクティブコマンドのパス・テンプレートパス・hooks・外部 CLI 依存・デプロイ方式を記録する。`primary_docs` キーで調査フェーズの起点ドキュメント（`investigation`: 責務サマリ、`structure`: ディレクトリ構造）を直接参照できる軽量 SSOT として機能する。
- 根拠: `docs/.ai/repo.profile.json:1-62`

## デプロイ構成

このリポジトリは実行コードを持たない。すべての成果物はシンボリックリンクで Claude Code のグローバル設定ディレクトリに展開される。

**原則: `~/.claude/` 配下には実体ファイルを置かない。全て本リポジトリへのシンボリックリンクとする。**
このリポジトリが single source of truth であり、`~/.claude/` はその参照点に過ぎない。

| 対象 | リポジトリ内パス | デプロイ先（symlink） | 対象ツール |
|---|---|---|---|
| コマンド群 | `commands/*.md` | `~/.claude/commands/*.md` | Claude |
| 共通部品 | `partials/*.md` | なし（symlink 不要、commands から Read で参照） | Claude |
| スキル群 | `skills/*/` | `~/.codex/skills/*/` | Codex |
| テンプレート | `commands/templates/` | `~/.config/claude-code-kit/templates/` | 共通 |
| AI 運用指示 | `CLAUDE.md` | `~/.claude/CLAUDE.md` | Claude |
| hooks | `hooks/*.sh` | `~/.claude/hooks/*.sh` | Claude |

- 根拠: `README.md:21-97`（Installation セクション）, `install.sh`（一括 symlink スクリプト）

## エントリポイント

- **ユーザー向け起点**: `/work`（`commands/work.md`）。ゲート確認・現状調査・ルーティング判定を行い `/patch` フローまたは task フローに分岐する
- **PR レビュー対応**: `/review-resolve #N`（`commands/review-resolve.md`）。`/work` を経由せず自己完結
- **任意の pre-/work**: `/new-issue`（`commands/new-issue.md`）。アイデアから issue 生成のみ（実装なし）
- アプリケーション的な `main/app/server` 実装エントリは存在しない（Markdown 仕様リポジトリのため）
- 根拠: `CLAUDE.md:13-15`（Custom Command の使い分け）
