#!/usr/bin/env bash
# Hook helper: set a status emoji prefix on the current tmux window title.
# Usage: tmux-agent-status.sh <emoji>
# Called by Claude Code hooks (UserPromptSubmit / Notification / Stop).
# Silently exits when not running inside tmux.

set -euo pipefail

EMOJI="${1:-}"
[[ -z "$EMOJI" ]] && exit 0
[[ -z "${TMUX:-}" ]] && exit 0

CURRENT=$(tmux display-message -p '#W' 2>/dev/null) || exit 0

# Strip any existing status prefix (one of our known emojis followed by a space)
CLEAN="$CURRENT"
for prefix in "⚪ " "🔵 " "🟠 "; do
    if [[ "$CURRENT" == "${prefix}"* ]]; then
        CLEAN="${CURRENT#"${prefix}"}"
        break
    fi
done

tmux rename-window "${EMOJI} ${CLEAN}"
exit 0
