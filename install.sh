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
if [ -f "$SCRIPT_DIR/tmux-bridge" ]; then
  cp "$SCRIPT_DIR/tmux-bridge" "$INSTALL_DIR/tmux-bridge"
else
  command -v curl >/dev/null 2>&1 || fail "curl is required to download tmux-bridge"
  curl -fsSL "$BASE_URL/tmux-bridge" -o "$INSTALL_DIR/tmux-bridge"
fi
chmod +x "$INSTALL_DIR/tmux-bridge"

# Install skill
if [ -f "$SCRIPT_DIR/skills/tmux-bridge/SKILL.md" ]; then
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

printf '\nTo add the skill to your project:\n'
printf '  mkdir -p .agents/skills\n'
printf '  cp -r ~/.local/share/tmux-bridge .agents/skills/\n'
printf '\nFor user-wide install, copy to ~/.codex/skills/ or ~/.claude/skills/ instead.\n'
