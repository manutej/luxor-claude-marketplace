#!/bin/bash

# LUXOR Testing Essentials Plugin Installer
# v1.0.0

set -e

CLAUDE_DIR="$HOME/.claude"
PLUGIN_NAME="luxor-testing-essentials"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Installing $PLUGIN_NAME..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Claude Code directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "❌ Error: Claude Code directory not found at $CLAUDE_DIR"
    echo "Please ensure Claude Code is installed."
    exit 1
fi

# Create directories
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/workflows"

count=0

# Install skills
echo "📦 Installing 3 skills..."
SKILLS=(
    "pytest"
    "pytest-patterns"
    "shell-testing-framework"
)

for skill in "${SKILLS[@]}"; do
    if [ -d "skills/$skill" ]; then
        cp -r "skills/$skill" "$CLAUDE_DIR/skills/$skill"
        echo "  ✅ $skill"
        count=$((count+1))
    fi
done
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ LUXOR Testing Essentials installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo "   Skills: 3"
echo "   Commands: 0"
echo "   Agents: 0"
echo "   Workflows: 0"
echo ""
echo "📝 Restart Claude Code to activate!"
echo ""
