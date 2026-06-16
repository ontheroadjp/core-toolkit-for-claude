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

echo "Done."
