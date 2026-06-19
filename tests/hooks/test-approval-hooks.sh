#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD_HOOK="${REPO_DIR}/hooks/guard-destructive-cmd.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TEST_REPO_DIR="${TMP_DIR}/repo"
mkdir -p "${TEST_REPO_DIR}/hooks/lib"
cp "${REPO_DIR}/hooks/auto-approve-readonly.sh" "${TEST_REPO_DIR}/hooks/auto-approve-readonly.sh"
cp "${REPO_DIR}/hooks/lib/approval-safety.sh" "${TEST_REPO_DIR}/hooks/lib/approval-safety.sh"
AUTO_HOOK="${TEST_REPO_DIR}/hooks/auto-approve-readonly.sh"
LOG_FILE="${TEST_REPO_DIR}/logs/auto-approve/$(date '+%Y-%m').log"
SESSION_FILE="${TMP_DIR}/session-approved"

run_auto() {
    local command="$1"
    printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${command}\"}}" \
        | env -u CODEX_MANAGED_BY_NPM -u CODEX_MANAGED_BY_BUN -u CODEX_CI -u CODEX_THREAD_ID \
            CLAUDE_CODE_KIT_STATE_HOME="$TMP_DIR/state" \
            CLAUDE_CODE_KIT_SESSION_ID="test-session-fixed" \
            CLAUDE_CODE_KIT_SESSION_APPROVED_FILE="$SESSION_FILE" \
            bash "$AUTO_HOOK"
}

run_auto_codex_symlink() {
    local command="$1"
    local codex_hook_dir="${TMP_DIR}/.codex/hooks"
    local codex_hook="${codex_hook_dir}/auto-approve-readonly.sh"
    mkdir -p "$codex_hook_dir"
    ln -sf "$AUTO_HOOK" "$codex_hook"
    printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${command}\"}}" \
        | CLAUDE_CODE_KIT_STATE_HOME="$TMP_DIR/state" \
            CLAUDE_CODE_KIT_SESSION_ID="test-session-fixed" \
            CLAUDE_CODE_KIT_SESSION_APPROVED_FILE="$SESSION_FILE" \
            bash "$codex_hook"
}

run_auto_without_session() {
    local command="$1"
    printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${command}\"}}" \
        | env -u CLAUDE_CODE_KIT_SESSION_ID \
            -u CODEX_MANAGED_BY_NPM -u CODEX_MANAGED_BY_BUN -u CODEX_CI -u CODEX_THREAD_ID \
            CLAUDE_CODE_KIT_STATE_HOME="$TMP_DIR/state" \
            bash "$AUTO_HOOK"
}

run_guard() {
    local command="$1"
    printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${command}\"}}" \
        | bash "$GUARD_HOOK"
}

assert_json_decision() {
    local output="$1" expected="$2"
    local actual
    actual=$(printf '%s' "$output" | jq -r '.decision')
    if [ "$actual" != "$expected" ]; then
        printf 'Expected decision=%s, got decision=%s\nOutput: %s\n' "$expected" "$actual" "$output" >&2
        exit 1
    fi
}

assert_no_output() {
    local output="$1"
    if [ -n "$output" ]; then
        printf 'Expected no output, got: %s\n' "$output" >&2
        exit 1
    fi
}

assert_log_matches() {
    local pattern="$1"
    local line
    line=$(tail -n 1 "$LOG_FILE")
    if ! printf '%s' "$line" | grep -qE "$pattern"; then
        printf 'Log line did not match pattern %s\nLine: %s\n' "$pattern" "$line" >&2
        exit 1
    fi
}

output=$(run_auto 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_auto 'rm -fr /usr')
assert_json_decision "$output" "block"

mkdir -p "$(dirname "$SESSION_FILE")"
printf '%s\n' 'tool:git_write' > "$SESSION_FILE"
output=$(run_auto 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_auto 'git status --porcelain')
assert_json_decision "$output" "approve"
assert_log_matches '] agent=claude session=test-session-fixed result=approved[[:space:]]+tool=Bash[[:space:]]+git status --porcelain$'

output=$(run_auto_codex_symlink 'git status --porcelain')
assert_json_decision "$output" "allow"
assert_log_matches '] agent=codex session=test-session-fixed result=approved[[:space:]]+tool=Bash[[:space:]]+git status --porcelain$'

output=$(run_auto_without_session 'git status --porcelain')
assert_json_decision "$output" "approve"
assert_log_matches '] agent=claude session=n/a result=approved[[:space:]]+tool=Bash[[:space:]]+git status --porcelain$'

output=$(run_auto 'git add hooks/auto-approve-readonly.sh')
assert_json_decision "$output" "approve"

output=$(run_auto 'gh run rerun 12345')
assert_no_output "$output"

output=$(run_auto 'some-unknown-command --flag')
assert_no_output "$output"

output=$(run_guard 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_guard 'git status --porcelain')
assert_no_output "$output"

printf 'approval hook tests passed\n'
