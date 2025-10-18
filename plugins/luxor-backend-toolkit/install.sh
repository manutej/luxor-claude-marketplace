#!/bin/bash

# LUXOR Backend Toolkit Plugin Installer
# v1.0.0

set -e

CLAUDE_DIR="$HOME/.claude"
PLUGIN_NAME="luxor-backend-toolkit"

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
echo "📦 Installing 14 skills..."
SKILLS=(
    "fastapi"
    "fastapi-development"
    "fastapi-microservices-development"
    "expressjs-development"
    "express-microservices-architecture"
    "nodejs-development"
    "golang-backend-development"
    "spring-boot-development"
    "axum-web-framework"
    "rust-systems-programming"
    "graphql-api-development"
    "rest-api-design-patterns"
    "grpc-microservices"
    "oauth2-authentication"
)

for skill in "${SKILLS[@]}"; do
    if [ -d "skills/$skill" ]; then
        cp -r "skills/$skill" "$CLAUDE_DIR/skills/$skill"
        echo "  ✅ $skill"
        ((count++))
    fi
done
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ LUXOR Backend Toolkit installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo "   Skills: 14"
echo "   Commands: 0"
echo "   Agents: 0"
echo "   Workflows: 0"
echo ""
echo "📝 Restart Claude Code to activate!"
echo ""
