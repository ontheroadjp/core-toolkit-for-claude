# Policy

## 技術選定ポリシー

### 言語・ランタイム

- **コマンド仕様: Markdown のみ** — AI エージェントが直接解釈して実行する。DSL や設定ファイルを別途設けない
  - 根拠: `commands/*.md`（全ファイルが純粋な Markdown 仕様）
- **自動化スクリプト: Bash のみ** — hooks および utility scripts は Bash で実装する。依存関係を最小に保つため、Node.js・Python 等は使用しない
  - 根拠: `hooks/*.sh`, `scripts/*.sh`
- **外部 CLI 依存の最小化**: `git`, `gh`, `jq`, `curl` の 4 本のみ。これ以上増やす場合は明示的な justification が必要
  - 根拠: `docs/.ai/repo.profile.json:external_cli_deps`

### パッケージ管理

- このリポジトリ自体はパッケージマネージャを持たない（`package_manager: unknown`）
  - 根拠: `docs/.ai/repo.profile.json:package_manager`

## セキュリティ方針

### 破壊的操作の防止

`hooks/guard-destructive-cmd.sh`（PreToolUse hook）により、Claude Code の Bash ツール実行前に以下を自動検査する:

- **Lv0（即座ブロック・バイパス不可）**: `rm -rf` でのシステムディレクトリ破壊、`dd`/`shred`/`wipefs`/`mkfs`/`truncate -s 0` によるブロックデバイス操作、フォークボム、`chmod`/`chown -R` でのシステムルート変更、`git filter-branch`/`filter-repo` による履歴書き換え
- **Lv1（ブロック＋ユーザー手動実行へ委譲）**: `git push --force`、`git reset --hard`、`git checkout .`/`restore .`、`git clean -fd`/`-fdx`、`git branch -D`、`git stash drop`/`clear`

根拠: `hooks/guard-destructive-cmd.sh`（Lv0/Lv1 分類節）

### 個人情報・機密情報

`partials/git-commit.md` のコミット前チェックで、コミット対象 diff に以下が含まれていないことを確認する:
- 個人情報（メールアドレス・電話番号・住所等）
- IP アドレス・内部ドメイン名
- 絶対パス（特定のマシン環境に依存するパス）

根拠: `partials/git-commit.md`（コミット前チェック節）

## パフォーマンス要件

- **hooks は Claude の応答をブロックしてはならない**: すべての hook は `exit 0` で終了し、ネットワーク操作には `curl --max-time 5` でタイムアウトを設定する
  - 根拠: `hooks/notify-slack.sh`（失敗耐性節）
- **hooks のログ書き込みは非同期・ベストエフォート**: ログ追記が失敗しても Claude のワークフローに影響しない設計とする
  - 根拠: `hooks/log-access-stop.sh`（動作仕様）

## 禁止事項

| 禁止操作 | 理由 | 根拠 |
|----------|------|------|
| `~/.claude/` への実体ファイル配置 | symlink-only 原則違反 | `README.md:18-19` |
| `/docs-sync` による docs 全体再構築 | 最小更新原則違反。全体再構築は `/init-docs` の責務 | `commands/docs-sync.md:1-10` |
| task フローでの `docs/*` 直接変更 | docs 更新は `/docs-sync` のみが担う | `CLAUDE.md:33`（Docs changes are isolated） |
| `git add -A` / `git add .` の使用 | 機密ファイルや大容量バイナリを意図せずコミットするリスク | `partials/git-commit.md` |
| `--no-verify` によるフック bypass | guard-destructive-cmd の迂回を防ぐ | `hooks/guard-destructive-cmd.sh:Lv0` |
| `git push --force` の AI 自動実行 | Lv1 コマンドはユーザーが手動実行する | `hooks/guard-destructive-cmd.sh:Lv1` |

## ルーティング判定ポリシー

作業のルーティングは **単一の質問** で決定する:

> 「この変更で `docs/*` への追加・変更・削除が必要か？」

- **不要** → patch フロー（branch + commit → ユーザーが ff-merge。issue/PR 不要）
- **必要** → task フロー（issue → 実装 → ドラフト PR → `/docs-sync`）

「判断に迷う」「まず実装してから考える」は禁止。ルーティング前に判定する。

根拠: `commands/work.md`（ルーティング判定節）, `CLAUDE.md:30`

## docs 更新ポリシー

- **L0（コンセプト・ポリシー）**: `/docs-sync` では更新しない。`/init-docs` 再実行時、または設計方針の根本的変更があった場合のみ更新する
- **L1〜L3**: `git diff` を事実として `/docs-sync` が最小更新を行う
- **HARD STOP 条件**: 以下のいずれかで `/docs-sync` は `/init-docs` を促して終了する:
  - 新規主要レイヤ / トップレベル構造の追加疑い
  - 起動経路・エントリポイント変更の疑い
  - 10 ファイル以上かつ 3 ドメイン以上の広範な変更

根拠: `commands/docs-sync.md`（HARD STOP 判定節）, `commands/init-docs.md:1-8`（再実行トリガー）
