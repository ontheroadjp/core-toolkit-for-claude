# Specification Summary

## 対象

このサマリは、アクティブなコマンド仕様ファイル（`commands/` 配下 + templates/ 2 本）および `hooks/` の要点を、断定可能な事実のみで整理したもの。

---

## 1. `commands/work.md` — 実装フロー（主コマンド）

### 概要
全ファイル変更のエントリポイント。ゲート確認・現状調査・ルーティング判定を行い、patch フローまたは task フローを実行する。ユーザーは常に `/work` を呼ぶ。
- 根拠: `commands/work.md:1-4`

### ルーティング判定（main ブランチの場合）
単一質問: 「この変更で `docs/*` への追加・変更・削除が必要か？」
- 不要 → patch フロー（`commands/patch.md` のワークフローを実行）
- 必要 → task フロー（issue → 実装 → ドラフト PR → /docs-sync 自動実行）
- 根拠: `commands/work.md`（ルーティング判定節）

### patch フロー
```
patch.md のワークフローを実行（G-2 通過済みとして扱う）
```
エスカレーション: 実行中にドキュメント変更が必要と判明した場合 → issue 生成 → task Step 0 へ
- 根拠: `commands/task.md`（patch フロー節）

### task フロー（Phase 1）
- Step 0: issue 確認または自動生成（issue なし時は `commands/new-issue.md` の Step 1〜5 フローを実行）
- Step 1: 現状調査の引き継ぎと補完（work.md の調査を引き継ぎ、不足があれば補完）
- Step 2: プラン策定（ユーザー許可必須）
- Step 3: 実装・コミット（コミット前チェック実施 → `<type>(#<issue>): <short description>`）。ソースコード修正時は言語別 coding コマンドを Read して原則を適用する（Python→coding-py.md / JS→coding-js.md / TS→coding-ts.md / その他→coding-general.md）
- 根拠: `commands/task.md`（Phase 1 節、ソースコード修正時の注意点節）

### task フロー（Phase 2）
- ドラフト PR 作成（`commands/templates/pr.md` 使用、`--body-file -` で本文渡し）
- 作成後 `/docs-sync` を自動実行（docs・README.md 更新 → PR 公開まで完結）
- 根拠: `commands/task.md`（Phase 2 節）

### task フロー（Phase 3）
- 最終報告（実装ファイル・テスト・issue URL・PR URL）
- 根拠: `commands/task.md`（Phase 3 節）

### ゲート
- G-1: `docs/.ai/repo.profile.json` の存在
- G-2: main ブランチかつワークスペースがクリーン（差分は stash で退避）
- 根拠: `commands/task.md`（G-1/G-2 節）

---

## 2. `commands/patch.md` — 軽微修正フロー

### 概要
ドキュメント変更を伴わない軽微な修正専用。issue/PR 不要。
- 根拠: `commands/patch.md:1-8`

### ワークフロー
Phase 1（実装）:
- Step 1: work.md からの現状調査結果を引き継ぐ（不足時のみ補完）
- Step 2: プラン確認（変更内容サマリ・利用ツール・新規作成/編集ファイルを提示、ユーザー許可必須）→ Write ツールで `~/.claude/session-approved` に `tool:git_write` と対象ファイルパス（`file:<絶対パス>`）を書き込む
- Step 3: ブランチ作成（`patch/<slug>`）→ 変更・コミット（コミット前チェック実施 → 複数 OK、Conventional Commits 形式）。ソースコード修正時は言語別 coding コマンドを Read して原則を適用する
Phase 3（報告）:
- ユーザーに ff-merge 手順を通知して main に戻る
- 根拠: `commands/patch.md`（Phase 1–3）

### エスカレーション（→ task フロー）
patch フローの前提（軽微・局所・追跡不要）が崩れたと判断した場合（docs 変更・スコープ拡大・影響読み切れない・スコープ超過など）:
1. 現時点の変更をコミット
2. `commands/templates/issue.md` から issue を作成
3. `/task` Phase 1 Step 2（プラン策定）から継続
4. ブランチは `patch/<slug>` のまま再利用
- 根拠: `commands/patch.md`（エスカレーション節）

### ゲート
- G-1: `docs/.ai/repo.profile.json` の存在
- G-2: main ブランチにいること
- G-3: ワークスペースがクリーン（差分は stash で退避）
- 根拠: `commands/patch.md:11-24`

---

## 3. `commands/docs-sync.md` — ドキュメント同期フロー

### 概要
git diff を事実として docs および README.md を最小更新し、ドラフト PR を公開する。全体再構築は禁止。
- 根拠: `commands/docs-sync.md:1-10`

### ワークフロー
1. PR ステータス確認（`--json isDraft,number,url`）→ 存在確認後に本文取得
2. `git diff --name-only` で変更ファイルを特定
3. PR 本文から `/docs-sync への引き継ぎ事項` を読み取る
4. 対象ファイルの targeted diff を取得し、docs・README.md 更新対象を確定
5. HARD STOP 判定（全体再構築が必要な場合は `/init-docs` を促して終了）
6. docs・README.md を最小更新（コミット前チェック実施 → コミット → `git push`）
7. ドラフト PR を公開（`gh pr ready`）
- 根拠: `commands/docs-sync.md`（各フェーズ）

### HARD STOP 条件
以下のいずれかで `/init-docs` を要求して終了:
- (A) 新規主要レイヤ/トップレベル構造の追加疑い
- (B) 起動経路・エントリポイント変更の疑い
- (C) 10 ファイル以上かつ 3 ドメイン以上の広範な変更
- 根拠: `commands/docs-sync.md`（各 HARD STOP 節）

---

## 4. `commands/init-docs.md` — ドキュメント初期化フロー

### 概要
リポジトリ実態の全体把握と設計ドキュメント再構築。重い初期化コマンド。
- 根拠: `commands/init-docs.md:1-8`

### ワークフロー（7 フェーズ）
1. プロジェクト分析（ディレクトリ・技術スタック・エントリポイント・機能・依存）
2. `docs/.ai/repo.profile.json` 生成（事実のみ、補完禁止）。`primary_docs` は Phase 3 完了後に設定する
3. docs 生成（L0/L1/L2/L3）。Phase 3 完了後に `primary_docs` を設定
4. 整合性検証（docs↔実体、docs↔repo.profile.json、CI 整合）
5. README.md の検証・scaffold（必須セクションの存在確認と不足セクションの追加）
6. CLAUDE.md 更新（AI 運用の起点として Custom Command の使い分けルールを更新）
7. ユーザー確認 → commit & ドラフト PR 作成（ブランチ: `docs/init-docs-<YYYYMMDD>`）
- 根拠: `commands/init-docs.md`（Phase 1–7 節）

### 再実行トリガー
- `/docs-sync` が HARD STOP を検知
- docs が現状を説明できなくなった
- 新規レイヤ導入・エントリポイント変更の疑い
- 根拠: `commands/init-docs.md:9-19`

---

## 5. `commands/templates/issue.md` — issue 本文テンプレート

使用コンテキスト:
- `commands/task.md` Step 0（issue 自動生成時）
- `commands/patch.md` エスカレーション時
- 根拠: `commands/task.md`（Step 0 節）, `commands/patch.md`（エスカレーション節）

セクション: 概要・背景・作業スコープ・完了条件（+ エスカレーション時: /patch 実施済み変更・追加スコープ）

---

## 6. `commands/templates/pr.md` — PR 本文テンプレート

使用コンテキスト: `commands/task.md` Phase 2（ドラフト PR 作成時）
- 根拠: `commands/task.md`（Phase 2 節）

セクション: 実装サマリ・変更ファイルと内容・変更の種別・/docs-sync への引き継ぎ事項・留意点

---

## 7. `hooks/log-token-usage.sh` — token 使用量ログ hook

Claude Code の Stop hook として `~/.claude/settings.json` から呼び出される。
- 動作: stdin から `transcript_path` / `session_id` を取得し、JSONL トランスクリプトを解析して `{repo}/logs/token-usage/YYYY-MM.log` に追記する
  - `custom-title` エントリから `/rename` で設定したセッション名（`name`）を抽出
  - 全 assistant エントリの `message.usage` を集計（input / output / cache_read / cache_create）
  - モデル名をサブストリングマッチで判定し `cost_usd` を推定（opus/haiku/その他→sonnet 単価）
- ログフィールド: `session`, `name`, `model`, `turns`, `input`, `output`, `cache_read`, `cache_create`, `total`, `cache_ratio`, `cost_usd`, `branch`, `cwd`
- 依存: `bash`, `jq`
- 根拠: `hooks/log-token-usage.sh`

---

## 8. `hooks/log-access-prompt.sh` — ユーザー指示保存 hook

Claude Code の UserPromptSubmit hook として `~/.claude/settings.json` から呼び出される。
- 動作: stdin から `session_id` / `prompt` を取得し、`/tmp/claude-access-sessions/{session_id}.prompt` に書き出す（複数回ユーザー入力があった場合は上書き）
- 新セッション開始時（state ファイルが存在しない場合）:
  - `/tmp/claude-access-sessions/*.pending` を走査し、現セッション以外の孤立 pending ファイルを `logs/access/YYYY-MM.log` にフラッシュして削除する
  - 対応する `.json` / `.prompt` ファイルもクリーンアップする
  - state ファイルを新規作成する（`user_instruction` には最初のプロンプトを記録）
- 依存: `bash`, `jq`
- 根拠: `hooks/log-access-prompt.sh`

---

## 9. `hooks/log-access-tool.sh` — フェーズ別ファイルアクセス追跡 hook

Claude Code の PostToolUse hook として `~/.claude/settings.json` から呼び出される。
- 動作: Read/Glob/Grep/Edit/Write ツール使用後に発火し、セッション状態ファイルを更新する
  - `work.md` 読み込み時:
    - state に蓄積データ（seq > 0）があり pending ファイルが存在する場合: pending ファイルを `logs/access/YYYY-MM.log` にフラッシュし、state を新しい `/work` 用にリセットする（`user_instruction` は `.prompt` ファイルの最新プロンプトで更新）
    - state が空（seq = 0）の場合: phase を `"work"` にセットするのみ
  - `task.md` / `patch.md` / `docs-sync.md` / `init-docs.md` の読み込みでフェーズを切り替え
  - Read/Glob/Grep はグローバルシーケンス番号をインクリメントし `accesses` 配列に追加（重複除去なし）
  - Edit/Write は `modified_files` リストに追加（重複除去）
- セッション状態ファイル: `/tmp/claude-access-sessions/{session_id}.json`
  - フィールド: `start_time`, `user_instruction`, `current_phase`, `seq`, `accesses`, `modified_files`
  - `accesses` 要素: `{seq, phase, tool, path}`
  - state ファイルは Stop をまたいで保持される（削除は新 `/work` 開始時または新セッション開始時）
- 依存: `bash`, `jq`
- 根拠: `hooks/log-access-tool.sh`

---

## 10. `hooks/log-access-stop.sh` — アクセスログ書き出し hook

Claude Code の Stop hook として `~/.claude/settings.json` から呼び出される。
- 動作: セッション状態ファイルが存在しかつアクセス数 > 0 の場合のみ、フォーマット済みログを pending ファイル（`/tmp/claude-access-sessions/{session_id}.pending`）に**上書き**保存する
  - main log（`logs/access/YYYY-MM.log`）へは書き込まない（フラッシュは `log-access-tool.sh` または `log-access-prompt.sh` が担う）
  - state ファイルは削除しない（複数ターンにまたがる `/work` セッションの蓄積を維持するため）
  - `/work` が呼ばれなかったセッション（state ファイルなし）では何もしない
- pending ファイルのフラッシュタイミング:
  - 同一セッション内で新しい `/work` が開始されたとき（`log-access-tool.sh` が担当）
  - 新しい Claude セッションが開始されたとき（`log-access-prompt.sh` が担当）
- ログ形式（pending ファイル / main log エントリ共通）:
  ```
  ---
  [日時]          yyyy.mm.dd hh.mm
  [ユーザーからの指示内容]  ...
  [アクセスサマリ]
  総アクセス数: N
  重複アクセス:
    - path/to/file (N回)
  [フェーズ別アクセス順序]
  [work] N件
    #1  Read  path/to/file
    #2  Glob  pattern
  [task] N件
    #3  Read  path/to/file
  [修正したファイル]
    - path/to/file
  [トークン使用量]
    input:       N
    output:      N
    cache_read:  N  (cache_ratio: N.N%)
    total:       N
    cost_usd:    N.NNNN
  ```
- `[トークン使用量]` セクションは `transcript_path` が取得できない場合は省略される
- フェーズ順序は初回出現順（アルファベット順ではない）
- 重複アクセスは頻度降順で表示。重複なしの場合は「重複アクセス: なし」
- 出力先（最終）: `{repo}/logs/access/YYYY-MM.log`（`logs/` は `.gitignore` 対象）
- 依存: `bash`, `jq`
- 根拠: `hooks/log-access-stop.sh`

---

## 11. `hooks/notify-slack.sh` — Slack 入力待ち通知 hook

Claude Code の `Notification` hook（permission prompt 等の待機）および `Stop` hook（応答完了後の入力待ち）として `~/.claude/settings.json` から呼び出される。
- 動作: stdin の hook event payload を `jq` で解析し、`hook_event_name` 別にメッセージを組み立てて Slack Incoming Webhook に POST する
  - `Notification` → 🔔 `Claude Code: permission/input needed`（payload の `message` を本文に含める）
  - `Stop` → ✅ `Claude Code: response finished` / `Waiting for next instruction`
  - その他 → ℹ️ 汎用メッセージ
  - 補助情報: project basename（`cwd` から抽出）、`git rev-parse --abbrev-ref HEAD`、短縮 `session_id`
- 環境変数: `CLAUDE_CODE_KIT_WAIT_NOTIFY_SLACK_WEBHOOK_URL`
  - 未設定または空文字列の場合は **silently `exit 0`**（Claude 本体に影響を与えない）
  - 設定されている場合のみ webhook URL として使用する
- 失敗耐性: `curl --max-time 5` でタイムアウト制限、ネットワーク失敗は `|| true` で握り潰し常に `exit 0`（Claude のレスポンスをブロックしない）
- 依存: `bash`, `curl`, `jq`
- 根拠: `hooks/notify-slack.sh`

---

## 12. `hooks/guard-destructive-cmd.sh` — 破壊的コマンドガード hook

Claude Code の PreToolUse hook として `~/.claude/settings.json` から呼び出される（matcher: `Bash`）。
- 動作: Bash ツール実行前に発火し、コマンドを Lv0 / Lv1 に分類してブロックまたは警告する
  - **Lv0（即座ブロック・バイパス不可）**: rm -rf でのシステムディレクトリ破壊、dd/shred/wipefs/mkfs/truncate -s 0 によるブロックデバイス操作、フォークボム、chmod/chown -R でのシステムルート変更、git filter-branch/filter-repo による履歴書き換え
  - **Lv1（ブロック＋ユーザー手動実行へ委譲）**: git push --force/-f/--force-with-lease、git reset --hard、git checkout ./restore .、git clean -fd/-fdx、git branch -D、git stash drop/clear
- Lv1 ブロック時の動作: フック stdout に「Claude 向け指示」を出力し、Claude がコマンド内容をユーザーに提示して手動実行を依頼 → ユーザーが完了報告後に作業再開
  - Claude 自身が再実行しない設計（バイパスマーカー方式は採用しない）
- 依存: `bash`, `jq`
- 根拠: `hooks/guard-destructive-cmd.sh`

---

## 13. `commands/review-resolve.md` — PR レビューコメント対話的解決コマンド

### 概要
PR レビューコメント対応専用のワークフローエントリポイント。`/work` を経由せず自己完結（checkout → 実装 → commit → push → 返信）。各コメントに対して Claude の意見を提示したうえでユーザーが対応方針を選択する。
- 根拠: `commands/review-resolve.md:1-6`

### 引数
- `/review-resolve 19` または `/review-resolve #19` の形式で PR 番号を指定する
- 引数がない場合はユーザーに報告して終了する
- 根拠: `commands/review-resolve.md`（Step 0）

### ブランチ checkout
- Step 1 で `headRefName` を取得後、Step 1.5 として `git fetch origin <headRefName>` + `git checkout <headRefName>` を実行する（Step 2 より前）
- checkout 失敗時は即終了（早期失敗）
- 根拠: `commands/review-resolve.md`（Step 1.5）

### レビューコメントの取得対象
- **(A) インラインコードコメント**: `gh api repos/{owner}/{repo}/pulls/{n}/comments`（diff に紐づくコメント）
- **(B) レビュー本体コメント**: `gh api repos/{owner}/{repo}/pulls/{n}/reviews`（CHANGES_REQUESTED / COMMENTED 状態かつ本文あり）
- 両方が空の場合は「コメントなし」と報告して終了する
- 根拠: `commands/review-resolve.md`（Step 2）

### 対応選択フロー（コメント 1 件ずつ）
各コメントに Claude の意見（妥当性・対応方針）を提示した後、4択から選択:
1. **対応する** → 該当コードを読み PR ブランチ上で直接実装 → `git-commit.md` でコミット（`issue_number=none`, `allowed_types=[fix, refactor, style]`）→ `git push` → 「対応しました。」を返信。スコープ超過と判断した場合は `/work` での対応を促してスキップ
2. **反対意見を返信する** → Claude の意見をベースに返信文を作成・ユーザー確認後に投稿
3. **対応しない** → ユーザーが理由を入力 → 理由をコメントに返信
4. **スキップ** → 次のコメントへ進む（返信なし）
- 根拠: `commands/review-resolve.md`（Step 3）

### 返信 API
- インラインコメント: `POST /repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies`
- レビュー本体コメント: `POST /repos/{owner}/{repo}/issues/{n}/comments`（PR の issue comment として投稿）
- 根拠: `commands/review-resolve.md`（Step 3 選択 1〜3）

### 完了報告
対応 / 反対意見を返信 / 返信 / スキップの件数サマリを表示。スキップがある場合は PR URL を添えて案内する。
- 根拠: `commands/review-resolve.md`（Step 4）

---

## 14. `commands/new-issue.md` — アイデアから issue 生成フロー（任意の pre-`/work` エントリポイント）

### 概要
漠然としたアイデアを 1 件または複数件の整形された GitHub issue に変換する、`/work` の前段に置く**任意**のエントリポイント。実装は行わず issue 作成のみで完結する。`/work` を含む既存コマンド・スキルには一切影響しない。
- 根拠: `commands/new-issue.md:1-9`

### ワークフロー（6 ステップ）
- Step 0: 前提確認（main ブランチ確認、`gh auth status` 確認。実装を伴わないためゲートは不要）
- Step 1: アイデア捕捉（解決したい問題・利用シーンをユーザーに尋ねる。推測禁止）
- Step 2: 明確化（背景・現状の挙動・制約・完了条件のシグナルを 1 件ずつ確認し、整理結果を提示して認識ズレを潰す）
- Step 3: スコープ判定（**ユーザー選択必須**。3 択を提示した後、Claude が Step 1/2 の事実に基づく推奨（1/2/3）を理由付きで提示する）
- Step 4: ドラフト作成（`~/.config/claude-code-kit/templates/issue.md` の構成に従い英語で起票文を作成、ユーザー OK 必須）+ ラベル選定
- Step 5: `gh issue create` で各 issue を作成（ラベルが決定している場合は `--label` を付与）
- Step 6: 引き継ぎ案内（作成 issue の番号・URL を提示し「次は `/work` を呼んでください」と案内。`/work` の自動呼び出しは禁止）
- 根拠: `commands/new-issue.md`（各 Step 節）

### Step 4 のラベル選定
- ドラフト OK 後、`gh label list` で既存ラベルを取得し、issue 内容に基づいて最適なラベルを自動選定する（ユーザー確認なし）
- 適切なラベルが存在しない場合: ユーザーへ報告 → 新規ラベル（name / description / color）を提案 → 承認時 `gh label create` で作成して採用、拒否時はラベルなしで作成
- 根拠: `commands/new-issue.md`（Step 4 ラベル選定節）

### Step 3 の 3 択（スコープ判定）
1. **1 つの issue で Phase 分割** — 1 件に保ち、本文 Scope に Phase 1 / Phase 2 / ... を明示する
2. **issue を分割（N 件）** — 独立した関心ごとを別 issue として作成する（分割案を提示する）
3. **issue を分割しない** — 1 件のシンプルな issue として作成する

各選択肢に個別の reasoning bullets はない。代わりに Claude が「**Claude の推奨: [N] — [理由]**」を Step 1/2 の事実のみを根拠として提示する。
- 根拠: `commands/new-issue.md`（Step 3 節）

### スコープ外
- 実装・コード変更・ブランチ作成、PR 作成・ドキュメント同期、既存 issue の編集・クローズ。これらは `/work` および委譲先が担う
- 根拠: `commands/new-issue.md`（スコープ外節）

### スキルラッパー
- `skills/new-issue/SKILL.md`: Codex 向けの薄いラッパー。`commands/new-issue.md` を Source Of Truth として Read し、その通り実行する。他スキル（work / task / patch / docs-sync / init-docs / review-resolve）と同形式
- 根拠: `skills/new-issue/SKILL.md`

---

## 15. `commands/coding-general.md` — 言語非依存コーディング原則コマンド

### 概要
言語・フレームワーク問わず AI エージェントが従うべき実装原則を定義した SSOT コマンド。言語固有コマンドの基盤として参照される。
- 根拠: `commands/coding-general.md:1-3`

### 原則一覧（6 項目）
1. **No guessing** — ライブラリ使用前に必ず公式ドキュメントまたは型スタブを確認する
2. **Ask when unclear** — 仕様・期待挙動が明示されていない場合は推測せずユーザーに確認する
3. **Follow existing patterns** — 周囲のコードを先に読み、命名規則・構造・エラーハンドリングスタイルに合わせる
4. **Single responsibility** — 関数・モジュールは 1 つのことだけを行う
5. **No silent exception suppression** — `except: pass` / 空 catch / 戻り値なし `_ = err` を禁止。無視する場合はコメント必須
6. **No magic numbers** — 業務ルールや設定値を表すリテラルは名前付き定数に置き換える
- 根拠: `commands/coding-general.md`（各 Principle 節）

### スキルラッパー
- `skills/coding-general/SKILL.md`: Codex 向けの薄いラッパー。`commands/coding-general.md` を Source Of Truth として Read し原則を適用する。他スキル（work / task / patch 等）と同形式
- 根拠: `skills/coding-general/SKILL.md`

---

## 16. `commands/coding-py.md` — Python コーディング規約コマンド

### 概要
`coding-general` を基盤とし、Python プロジェクト向けの言語固有コーディング規約を定義した SSOT コマンド。`coding-general` を先に参照してから適用する。
- 根拠: `commands/coding-py.md:1-4`

### ツールチェーン
- Linter / Formatter: ruff
- 型チェッカー: mypy（strict モード）
- テストフレームワーク: pytest
- 根拠: `commands/coding-py.md`（Toolchain 節）

### 原則一覧（6 項目）
1. **型アノテーション必須** — 全関数の引数・戻り値に型アノテーションを付与する
2. **`Any` 原則禁止** — `typing.Any` は代替不能な場合のみ許可。使用する場合は `# type: ignore` と理由コメントを必須とする。代替として `object`・`Protocol`・`TypeVar` を推奨
3. **No silent exception suppression** — `except: pass` / `except Exception: pass` は禁止。無視する場合はコメント必須（`coding-general` と同内容）
4. **No magic numbers** — 業務ルールや設定値はすべて名前付き定数に置き換える（`coding-general` と同内容）
5. **Single responsibility** — 関数は 1 つのことのみを行う（`coding-general` と同内容）
6. **pytest 規約** — テストファイル `test_<module>.py`、テスト関数 `test_<behavior>_<condition>()`、例外検証は `pytest.raises` 使用
- 根拠: `commands/coding-py.md`（各 Principle 節）

### スキルラッパー
- `skills/coding-py/SKILL.md`: Codex 向けの薄いラッパー。`commands/coding-general.md` → `commands/coding-py.md` の順に Read し原則を適用する。他スキルと同形式
- 根拠: `skills/coding-py/SKILL.md`

---

## 17. `commands/coding-js.md` — JavaScript コーディング規約コマンド

### 概要
`coding-general` を基盤とし、JavaScript プロジェクト向けの言語固有コーディング規約を定義した SSOT コマンド。`coding-general` を先に参照してから適用する。
- 根拠: `commands/coding-js.md:1-4`

### ツールチェーン
- Linter / Formatter: Biome（lint + format）
- テストフレームワーク: Vitest
- 根拠: `commands/coding-js.md`（ツールチェーン節）

### 原則一覧（5 項目）
1. **`var` 禁止** — `const` / `let` のみ使用する。再代入が必要な場合は `let`、それ以外は `const`
2. **`==` 禁止** — 型強制を防ぐため `===` / `!==` のみ使用する
3. **アロー関数優先** — コールバック・無名関数はアロー関数で書く。`this` バインディングが必要なメソッド定義を除き `function` キーワードの無名関数は使わない
4. **`?.` / `??` を積極活用** — ネストした null/undefined チェックには `?.`、デフォルト値には `??` を使う
5. **No silent exception suppression** — 空の `catch {}` は禁止。無視する場合はコメント必須（`coding-general` と同内容）
- 根拠: `commands/coding-js.md`（各 Principle 節）

### スキルラッパー
- `skills/coding-js/SKILL.md`: Codex 向けの薄いラッパー。`commands/coding-general.md` → `commands/coding-js.md` の順に Read し原則を適用する。他スキルと同形式
- 根拠: `skills/coding-js/SKILL.md`

---

## 18. `commands/coding-ts.md` — TypeScript コーディング規約コマンド

### 概要
`coding-general` と `coding-js` を基盤とし、TypeScript プロジェクト向けの言語固有コーディング規約を定義した SSOT コマンド。`coding-general` → `coding-js` を先に参照してから適用する。
- 根拠: `commands/coding-ts.md:1-4`

### ツールチェーン
- Linter / Formatter: Biome（lint + format）
- テストフレームワーク: Vitest
- 型チェッカー: TypeScript コンパイラ（`strict: true`）
- 根拠: `commands/coding-ts.md`（ツールチェーン節）

### 原則一覧（6 項目）
1. **`strict: true` 必須** — `tsconfig.json` の `compilerOptions` に `"strict": true` を明示する。個別フラグで代替しない
2. **`any` 原則禁止** — 型が不明な値には `unknown` を使い、型ガードで絞り込む
3. **型アサーション（`as`）原則禁止** — 型ガード関数（`is` 述語）または `in` / `typeof` / `instanceof` で型を絞り込む
4. **非 null アサーション（`!`）禁止** — `??` / `?.` またはガード節で明示的に処理する
5. **`enum` 禁止** — `const` + `as const` または string ユニオン型を使う
6. **`interface` vs `type` の使い分け** — オブジェクト形状には `interface`、ユニオン・エイリアスには `type`
- 根拠: `commands/coding-ts.md`（各 Principle 節）

### スキルラッパー
- `skills/coding-ts/SKILL.md`: Codex 向けの薄いラッパー。`commands/coding-general.md` → `commands/coding-js.md` → `commands/coding-ts.md` の順に Read し原則を適用する。他スキルと同形式
- 根拠: `skills/coding-ts/SKILL.md`

---

## 19. `hooks/auto-approve-readonly.sh` — 読み取り専用・セッション承認ツール自動承認 hook

Claude Code の PreToolUse hook として `~/.claude/settings.json` から呼び出される（matcher: `""`、全ツール対象）。
- 動作: ツール実行前に発火し、安全な操作およびセッション承認済み操作を自動承認してパーミッションプロンプトを抑制する
  - **Read ツール**: 全入力を問わず常に auto-approve
  - **Write ツール**: `~/.claude/session-approved` 自体への書き込みは常に approve。それ以外のパスはセッションファイルの `file:` エントリと一致する場合のみ approve
  - **Edit ツール**: セッションファイルの `file:` エントリと一致するパスの場合のみ approve
  - **Bash ツール（read-only ホワイトリスト）**: コマンドが以下のいずれかにマッチする場合のみ auto-approve
    - `git status/log/diff/show/branch/remote/tag/describe/rev-parse/ls-files/ls-tree/cat-file/blame/shortlog/reflog/stash list/config --list|--get/worktree list`
    - `gh issue/pr/label/repo/release/run/workflow list|view|status`、`gh auth status`
    - `ls`/`ll`/`la`、`cat`、`head`、`tail`、`grep`/`egrep`/`fgrep`/`rg`、`find`、`wc`、`sort`、`uniq`、`cut`、`tr`、`awk`、`sed`、`echo`、`printf`、`pwd`、`which`、`type`、`env`、`printenv`、`du`、`df`、`stat`、`file`、`basename`、`dirname`、`date`、`uname`、`hostname`、`whoami`、`id`、`groups`、`ps`、`jq`、`yq`、`column`
    - ランタイムバージョン確認: `node/npm/npx/python3/pip3/ruby/go/cargo/rustc/bash/zsh --version`
  - **Bash ツール（セッション承認）**: `~/.claude/session-approved` の `tool:` エントリに一致する書き込み系コマンドも auto-approve
    - `tool:git_write`: `git add/commit/merge/stash/push`（force 以外）、`git checkout/switch`（ファイル単位除く）、`git branch`（`-D` 除く）
    - `tool:gh_issue_write`: `gh issue create/edit/close/delete/comment/reopen`
    - `tool:gh_pr_write`: `gh pr create/edit/merge/close/comment/reopen/ready/review/checkout`
  - **複合コマンド処理**: `&&`/`||`/`;`/`|` で分割し、全セグメントがホワイトリストまたはセッション承認に一致する場合のみ approve
  - **ファイル書き込みリダイレクト検出**: `>[^&]`（`>&` 以外の `>`）を含む場合はパススルー（通常 permission フロー）
  - **その他のツール・コマンド**: 出力なしで `exit 0`（通常 permission フロー）
- セッションファイル形式（`~/.claude/session-approved`）: 1行1エントリ。`tool:<category>` で Bash 操作カテゴリ、`file:<絶対パス>` で Write/Edit 対象ファイルを指定。`#` 始まり・空行は無視
- 依存: `bash`, `jq`
- 根拠: `hooks/auto-approve-readonly.sh`

---

## 20. `hooks/cleanup-session.sh` — セッション承認ファイルクリーンアップ hook

Claude Code の Stop hook として `~/.claude/settings.json` から呼び出される（`install.sh` で自動登録）。
- 動作: `~/.claude/session-approved` が存在する場合、セッション終了時に削除する。これにより作業プランで付与された承認が次のセッションに持ち越されない
- 依存: `bash`
- 根拠: `hooks/cleanup-session.sh`

---

## 21. `.github/workflows/deploy.yml` — VitePress ドキュメントサイト自動デプロイ

GitHub Actions workflow として `~/.claude/` へはデプロイされない（CI 定義のみ）。

- **トリガー**: `main` ブランチへの push、および `workflow_dispatch`（手動実行）
- **パーミッション**: `contents: read`、`pages: write`、`id-token: write`
- **ジョブ構成**:
  - `build`: Node.js 20 + npm ci → `npm run docs:build`（`site/` ディレクトリで実行）→ `actions/upload-pages-artifact@v3` で `site/.vitepress/dist` をアップロード
  - `deploy`: `actions/deploy-pages@v4` で GitHub Pages へデプロイ。gh-pages ブランチを使用しない
- **前提**: GitHub リポジトリ設定で Settings → Pages → Source を「GitHub Actions」に手動設定する必要がある
- **依存**: Node.js 20, npm, VitePress（`site/package.json`）
- 根拠: `.github/workflows/deploy.yml`

---

## 未確認事項

- 実行ランタイム: このリポジトリ自体は Markdown + Bash のみ。アプリケーションランタイムなし。確認済み。
- `commands/docs-sync.md` の HARD STOP 条件 (C)「10 ファイル以上かつ 3 ドメイン以上」は AI の判断に委ねられる。
