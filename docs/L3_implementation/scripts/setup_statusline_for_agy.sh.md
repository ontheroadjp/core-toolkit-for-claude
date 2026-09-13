# setup_statusline_for_agy.sh

`scripts/setup_statusline_for_agy.sh` は Agy status line 用の renderer である。`~/.cache/agy/rate_limit.json` から five-hour と weekly の残量・reset time を読み、情報または `jq` が利用できないときは placeholder を表示する。

`install.sh` の Agy 選択時に `~/.local/bin/agy-rate-status` へ symlink され、`~/.gemini/antigravity-cli/settings.json` の `statusLine` command として登録される。その他の Agy settings は保持する。

根拠: `scripts/setup_statusline_for_agy.sh:1-28`, `install.sh:160-170`
