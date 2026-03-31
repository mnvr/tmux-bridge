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
SKILL_DEST_1=".agents/skills/tmux-bridge"
SKILL_DEST_2=".claude/skills/tmux-bridge"
SKILL_DEST_3="$HOME/.codex/skills/tmux-bridge"
SKILL_DEST_4="$HOME/.claude/skills/tmux-bridge"

install_skill() {
  mkdir -p "$1"
  cp "$SKILL_DIR/SKILL.md" "$1/SKILL.md"
  printf '  %s\n' "$1"
}

# Pre-select existing installs
default=""
for i in 1 2 3 4; do
  eval "dest=\$SKILL_DEST_$i"
  if [ -f "$dest/SKILL.md" ]; then
    default="${default:+$default,}$i"
  fi
done

printf '\nWhere should the skill be installed?\n'
printf '  1) .agents/skills/tmux-bridge/    (this project, Codex)\n'
printf '  2) .claude/skills/tmux-bridge/    (this project, Claude Code)\n'
printf '  3) ~/.codex/skills/tmux-bridge/   (all projects, Codex)\n'
printf '  4) ~/.claude/skills/tmux-bridge/  (all projects, Claude Code)\n'
printf '  s) skip\n'
if [ -n "$default" ]; then
  printf 'Choice (comma-separated for multiple) [%s]: ' "$default"
else
  printf 'Choice (comma-separated for multiple) [s]: '
fi
read -r choice

if [ -z "$choice" ]; then
  choice="${default:-s}"
fi

IFS=', '
for c in $choice; do
  case "$c" in
    1) install_skill "$SKILL_DEST_1" ;;
    2) install_skill "$SKILL_DEST_2" ;;
    3) install_skill "$SKILL_DEST_3" ;;
    4) install_skill "$SKILL_DEST_4" ;;
    s) ;;
    *) printf 'unknown choice: %s\n' "$c" ;;
  esac
done
