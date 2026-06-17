#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_TARGET="${HOME}/.claude/commands"
CODEX_COMMANDS_TARGET="${HOME}/.codex/commands"
HOOKS_TARGET="${HOME}/.claude/hooks"
SKILLS_TARGET="${HOME}/.codex/skills"

mkdir -p "$COMMANDS_TARGET"
mkdir -p "$CODEX_COMMANDS_TARGET"
mkdir -p "$HOOKS_TARGET"
mkdir -p "$SKILLS_TARGET"

echo "Linking commands -> ${COMMANDS_TARGET}"
for src in "$REPO_DIR"/commands/*.md; do
  name="$(basename "$src")"
  ln -sf "$src" "${COMMANDS_TARGET}/${name}"
  echo "  ${COMMANDS_TARGET}/${name} -> ${src}"
done

echo "Linking commands -> ${CODEX_COMMANDS_TARGET}"
for src in "$REPO_DIR"/commands/*.md; do
  name="$(basename "$src")"
  ln -sf "$src" "${CODEX_COMMANDS_TARGET}/${name}"
  echo "  ${CODEX_COMMANDS_TARGET}/${name} -> ${src}"
done

echo "Linking hooks -> ${HOOKS_TARGET}"
for src in "$REPO_DIR"/hooks/*.sh; do
  name="$(basename "$src")"
  ln -sf "$src" "${HOOKS_TARGET}/${name}"
  echo "  ${HOOKS_TARGET}/${name} -> ${src}"
done

echo "Linking skills -> ${SKILLS_TARGET}"
for src in "$REPO_DIR"/skills/*/; do
  name="$(basename "$src")"
  ln -sf "$src" "${SKILLS_TARGET}/${name}"
  echo "  ${SKILLS_TARGET}/${name} -> ${src}"
done

SETTINGS_FILE="${HOME}/.claude/settings.json"

echo "Configuring ${SETTINGS_FILE}..."

if ! command -v jq &>/dev/null; then
    echo "  Warning: jq not found — skipping settings.json update."
    echo "  Add hook entries manually (see README.md)."
    echo "Done."
    exit 0
fi

[ -f "$SETTINGS_FILE" ] || echo '{}' > "$SETTINGS_FILE"

# Idempotently add a hook entry: skip if the command is already registered for that event.
# Usage: add_hook <event> <matcher> <command>
add_hook() {
    local event="$1" matcher="$2" cmd="$3"
    local current
    current=$(cat "$SETTINGS_FILE")

    local exists
    exists=$(printf '%s' "$current" | jq -r \
        --arg e "$event" --arg c "$cmd" \
        '[(.hooks[$e] // [])[] | .hooks[]? | .command] | any(. == $c)')

    if [ "$exists" = "true" ]; then
        echo "  Already present [${event}]: ${cmd}"
        return
    fi

    printf '%s' "$current" | jq \
        --arg e "$event" --arg m "$matcher" --arg c "$cmd" \
        '.hooks[$e] = ((.hooks[$e] // []) + [{"matcher": $m, "hooks": [{"type": "command", "command": $c}]}])' \
        > "$SETTINGS_FILE"
    echo "  Added [${event}]: ${cmd}"
}

add_hook "PreToolUse"      ""     "bash ~/.claude/hooks/auto-approve-readonly.sh"
add_hook "PreToolUse"      "Bash" "bash ~/.claude/hooks/guard-destructive-cmd.sh"
add_hook "UserPromptSubmit" ""    "bash ~/.claude/hooks/log-access-prompt.sh"
add_hook "PostToolUse"     ""     "bash ~/.claude/hooks/log-access-tool.sh"
add_hook "Notification"    ""     "bash ~/.claude/hooks/notify-slack.sh"
add_hook "Stop"            ""     "bash ~/.claude/hooks/log-token-usage.sh"
add_hook "Stop"            ""     "bash ~/.claude/hooks/log-access-stop.sh"
add_hook "Stop"            ""     "bash ~/.claude/hooks/cleanup-session.sh"
add_hook "Stop"            ""     "bash ~/.claude/hooks/notify-slack.sh"

echo "Done."
