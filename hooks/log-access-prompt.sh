#!/bin/bash
# UserPromptSubmit: save latest prompt for session correlation

payload=$(cat)
session_id=$(echo "$payload" | jq -r '.session_id // empty')
prompt=$(echo "$payload" | jq -r '.prompt // ""')

[ -z "$session_id" ] && exit 0

mkdir -p "/tmp/claude-access-sessions"
printf '%s' "$prompt" > "/tmp/claude-access-sessions/${session_id}.prompt"
