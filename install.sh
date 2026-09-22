#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing team Claude config from $REPO_DIR..."

# CLAUDE.md: replace with symlink (backs up existing)
if [ -e "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  Backing up CLAUDE.md → CLAUDE.md.bak"
  mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
elif [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
  rm "$CLAUDE_DIR/CLAUDE.md"
fi
ln -sf "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  CLAUDE.md → symlinked"

# Skills: symlink each skill individually (preserves personal skills)
mkdir -p "$CLAUDE_DIR/skills"
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$CLAUDE_DIR/skills/$skill_name"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  Skipping $skill_name — personal version exists (remove manually to use shared)"
    continue
  fi
  ln -sf "$skill_dir" "$target"
  echo "  skill/$skill_name → symlinked"
done

# Agents: symlink each agent individually (preserves personal agents)
mkdir -p "$CLAUDE_DIR/agents"
for agent_file in "$REPO_DIR/agents"/*.md; do
  agent_name="$(basename "$agent_file")"
  target="$CLAUDE_DIR/agents/$agent_name"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  Skipping $agent_name — personal version exists (remove manually to use shared)"
    continue
  fi
  ln -sf "$agent_file" "$target"
  echo "  agent/$agent_name → symlinked"
done

echo ""
echo "Done. Run 'git pull && ./install.sh' to update shared config."
