# /triage-issues

open issue が溜まったタイミングで実行する、issue トリアージ専用のエントリポイントです。open issue をレビューし、各 issue が `/work #xxx` で安全・一貫して使える状態かを確認・整理します。

- `/work`・`/task`・`/new-issue`・`/review-resolve` とは独立したスタンドアロンのワークフローです
- **AI による issue 操作（close / edit / comment / label など）はユーザーの明示的な承認なしに実行しません**
- すべての提案は「理由」と「推奨アクション」をセットで提示してからユーザー承認を取ります
- 既存コマンドの振る舞いは変更しません

---

## ワークフロー

### Step 0: 前提確認

- `gh auth status` でログイン済みであることを確認する
- ログインできていない場合は「gh にログインしてから再実行してください」と報告して終了する

### Step 1: open issue 一覧取得

以下のコマンドで open issue をすべて取得する:

```bash
gh issue list --state open --json number,title,body,labels,createdAt,updatedAt --limit 200
```

取得件数をユーザーに報告する。issue が 0 件の場合は「open issue はありません」と報告して終了する。

### Step 2: リポジトリ現状の把握

以下を確認してトリアージの基準を確立する:

- `docs/.ai/repo.profile.json` を Read してリポジトリの現在の構成を把握する
- `docs/L3_implementation/specification_summary.md` を Read して現在の仕様・コマンド・スキルを把握する
- 各 open issue の内容を上記と照合する

### Step 3: issue 分類

各 issue を以下の5カテゴリに分類する。1 つの issue が複数カテゴリに該当することもある:

| カテゴリ | 判定基準 |
|---|---|
| **stale** | 長期間（目安: 90日以上）更新がなく、依存するコンテキストが変化している |
| **inconsistent** | 本文の前提・対象ファイル・挙動記述が現在のリポジトリ状態と矛盾している |
| **duplicated** | 別の open issue と目的・スコープが重複または大きく重なる |
| **unclear** | 完了条件・背景・スコープのいずれかが不明確で `/work` を開始するには不十分 |
| **ready** | 上記のいずれにも該当せず、現状と矛盾なく `/work #xxx` で作業を開始できる |

分類根拠は事実のみを引用する（推測・補完禁止）。

### Step 4: トリアージ結果の提示

分類結果をカテゴリ別に一覧表示する:

```
## Triage Results (N issues)

### Ready (N)
- #XX: <title>

### Stale (N)
- #XX: <title> — 最終更新: YYYY-MM-DD

### Inconsistent (N)
- #XX: <title> — 矛盾点: <事実を 1 行で>

### Duplicated (N)
- #XX: <title> — 重複先: #YY

### Unclear (N)
- #XX: <title> — 不明点: <具体的な不明項目>
```

ready 以外の各 issue について Step 5 で処理する。ready issue はそのまま終了する。

**ここでユーザーに確認する:**
「上記の分類を確認してください。処理を続けてよいですか？（yes / no / 修正したい点があれば記述）」

- no → 終了する
- 修正依頼 → 指摘に従って分類を修正し、再提示する
- yes → Step 5 へ進む

### Step 5: issue ごとのアクション確認・実行

ready 以外の各 issue を 1 件ずつ処理する。

各 issue について以下の形式で提示する:

```
---
Issue #XX: <title>
カテゴリ: <stale / inconsistent / duplicated / unclear>
理由: <判定根拠（事実のみ）>
推奨アクション: <以下のいずれか>
```

**推奨アクション候補:**

| アクション | 説明 |
|---|---|
| `close` | issue をクローズする（理由コメントを付ける） |
| `comment` | 現状との差異や確認事項をコメントとして投稿する |
| `edit-title` | タイトルを修正して明確にする（修正案を提示） |
| `edit-body` | 本文を更新して現状と整合させる（変更箇所を diff 形式で提示） |
| `label` | ラベルを追加/変更する |
| `link-duplicate` | 重複先 issue へのリンクをコメントに追加する |
| `skip` | 今回はアクションを取らない |

**ユーザーへの確認プロンプト:**

```
上記 issue に対して推奨アクション「<アクション>」を実行します。
承認しますか？ (yes / no / skip / 別のアクションを指定)
```

- `yes` → 承認されたアクションを実行し、次の issue へ進む
- `no` → アクションを取らず次の issue へ進む（= skip と同義）
- `skip` → アクションを取らず次の issue へ進む
- 別のアクション → 指定されたアクションを推奨アクションとして再提示し、再度承認を取る

**実行できる gh コマンド例:**

```bash
# close（理由コメント付き）
gh issue comment <number> --body-file - <<'EOF'
<理由>
EOF
gh issue close <number>

# comment のみ
gh issue comment <number> --body-file - <<'EOF'
<コメント内容>
EOF

# タイトル編集
gh issue edit <number> --title "<new title>"

# 本文編集
gh issue edit <number> --body-file - <<'EOF'
<updated body>
EOF

# ラベル追加
gh issue edit <number> --add-label "<label>"

# 重複リンクコメント
gh issue comment <number> --body-file - <<'EOF'
Duplicate of #<other-number>
EOF
```

### Step 6: 完了報告

すべての issue を処理した後、以下を報告する:

```
## Triage Complete

処理件数: N 件
- 実行したアクション: N 件
  - close: N 件
  - comment: N 件
  - edit: N 件
  - label: N 件
  - skip: N 件
- ready のまま変更なし: N 件

残存 open issue はすべて `/work #xxx` で作業を開始できる状態です。
```

---

## スコープ外

- 新規 issue の作成（`/new-issue` が担う）
- 実装・コード変更・ブランチ作成（`/work` / `/task` / `/patch` が担う）
- PR 作成・ドキュメント同期（`/docs-sync` が担う）
- PR レビューコメントへの対応（`/review-resolve` が担う）
