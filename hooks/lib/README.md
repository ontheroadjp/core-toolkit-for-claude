# hooks/lib/

hook scripts 間で共有する Bash helper 関数ライブラリ。

## ファイル一覧

| ファイル | 用途 |
|---|---|
| `approval-safety.sh` | PreToolUse hook で使う破壊的操作検出 helper |

## approval-safety.sh

`auto-approve-readonly.sh` と `guard-destructive-cmd.sh` の両方から `source` で読み込まれる共有 helper。

### 提供する関数

**`approval_safety_destructive_reason <command>`**

渡した Bash コマンド文字列が破壊的操作に該当するかを判定し、該当する場合は理由文字列を stdout に出力して `return 0` する。該当しない場合は何も出力せず `return 1` する。

検出対象の操作:

| パターン | 理由 |
|---|---|
| `rm -rf /` などシステムディレクトリへの再帰削除 | システムディレクトリ破壊 |
| `dd of=/dev/*` | ブロックデバイスへの直接書き込み |
| `shred /dev/*` | ブロックデバイスの破壊的消去 |
| `wipefs` | ファイルシステムシグネチャの消去 |
| `truncate -s 0 /dev/*` | ブロックデバイスのゼロ化 |
| `mkfs.*` | ファイルシステムの作成・上書き |
| `:(){ :|: & };:` などの fork bomb | プロセス爆弾 |
| `git filter-repo`, `git filter-branch` | 履歴書き換え |
| `git push --force` / `push -f` | 強制プッシュ |
| `git reset --hard` | ハードリセット |
| `git checkout -- .`, `git restore .` | 全ファイル復元（変更破棄） |
| `git clean -f` | 未追跡ファイルの強制削除 |
| `git branch -D` | ブランチの強制削除 |
| `git stash drop`, `git stash clear` | stash の削除 |

### 使い方（hook から呼び出す例）

```bash
# hook script 内で source する
. "${REPO_DIR}/hooks/lib/approval-safety.sh"

# コマンドが破壊的か判定する
reason=$(approval_safety_destructive_reason "$command")
if [ -n "$reason" ]; then
    # JSON block decision を返す
    printf '{"decision":"block","reason":"%s"}\n' "$reason"
    exit 0
fi
```
