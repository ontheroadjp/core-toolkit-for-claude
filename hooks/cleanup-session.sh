#!/bin/bash
# Stop hook: delete session approval file at the end of each Claude session
set -euo pipefail

SESSION_APPROVED_FILE="${HOME}/.claude/session-approved"
[ -f "$SESSION_APPROVED_FILE" ] && rm -f "$SESSION_APPROVED_FILE"
exit 0
