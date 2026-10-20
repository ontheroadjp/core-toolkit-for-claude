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

assert_line_count() {
  local file=$1 line=$2 expected=$3 actual
  actual=$(grep -cxF -- "$line" "$file" || true)
  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: expected %s occurrence(s) of %s in %s, got %s\n' "$expected" "$line" "$file" "$actual" >&2
    exit 1
  fi
}

# An existing .gitignore without a trailing newline must keep its last rule intact.
printf 'node_modules/' >"$PROJECT_ROOT/.gitignore"

printf '2\n' | (cd "$PROJECT_ROOT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)
printf '2\n' | (cd "$PROJECT_ROOT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)

assert_line_count "$PROJECT_ROOT/.gitignore" 'node_modules/' 1
assert_line_count "$PROJECT_ROOT/.gitignore" '# core-toolkit-for-claude (install.sh)' 1
for name in commands hooks scripts skills templates; do
  assert_line_count "$PROJECT_ROOT/.gitignore" ".codex/$name/" 1
done
assert_line_count "$PROJECT_ROOT/.gitignore" '.codex/hooks.json' 1
test -z "$(git -C "$PROJECT_ROOT" status --porcelain --untracked-files=all -- .codex)"

test -L "$PROJECT_ROOT/.codex/commands/work.md"
test -L "$PROJECT_ROOT/.codex/hooks/auto-approve-readonly.sh"
test -L "$PROJECT_ROOT/.codex/skills/work"
test -f "$PROJECT_ROOT/.codex/hooks.json"
test -f "$TEST_HOME/.codex/config.toml"
test ! -e "$TEST_HOME/.claude/commands/work.md"
test "$(jq -r '.statusLine // empty' "$TEST_HOME/.claude/settings.json")" = ''
grep -Fq '"context-used"' "$TEST_HOME/.codex/config.toml"

cp "$PROJECT_ROOT/.gitignore" "$TMP_DIR/gitignore.before-agy"
printf '3\n' | (cd "$PROJECT_ROOT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)
cmp -s "$TMP_DIR/gitignore.before-agy" "$PROJECT_ROOT/.gitignore"
test -L "$TEST_HOME/.local/bin/agy-rate-status"
test "$(readlink "$TEST_HOME/.local/bin/agy-rate-status")" = "$TOOLKIT_ROOT/scripts/setup_statusline_for_agy.sh"
test "$(jq -r '.statusLine.type' "$TEST_HOME/.gemini/antigravity-cli/settings.json")" = command
test "$(jq -r '.statusLine.command' "$TEST_HOME/.gemini/antigravity-cli/settings.json")" = 'bash ~/.local/bin/agy-rate-status'

# Claude: hooks move from a shared settings.json registered by earlier installs to the ignored settings.local.json.
CLAUDE_PROJECT="$TMP_DIR/claude-project"
git init -q "$CLAUDE_PROJECT"
mkdir -p "$CLAUDE_PROJECT/.claude"
# shellcheck disable=SC2016 # The literal $CLAUDE_PROJECT_DIR is what earlier installs wrote.
jq -n '{permissions: {allow: ["Bash(ls)"]}, hooks: {Stop: [
  {matcher: "", hooks: [{type: "command", command: "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/cleanup-session.sh\""}]},
  {matcher: "", hooks: [{type: "command", command: "bash ./my-hook.sh"}]}]}}' >"$CLAUDE_PROJECT/.claude/settings.json"
printf '1\n' | (cd "$CLAUDE_PROJECT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)
for name in commands hooks scripts skills templates; do
  assert_line_count "$CLAUDE_PROJECT/.gitignore" ".claude/$name/" 1
done
assert_line_count "$CLAUDE_PROJECT/.gitignore" '.claude/settings.local.json' 1
assert_line_count "$CLAUDE_PROJECT/.gitignore" '.claude/settings.json' 0
test "$(jq -c '[.hooks.Stop[].hooks[].command]' "$CLAUDE_PROJECT/.claude/settings.json")" = '["bash ./my-hook.sh"]'
test "$(jq -r '.permissions.allow[0]' "$CLAUDE_PROJECT/.claude/settings.json")" = 'Bash(ls)'
jq -e '[.hooks.Stop[].hooks[].command] | any(endswith("/.claude/hooks/cleanup-session.sh\""))' "$CLAUDE_PROJECT/.claude/settings.local.json" >/dev/null
test "$(git -C "$CLAUDE_PROJECT" status --porcelain --untracked-files=all -- .claude)" = '?? .claude/settings.json'

IGNORED_PROJECT="$TMP_DIR/ignored-project"
git init -q "$IGNORED_PROJECT"
printf '.claude/\n' >"$IGNORED_PROJECT/.gitignore"
printf '1\n' | (cd "$IGNORED_PROJECT" && HOME="$TEST_HOME" bash "$TOOLKIT_ROOT/install.sh" >/dev/null)
test "$(cat "$IGNORED_PROJECT/.gitignore")" = '.claude/'

printf 'Local installer tests passed.\n'
