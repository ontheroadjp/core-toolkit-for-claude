# scripts/

Claude Code のステータス表示とトークン使用量確認のためのユーティリティスクリプトを置くディレクトリ。

## ファイル一覧

| ファイル | 用途 |
|---|---|
| `statusline.sh` | Claude Code のステータスライン表示スクリプト |
| `show-token-usage.sh` | ローカルに蓄積したトークン使用ログの集計・表示スクリプト |

## statusline.sh

Claude Code の statusLine として動作する。stdin に JSON（context window・rate limit 情報）を受け取り、
フォーマットして表示する。

表示項目:
- コンテキスト使用率（%）
- 5時間レートリミットの残量
- 7日レートリミットの残量

**セットアップ**: `setup_statusline.sh` を実行する。`scripts/statusline.sh` を `~/.claude/statusline.sh` に symlink し、`~/.claude/settings.json` に `statusLine` 設定を追加する。

```bash
./setup_statusline.sh
```

## show-token-usage.sh

`hooks/log-token-usage.sh` が `~/.claude/token-usage.log` に記録したデータを集計・表示する。

```
Usage: show-token-usage.sh [-n <count>] [-a|--all] [MODE]

Modes:
  (default)  セッション一覧
  --sum      集計合計・平均・コスト
  --model    モデル別コスト内訳
  --cost     日別コストタイムライン
  --project  プロジェクト別コストランキング
  --time     時間帯別使用ヒートマップ
  --anomaly  低キャッシュ・高トークン密度セッションの検出
```

```bash
# 直近 20 件を表示
bash scripts/show-token-usage.sh

# 全件を集計表示
bash scripts/show-token-usage.sh --all --sum
```
