#!/bin/bash
# UserPromptSubmit: save latest prompt for session correlation

payload=$(cat)
session_id=$(echo "$payload" | jq -r '.session_id // empty')
prompt=$(echo "$payload" | jq -r '.prompt // ""')

[ -z "$session_id" ] && exit 0

SESSION_DIR="/tmp/claude-access-sessions"
mkdir -p "$SESSION_DIR"
printf '%s' "$prompt" > "${SESSION_DIR}/${session_id}.prompt"

STATE_FILE="${SESSION_DIR}/${session_id}.json"
if [ ! -f "$STATE_FILE" ]; then
  timestamp=$(date '+%Y.%m.%d %H.%M')
  jq -n \
    --arg t "$timestamp" \
    --arg p "$prompt" \
    '{start_time:$t, user_instruction:$p, current_phase:"work",
      seq:0, accesses:[], modified_files:[]}' \
    > "$STATE_FILE"
fi
