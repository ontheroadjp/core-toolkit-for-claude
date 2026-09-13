#!/usr/bin/env bash
set -euo pipefail

TOOLKIT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT_ROOT="$TMP_DIR/project"
TEST_HOME="$TMP_DIR/home"
mkdir -p "$TEST_HOME/.claude/commands"
git init -q "$PROJECT_ROOT"

ln -s "$TOOLKIT_ROOT/commands/work.md" "$TEST_HOME/.claude/commands/work.md"
printf '{"hooks":{},"statusLine":{"command":"bash ~/.claude/statusline.sh"}}\n' >"$TEST_HOME/.claude/settings.json"
mkdir -p "$TEST_HOME/.codex"
printf '[tui]\nstatus_line = ["context-used", "used-tokens", "five-hour-limit", "weekly-limit"]\n' >"$TEST_HOME/.codex/config.toml"

if HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" </dev/null >/dev/null 2>&1; then
  printf 'FAIL: installer accepted a non-root invocation\n' >&2
  exit 1
fi

printf '2\n' | (cd "$PROJECT_ROOT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)

test -L "$PROJECT_ROOT/.codex/commands/work.md"
test -L "$PROJECT_ROOT/.codex/hooks/auto-approve-readonly.sh"
test -L "$PROJECT_ROOT/.codex/skills/work"
test -f "$PROJECT_ROOT/.codex/hooks.json"
test -f "$TEST_HOME/.codex/config.toml"
test ! -e "$TEST_HOME/.claude/commands/work.md"
test "$(jq -r '.statusLine // empty' "$TEST_HOME/.claude/settings.json")" = ''
grep -Fq '"context-used"' "$TEST_HOME/.codex/config.toml"

printf '3\n' | (cd "$PROJECT_ROOT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)
test -L "$TEST_HOME/.local/bin/agy-rate-status"
test "$(readlink "$TEST_HOME/.local/bin/agy-rate-status")" = "$TOOLKIT_ROOT/scripts/setup_statusline_for_agy.sh"
test "$(jq -r '.statusLine.type' "$TEST_HOME/.gemini/antigravity-cli/settings.json")" = command
test "$(jq -r '.statusLine.command' "$TEST_HOME/.gemini/antigravity-cli/settings.json")" = 'bash ~/.local/bin/agy-rate-status'

printf 'Local installer tests passed.\n'
