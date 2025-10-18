#!/bin/bash

# LUXOR DevOps Suite Plugin Installer
# v1.0.0

set -e

CLAUDE_DIR="$HOME/.claude"
PLUGIN_NAME="luxor-devops-suite"

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
echo "📦 Installing 12 skills..."
SKILLS=(
    "docker-compose-orchestration"
    "kubernetes-orchestration"
    "aws-cloud-architecture"
    "aws-cloud-services"
    "terraform-infrastructure"
    "terraform-infrastructure-as-code"
    "ci-cd-pipeline-patterns"
    "observability-monitoring"
    "microservices-patterns"
    "enterprise-architecture-patterns"
    "api-gateway-patterns"
    "hasura-graphql-engine"
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
echo "✅ LUXOR DevOps Suite installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo "   Skills: 12"
echo "   Commands: 0"
echo "   Agents: 0"
echo "   Workflows: 0"
echo ""
echo "📝 Restart Claude Code to activate!"
echo ""
