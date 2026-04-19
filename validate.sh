#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$ROOT_DIR/skills"
HOOKS_ROOT="$ROOT_DIR/hooks"
ERRORS=0

fail() {
  echo "FAIL: $1" >&2
  ERRORS=$((ERRORS + 1))
}

pass() {
  echo "PASS: $1"
}

# --- 1. Shell syntax check ---
for script in "$ROOT_DIR/install.sh" "$ROOT_DIR/uninstall.sh" "$ROOT_DIR/validate.sh"; do
  if bash -n "$script" 2>/dev/null; then
    pass "$(basename "$script") syntax"
  else
    fail "$(basename "$script") syntax error"
  fi
done

# --- 2. SKILL.md frontmatter validation ---
for skill_dir in "$SOURCE_ROOT"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill="$(basename "$skill_dir")"

  python3 - <<'PY' "$skill_dir" || { fail "$skill frontmatter"; continue; }
from pathlib import Path
import re
import sys
skill_dir = Path(sys.argv[1])
skill = skill_dir.name
text = (skill_dir / "SKILL.md").read_text(encoding="utf-8")
if not text.startswith("---\n"):
    raise SystemExit(f"{skill}: SKILL.md must start with frontmatter")
front = text.split("---\n", 2)[1]
# name check
if f"name: {skill}" not in front:
    raise SystemExit(f"{skill}: frontmatter name must be '{skill}'")
# description check
match = re.search(r"^description:\s*(.+)$", front, re.M)
if not match or "TODO" in match.group(1) or len(match.group(1).strip()) < 30:
    raise SystemExit(f"{skill}: description is missing or too short (min 30 chars)")
# allowed-tools check
if "allowed-tools:" not in front:
    raise SystemExit(f"{skill}: allowed-tools is required")
# user-invocable check
if "user-invocable: true" not in front:
    raise SystemExit(f"{skill}: user-invocable: true is required")
# when_to_use check
if "when_to_use:" not in front:
    raise SystemExit(f"{skill}: when_to_use is required")
# no TODO in body
if "TODO" in text:
    raise SystemExit(f"{skill}: TODO placeholder remains")
PY
  pass "$skill frontmatter"
done

# --- 3. References exist check ---
for skill_dir in "$SOURCE_ROOT"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill="$(basename "$skill_dir")"
  if [[ -d "$skill_dir/references" ]]; then
    ref_count=$(find "$skill_dir/references" -name "*.md" -type f | wc -l | tr -d ' ')
    if [[ "$ref_count" -gt 0 ]]; then
      pass "$skill references ($ref_count files)"
    else
      fail "$skill references directory is empty"
    fi
  else
    fail "$skill missing references directory"
  fi
done

# --- 4. Hook validation ---
HOOK_SCRIPT="$HOOKS_ROOT/safety-guard.sh"

if [[ -x "$HOOK_SCRIPT" ]]; then
  pass "safety-guard.sh is executable"
else
  fail "safety-guard.sh is not executable"
fi

# Test: safe command should pass (exit 0)
if echo '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}' | bash "$HOOK_SCRIPT" >/dev/null 2>&1; then
  pass "safety-guard.sh allows safe commands"
else
  fail "safety-guard.sh blocked a safe command"
fi

# Test: dangerous command should block (exit 2)
HOOK_EXIT=0
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bash "$HOOK_SCRIPT" >/dev/null 2>&1 || HOOK_EXIT=$?
if [[ "$HOOK_EXIT" -eq 2 ]]; then
  pass "safety-guard.sh blocks dangerous commands"
else
  fail "safety-guard.sh did not block 'rm -rf /' (exit=$HOOK_EXIT, expected 2)"
fi

# Test: non-Bash tool should pass
if echo '{"tool_name":"Read","tool_input":{"file_path":"/tmp/test"}}' | bash "$HOOK_SCRIPT" >/dev/null 2>&1; then
  pass "safety-guard.sh ignores non-Bash tools"
else
  fail "safety-guard.sh incorrectly blocked non-Bash tool"
fi

# --- 5. Install/uninstall smoke test ---
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

# Install all skills
CLAUDE_HOME="$tmp_root/.claude" "$ROOT_DIR/install.sh" all >/tmp/claude-devflow-install.log 2>&1

# Verify skills installed
for skill_dir in "$SOURCE_ROOT"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill="$(basename "$skill_dir")"
  if [[ -f "$tmp_root/.claude/skills/$skill/SKILL.md" ]]; then
    pass "smoke install: $skill"
  else
    fail "smoke install: $skill not found"
  fi
done

# Verify hook installed
if [[ -f "$tmp_root/.claude/hooks/safety-guard.sh" ]]; then
  pass "smoke install: safety-guard.sh"
else
  fail "smoke install: safety-guard.sh not found"
fi

# Verify settings.json is valid JSON
if [[ -f "$tmp_root/.claude/settings.json" ]]; then
  if python3 -c "import json; json.load(open('$tmp_root/.claude/settings.json'))" 2>/dev/null; then
    pass "smoke install: settings.json valid JSON"
  else
    fail "smoke install: settings.json invalid JSON"
  fi
fi

# Uninstall all
CLAUDE_HOME="$tmp_root/.claude" "$ROOT_DIR/uninstall.sh" all >/tmp/claude-devflow-uninstall.log 2>&1

# Verify skills removed
for skill_dir in "$SOURCE_ROOT"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill="$(basename "$skill_dir")"
  if [[ ! -e "$tmp_root/.claude/skills/$skill" ]]; then
    pass "smoke uninstall: $skill"
  else
    fail "smoke uninstall: $skill still exists"
  fi
done

# --- Summary ---
echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo "claude-devflow-plugin validation passed"
else
  echo "claude-devflow-plugin validation FAILED ($ERRORS errors)"
  exit 1
fi
