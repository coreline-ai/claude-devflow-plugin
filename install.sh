#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$ROOT_DIR/skills"
HOOKS_ROOT="$ROOT_DIR/hooks"
CLAUDE_HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
TARGET_ROOT="$CLAUDE_HOME_DIR/skills"
HOOKS_TARGET="$CLAUDE_HOME_DIR/hooks"
SETTINGS_FILE="$CLAUDE_HOME_DIR/settings.json"

usage() {
  echo "Usage: $0 [all|hooks|skill-name ...]"
  echo ""
  echo "Options:"
  echo "  all          Install all skills + safety hook"
  echo "  hooks        Install safety hook only"
  echo "  <skill-name> Install specific skill(s)"
  echo ""
  echo "Available skills:"
  find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | sed 's/^/  - /'
}

available_skill() {
  [[ -d "$SOURCE_ROOT/$1" && -f "$SOURCE_ROOT/$1/SKILL.md" ]]
}

frontmatter_name() {
  awk -F': *' '/^name:/{print $2; exit}' "$1/SKILL.md"
}

warn_name_conflicts() {
  local skill="$1"
  [[ -d "$TARGET_ROOT" ]] || return 0
  for existing in "$TARGET_ROOT"/*; do
    [[ -e "$existing" && -f "$existing/SKILL.md" ]] || continue
    [[ "$(basename "$existing")" == "$skill" ]] && continue
    local existing_name
    existing_name="$(frontmatter_name "$existing" 2>/dev/null || true)"
    if [[ "$existing_name" == "$skill" ]]; then
      echo "Warning: another installed skill declares name '$skill': $existing" >&2
    fi
  done
}

install_one() {
  local skill="$1"
  if ! available_skill "$skill"; then
    echo "Unknown skill: $skill" >&2
    usage >&2
    exit 1
  fi

  mkdir -p "$TARGET_ROOT"
  warn_name_conflicts "$skill"

  local source="$SOURCE_ROOT/$skill"
  local target="$TARGET_ROOT/$skill"
  if [[ -e "$target" ]]; then
    local backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$target" "$backup"
    echo "Backed up existing $skill to: $backup"
  fi

  cp -R "$source" "$target"
  echo "Installed skill: $skill -> $target"
}

install_hooks() {
  mkdir -p "$HOOKS_TARGET"

  # Copy safety-guard.sh
  cp "$HOOKS_ROOT/safety-guard.sh" "$HOOKS_TARGET/safety-guard.sh"
  chmod +x "$HOOKS_TARGET/safety-guard.sh"
  echo "Installed hook: safety-guard.sh -> $HOOKS_TARGET/"

  # Merge into settings.json
  if ! command -v jq &>/dev/null; then
    echo "Warning: jq not found. Hook script installed but settings.json not updated." >&2
    echo "Manually add the PreToolUse hook entry to $SETTINGS_FILE" >&2
    return 0
  fi

  local hook_command="$HOOKS_TARGET/safety-guard.sh"

  # Create settings.json if it doesn't exist
  if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Check if hook already registered
  if jq -e ".hooks.PreToolUse[]?.hooks[]? | select(.command == \"$hook_command\")" "$SETTINGS_FILE" &>/dev/null; then
    echo "Hook already registered in settings.json"
    return 0
  fi

  # Backup settings.json
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak.$(date +%Y%m%d_%H%M%S)"

  # Merge hook entry
  local tmp
  tmp="$(mktemp)"
  jq --arg cmd "$hook_command" '
    .hooks //= {} |
    .hooks.PreToolUse //= [] |
    .hooks.PreToolUse += [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": $cmd,
        "timeout": 5
      }]
    }]
  ' "$SETTINGS_FILE" > "$tmp"
  mv "$tmp" "$SETTINGS_FILE"
  echo "Registered PreToolUse hook in $SETTINGS_FILE"
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
    install_one "$skill"
  done
  install_hooks
elif [[ "$1" == "hooks" ]]; then
  install_hooks
else
  for skill in "$@"; do
    install_one "$skill"
  done
fi
