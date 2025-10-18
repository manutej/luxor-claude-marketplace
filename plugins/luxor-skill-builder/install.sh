#!/bin/bash

# LUXOR Skill Builder Plugin Installer
# v1.0.0

set -e

CLAUDE_DIR="$HOME/.claude"
PLUGIN_NAME="luxor-skill-builder"

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
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/workflows"

# Install commands
echo "📦 Installing 28 commands..."
for cmd in commands/*.md; do
    if [ -f "$cmd" ]; then
        cp "$cmd" "$CLAUDE_DIR/commands/"
        echo "  ✅ $(basename "$cmd")"
    fi
done
echo ""

# Install agents
echo "📦 Installing 30 agents..."
for agent in agents/*.md; do
    if [ -f "$agent" ]; then
        cp "$agent" "$CLAUDE_DIR/agents/"
        echo "  ✅ $(basename "$agent")"
    fi
done
echo ""

# Install workflows
echo "📦 Installing 15 workflows..."
for workflow in workflows/*.yaml; do
    if [ -f "$workflow" ]; then
        cp "$workflow" "$CLAUDE_DIR/workflows/"
        echo "  ✅ $(basename "$workflow")"
    fi
done
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ LUXOR Skill Builder installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo "   Commands:  28"
echo "   Agents:    30"
echo "   Workflows: 15"
echo ""
echo "📝 Restart Claude Code to activate!"
echo ""
echo "🎯 Key Commands to Try:"
echo "   /coord - Interactive coordination"
echo "   /wflw - Workflow management"
echo "   /crew - Agent discovery"
echo "   /ctx7 - Context7 documentation"
echo ""
