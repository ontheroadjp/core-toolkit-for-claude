#!/bin/bash
# PreToolUse compatibility wrapper for Bash destructive command blocking.
set -euo pipefail

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // ""')

[ "$tool_name" != "Bash" ] && exit 0

_SCRIPT="${BASH_SOURCE[0]}"
[ -L "$_SCRIPT" ] && _SCRIPT="$(readlink "$_SCRIPT")"
REPO_DIR="$(cd "$(dirname "$_SCRIPT")/.." && pwd)"

# shellcheck source=hooks/lib/approval-safety.sh
. "${REPO_DIR}/hooks/lib/approval-safety.sh"

command=$(echo "$payload" | jq -r '.tool_input.command // ""')

if destructive_reason=$(approval_safety_destructive_reason "$command"); then
    approval_safety_emit_block "$destructive_reason"
    exit 0
fi

exit 0
