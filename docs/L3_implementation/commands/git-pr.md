# /git-pr specification

## 目的・役割

`commands/git-pr.md` は `git push` と `gh pr create` を担う単一責任のスラッシュコマンドである。`/git-commit` が commit 操作を集約するのと同様に、push・PR 作成操作をここに集約する。

`/task` Phase 2 から `/docs-sync` 完了後に呼び出される。ユーザーが手動で呼び出すこともできる。

根拠: `commands/git-pr.md:1-7`

## 動作の概要

7 ステップで構成される:

```
Step 1: セッション temp ディレクトリの特定
Step 2: PR タイトルの準備（temp ファイルまたは git log から生成）
Step 3: PR body の準備（temp ファイルまたは diff から生成）
Step 4: docs sync 結果の追記（pr-docs-sync-result.md があれば body 末尾に追加）
Step 5: git push
Step 6: gh pr create（ready for review）
Step 7: 結果報告
```

根拠: `commands/git-pr.md:13-54`

## 主要な判定ロジック

### SESSION_TMP_DIR の導出

```bash
APPROVED_PATH=$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/current-session-approved-path" 2>/dev/null)
SESSION_ID=$(basename "$(dirname "$APPROVED_PATH")" 2>/dev/null)
SESSION_TMP_DIR="/tmp/claude-code-kit/${SESSION_ID}"
```

`current-session-approved-path` はセッション開始時に hook が書き込むポインタファイル。そのディレクトリ名がセッション ID であり、temp ディレクトリのパスを一意に決定する。

### temp ファイルの優先順位

| ファイル | あり | なし |
|---|---|---|
| `pr-title.txt` | そのまま使用 | `git log main...HEAD --oneline` から生成 |
| `pr-body.md` | そのまま使用 | テンプレート or diff から生成 |
| `pr-docs-sync-result.md` | body 末尾に追記 | スキップ |

根拠: `commands/git-pr.md:25-45`

## 重要な設計判断

### push を /git-pr に移動した理由

従来は `/task` Phase 2 が draft PR 作成のために push し、`/docs-sync` Phase 3 が docs commit のために再度 push していた（合計 2 回）。push 後はローカルの commit 操作（amend/squash/rebase）が実質困難になるため、全コミット（実装 + docs）が確定してから 1 回だけ push する設計に変更した。

### draft → ready の遷移をなくした理由

従来は draft PR を作成し、`/docs-sync` 完了後に `gh pr ready` で公開状態に遷移していた。`/git-pr` が担うことで、docs sync 完了済みの状態で直接 ready PR を作成できるため、中間状態（draft）が不要になった。

根拠: 設計経緯は issue #167 参照

## 統合ポイント

- 呼び出し元: `commands/task.md`（Phase 2 Step 1 から `/docs-sync` 完了後に自動呼び出し）、ユーザーの手動呼び出し
- 呼び出すもの: なし（`git push`・`gh pr create` を直接実行）
- 依存 temp ファイル（任意）:
    - `SESSION_TMP_DIR/pr-title.txt`（`/task` が書き出す）
    - `SESSION_TMP_DIR/pr-body.md`（`/task` が書き出す）
    - `SESSION_TMP_DIR/pr-docs-sync-result.md`（`/docs-sync` が書き出す）

## 注意事項

- PR は ready for review として作成する（draft では作成しない）
- SESSION_TMP_DIR が特定できない場合は temp ファイルなしとして動作する（エラーにしない）
- 手動呼び出し時に temp ファイルがなければ diff からタイトル・本文を生成するため、単独でも動作する

## 変更履歴（git log より自動生成）

- 82717a1 feat(#167): add /git-pr command; refactor push and PR creation out of /task and /docs-sync
