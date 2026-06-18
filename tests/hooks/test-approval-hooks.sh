#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUTO_HOOK="${REPO_DIR}/hooks/auto-approve-readonly.sh"
GUARD_HOOK="${REPO_DIR}/hooks/guard-destructive-cmd.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SESSION_FILE="${TMP_DIR}/session-approved"

run_auto() {
    local command="$1"
    printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"${command}\"}}" \
        | CODEX_CI=1 \
            CLAUDE_CODE_KIT_STATE_HOME="$TMP_DIR/state" \
            CLAUDE_CODE_KIT_SESSION_APPROVED_FILE="$SESSION_FILE" \
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

output=$(run_auto 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_auto 'rm -fr /usr')
assert_json_decision "$output" "block"

mkdir -p "$(dirname "$SESSION_FILE")"
printf '%s\n' 'tool:git_write' > "$SESSION_FILE"
output=$(run_auto 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_auto 'git status --porcelain')
assert_json_decision "$output" "allow"

output=$(run_auto 'git add hooks/auto-approve-readonly.sh')
assert_json_decision "$output" "allow"

output=$(run_auto 'gh run rerun 12345')
assert_no_output "$output"

output=$(run_auto 'some-unknown-command --flag')
assert_no_output "$output"

output=$(run_guard 'git reset --hard')
assert_json_decision "$output" "block"

output=$(run_guard 'git status --porcelain')
assert_no_output "$output"

printf 'approval hook tests passed\n'
