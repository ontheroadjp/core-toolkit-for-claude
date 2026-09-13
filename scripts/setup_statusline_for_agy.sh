#!/usr/bin/env bash
set -euo pipefail
# agy のレートリミット情報を取得して整形するスクリプト

STATUS_FILE="$HOME/.cache/agy/rate_limit.json"
# Claude Code / 外部キャッシュ等のパス（環境に合わせて調整）
# STATUS_FILE="$HOME/.claude/rate_limits.json"

if [ -f "$STATUS_FILE" ] && command -v jq >/dev/null 2>&1; then
    # 5h リミット情報の抽出
    FIVE_PCT=$(jq -r '.five_hour.remaining_pct // .five_hour.remaining // empty' "$STATUS_FILE")
    FIVE_RESET=$(jq -r '.five_hour.resets_at // .five_hour.reset_time // empty' "$STATUS_FILE")

    # Weekly リミット情報の抽出
    WEEK_PCT=$(jq -r '.weekly.remaining_pct // .weekly.remaining // empty' "$STATUS_FILE")
    WEEK_RESET=$(jq -r '.weekly.resets_at // .weekly.reset_time // empty' "$STATUS_FILE")

    # 取得できた場合のフォーマット
    if [ -n "$FIVE_PCT" ] && [ -n "$WEEK_PCT" ]; then
        echo "5h: ${FIVE_PCT}% (${FIVE_RESET}) | W: ${WEEK_PCT}% (${WEEK_RESET})"
        exit 0
    fi
fi

# APIやCLI経由で直接取得・パースする場合のフォールバック例
# 取得不可または初期状態
echo "5h: --% | W: --%"
