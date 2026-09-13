#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC2016 # Claude expands CLAUDE_PROJECT_DIR when each hook runs.

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [ -z "$PROJECT_ROOT" ] || [ "$(pwd -P)" != "$PROJECT_ROOT" ] || [ ! -e .git ]; then
  printf '%s\n' 'ERROR: Run install.sh from a Git repository root.' >&2
  exit 1
fi

link_directory() {
  local source_dir=$1 target_dir=$2 pattern=$3 source name
  mkdir -p "$target_dir"
  for source in "$source_dir"/$pattern; do
    [ -e "$source" ] || continue
    name="$(basename "$source")"
    ln -sfn "$source" "$target_dir/$name"
    printf '  %s -> %s\n' "$target_dir/$name" "$source"
  done
}

remove_managed_link() {
  local path=$1 target
  [ -L "$path" ] || return 0
  target="$(readlink "$path")"
  case "$target" in
    "$TOOLKIT_ROOT"/*) rm "$path"; printf '  Removed managed global link: %s\n' "$path" ;;
  esac
}

remove_global_links() {
  local path
  for path in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.claude/keybindings.json" "$HOME/.claude/statusline.sh" "$HOME/.local/bin/agy-rate-status"; do remove_managed_link "$path"; done
  for path in "$HOME/.claude/commands"/* "$HOME/.codex/commands"/* "$HOME/.claude/hooks"/*.sh "$HOME/.codex/hooks"/*.sh "$HOME/.claude/hooks/lib"/*.sh "$HOME/.codex/hooks/lib"/*.sh "$HOME/.claude/scripts"/*.sh "$HOME/.codex/scripts"/*.sh "$HOME/.claude/templates"/*.md "$HOME/.codex/templates"/*.md "$HOME/.codex/skills"/*; do remove_managed_link "$path"; done
}

remove_hook_registrations() {
  local settings_file=$1 prefix=$2 current tmp
  [ -f "$settings_file" ] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  current="$(cat "$settings_file")"; tmp="${settings_file}.tmp"
  printf '%s' "$current" | jq --arg prefix "$prefix" '.hooks |= with_entries(.value |= map(select([.hooks[]?.command | startswith($prefix)] | any | not)))' >"$tmp"
  mv "$tmp" "$settings_file"
}

remove_claude_status_line() {
  local settings_file="$HOME/.claude/settings.json" tmp
  [ -f "$settings_file" ] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  if ! jq -e '.statusLine.command == "bash ~/.claude/statusline.sh"' "$settings_file" >/dev/null; then
    return 0
  fi
  tmp="${settings_file}.tmp"
  jq 'del(.statusLine)' "$settings_file" >"$tmp"
  mv "$tmp" "$settings_file"
}

remove_codex_status_line() {
  local config_file="$HOME/.codex/config.toml" tmp
  [ -f "$config_file" ] || return 0
  tmp="${config_file}.tmp"
  awk '
    /^[[:space:]]*\[tui][[:space:]]*(#.*)?$/ { in_tui = 1 }
    in_tui && /^[[:space:]]*\[/ && $0 !~ /^[[:space:]]*\[tui][[:space:]]*(#.*)?$/ { in_tui = 0 }
    in_tui && /^[[:space:]]*status_line[[:space:]]*=/ {
      block = $0 ORS
      if ($0 !~ /\]/) {
        while ((getline line) > 0) {
          block = block line ORS
          if (line ~ /\]/) break
        }
      }
      if (block ~ /"context-used"/ && block ~ /"used-tokens"/ && block ~ /"five-hour-limit"/ && block ~ /"weekly-limit"/) next
      printf "%s", block
      next
    }
    { print }
  ' "$config_file" >"$tmp"
  if cmp -s "$config_file" "$tmp"; then
    rm "$tmp"
  else
    mv "$tmp" "$config_file"
  fi
}

remove_global_configuration() {
  remove_global_links
  remove_hook_registrations "$HOME/.claude/settings.json" 'bash ~/.claude/hooks/'
  remove_hook_registrations "$HOME/.codex/hooks.json" 'bash ~/.codex/hooks/'
  remove_claude_status_line
  remove_codex_status_line
}

add_hook() {
  local settings_file=$1 event=$2 matcher=$3 command=$4 current
  current="$(cat "$settings_file")"
  if printf '%s' "$current" | jq -e --arg event "$event" --arg command "$command" '[(.hooks[$event] // [])[] | .hooks[]?.command] | any(. == $command)' >/dev/null; then return; fi
  printf '%s' "$current" | jq --arg event "$event" --arg matcher "$matcher" --arg command "$command" '.hooks[$event] = ((.hooks[$event] // []) + [{"matcher": $matcher, "hooks": [{"type": "command", "command": $command}]}])' >"$settings_file"
}

configure_claude_hooks() {
  local settings_file="$PROJECT_ROOT/.claude/settings.json"
  command -v jq >/dev/null 2>&1 || { printf '%s\n' 'Warning: jq not found; skipped Claude hook registration.' >&2; return; }
  [ -f "$settings_file" ] || printf '{}\n' >"$settings_file"
  add_hook "$settings_file" PreToolUse '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/auto-approve-readonly.sh\""
  add_hook "$settings_file" PreToolUse Bash "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/guard-destructive-cmd.sh\""
  add_hook "$settings_file" PreToolUse '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/tmux-agent-status.sh\" 🔵"
  add_hook "$settings_file" UserPromptSubmit '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/log-access-prompt.sh\""
  add_hook "$settings_file" UserPromptSubmit '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/tmux-agent-status.sh\" 🔵"
  add_hook "$settings_file" PostToolUse '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/log-access-tool.sh\""
  add_hook "$settings_file" PostToolUse '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/tmux-agent-status.sh\" 🔵"
  add_hook "$settings_file" Notification '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/notify-slack.sh\""
  add_hook "$settings_file" Notification '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/tmux-agent-status.sh\" 🔴"
  add_hook "$settings_file" Stop '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/log-token-usage.sh\""
  add_hook "$settings_file" Stop '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/log-access-stop.sh\""
  add_hook "$settings_file" Stop '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/cleanup-session.sh\""
  add_hook "$settings_file" Stop '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/notify-slack.sh\""
  add_hook "$settings_file" Stop '' "bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/tmux-agent-status.sh\" ✅"
}

configure_codex_hooks() {
  local settings_file="$PROJECT_ROOT/.codex/hooks.json"
  command -v jq >/dev/null 2>&1 || { printf '%s\n' 'Warning: jq not found; skipped Codex hook registration.' >&2; return; }
  [ -f "$settings_file" ] || printf '{}\n' >"$settings_file"
  add_hook "$settings_file" PermissionRequest '' 'bash .codex/hooks/auto-approve-readonly.sh'
  add_hook "$settings_file" PreToolUse Bash 'bash .codex/hooks/guard-destructive-cmd.sh'
  add_hook "$settings_file" PreToolUse '' 'bash .codex/hooks/tmux-agent-status.sh 🔵'
  add_hook "$settings_file" UserPromptSubmit '' 'bash .codex/hooks/log-access-prompt.sh'
  add_hook "$settings_file" UserPromptSubmit '' 'bash .codex/hooks/tmux-agent-status.sh 🔵'
  add_hook "$settings_file" PostToolUse '' 'bash .codex/hooks/log-access-tool.sh'
  add_hook "$settings_file" PostToolUse '' 'bash .codex/hooks/tmux-agent-status.sh 🔵'
  add_hook "$settings_file" Notification '' 'bash .codex/hooks/notify-slack.sh'
  add_hook "$settings_file" Notification '' 'bash .codex/hooks/tmux-agent-status.sh 🔴'
  add_hook "$settings_file" Stop '' 'bash .codex/hooks/log-token-usage.sh'
  add_hook "$settings_file" Stop '' 'bash .codex/hooks/log-access-stop.sh'
  add_hook "$settings_file" Stop '' 'bash .codex/hooks/cleanup-session.sh'
  add_hook "$settings_file" Stop '' 'bash .codex/hooks/notify-slack.sh'
  add_hook "$settings_file" Stop '' 'bash .codex/hooks/tmux-agent-status.sh ✅'
}

install_claude() {
  local target="$PROJECT_ROOT/.claude"
  link_directory "$TOOLKIT_ROOT/commands" "$target/commands" '*.md'
  link_directory "$TOOLKIT_ROOT/hooks" "$target/hooks" '*.sh'
  link_directory "$TOOLKIT_ROOT/hooks/lib" "$target/hooks/lib" '*.sh'
  link_directory "$TOOLKIT_ROOT/scripts" "$target/scripts" '*.sh'
  link_directory "$TOOLKIT_ROOT/skills" "$target/skills" '*'
  link_directory "$TOOLKIT_ROOT/templates" "$target/templates" '*.md'
  configure_claude_hooks
  bash "$TOOLKIT_ROOT/scripts/setup_statusline_for_claude.sh"
}

install_codex() {
  local target="$PROJECT_ROOT/.codex"
  link_directory "$TOOLKIT_ROOT/commands" "$target/commands" '*.md'
  link_directory "$TOOLKIT_ROOT/hooks" "$target/hooks" '*.sh'
  link_directory "$TOOLKIT_ROOT/hooks/lib" "$target/hooks/lib" '*.sh'
  link_directory "$TOOLKIT_ROOT/scripts" "$target/scripts" '*.sh'
  link_directory "$TOOLKIT_ROOT/skills" "$target/skills" '*'
  link_directory "$TOOLKIT_ROOT/templates" "$target/templates" '*.md'
  configure_codex_hooks
  bash "$TOOLKIT_ROOT/scripts/setup_statusline_for_codex.sh"
}

install_agy() {
  local target="$HOME/.local/bin/agy-rate-status"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$TOOLKIT_ROOT/scripts/setup_statusline_for_agy.sh" "$target"
  printf '  %s -> %s\n' "$target" "$TOOLKIT_ROOT/scripts/setup_statusline_for_agy.sh"
}

printf '%s\n' 'Select an agent to install:' '  1) Claude Code' '  2) Codex CLI' '  3) Agy'
read -r -p 'Selection: ' selection
case "$selection" in
  1) remove_global_configuration; install_claude ;;
  2) remove_global_configuration; install_codex ;;
  3) remove_global_configuration; install_agy ;;
  *) printf '%s\n' 'ERROR: Choose 1, 2, or 3.' >&2; exit 1 ;;
esac
printf '%s\n' 'Installation complete.'
