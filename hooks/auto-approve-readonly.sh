#!/bin/bash
# PreToolUse hook: auto-approve Read tool and read-only Bash commands
set -euo pipefail

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // ""')

# Resolve repo root (handles symlink from ~/.claude/hooks/)
_SCRIPT="${BASH_SOURCE[0]}"
[ -L "$_SCRIPT" ] && _SCRIPT="$(readlink "$_SCRIPT")"
REPO_DIR="$(cd "$(dirname "$_SCRIPT")/.." && pwd)"
LOG_FILE="${REPO_DIR}/logs/auto-approve/$(date '+%Y-%m').log"

log_decision() {
    local result="$1" tool="$2" detail="${3:-}"
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || return 0
    local short
    short=$(printf '%s' "$detail" | tr '\n' ' ' | cut -c1-120)
    printf '[%s] result=%-12s tool=%-10s %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$result" "$tool" "$short" >> "$LOG_FILE" || true
}

# Always approve Read tool
if [ "$tool_name" = "Read" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // "-"')
    log_decision "approved" "Read" "$file_path"
    echo '{"decision": "approve"}'
    exit 0
fi

[ "$tool_name" != "Bash" ] && exit 0

command=$(echo "$payload" | jq -r '.tool_input.command // ""')

# Normalize before write-redirect check and pipe splitting:
#   1. Strip /dev/null redirects (2>/dev/null, >>/dev/null, &>/dev/null, etc.)
#      to avoid false positives from stderr suppression.
#   2. Escape grep-style \| (backslash-pipe) to __ESCAPED_PIPE__ so the pipe
#      splitter below does not fragment grep pattern strings.
command_normalized=$(printf '%s' "$command" \
    | sed 's/\\|/__ESCAPED_PIPE__/g; s/[0-9]*>>\/dev\/null//g; s/[0-9]*>\/dev\/null//g; s/&>>\/dev\/null//g; s/&>\/dev\/null//g')

# Reject if command writes to a file (> but not >&)
if printf '%s' "$command_normalized" | grep -qE '>[^&]'; then
    log_decision "user_prompt" "Bash" "$command"
    exit 0
fi

is_safe_segment() {
    local seg
    seg=$(printf '%s' "$1" | sed 's/^[[:space:]]*//')
    [ -z "$seg" ] && return 0

    # git read-only subcommands
    printf '%s' "$seg" | grep -qE '^git[[:space:]]+(status|log|diff|show|branch|remote|tag|describe|rev-parse|ls-files|ls-tree|cat-file|blame|shortlog|reflog|(stash[[:space:]]+list)|(config[[:space:]]+(--(list|get))?)|(worktree[[:space:]]+list))(\s|$)' && return 0

    # gh read-only subcommands
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+(issue|pr|label|repo|release|run|workflow)[[:space:]]+(list|view|status)(\s|$)' && return 0
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+auth[[:space:]]+status(\s|$)' && return 0
    # gh run rerun — triggers a CI re-run (write operation, but approved by policy)
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+run[[:space:]]+rerun(\s|$)' && return 0

    # Standard read-only Unix tools (prefer fd over find)
    printf '%s' "$seg" | grep -qE '^(ls|ll|la|cat|head|tail|grep|egrep|fgrep|rg|fd|find|wc|sort|uniq|cut|tr|awk|sed|echo|printf|pwd|which|type|env|printenv|du|df|stat|file|basename|dirname|date|uname|hostname|whoami|id|groups|ps|jq|yq|column)(\s|$)' && return 0

    # Runtime version checks
    printf '%s' "$seg" | grep -qE '^(node|npm|npx|python3?|pip3?|ruby|go|cargo|rustc|bash|zsh)[[:space:]]+(--version|-v|version)(\s|$)' && return 0

    # curl — allowed for HTTP requests; blocked when downloading to a file
    if printf '%s' "$seg" | grep -qE '^curl(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|\s)(-o([[:space:]]|$)|--output([[:space:]]|=|$)|-O([[:space:]]|$)|--remote-name([[:space:]]|=|$)|--remote-name-all([[:space:]]|$))' && return 1
        return 0
    fi

    # npm — allowed except install/uninstall operations and global installs
    if printf '%s' "$seg" | grep -qE '^npm(\s|$)'; then
        printf '%s' "$seg" | grep -qE '^npm[[:space:]]+(install|i|ci|uninstall|un|remove|rm|r|link|rebuild)(\s|$)' && return 1
        printf '%s' "$seg" | grep -qE '(-g|--global)(\s|$)' && return 1
        return 0
    fi

    # pytest and python -m pytest
    printf '%s' "$seg" | grep -qE '^pytest(\s|$)' && return 0
    printf '%s' "$seg" | grep -qE '^python3?\s+-m\s+pytest(\s|$)' && return 0

    return 1
}

# Split on &&, ||, ;, | and verify every segment is read-only.
# Uses command_normalized so that \| inside grep patterns (already replaced
# with __ESCAPED_PIPE__) does not create spurious segments.
while IFS= read -r segment; do
    segment=$(printf '%s' "$segment" | sed 's/__ESCAPED_PIPE__/\\|/g')
    if [ -n "$segment" ] && ! is_safe_segment "$segment"; then
        log_decision "user_prompt" "Bash" "$command"
        exit 0
    fi
done < <(printf '%s\n' "$command_normalized" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g')

log_decision "approved" "Bash" "$command"
echo '{"decision": "approve"}'
exit 0
