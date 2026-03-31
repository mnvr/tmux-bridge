#!/bin/sh

# Install tmux-bridge to ~/.local/bin (macOS)

set -eu

INSTALL_DIR="$HOME/.local/bin"
SKILL_DIR="$HOME/.local/share/tmux-bridge"
BASE_URL="https://raw.githubusercontent.com/mnvr/tmux-bridge/main"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# Resolve source: local files next to this script, or download
SCRIPT_DIR=""
if [ "${0##*/}" = "install.sh" ]; then
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
fi

command -v tmux >/dev/null 2>&1 || fail "tmux is required. Install it with: brew install tmux"

mkdir -p "$INSTALL_DIR" "$SKILL_DIR"

# Install binary
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tmux-bridge" ]; then
  cp "$SCRIPT_DIR/tmux-bridge" "$INSTALL_DIR/tmux-bridge"
else
  command -v curl >/dev/null 2>&1 || fail "curl is required to download tmux-bridge"
  curl -fsSL "$BASE_URL/tmux-bridge" -o "$INSTALL_DIR/tmux-bridge"
fi
chmod +x "$INSTALL_DIR/tmux-bridge"

# Install skill to staging area
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/skills/tmux-bridge/SKILL.md" ]; then
  cp "$SCRIPT_DIR/skills/tmux-bridge/SKILL.md" "$SKILL_DIR/SKILL.md"
else
  curl -fsSL "$BASE_URL/skills/tmux-bridge/SKILL.md" -o "$SKILL_DIR/SKILL.md"
fi

printf 'installed tmux-bridge to %s/tmux-bridge\n' "$INSTALL_DIR"

# Check if ~/.local/bin is on PATH
case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    printf '\n%s is not on your PATH. Add it with:\n' "$INSTALL_DIR"
    printf '  export PATH="$HOME/.local/bin:$PATH"\n\n'
    ;;
esac

# Skill install locations
SKILL_DEST_1="$HOME/.codex/skills/tmux-bridge"
SKILL_DEST_2="$HOME/.claude/skills/tmux-bridge"
SKILL_DEST_3=".agents/skills/tmux-bridge"
SKILL_DEST_4=".claude/skills/tmux-bridge"

install_skill() {
  mkdir -p "$1"
  cp "$SKILL_DIR/SKILL.md" "$1/SKILL.md"
  printf '  installed skill to %s\n' "$1"
}

# Parse flags
AUTO=0
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=1 ;;
  esac
done

if [ "$AUTO" -eq 1 ]; then
  # Auto mode: install to ~/.codex and ~/.claude if they exist
  installed=0
  if [ -d "$HOME/.codex" ]; then
    install_skill "$SKILL_DEST_1"
    installed=$((installed + 1))
  fi
  if [ -d "$HOME/.claude" ]; then
    install_skill "$SKILL_DEST_2"
    installed=$((installed + 1))
  fi
  if [ "$installed" -eq 0 ]; then
    printf '\nneither ~/.codex nor ~/.claude found, skipping skill install\n'
  fi
else
  # Default mode: print instructions for installing the skill
  printf '\nTo install the skill, copy it to one of:\n'
  printf '  ~/.codex/skills/    (all projects, Codex)\n'
  printf '  ~/.claude/skills/   (all projects, Claude Code)\n'
  printf '  .agents/skills/     (this project, Codex)\n'
  printf '  .claude/skills/     (this project, Claude Code)\n'
  printf '\nFor example:\n'
  printf '  cp -r %s ~/.codex/skills/\n' "$SKILL_DIR"
  printf '\nOr rerun with --auto to install to ~/.codex and ~/.claude if they exist.\n'
fi
