# Operation Model

## コマンド使い分けの判定ロジック

ユーザーは常に `/work` を呼ぶ。`work.md` 内部でゲート確認・現状調査・ルーティング判定を行い、patch フローまたは task フローを実行する。

**判定基準（単一質問）:**
「この変更の結果として、`docs/*` に対して追加・変更・削除のいずれかが必要になるか？」

- → 変わらない場合: patch フロー（branch + commit、issue/PR なし）
- → 変わる場合: task フロー（issue → 実装 → ドラフト PR → /docs-sync）

根拠: `commands/work.md`（ルーティング判定節）

## ワークフロー概要

### 軽微な修正（patch フロー）
```
/work 呼び出し
→ ゲート確認（G-0/G-1/G-2）
→ 現状調査
→ ルーティング判定（docs 変更不要）
→ patch.md のワークフローを実行
→ branch 作成（patch/<slug>）
→ 変更・コミット
→ ユーザーが main へ ff-merge
```
根拠: `commands/work.md`（ルーティング判定節）, `commands/patch.md`

### ドキュメントを伴う実装（task フロー）
```
/work 呼び出し
→ ゲート確認（G-0/G-1/G-2）
→ 現状調査
→ ルーティング判定（docs 変更あり）
→ issue 確認/自動生成（new-issue.md Step 1〜5 フローを実行）
→ Step1: 現状調査の引き継ぎと補完
→ Step2: プラン策定（ユーザー許可必須）
→ Step3: 実装・コミット（Conventional Commits）
→ Phase 2: ドラフト PR 作成（commands/templates/pr.md 使用）
→ /docs-sync 自動実行（docs・README.md 更新 → PR 公開）
```
根拠: `commands/work.md`（現状調査節）, `commands/task.md`（Phase 1–3）

### PR レビューコメント対応（/review-resolve）
```
/review-resolve #N 呼び出し
→ PR 情報取得・ブランチ checkout
→ インラインコメント + レビュー本体コメントを取得
→ 各コメントに Claude の意見を提示
→ ユーザーが対応方針を 4 択で選択（対応する / 反対意見を返信 / 対応しない / スキップ）
→ 対応時: 実装 → コミット → push → 返信投稿
→ 完了報告（対応/返信/スキップの件数サマリ）
```
根拠: `commands/review-resolve.md`（全 Step）

### ドキュメント同期（/docs-sync）
```
/docs-sync 呼び出し
→ git diff --name-only で変更ファイル確定
→ HARD STOP 判定（全体再構築が必要か）
→ 対象 docs および README.md を最小更新
→ ドラフト PR を公開（gh pr ready）
```
根拠: `commands/docs-sync.md`（各フェーズ）

### ドキュメント全体再構築（/init-docs）
再実行トリガー:
- `/docs-sync` が HARD STOP を検知した場合
- docs が現状を説明できなくなった場合
- 新規レイヤ導入・エントリポイント変更の疑いがある場合

根拠: `commands/init-docs.md:9-19`

## ゲート設計

| コマンド | G-0 | G-1 | G-2 | G-3 | G-4 |
|----------|-----|-----|-----|-----|-----|
| work.md | main へ checkout | repo.profile.json 必須 | ワークスペース確認（stash 選択肢提示） | - | - |
| task.md | - | repo.profile.json 必須 | （work.md から継承） | - | - |
| patch.md | - | repo.profile.json 必須 | main ブランチにいること | クリーン（stash） | - |
| docs-sync.md | - | repo.profile.json 必須 | docs/ 必須 | main 以外のブランチ | PR 存在確認 |
| init-docs.md | - | .git/ 必須 | - | - | - |
| review-resolve.md | - | PR 番号の引数必須 | PR 情報取得・ブランチ checkout | - | - |
| new-issue.md | - | main ブランチ確認 | gh auth status 確認 | - | - |

根拠: `commands/work.md`（G-0/G-1/G-2 節）, `commands/patch.md`（G-1–G-3 節）, `commands/docs-sync.md`（G-1–G-4 節）, `commands/init-docs.md:21-26`, `commands/review-resolve.md`（Step 0）, `commands/new-issue.md`（Step 0）

## デプロイ方法

**原則: `~/.claude/` 配下には実体ファイルを置かない。全て本リポジトリへのシンボリックリンクとする。**
このリポジトリが single source of truth であり、`~/.claude/` はその参照点に過ぎない。ファイルを直接 `~/.claude/` に置いた場合、リポジトリとの乖離が発生し管理が破綻する。

```bash
# 一括インストール（推奨）
./install.sh
# → commands/*.md → ~/.claude/commands/
# → hooks/*.sh    → ~/.claude/hooks/
# → skills/*/     → ~/.codex/skills/
# → ~/.claude/settings.json に hook エントリを自動追加（jq 必須）

# 共通テンプレート（Claude / Codex 両ツールが参照）
mkdir -p ~/.config/claude-code-kit
ln -s <repo>/commands/templates ~/.config/claude-code-kit/templates

# CLAUDE.md（全セッション自動ロード）
ln -s <repo>/CLAUDE.md ~/.claude/CLAUDE.md
```

根拠: `install.sh`（一括 symlink スクリプト）, `README.md:21-97`（Installation セクション）

## コミット形式（task フロー）

task フローのコミットは Conventional Commits 形式を使用する:
- `<type>(#<issue番号>): <short description in English>`
  - 例: `feat(#23): implement user auth endpoint`
  - 根拠: `commands/task.md`（Step 3 コミット節）
- types: feat / fix / refactor / chore / style / test / docs（task フロー）
- patch フローでは `feat` は使用しない（スコープが大きくなった場合は task へエスカレーション）
- Phase 2（ドラフト PR 作成）のガードは `git log main..HEAD --oneline` の出力が 1 件以上あることで行う
  - 根拠: `commands/task.md`（Phase 2 ガード節）

## 実行コマンド（repo.profile.json 観点）

- `repo.profile.json.commands` は空（このリポジトリ自体に run/build/test コマンドは存在しない）
  - 根拠: `docs/.ai/repo.profile.json`
- 外部 CLI として `git`, `gh`, `jq`, `curl` をコマンド仕様・hooks 内で使用する
  - 根拠: `commands/task.md`（github 操作節）, `hooks/log-token-usage.sh:5`, `hooks/notify-slack.sh`（curl 使用）

## token 使用量ログ

セッション終了時に Stop hook が自動実行され、`{repo}/logs/token-usage/YYYY-MM.log` に以下の形式で追記される:
```
[timestamp] session=<id>  name=<session_name>  model=<model>  turns=N  input=N  output=N  cache_read=N  cache_create=N  total=N  cache_ratio=N  cost_usd=N  branch=<branch>  cwd=<dir>
```
- `name`: `/rename` コマンドで設定したセッション名（transcript の `custom-title` エントリから取得）
- `total` = input + output + cache_create（cache_read は既存キャッシュの読み取りで新規課金なし）
- `cost_usd`: モデル別単価（opus/haiku/sonnet）× 各トークン数で推定。cache_read コストも含む
- 根拠: `hooks/log-token-usage.sh`, `logs/token-usage/` の実ログで動作確認済み
