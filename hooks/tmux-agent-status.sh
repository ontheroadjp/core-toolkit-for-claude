#!/usr/bin/env bash
# Hook helper: set a status emoji prefix on the current tmux window title.
# Usage: tmux-agent-status.sh <emoji>
# Called by Claude Code / Codex hooks.
# Silently exits when not running inside tmux.

set -euo pipefail

EMOJI="${1:-}"
[[ -z "${TMUX:-}" ]] && exit 0

TARGET=()
if [[ -n "${TMUX_PANE:-}" ]]; then
    TARGET=(-t "$TMUX_PANE")
fi

CURRENT=$(tmux display-message "${TARGET[@]}" -p '#W' 2>/dev/null) || exit 0

CLEAN="$CURRENT"
while :; do
    PREVIOUS="$CLEAN"
    case "$CLEAN" in
        "✅ "*) CLEAN="${CLEAN#"✅ "}" ;;
        "🔵 "*) CLEAN="${CLEAN#"🔵 "}" ;;
        "🔴 "*) CLEAN="${CLEAN#"🔴 "}" ;;
    esac
    [[ "$CLEAN" == "$PREVIOUS" ]] && break
done

if [[ -z "$EMOJI" ]]; then
    tmux rename-window "${TARGET[@]}" "${CLEAN}" >/dev/null 2>&1 || exit 0
else
    tmux rename-window "${TARGET[@]}" "${EMOJI} ${CLEAN}" >/dev/null 2>&1 || exit 0
fi
exit 0
