# hooks/tmux-agent-status.sh

## 目的・役割

`hooks/tmux-agent-status.sh` は Claude Code / Codex hook から呼び出され、現在の tmux window 名の先頭に AI agent の状態アイコンを付ける補助スクリプトである。

引数に表示したいアイコンを 1 つ受け取る。引数なしで呼び出すと「クリアモード」としてプレフィックスを除去し、アイコンなしの素の window 名に戻す。tmux 外では何も出力せず終了する。

根拠: `hooks/tmux-agent-status.sh:1-11`

## 動作概要

1. 第 1 引数からアイコンを取得する（省略可）。
2. `$TMUX` が未設定の場合は tmux 外とみなし終了する。
3. `$TMUX_PANE` がある場合は tmux command の対象として指定する。
4. 現在の window 名を取得する。
5. 既知の状態 prefix（`✅ `, `🔵 `, `🔴 `）が先頭に積まれている限り除去する。
6. アイコンが指定されている場合は `${EMOJI} ${CLEAN}` で rename-window する。引数なしの場合は `${CLEAN}` のみで rename-window する（クリアモード）。

根拠: `hooks/tmux-agent-status.sh:9-35`

## 主要な判定ロジック

### tmux 外の no-op

`$TMUX` が空の場合は `exit 0` する。hook は tmux 外でも実行され得るため、通常の AI session を邪魔しない。

根拠: `hooks/tmux-agent-status.sh:10`

### 対象 pane の固定

`$TMUX_PANE` が存在する場合は `tmux display-message` と `tmux rename-window` に `-t "$TMUX_PANE"` を渡す。複数 client/session がある場合でも、hook を起動した pane が属する window を対象にするためである。

根拠: `hooks/tmux-agent-status.sh:12-17`

### prefix の正規化

既知の状態 prefix を while loop で繰り返し除去する。これにより `🔴 ✅ zsh` のように過去の状態が複数積まれた window 名でも、次回更新時に単一 prefix へ戻る。

根拠: `hooks/tmux-agent-status.sh:19-28`

### クリアモード（引数なし）

`$EMOJI` が空の場合は prefix を除去した `$CLEAN` だけで `rename-window` する。プロセス終了時に window 名からアイコンを消すために使う。以前は引数なしを「何もしない」として exit していたが、プロセス終了後のクリアが必要になったため変更した。

根拠: `hooks/tmux-agent-status.sh:30-34`

## 統合ポイント

`install.sh` が Claude Code と Codex の hook 設定にこのスクリプトを登録する。主な意味づけは以下である。

- `UserPromptSubmit` / `PreToolUse` / `PostToolUse`: `🔵`（処理中）
- `Notification`: `🔴`（ツール許可待ち）
- `Stop`: `✅`（ターン完了、次の入力待ち）
- プロセス終了: 引数なし呼び出し（クリア）

シェルラッパーでプロセス終了時に引数なしで呼び出す:
```bash
claude() { command claude "$@"; bash ~/.claude/hooks/tmux-agent-status.sh 2>/dev/null; }
codex()  { command codex  "$@"; bash ~/.claude/hooks/tmux-agent-status.sh 2>/dev/null; }
```

根拠: `install.sh:155-187`

## 注意事項・既知の制限

`tmux rename-window` を使うため、window 名は hook 実行時点で更新される。tmux の window 名を常時自動追従させる仕組みではない。

`tmux rename-window` の失敗は hook 全体の失敗として表に出さず、無音で終了する。status 表示は補助機能であり、AI tool 実行を止めるべきではないためである。

claude/codex を Ctrl+C で中断した場合、シェルラッパーの後続コマンドが走らないことがある。その場合はアイコンが残る（許容範囲）。

根拠: `hooks/tmux-agent-status.sh:31-35`

## 変更履歴（git log より自動生成）

- 15e9c5c fix(#181): remap Stop hook to ✅ and add clear mode to tmux-agent-status.sh
- 8105003 fix(#173): fix tmux agent status transitions
- 612b51e fix(#154): replace tmux-agent-status emojis for better terminal visibility
- 544e1ad docs: sync documentation
