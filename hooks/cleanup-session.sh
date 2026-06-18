#!/bin/bash
# Stop hook: delete the current AI session approval file
set -euo pipefail

payload=$(cat)

sanitize_session_id() {
    printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_'
}

hash_session_key() {
    local key="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$key" | sha256sum | cut -c1-16
    else
        printf '%s' "$key" | cksum | awk '{print $1}'
    fi
}

resolve_session_id() {
    local session_id transcript_path
    session_id="${CLAUDE_CODE_KIT_SESSION_ID:-}"
    if [ -z "$session_id" ]; then
        session_id=$(echo "$payload" | jq -r '.session_id // empty')
    fi
    if [ -z "$session_id" ]; then
        transcript_path=$(echo "$payload" | jq -r '.transcript_path // empty')
        [ -n "$transcript_path" ] && session_id="transcript-$(hash_session_key "$transcript_path")"
    fi
    if [ -z "$session_id" ]; then
        session_id="process-${PPID:-$$}"
    fi
    sanitize_session_id "$session_id"
}

STATE_ROOT="${CLAUDE_CODE_KIT_STATE_HOME:-${XDG_STATE_HOME:-${HOME}/.local/state}/claude-code-kit}"
SESSION_ID="$(resolve_session_id)"
SESSION_DIR="${CLAUDE_CODE_KIT_SESSION_DIR:-${STATE_ROOT}/sessions/${SESSION_ID}}"
SESSION_APPROVED_FILE="${CLAUDE_CODE_KIT_SESSION_APPROVED_FILE:-${SESSION_DIR}/session-approved}"

[ -f "$SESSION_APPROVED_FILE" ] && rm -f "$SESSION_APPROVED_FILE"
case "$SESSION_DIR" in
    "$STATE_ROOT"/sessions/*) rmdir "$SESSION_DIR" 2>/dev/null || true ;;
esac
exit 0
