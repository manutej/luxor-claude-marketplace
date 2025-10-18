#!/bin/bash

# LUXOR Frontend Essentials Plugin Uninstaller
# v1.0.0

set -e

CLAUDE_DIR="$HOME/.claude"
PLUGIN_NAME="luxor-frontend-essentials"

echo "🗑️  Uninstalling $PLUGIN_NAME..."
echo ""

read -p "Are you sure you want to uninstall? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Skills to remove
SKILLS=(
    "react-development"
    "react-patterns"
    "nextjs-development"
    "angular-development"
    "svelte-development"
    "vuejs-development"
    "tailwind-css"
    "javascript-fundamentals"
    "frontend-architecture"
    "responsive-design"
    "ui-design-patterns"
    "mobile-design"
    "jest-react-testing"
)

echo "🗑️  Removing skills..."
skill_count=0
for skill in "${SKILLS[@]}"; do
    if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
        rm -rf "$CLAUDE_DIR/skills/$skill"
        echo "  ✅ Removed $skill"
        ((skill_count++))
    fi
done

echo ""
echo "✅ $PLUGIN_NAME uninstalled successfully!"
echo ""
echo "Removed:"
echo "  Skills: $skill_count"
echo ""
echo "Please restart Claude Code."
echo ""
