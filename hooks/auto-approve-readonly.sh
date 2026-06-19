#!/bin/bash
# PreToolUse hook: auto-approve Read tool and read-only Bash commands
set -euo pipefail

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // ""')

# Resolve repo root (handles symlink from ~/.claude/hooks/)
HOOK_INVOKED_PATH="${BASH_SOURCE[0]}"
CODEX_HOOK_INVOCATION=0
case "$HOOK_INVOKED_PATH" in
    */.codex/hooks/*) CODEX_HOOK_INVOCATION=1 ;;
esac

_SCRIPT="$HOOK_INVOKED_PATH"
[ -L "$_SCRIPT" ] && _SCRIPT="$(readlink "$_SCRIPT")"
REPO_DIR="$(cd "$(dirname "$_SCRIPT")/.." && pwd)"
LOG_FILE="${REPO_DIR}/logs/auto-approve/$(date '+%Y-%m').log"

# shellcheck source=hooks/lib/approval-safety.sh
. "${REPO_DIR}/hooks/lib/approval-safety.sh"

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
    if [ -z "$session_id" ] && [ -n "${CODEX_THREAD_ID:-}" ]; then
        session_id="codex-$(hash_session_key "${CODEX_THREAD_ID}")"
    fi
    if [ -z "$session_id" ]; then
        session_id="process-${PPID:-$$}"
    fi
    sanitize_session_id "$session_id"
}

STATE_ROOT="${CLAUDE_CODE_KIT_STATE_HOME:-${XDG_STATE_HOME:-${HOME}/.local/state}/claude-code-kit}"
SESSION_ID="$(resolve_session_id)"
SESSION_ID_IS_FALLBACK=0
case "$SESSION_ID" in process-*) SESSION_ID_IS_FALLBACK=1 ;; esac
SESSION_DIR="${CLAUDE_CODE_KIT_SESSION_DIR:-${STATE_ROOT}/sessions/${SESSION_ID}}"
SESSION_APPROVED_FILE="${CLAUDE_CODE_KIT_SESSION_APPROVED_FILE:-${SESSION_DIR}/session-approved}"
SESSION_TMP_ROOT="${CLAUDE_CODE_KIT_TMP_ROOT:-/tmp/claude-code-kit}"
SESSION_TMP_DIR="${SESSION_TMP_ROOT}/${SESSION_ID}"

is_codex_invocation() {
    [ "$CODEX_HOOK_INVOCATION" = "1" ] ||
        [ -n "${CODEX_MANAGED_BY_NPM:-}" ] ||
        [ -n "${CODEX_MANAGED_BY_BUN:-}" ] ||
        [ -n "${CODEX_CI:-}" ] ||
        [ -n "${CODEX_THREAD_ID:-}" ]
}

AGENT="claude"
is_codex_invocation && AGENT="codex"
LOG_SESSION_ID="$SESSION_ID"
[ "$SESSION_ID_IS_FALLBACK" = "1" ] && LOG_SESSION_ID="n/a"

# Announce the resolved path so Claude can locate it (task.md / patch.md Step 2)
if [ "$SESSION_ID_IS_FALLBACK" = "0" ]; then
    mkdir -p "$STATE_ROOT" 2>/dev/null || true
    printf '%s\n' "$SESSION_APPROVED_FILE" > "${STATE_ROOT}/current-session-approved-path" 2>/dev/null || true
fi

ensure_session_dir() {
    mkdir -p "$SESSION_DIR"
    chmod 700 "$STATE_ROOT" "${STATE_ROOT}/sessions" "$SESSION_DIR" 2>/dev/null || true
}

ensure_session_tmp_dir() {
    [ -L "$SESSION_TMP_ROOT" ] && return 1
    [ -L "$SESSION_TMP_DIR" ] && return 1
    mkdir -p "$SESSION_TMP_DIR" || return 1
    chmod 700 "$SESSION_TMP_DIR" 2>/dev/null || true
    [ -L "$SESSION_TMP_DIR" ] && return 1
    return 0
}

is_session_approved_path() {
    local path="$1"
    local norm_path norm_approved
    norm_path=$(realpath -m "$path" 2>/dev/null || printf '%s' "$path")
    norm_approved=$(realpath -m "$SESSION_APPROVED_FILE" 2>/dev/null || printf '%s' "$SESSION_APPROVED_FILE")
    [ "$norm_path" = "$norm_approved" ]
}

is_session_tmp_file() {
    local path="$1"
    local norm_path norm_tmp
    ensure_session_tmp_dir || return 1
    norm_path=$(realpath -m "$path" 2>/dev/null || printf '%s' "$path")
    norm_tmp=$(realpath -m "$SESSION_TMP_DIR" 2>/dev/null || printf '%s' "$SESSION_TMP_DIR")
    case "$norm_path" in
        "$norm_tmp"/*) return 0 ;;
        *) return 1 ;;
    esac
}

normalize_git_directory_prefix() {
    local seg="$1"
    local git_c_pattern
    git_c_pattern="^git[[:space:]]+-C[[:space:]]+(\"[^\"]*\"|'[^']*'|[^[:space:]]+)[[:space:]]+(.+)$"
    if [[ "$seg" =~ $git_c_pattern ]]; then
        printf 'git %s' "${BASH_REMATCH[2]}"
    else
        printf '%s' "$seg"
    fi
}

has_unsupported_expansion() {
    printf '%s' "$1" | grep -qE '\$\(|`|[<>]\('
}

is_safe_test_expression() {
    local expression="$1"
    has_unsupported_expansion "$expression" && return 1
    printf '%s' "$expression" | grep -qE '[;&|<>]' && return 1
    printf '%s' "$expression" | grep -qE '^(test[[:space:]]+.+|\[[[:space:]].*[[:space:]]\])$'
}

is_safe_git_read_command() {
    local seg
    seg=$(normalize_git_directory_prefix "$1")

    has_unsupported_expansion "$seg" && return 1
    printf '%s' "$seg" | grep -qE '(^|[[:space:]])--output([=[:space:]]|$)' && return 1

    printf '%s' "$seg" | grep -qE '^git[[:space:]]+(status|log|diff|show|describe|rev-parse|ls-files|ls-tree|cat-file|blame|shortlog)([[:space:]]|$)' && return 0
    printf '%s' "$seg" | grep -qE '^git[[:space:]]+stash[[:space:]]+list([[:space:]]|$)' && return 0
    printf '%s' "$seg" | grep -qE '^git[[:space:]]+worktree[[:space:]]+list([[:space:]]|$)' && return 0

    [ "$seg" = "git branch" ] && return 0
    if printf '%s' "$seg" | grep -qE '^git[[:space:]]+branch[[:space:]]+'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-d|-D|-m|-M|-c|-C|--delete|--move|--copy|--edit-description|--set-upstream-to|--unset-upstream)([=[:space:]]|$)' && return 1
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(--list|--show-current|--contains|--no-contains|--merged|--no-merged|-a|-r|-v|-vv)([=[:space:]]|$)' && return 0
        return 1
    fi

    printf '%s' "$seg" | grep -qE '^git[[:space:]]+remote([[:space:]]+-v)?[[:space:]]*$' && return 0
    printf '%s' "$seg" | grep -qE '^git[[:space:]]+remote[[:space:]]+(show|get-url)([[:space:]]|$)' && return 0

    [ "$seg" = "git tag" ] && return 0
    if printf '%s' "$seg" | grep -qE '^git[[:space:]]+tag[[:space:]]+'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-d|-a|-s|-u|-m|-F|-f|--delete|--annotate|--sign|--local-user|--message|--file|--force)([=[:space:]]|$)' && return 1
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-l|-n|-v|--list|--contains|--no-contains|--points-at|--merged|--no-merged)([=[:space:]]|$)' && return 0
        return 1
    fi

    [ "$seg" = "git reflog" ] && return 0
    printf '%s' "$seg" | grep -qE '^git[[:space:]]+reflog[[:space:]]+(show|exists)([[:space:]]|$)' && return 0

    printf '%s' "$seg" | grep -qE '^git[[:space:]]+config[[:space:]]+(-l|--list|--get|--get-all|--get-regexp|--get-urlmatch)([=[:space:]]|$)' && return 0

    return 1
}

split_shell_segments() {
    local input="$1" current="" quote="" char next
    local escaped=0 i
    for ((i = 0; i < ${#input}; i++)); do
        char="${input:i:1}"
        next="${input:i+1:1}"

        if [ "$quote" = "'" ]; then
            current+="$char"
            [ "$char" = "'" ] && quote=""
            continue
        fi
        if [ "$escaped" = "1" ]; then
            current+="$char"
            escaped=0
            continue
        fi
        if [ "$char" = "\\" ]; then
            current+="$char"
            escaped=1
            continue
        fi
        if [ "$quote" = '"' ]; then
            current+="$char"
            [ "$char" = '"' ] && quote=""
            continue
        fi
        if [ "$char" = "'" ] || [ "$char" = '"' ]; then
            quote="$char"
            current+="$char"
            continue
        fi

        case "$char" in
            $'\n'|';'|'|')
                printf '%s\n' "$current"
                current=""
                [ "$next" = "$char" ] && i=$((i + 1))
                ;;
            '&')
                if [ "$next" = '&' ]; then
                    printf '%s\n' "$current"
                    current=""
                    i=$((i + 1))
                else
                    printf '%s\n' "$current"
                    printf '%s\n' '__UNSUPPORTED_BACKGROUND_OPERATOR__'
                    current=""
                fi
                ;;
            *) current+="$char" ;;
        esac
    done
    printf '%s\n' "$current"
}

log_decision() {
    local result="$1" tool="$2" detail="${3:-}"
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || return 0
    local short
    short=$(printf '%s' "$detail" | tr '\n' ' ' | cut -c1-120)
    printf '[%s] agent=%s session=%s result=%-12s tool=%-10s %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$AGENT" "$LOG_SESSION_ID" \
        "$result" "$tool" "$short" >> "$LOG_FILE" || true
}

emit_approval() {
    if is_codex_invocation; then
        echo '{"decision": "allow"}'
    else
        echo '{"decision": "approve"}'
    fi
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
    local seg
    seg=$(normalize_git_directory_prefix "$1")
    [ -f "$SESSION_APPROVED_FILE" ] || return 1
    while IFS= read -r category; do
        case "$category" in
            ''|\#*) continue ;;
            tool:git_write)
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+add(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+commit(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+merge(\s|$)' && return 0
                printf '%s' "$seg" | grep -qE '^git[[:space:]]+fetch(\s|$)' && return 0
                if printf '%s' "$seg" | grep -qE '^git[[:space:]]+pull(\s|$)'; then
                    if printf '%s' "$seg" | grep -qE '(^|[[:space:]])--ff-only([[:space:]]|$)' \
                        && ! printf '%s' "$seg" | grep -qE '(^|[[:space:]])(--no-ff|--rebase|-r|--force|-f)([=[:space:]]|$)'; then
                        return 0
                    fi
                fi
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
                printf '%s' "$seg" | grep -qE '^gh[[:space:]]+pr[[:space:]]+(create|edit|close|comment|reopen|ready|review|checkout|merge)(\s|$)' && return 0
                ;;
        esac
    done < "$SESSION_APPROVED_FILE"
    return 1
}

# Always approve Read tool
if [ "$tool_name" = "Read" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // "-"')
    log_decision "approved" "Read" "$file_path"
    emit_approval
    exit 0
fi

# Write tool: guard session file against scope expansion; approve other paths if session-listed
if [ "$tool_name" = "Write" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // ""')
    if is_session_tmp_file "$file_path"; then
        log_decision "approved" "Write" "$file_path (session-tmp)"
        emit_approval
        exit 0
    fi
    if is_session_approved_path "$file_path"; then
        ensure_session_dir
        # Initial write (file absent) - approve
        if [ ! -f "$SESSION_APPROVED_FILE" ]; then
            log_decision "approved" "Write" "$file_path (session-file initial)"
            emit_approval
            exit 0
        fi
        new_content=$(echo "$payload" | jq -r '.tool_input.content // ""')
        existing_content=$(cat "$SESSION_APPROVED_FILE")
        # Identical content - approve (idempotent)
        if [ "$new_content" = "$existing_content" ]; then
            log_decision "approved" "Write" "$file_path (session-file idempotent)"
            emit_approval
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
        # New content is narrower than or equal to existing - approve
        log_decision "approved" "Write" "$file_path (session-file narrower)"
        emit_approval
        exit 0
    fi
    if [ "$SESSION_ID_IS_FALLBACK" = "0" ] && is_session_approved_file "$file_path"; then
        log_decision "approved" "Write" "$file_path (session)"
        emit_approval
        exit 0
    fi
    log_decision "user_prompt" "Write" "$file_path"
    exit 0
fi

# Edit tool: approve if the path is session-listed
if [ "$tool_name" = "Edit" ]; then
    file_path=$(echo "$payload" | jq -r '.tool_input.file_path // ""')
    if is_session_tmp_file "$file_path"; then
        log_decision "approved" "Edit" "$file_path (session-tmp)"
        emit_approval
        exit 0
    fi
    if [ "$SESSION_ID_IS_FALLBACK" = "0" ] && is_session_approved_file "$file_path"; then
        log_decision "approved" "Edit" "$file_path (session)"
        emit_approval
        exit 0
    fi
    log_decision "user_prompt" "Edit" "$file_path"
    exit 0
fi

if [ "$tool_name" != "Bash" ]; then
    log_decision "user_prompt" "${tool_name:-unknown}" ""
    exit 0
fi

command=$(echo "$payload" | jq -r '.tool_input.command // ""')

if destructive_reason=$(approval_safety_destructive_reason "$command"); then
    log_decision "blocked" "Bash" "$command ($destructive_reason)"
    approval_safety_emit_block "$destructive_reason"
    exit 0
fi

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
    local seg condition
    seg=$(printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -z "$seg" ] && return 0

    has_unsupported_expansion "$seg" && return 1

    case "$seg" in
        then|else|fi) return 0 ;;
        then[[:space:]]*) is_safe_segment "${seg#then}" && return 0; return 1 ;;
        else[[:space:]]*) is_safe_segment "${seg#else}" && return 0; return 1 ;;
    esac
    case "$seg" in
        if[[:space:]]*)
            condition="${seg#if}"
            condition=$(printf '%s' "$condition" | sed 's/^[[:space:]]*//')
            is_safe_test_expression "$condition" && return 0
            return 1
            ;;
    esac
    is_safe_test_expression "$seg" && return 0

    # tee writes to files — block unconditionally regardless of future allowlist additions
    printf '%s' "$seg" | grep -qE '^tee(\s|$)' && return 1

    # git read-only subcommands
    is_safe_git_read_command "$seg" && return 0

    # gh read-only subcommands
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+(issue|pr|label|repo|release|run|workflow)[[:space:]]+(list|view|status)(\s|$)' && return 0
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+pr[[:space:]]+checks(\s|$)' && return 0
    printf '%s' "$seg" | grep -qE '^gh[[:space:]]+auth[[:space:]]+status(\s|$)' && return 0
    # Standard read-only Unix tools (prefer fd over find)
    printf '%s' "$seg" | grep -qE '^cd(\s|$)' && return 0
    printf '%s' "$seg" | grep -qE '^(ls|ll|la|cat|head|tail|grep|egrep|fgrep|rg|fd|wc|uniq|cut|tr|echo|printf|pwd|which|type|printenv|du|df|stat|file|basename|dirname|uname|whoami|id|groups|ps|jq|column|nl)(\s|$)' && return 0
    if printf '%s' "$seg" | grep -qE '^find(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])-(delete|exec|execdir|ok|okdir|fls|fprint|fprintf)([[:space:]]|$)' && return 1
        return 0
    fi
    if printf '%s' "$seg" | grep -qE '^sed(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-i|--in-place)([^[:space:]]*|$)' && return 1
        return 0
    fi
    if printf '%s' "$seg" | grep -qE '^sort(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-o|--output)([=[:space:]]|$)' && return 1
        return 0
    fi
    if printf '%s' "$seg" | grep -qE '^yq(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-i|--inplace)([=[:space:]]|$)' && return 1
        return 0
    fi
    if printf '%s' "$seg" | grep -qE '^awk(\s|$)'; then
        printf '%s' "$seg" | grep -qE 'system[[:space:]]*\(' && return 1
        return 0
    fi
    printf '%s' "$seg" | grep -qE '^env[[:space:]]*$' && return 0
    if printf '%s' "$seg" | grep -qE '^date(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-s|--set)([=[:space:]]|$)' && return 1
        return 0
    fi
    printf '%s' "$seg" | grep -qE '^hostname[[:space:]]*$' && return 0

    # Runtime version checks
    printf '%s' "$seg" | grep -qE '^(node|npm|npx|python3?|pip3?|ruby|go|cargo|rustc|bash|zsh)[[:space:]]+(--version|-v|version)(\s|$)' && return 0

    # curl — allow default GET/HEAD requests only; reject writes and custom methods
    if printf '%s' "$seg" | grep -qE '^curl(\s|$)'; then
        printf '%s' "$seg" | grep -qE '(^|[[:space:]])(-o[^[:space:]]*|-O|-X[^[:space:]]*|-d[^[:space:]]*|-F[^[:space:]]*|-T[^[:space:]]*|-K[^[:space:]]*|--output|--remote-name|--remote-name-all|--request|--data[^[:space:]]*|--form[^[:space:]]*|--upload-file|--json|--config)([=[:space:]]|$)' && return 1
        return 0
    fi

    # npm — allow metadata inspection only; scripts and package mutations require a prompt
    if printf '%s' "$seg" | grep -qE '^npm(\s|$)'; then
        printf '%s' "$seg" | grep -qE '^npm[[:space:]]+(view|info|show|search|list|ls|outdated|explain|why|prefix|root|help)([[:space:]]|$)' && return 0
        printf '%s' "$seg" | grep -qE '^npm[[:space:]]+config[[:space:]]+(get|list|ls)([[:space:]]|$)' && return 0
        printf '%s' "$seg" | grep -qE '^npm[[:space:]]+run[[:space:]]*$' && return 0
        return 1
    fi

    [ "$SESSION_ID_IS_FALLBACK" = "0" ] && check_session_approved "$seg" && return 0

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
done < <(split_shell_segments "$command_normalized")

log_decision "approved" "Bash" "$command"
emit_approval
exit 0
