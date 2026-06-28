# scripts/README.md — L3 per-file doc

## 目的・役割

`scripts/` ディレクトリの目的・各スクリプトの機能と使い方を説明するドキュメント。

## 動作の概要

- `statusline.sh`: stdin JSON からコンテキスト使用率とレートリミット情報を抽出して表示
- `show-token-usage.sh`: `~/.claude/token-usage.log` を集計し、複数の表示モードで可視化

## 重要な設計判断

- `statusline.sh` は `setup_statusline.sh` 経由でセットアップする（直接編集不要）
- `show-token-usage.sh` のデータソースは `hooks/log-token-usage.sh` が生成するログファイルに依存

## 統合ポイント

- `statusline.sh` セットアップ: `setup_statusline.sh`（symlink + settings 登録）
- `show-token-usage.sh` データソース: `hooks/log-token-usage.sh`（Stop hook）→ `~/.claude/token-usage.log`

根拠: `scripts/README.md:1-45`, `setup_statusline.sh:6-55`, `scripts/statusline.sh:10-83`

## 変更履歴（git log より自動生成）

- 3656e6e docs(#175): add README.md to each module directory
