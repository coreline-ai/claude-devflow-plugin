#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$ROOT_DIR/skills"
CLAUDE_HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
TARGET_ROOT="$CLAUDE_HOME_DIR/skills"
HOOKS_TARGET="$CLAUDE_HOME_DIR/hooks"
SETTINGS_FILE="$CLAUDE_HOME_DIR/settings.json"

usage() {
  echo "Usage: $0 [all|hooks|skill-name ...]"
  echo ""
  echo "Options:"
  echo "  all          Remove all skills + safety hook"
  echo "  hooks        Remove safety hook only"
  echo "  <skill-name> Remove specific skill(s)"
  echo ""
  echo "Available skills:"
  find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | sed 's/^/  - /'
}

remove_one() {
  local skill="$1"
  if [[ ! -d "$SOURCE_ROOT/$skill" ]]; then
    echo "Unknown packaged skill: $skill" >&2
    usage >&2
    exit 1
  fi
  local target="$TARGET_ROOT/$skill"
  if [[ ! -e "$target" ]]; then
    echo "Not installed: $target"
    return 0
  fi
  rm -rf "$target"
  echo "Removed skill: $skill from $target"
}

remove_hooks() {
  # Remove hook script
  if [[ -f "$HOOKS_TARGET/safety-guard.sh" ]]; then
    rm -f "$HOOKS_TARGET/safety-guard.sh"
    echo "Removed hook: safety-guard.sh"
  else
    echo "Hook not installed: safety-guard.sh"
  fi

  # Remove from settings.json
  if ! command -v jq &>/dev/null; then
    echo "Warning: jq not found. Please manually remove the PreToolUse hook from $SETTINGS_FILE" >&2
    return 0
  fi

  if [[ ! -f "$SETTINGS_FILE" ]]; then
    return 0
  fi

  local hook_command="$HOOKS_TARGET/safety-guard.sh"

  # Check if hook exists in settings
  if ! jq -e ".hooks.PreToolUse[]?.hooks[]? | select(.command == \"$hook_command\")" "$SETTINGS_FILE" &>/dev/null; then
    echo "Hook not registered in settings.json"
    return 0
  fi

  # Backup settings.json
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak.$(date +%Y%m%d_%H%M%S)"

  # Remove hook entry
  local tmp
  tmp="$(mktemp)"
  jq --arg cmd "$hook_command" '
    .hooks.PreToolUse |= [.[] | select(.hooks | all(.command != $cmd))]
  ' "$SETTINGS_FILE" > "$tmp"
  mv "$tmp" "$SETTINGS_FILE"
  echo "Removed PreToolUse hook from $SETTINGS_FILE"
}

# --- Main ---

if [[ $# -eq 0 ]]; then
  set -- all
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$1" == "all" ]]; then
  skills=()
  while IFS= read -r skill_name; do
    skills+=("$skill_name")
  done < <(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
  for skill in "${skills[@]}"; do
    remove_one "$skill"
  done
  remove_hooks
elif [[ "$1" == "hooks" ]]; then
  remove_hooks
else
  for skill in "$@"; do
    remove_one "$skill"
  done
fi
