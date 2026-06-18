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
SESSION_APPROVED_FILE="${HOME}/.claude/session-approved"

log_decision() {
    local result="$1" tool="$2" detail="${3:-}"
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || return 0
    local short
    short=$(printf '%s' "$detail" | tr '\n' ' ' | cut -c1-120)
    printf '[%s] result=%-12s tool=%-10s %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$result" "$tool" "$short" >> "$LOG_FILE" || true
}

is_session_approved_file() {
    local path="$1"
    [ -f "$SESSION_APPROVED_FILE" ] || return 1
    while IFS= read -r line; do
        case "$line" in
            ''|\#*) continue ;;
            file:*)
                local approved="${line#file:}"
                local norm_path norm_approved
                norm_path=$(realpath -m "$path" 2>/dev/null || printf '%s' "$path")
                norm_approved=$(realpath -m "$approved" 2>/dev/null || printf '%s' "$approved")
                [ "$norm_path" = "$norm_approved" ] && return 0
                ;;
        esac
    done < "$SESSION_APPROVED_FILE"
    return 1
}

check_session_approved() {
    local seg="$1"
    [ -f "$SESSION_APPROVED_FILE" ] || return 1
    while IFS= read -r category; do
        case "$category" in
            ''|\#*) continue ;;
            tool:git_write)
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+add(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+commit(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+merge(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+stash([[:space:]]+(push|pop|apply)(\s|$)|[[:space:]]*$)' && return 0
                if printf '%s' "$seg" | grep -qE '^git[[:space:]]+push(\s|$)'; then
                    printf '%s' "$seg" | grep -qE '(--force|-f[[:space:]]|-f$|--force-with-lease)' || return 0
                fi
                if printf '%s' "$seg" | grep -qE '^git[[:space:]]+(checkout|switch)(\s|$)'; then
                    if ! printf '%s' "$seg" | grep -qE '([[:space:]]--([[:space:]]|$)|^git[[:space:]]+(checkout|switch)[[:space:]]+\.)'; then
                        return 0
                    fi
                fi
                if printf '%s' "$seg" | grep -qE '^git[[:space:]]+branch(\s|$)'; then
                    printf '%s' "$seg" | grep -qE '[[:space:]]-D([[:space:]]|$)' || return 0
                fi
                ;;
            tool:gh_issue_write)
                printf '%s' "$seg" | grep -qE '^gh[[:space:]]+issue[[:space:]]+(create|edit|close|delete|comment|reopen)(\s|$)' && return 0
                ;;
            tool:gh_pr_write)
                printf '%s' "$seg" | grep -qE '^gh[[:space:]]+pr[[:space:]]+(create|edit|close|comment|reopen|ready|review|checkout)(\s|$)' && return 0
                ;;
        esac
    done < "$SESSION_APPROVED_FILE"
    return 1
}

# Always approve Read tool
if [ "$tool_name" = "Read" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // "-"')
    log_decision "approved" "Read" "$file_path"
    echo '{"decision": "approve"}'
    exit 0
fi

# Write tool: guard session file against scope expansion; approve other paths if session-listed
if [ "$tool_name" = "Write" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // ""')
    if [ "$file_path" = "$SESSION_APPROVED_FILE" ]; then
        # Initial write (file absent) — approve
        if [ ! -f "$SESSION_APPROVED_FILE" ]; then
            log_decision "approved" "Write" "$file_path (session-file initial)"
            echo '{"decision": "approve"}'
            exit 0
        fi
        new_content=$(echo "$payload" | jq -r '.tool_input.content // ""')
        existing_content=$(cat "$SESSION_APPROVED_FILE")
        # Identical content — approve (idempotent)
        if [ "$new_content" = "$existing_content" ]; then
            log_decision "approved" "Write" "$file_path (session-file idempotent)"
            echo '{"decision": "approve"}'
            exit 0
        fi
        # Detect scope expansion: any non-comment line in new content absent from existing
        expanded=""
        while IFS= read -r line; do
            case "$line" in ''|\#*) continue ;; esac
            grep -qxF "$line" "$SESSION_APPROVED_FILE" 2>/dev/null || expanded="${expanded}+ ${line}\n"
        done <<< "$new_content"
        if [ -n "$expanded" ]; then
            reason=$(printf 'session-approved scope expansion blocked.\nNew entries not presented to user in Step 2:\n%b\nTo grant additional permissions, return to Step 2 and obtain user approval.' "$expanded")
            log_decision "blocked" "Write" "$file_path (scope expansion: $expanded)"
            printf '%s' "$reason" | jq -Rs '{"decision": "block", "reason": .}'
            exit 0
        fi
        # New content is narrower than or equal to existing — approve
        log_decision "approved" "Write" "$file_path (session-file narrower)"
        echo '{"decision": "approve"}'
        exit 0
    fi
    if is_session_approved_file "$file_path"; then
        log_decision "approved" "Write" "$file_path (session)"
        echo '{"decision": "approve"}'
        exit 0
    fi
    exit 0
fi

# Edit tool: approve if the path is session-listed
if [ "$tool_name" = "Edit" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // ""')
    if is_session_approved_file "$file_path"; then
        log_decision "approved" "Edit" "$file_path (session)"
        echo '{"decision": "approve"}'
        exit 0
    fi
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

    # tee writes to files — block unconditionally regardless of future allowlist additions
    printf '%s' "$seg" | grep -qE '^tee(\s|$)' && return 1

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

    check_session_approved "$seg" && return 0

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
