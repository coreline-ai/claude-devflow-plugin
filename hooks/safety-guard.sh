#!/usr/bin/env bash
# safety-guard.sh — PreToolUse hook for Claude Code
# Blocks dangerous Bash commands before execution.
# Exit codes: 0 = allow, 2 = block
set -euo pipefail

INPUT="$(cat)"

# Extract tool_name
if command -v jq &>/dev/null; then
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)"
  COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  TOOL_NAME="$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4 || true)"
  COMMAND="$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 | cut -d'"' -f4 || true)"
fi

# Only check Bash tool calls
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Normalize: lowercase for pattern matching
CMD_LOWER="$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')"

block() {
  echo "BLOCKED: $1" >&2
  exit 2
}

# --- Destructive filesystem operations ---

# rm -rf on root, home, or broad paths
if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[a-z]*f[a-z]*\s+|--force\s+)*-[a-z]*r[a-z]*\s+(/|~|\$home)\b'; then
  block "rm -rf on root or home directory"
fi
if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[a-z]*r[a-z]*\s+|--recursive\s+)*-[a-z]*f[a-z]*\s+(/|~|\$home)\b'; then
  block "rm -rf on root or home directory"
fi

# --- Git force operations on main/master ---

if echo "$CMD_LOWER" | grep -qE 'git\s+push\s+.*--force.*\s+(main|master)\b'; then
  block "git push --force to main/master"
fi
if echo "$CMD_LOWER" | grep -qE 'git\s+push\s+.*-f\s+.*\s+(main|master)\b'; then
  block "git push -f to main/master"
fi
if echo "$CMD_LOWER" | grep -qE 'git\s+push\s+--force\s+(origin\s+)?(main|master)\b'; then
  block "git push --force to main/master"
fi

# git reset --hard (warn-level block)
if echo "$CMD_LOWER" | grep -qE 'git\s+reset\s+--hard'; then
  block "git reset --hard — potential data loss"
fi

# --- Permission escalation ---

if echo "$CMD_LOWER" | grep -qE 'chmod\s+(-[a-z]*\s+)*777'; then
  block "chmod 777 — overly permissive"
fi

# --- Secret exposure ---

# Writing to .env or credentials files
if echo "$CMD_LOWER" | grep -qE '>\s*\.env\b'; then
  block "overwriting .env file"
fi

# Printing secret files to stdout
if echo "$CMD_LOWER" | grep -qE 'cat\s+.*\.(env|pem|key)\b'; then
  block "printing secret/key file to stdout"
fi

# --- System destructive ---

if echo "$CMD_LOWER" | grep -qE '\bmkfs\b'; then
  block "mkfs — filesystem format"
fi
if echo "$CMD_LOWER" | grep -qE '\bdd\s+if='; then
  block "dd — raw disk write"
fi

# All checks passed — allow
exit 0
