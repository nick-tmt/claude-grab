#!/bin/bash
set -e

echo "Installing /grab skill for Claude Code..."

# Copy skill
mkdir -p ~/.claude/skills/grab
cp SKILL.md ~/.claude/skills/grab/SKILL.md
echo "  Skill installed to ~/.claude/skills/grab/"

# Copy binaries
mkdir -p ~/.claude/bin
cp bin/grab-img.sh ~/.claude/bin/grab-img.sh
cp bin/grab-crop.swift ~/.claude/bin/grab-crop.swift
chmod +x ~/.claude/bin/grab-img.sh
echo "  Scripts copied to ~/.claude/bin/"

# Compile Swift binary
echo "  Compiling grab-crop..."
swiftc -O -o ~/.claude/bin/grab-crop ~/.claude/bin/grab-crop.swift
echo "  Binary compiled"

# Check dependencies
echo ""
if command -v pandoc &>/dev/null; then
  echo "  pandoc: installed"
else
  echo "  pandoc: missing (brew install pandoc)"
fi

if command -v silicon &>/dev/null; then
  echo "  silicon: installed"
else
  echo "  silicon: missing — optional, only needed for /grab fast mode (brew install silicon)"
fi

echo ""
echo "Done. Use /grab, /grab img, /grab slack, or /grab docs in Claude Code."
