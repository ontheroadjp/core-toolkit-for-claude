# install.sh

## 目的・役割

`install.sh` は、対象リポジトリの root で実行する対話式 installer である。Claude Code、Codex CLI、Agy のいずれかを選択し、agent 固有の repository-local assets と必要な global status line を設定する。

根拠: `install.sh:1-170`

## 動作概要

1. `git rev-parse --show-toplevel` と現在ディレクトリを照合し、Git repository root 以外では変更せず失敗する。
2. この toolkit を指す既存の global symlink、global hook registration、Claude/Codex の toolkit 管理 status line だけを除去する。認証情報、履歴、他者の設定は対象外である。
3. Claude を選ぶと `<project>/.claude/`、Codex を選ぶと `<project>/.codex/` に commands、hooks、hooks/lib、scripts、skills、templates の symlink を作る。
4. `jq` がある場合、同じ project-local settings file へ hook registration を冪等に追加する。
5. Claude/Codex は各 native status line setup script を実行する。Agy は `~/.local/bin/agy-rate-status` を `scripts/setup_statusline_for_agy.sh` へ symlink し、`~/.gemini/antigravity-cli/settings.json` の `statusLine` を command として設定する。

根拠: `install.sh:5-170`, `scripts/setup_statusline_for_claude.sh:1-57`, `scripts/setup_statusline_for_codex.sh:1-93`, `scripts/setup_statusline_for_agy.sh:1-28`

## 主要な判定ロジック

`remove_managed_link` は link target が toolkit root 配下である場合だけ global link を削除する。JSON の解除も、過去の global hook command prefix または Claude status-line command が toolkit 由来の既知値である場合だけ行う。Codex の status line は toolkit が設定する4項目を含むものだけを解除する。

`add_hook` は event 内に同じ command があるとき再登録しない。Claude hook command は実行時の `$CLAUDE_PROJECT_DIR` を使用し、Codex hook command は repository root からの `.codex/...` 相対 path を使用する。

根拠: `install.sh:20-140`

## 統合ポイント

- Claude local assets: `<project>/.claude/`
- Codex local assets: `<project>/.codex/`
- Claude global status line: `~/.claude/statusline.sh`, `~/.claude/settings.json`
- Codex global status line: `~/.codex/config.toml`
- Agy global status command: `~/.local/bin/agy-rate-status`
- regression test: `tests/install/test-local-install.sh`

## 検証

```bash
bash tests/install/test-local-install.sh
bash tests/install/test-setup-statusline-for-codex.sh
shellcheck -x install.sh scripts/setup_statusline_for_agy.sh
```
