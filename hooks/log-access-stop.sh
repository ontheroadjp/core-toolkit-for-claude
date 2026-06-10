#!/bin/bash
# Stop: write formatted access log entry if /work was invoked this session

payload=$(cat)
session_id=$(echo "$payload" | jq -r '.session_id // empty')

[ -z "$session_id" ] && exit 0

SESSION_DIR="/tmp/claude-access-sessions"
STATE_FILE="${SESSION_DIR}/${session_id}.json"

[ ! -f "$STATE_FILE" ] && exit 0

state=$(cat "$STATE_FILE")
start_time=$(echo "$state"       | jq -r '.start_time')
user_instruction=$(echo "$state" | jq -r '.user_instruction')
total=$(echo "$state"            | jq '.accesses | length')
modified_files=$(echo "$state"   | jq -r '.modified_files[]' 2>/dev/null || true)

LOG_DIR="${HOME}/dev/src/github.com/ontheroadjp/claude-code-kit/logs/$(date '+%Y-%m')"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/access.log"

format_modified() {
  if [ -n "$modified_files" ]; then
    echo "$modified_files" | while IFS= read -r f; do echo "  - $f"; done
  fi
}

# Build duplicate summary: files accessed more than once
duplicates=$(echo "$state" | jq -r '
  .accesses
  | group_by(.path)
  | map(select(length > 1) | {path: .[0].path, count: length})
  | sort_by(-.count)[]
  | "  - \(.path) (\(.count)回)"
')

# Build per-phase access sequence (in order of first appearance)
phases=$(echo "$state" | jq -r '
  [.accesses[].phase]
  | reduce .[] as $p ([]; if (. | contains([$p])) then . else . + [$p] end)
  | .[]
')

{
  printf '\n---\n\n'
  printf '[日時]\n%s\n\n' "$start_time"
  printf '[ユーザーからの指示内容]\n%s\n\n' "$user_instruction"
  printf '[アクセスサマリ]\n総アクセス数: %d\n' "$total"

  if [ -n "$duplicates" ]; then
    printf '重複アクセス:\n%s\n' "$duplicates"
  else
    printf '重複アクセス: なし\n'
  fi
  printf '\n'

  printf '[フェーズ別アクセス順序]\n'
  while IFS= read -r phase; do
    phase_count=$(echo "$state" | jq --arg p "$phase" '[.accesses[] | select(.phase==$p)] | length')
    printf '[%s] %d件\n' "$phase" "$phase_count"
    echo "$state" | jq -r --arg p "$phase" '
      .accesses[] | select(.phase==$p) |
      "  #\(.seq)  \(.tool)  \(.path)"
    '
    printf '\n'
  done <<< "$phases"

  printf '[修正したファイル]\n'
  format_modified
  printf '\n'
} >> "$LOG_FILE"

rm -f "$STATE_FILE" "${SESSION_DIR}/${session_id}.prompt"
