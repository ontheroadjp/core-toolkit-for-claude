# /codex-review

Codex CLI を使って指定した PR をレビューし、結果を PR コメントとして投稿します。

**使用方法:** `/codex-review #N` または `/codex-review N`

---

## Step 0: 引数チェック

`$ARGUMENTS` から PR 番号を取得する。
- `#N` 形式の場合は `#` を除去して `N` として扱う
- PR 番号が指定されていない場合:
  - 「PR 番号を指定してください。例: `/codex-review #19`」と報告して終了する

---

## Step 1: PR の存在確認

```bash
gh pr view <PR番号> --json number,url,title,headRefName,baseRefName
```

- PR が存在しない場合: 「PR #<番号> が見つかりません」と報告して終了する
- PR が存在する場合: タイトル・URL・headRefName・baseRefName を記録して Step 2 へ進む

---

## Step 2: PR ブランチへの切り替え

現在のブランチを記録し、PR ブランチに切り替える。

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git fetch origin <headRefName>
git checkout <headRefName>
```

- checkout に失敗した場合: 「ブランチ '<headRefName>' への切り替えに失敗しました」と報告して終了する

---

## Step 3: Codex CLI によるレビュー実行

以下のプロンプトで `codex review` を実行し、端末に表示しながら一時ファイルに保存する。

```bash
TMPFILE="/tmp/codex-review-<PR番号>.txt"

codex review \
  --base "origin/<baseRefName>" \
  --title "<PR タイトル>" \
  "レビューは全て日本語で回答してください。このリポジトリは Claude Code / Codex CLI 向けのコマンド・フック・スキル・設定を管理するツールキットです。以下のリポジトリ固有ルールを適用してください:
- symlink-only 原則: ~/.claude/ 配下には実体ファイルを置かず、全て本リポジトリへの symlink とする
- コミット形式: <type>(#<issue number>): <short description> (Conventional Commits)
- docs/* 変更は /docs-sync が担う（実装者が直接編集しない）
- ワークスペースのクリーン化は stash で行う（破壊的操作禁止）
- git diff が事実。AI の要約・解釈は補助情報にとどめる" \
  | tee "$TMPFILE"
```

- コマンドが失敗した場合: 「codex review の実行に失敗しました」と報告して Step 4 へ進む（クリーンアップを行う）

---

## Step 4: 元のブランチに戻る

```bash
git checkout "$CURRENT_BRANCH"
```

---

## Step 5: PR コメントとして投稿

ANSI エスケープシーケンスを除去してから PR コメントとして投稿し、コメント URL を取得する。

```bash
CLEAN_OUTPUT=$(sed 's/\x1b\[[0-9;]*[mGKHF]//g' "$TMPFILE")

REPO=$(gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"')

COMMENT_URL=$(gh api "repos/$REPO/issues/<PR番号>/comments" \
  --method POST \
  -f body="$CLEAN_OUTPUT" \
  --jq '.html_url')
```

- 投稿に失敗した場合: 「コメントの投稿に失敗しました。`$TMPFILE` の内容を確認してください」と報告して終了する

---

## Step 6: 一時ファイルの削除と完了報告

```bash
rm "$TMPFILE"
```

ユーザーに以下を報告する:

```
コメントを投稿しました: <COMMENT_URL>
```
