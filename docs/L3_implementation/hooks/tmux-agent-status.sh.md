# hooks/tmux-agent-status.sh

## 目的・役割

`hooks/tmux-agent-status.sh` は Claude Code / Codex hook から呼び出され、現在の tmux window 名の先頭に AI agent の状態アイコンを付ける補助スクリプトである。

引数に表示したいアイコンを 1 つ受け取り、tmux 外では何も出力せず終了する。

根拠: `hooks/tmux-agent-status.sh:1-11`

## 動作概要

1. 第 1 引数から表示するアイコンを取得する。空の場合は終了する。
2. `$TMUX` が未設定の場合は tmux 外とみなし終了する。
3. `$TMUX_PANE` がある場合は tmux command の対象として指定する。
4. 現在の window 名を取得する。
5. 既知の状態 prefix（`✅ `, `🔵 `, `🔴 `）が先頭に積まれている限り除去する。
6. `tmux rename-window` で新しい状態 prefix を付けた window 名に更新する。

根拠: `hooks/tmux-agent-status.sh:9-32`

## 主要な判定ロジック

### tmux 外の no-op

`$TMUX` が空の場合は `exit 0` する。hook は tmux 外でも実行され得るため、通常の AI session を邪魔しない。

根拠: `hooks/tmux-agent-status.sh:11`

### 対象 pane の固定

`$TMUX_PANE` が存在する場合は `tmux display-message` と `tmux rename-window` に `-t "$TMUX_PANE"` を渡す。複数 client/session がある場合でも、hook を起動した pane が属する window を対象にするためである。

根拠: `hooks/tmux-agent-status.sh:13-18`, `hooks/tmux-agent-status.sh:31`

### prefix の正規化

既知の状態 prefix を while loop で繰り返し除去する。これにより `🔴 ✅ zsh` のように過去の状態が複数積まれた window 名でも、次回更新時に単一 prefix へ戻る。

根拠: `hooks/tmux-agent-status.sh:20-29`

## 統合ポイント

`install.sh` が Claude Code と Codex の hook 設定にこのスクリプトを登録する。主な意味づけは以下である。

- `UserPromptSubmit` / `PreToolUse` / `PostToolUse`: `🔵`
- `Notification`: `🔴`
- `Stop`: `✅`

根拠: `install.sh:122-149`

## 注意事項・既知の制限

`tmux rename-window` を使うため、window 名は hook 実行時点で更新される。tmux の window 名を常時自動追従させる仕組みではない。

`tmux rename-window` の失敗は hook 全体の失敗として表に出さず、無音で終了する。status 表示は補助機能であり、AI tool 実行を止めるべきではないためである。

根拠: `hooks/tmux-agent-status.sh:31-32`

## 変更履歴（git log より自動生成）

- 8105003 fix(#173): fix tmux agent status transitions
- 612b51e fix(#154): replace tmux-agent-status emojis for better terminal visibility
- 544e1ad docs: sync documentation
