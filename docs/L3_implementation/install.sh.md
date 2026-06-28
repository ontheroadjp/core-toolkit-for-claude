# install.sh

## 目的・役割

`install.sh` はこのリポジトリの commands, hooks, skills, templates を Claude Code / Codex の実行環境へ symlink し、`jq` が利用可能な場合は Claude Code と Codex の hook 設定も登録する installer である。

このリポジトリを single source of truth とし、`~/.claude/` や `~/.codex/` 配下へ実体ファイルを複製しない。

根拠: `install.sh:1-60`

## 動作概要

1. repository root を解決する。
2. `~/.claude/commands`, `~/.codex/commands`, `~/.claude/hooks`, `~/.codex/hooks`, `~/.codex/skills`, `~/.config/claude-code-kit/templates` などの target directory を作成する。
3. repository 内の commands / hooks / skills / templates を target directory へ symlink する。
4. `jq` がない場合は settings 更新をスキップして終了する。
5. `~/.claude/settings.json` と `~/.codex/hooks.json` がない場合は空 JSON として作成する。
6. idempotent な helper で hook entries を追加する。

根拠: `install.sh:3-72`, `install.sh:74-120`

## 主要な判定ロジック

### symlink-only installer

installer は `ln -sfn` で repository 内ファイルへの symlink を作成する。hook や command の実体は repository 側に残るため、変更は symlink 経由で反映される。

根拠: `install.sh:11-49`

### jq がない場合の設定更新スキップ

hook 設定 JSON の安全な更新には `jq` を使う。`jq` が見つからない場合、symlink 作成後に warning を出して settings 更新だけをスキップする。

根拠: `install.sh:62-69`

### idempotent hook registration

`add_claude_hook` と `add_codex_hook` は、同じ command が既に対象 event に登録されている場合は追加しない。これにより installer を複数回実行しても同一 hook entry が重複しない。

根拠: `install.sh:74-120`

## Hook 登録

Claude Code には `~/.claude/settings.json`、Codex には `~/.codex/hooks.json` へ同等の hook event 構造を登録する。

`tmux-agent-status.sh` は以下の event に登録される。

- `PreToolUse`: `🔵`
- `UserPromptSubmit`: `🔵`
- `PostToolUse`: `🔵`
- `Notification`: `🔴`
- `Stop`: `✅`

`PreToolUse` / `PostToolUse` にも `🔵` を登録することで、permission/input wait 後に新しい `UserPromptSubmit` が発火しない再開経路でも、次の tool execution に合わせて実行中表示へ戻せる。

根拠: `install.sh:122-149`

## 統合ポイント

- `hooks/auto-approve-readonly.sh`: safe/read-only tool approval
- `hooks/guard-destructive-cmd.sh`: destructive Bash guard
- `hooks/log-access-prompt.sh`, `hooks/log-access-tool.sh`, `hooks/log-access-stop.sh`: access logging
- `hooks/log-token-usage.sh`: token usage logging
- `hooks/cleanup-session.sh`: session approval cleanup
- `hooks/notify-slack.sh`: wait/stop notification
- `hooks/tmux-agent-status.sh`: tmux window status prefix

根拠: `install.sh:122-149`

## 注意事項・既知の制限

Codex hooks は installer が登録しただけでは信頼済みとは限らない。installer は `/hooks` で review/trust するよう案内する。

根拠: `install.sh:148`

## 変更履歴（git log より自動生成）

- 8105003 fix(#173): fix tmux agent status transitions
- 612b51e fix(#154): replace tmux-agent-status emojis for better terminal visibility
- 544e1ad docs: sync documentation
- fa587bc chore: restore notify-slack.sh and register in install.sh
- 0b61b53 feat(#127): enable codex hook installation
- d2aa807 fix(#113): address 10 bugs found by code-review in codex-review command
- 07ae6ac docs: initialize project documentation (init-docs)
- 83374dc feat(#108): add session-based approval to eliminate double-confirmation prompts
- e160237 feat(#104): auto-configure settings.json hook entries in install.sh
- 96e1efd fix(install): drop -h flag from ln when creating symlinks
