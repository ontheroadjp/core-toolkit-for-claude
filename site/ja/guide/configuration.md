# 設定

## settings.json への hooks 登録

以下を `~/.claude/settings.json` に追加して hooks を有効化します。`jq` が利用可能な場合、`install.sh` が自動で設定します。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/auto-approve-readonly.sh"
        }]
      },
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/guard-destructive-cmd.sh"
        }]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/log-access-prompt.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/log-access-tool.sh"
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/log-token-usage.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/log-access-stop.sh" },
          { "type": "command", "command": "bash ~/.claude/hooks/cleanup-session.sh" }
        ]
      }
    ]
  }
}
```

## Hook リファレンス

### auto-approve-readonly.sh

安全な読み取り専用ツール呼び出しの許可プロンプトを排除します。

- `Read` ツールを常に自動承認
- 読み取り専用 `Bash` コマンドを自動承認: `git status/log/diff`、`ls`、`cat`、`grep`、`fd`、`curl`（ファイルダウンロードなし）、`npm`（install なし）、`pytest` など
- 複合コマンド（`&&`、`||`、`;`、`|`）は分割評価 — 全セグメントが安全な場合のみ承認
- 書き込みリダイレクト（`>`）は通常の許可フローへ

### guard-destructive-cmd.sh

危険なコマンドを Claude が実行する前にブロックまたは委譲します。

- **Level 0（即時ブロック）:** システムディレクトリへの `rm -rf`、`dd`/`mkfs`、fork bomb、`git filter-branch`
- **Level 1（ユーザーへ委譲）:** `git push --force`、`git reset --hard`、`git clean -fd`、`git branch -D`

### log-token-usage.sh

セッション終了時にトークン使用量を `logs/token-usage/YYYY-MM.log` へ追記します。

```
[2026-05-23 20:54:56] session=abc123  input=1411  output=445336  cache_read=80565208  total=1539424  cost_usd=0.0412
```

### log-access-*.sh

`/work` セッションのユーザープロンプト・ファイルアクセス順序・変更ファイルを記録します。

- `log-access-prompt.sh`: 現在のユーザープロンプトを保存
- `log-access-tool.sh`: ワークフローフェーズごとに Read/Glob/Grep/Edit/Write を追跡
- `log-access-stop.sh`: セッション停止時にアクセスログを書き出す

### cleanup-session.sh

セッション終了時に `~/.claude/session-approved` を削除し、あるセッションの承認が次のセッションに持ち越されないようにします。

## ステータスライン

`./setup_statusline.sh` を実行すると、Claude Code のステータスバーに以下が表示されます:

```
CTX:35% | 5h:12%(>23:00) | 7d:41%(>06/15 23:00)
```

- **CTX** — コンテキストウィンドウ使用率
- **5h** — 5時間レート制限の使用率とリセット時刻
- **7d** — 7日間レート制限のリセット日時

レート制限データは Claude.ai Pro/Max サブスクライバーのみ利用可能です。
