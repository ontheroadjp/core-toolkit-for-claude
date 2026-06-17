#!/bin/bash
# PreToolUse hook: auto-approve Read tool and read-only Bash commands
set -euo pipefail

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // ""')

# Always approve Read tool
if [ "$tool_name" = "Read" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

[ "$tool_name" != "Bash" ] && exit 0

command=$(echo "$payload" | jq -r '.tool_input.command // ""')

# Reject if command writes to a file (> but not >&)
if echo "$command" | grep -qE '>[^&]'; then
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

# Split on &&, ||, ;, | and verify every segment is read-only
while IFS= read -r segment; do
    if [ -n "$segment" ] && ! is_safe_segment "$segment"; then
        exit 0  # at least one segment is not read-only — let normal permission flow handle it
    fi
done < <(printf '%s\n' "$command" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g')

echo '{"decision": "approve"}'
exit 0
