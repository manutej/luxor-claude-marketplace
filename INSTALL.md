# LUXOR Claude Code Marketplace - Installation Guide

Complete installation instructions for all plugins and skills.

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Installation](#quick-installation)
- [Individual Plugin Installation](#individual-plugin-installation)
- [Custom Installation](#custom-installation)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

---

## Prerequisites

### Required

- **Claude Code** >= 2.0.0
- **Bash** shell (macOS, Linux, WSL on Windows)
- **~/.claude/** directory (created by Claude Code)

### Optional

- **Git** (for cloning from GitHub)
- **Python 3.8+** (for some data skills)
- **Node.js 16+** (for some backend skills)

---

## Quick Installation

### Method 1: Install All Plugins (Recommended for Complete Setup)

```bash
# Clone marketplace
git clone https://github.com/luxor/luxor-claude-marketplace.git
cd luxor-claude-marketplace

# Install all 10 plugins
for plugin in plugins/*/; do
    echo "Installing $(basename "$plugin")..."
    (cd "$plugin" && chmod +x install.sh && ./install.sh)
done

# Restart Claude Code
echo "✅ All plugins installed! Restart Claude Code."
```

**What You Get**:
- 67 skills
- 28 commands
- 30 agents
- 15 workflows
- Complete professional development environment (140 total tools)

---

### Method 2: Install Featured Bundle (Top 4 Plugins)

```bash
# Clone marketplace
git clone https://github.com/luxor/luxor-claude-marketplace.git
cd luxor-claude-marketplace/plugins

# Install featured plugins
FEATURED=(
    "luxor-frontend-essentials"
    "luxor-backend-toolkit"
    "luxor-devops-suite"
    "luxor-skill-builder"
)

for plugin in "${FEATURED[@]}"; do
    echo "Installing $plugin..."
    (cd "$plugin" && chmod +x install.sh && ./install.sh)
done

# Restart Claude Code
echo "✅ Featured plugins installed! Restart Claude Code."
```

**What You Get**:
- 13 frontend skills
- 14 backend skills
- 12 DevOps skills
- 28 commands + 30 agents + 15 workflows
- Essential professional toolkit (112 total tools)

---

## Individual Plugin Installation

Install only the plugins you need.

### Frontend Development

```bash
cd luxor-claude-marketplace/plugins/luxor-frontend-essentials
chmod +x install.sh
./install.sh
```

**13 Skills**: React, Next.js, Angular, Vue, Svelte, Tailwind, JavaScript, testing, responsive design

---

### Backend Development

```bash
cd luxor-claude-marketplace/plugins/luxor-backend-toolkit
chmod +x install.sh
./install.sh
```

**14 Skills**: FastAPI, Express, Node.js, Go, Rust, GraphQL, REST, gRPC, OAuth2

---

### Database & Data

```bash
cd luxor-claude-marketplace/plugins/luxor-database-pro
chmod +x install.sh
./install.sh
```

**9 Skills**: PostgreSQL, SQLAlchemy, Alembic, pandas, Redis, vector databases

---

### DevOps & Infrastructure

```bash
cd luxor-claude-marketplace/plugins/luxor-devops-suite
chmod +x install.sh
./install.sh
```

**12 Skills**: Docker, Kubernetes, AWS, Terraform, CI/CD, monitoring, microservices

---

### Data Engineering

```bash
cd luxor-claude-marketplace/plugins/luxor-data-engineering
chmod +x install.sh
./install.sh
```

**5 Skills**: Airflow, Spark, Kafka, dbt, MLOps

---

### Testing

```bash
cd luxor-claude-marketplace/plugins/luxor-testing-essentials
chmod +x install.sh
./install.sh
```

**3 Skills**: pytest, pytest patterns, shell testing

---

### AI Integration

```bash
cd luxor-claude-marketplace/plugins/luxor-ai-integration
chmod +x install.sh
./install.sh
```

**2 Skills**: LangChain, Claude SDK

---

### Design & UX

```bash
cd luxor-claude-marketplace/plugins/luxor-design-toolkit
chmod +x install.sh
./install.sh
```

**4 Skills**: Figma, wireframing, UX principles, performance

---

### Specialized Tools

```bash
cd luxor-claude-marketplace/plugins/luxor-specialized-tools
chmod +x install.sh
./install.sh
```

**5 Skills**: Playwright, Linear, asyncio, unix-goto, Pydantic

---

### Skill Builder (Meta Tools)

```bash
cd luxor-claude-marketplace/plugins/luxor-skill-builder
chmod +x install.sh
./install.sh
```

**28 Commands + 30 Agents + 15 Workflows**: Essential for creating and managing skills, commands, agents, and workflows

---

## Custom Installation

### Select Specific Skills

You can manually copy individual skills:

```bash
# Copy a specific skill
cp -r luxor-claude-marketplace/plugins/luxor-frontend-essentials/skills/react-development \
    ~/.claude/skills/

# Restart Claude Code
```

### Symlink for Development

Use symlinks to keep plugins editable:

```bash
# Symlink entire plugin
ln -s "$(pwd)/luxor-claude-marketplace/plugins/luxor-frontend-essentials/skills"/* \
    ~/.claude/skills/

# Changes to source will automatically reflect in Claude Code
```

---

## Verification

### Check Installed Skills

```bash
# List installed skills
ls -1 ~/.claude/skills/ | wc -l

# Should show number of installed skills
```

### Check Installed Commands

```bash
# List installed commands
ls -1 ~/.claude/commands/

# Try a command in Claude Code
# /skills
```

### Test a Skill

```bash
# In Claude Code, try:
"Build a React component with Tailwind CSS"

# Claude should use react-development and tailwind-css skills
```

---

## Troubleshooting

### Issue: "Claude Code directory not found"

**Problem**: `~/.claude/` doesn't exist

**Solution**:
```bash
# Ensure Claude Code is installed and has been run at least once
# The directory is created on first run
# Check:
ls -la ~/.claude/
```

---

### Issue: "Permission denied"

**Problem**: Install script isn't executable

**Solution**:
```bash
chmod +x install.sh
./install.sh
```

---

### Issue: "Skill already exists"

**Problem**: Skill is already installed

**Options**:
1. **Skip**: Press 'N' when prompted
2. **Overwrite**: Press 'Y' to replace with latest version
3. **Manual Backup**: Back up existing skill first

```bash
# Backup existing skills
cp -r ~/.claude/skills/skill-name ~/.claude/skills/skill-name.backup

# Then install plugin
./install.sh
```

---

### Issue: "Skills not appearing"

**Problem**: Claude Code not restarted

**Solution**:
```bash
# Restart Claude Code completely
# Skills are loaded on startup
```

---

### Issue: "Some skills missing"

**Problem**: Partial installation

**Solution**:
```bash
# Re-run install script
./install.sh

# Or manually check for missing skills
ls plugins/luxor-frontend-essentials/skills/
ls ~/.claude/skills/
```

---

## Uninstallation

### Remove Entire Marketplace

```bash
# Uninstall all plugins
cd luxor-claude-marketplace/plugins
for plugin in */; do
    (cd "$plugin" && chmod +x uninstall.sh && ./uninstall.sh)
done

# Or manually remove
rm -rf ~/.claude/skills/{list-of-skill-names}
rm -rf ~/.claude/commands/{list-of-command-names}
rm -rf ~/.claude/agents/{list-of-agent-names}
rm -rf ~/.claude/workflows/{list-of-workflow-names}

# Restart Claude Code
```

---

### Remove Individual Plugin

```bash
# Use uninstall script
cd luxor-claude-marketplace/plugins/luxor-frontend-essentials
chmod +x uninstall.sh
./uninstall.sh

# Restart Claude Code
```

---

### Remove Specific Skill

```bash
# Remove single skill
rm -rf ~/.claude/skills/react-development

# Restart Claude Code
```

---

## Advanced Installation

### Install from GitHub Directly

```bash
# Install plugin directly from GitHub (future)
/plugin marketplace add luxor/luxor-claude-marketplace
/plugin install luxor-frontend-essentials

# Note: This requires Claude Code plugin marketplace support
```

---

### Automated Installation Script

Create a script for your preferred setup:

```bash
#!/bin/bash
# my-luxor-setup.sh

cd luxor-claude-marketplace/plugins

# Full-stack developer setup
PLUGINS=(
    "luxor-frontend-essentials"
    "luxor-backend-toolkit"
    "luxor-database-pro"
    "luxor-testing-essentials"
)

for plugin in "${PLUGINS[@]}"; do
    (cd "$plugin" && ./install.sh)
done

echo "✅ Full-stack setup complete!"
```

```bash
chmod +x my-luxor-setup.sh
./my-luxor-setup.sh
```

---

## Post-Installation

### Verify Installation

```bash
# Count installed skills
echo "Skills: $(ls -1 ~/.claude/skills/ | wc -l)"

# Count installed commands
echo "Commands: $(ls -1 ~/.claude/commands/ | wc -l)"

# Count installed agents
echo "Agents: $(ls -1 ~/.claude/agents/ | wc -l)"
```

### Test Installation

In Claude Code:

```
# Test frontend skills
"Create a React app with TypeScript and Tailwind"

# Test backend skills
"Build a FastAPI endpoint with PostgreSQL"

# Test DevOps skills
"Create a Dockerfile for a Node.js app"

# Test commands
/skills
/workflows
```

---

## Keeping Updated

### Update All Plugins

```bash
cd luxor-claude-marketplace
git pull origin main

# Re-install plugins
for plugin in plugins/*/; do
    (cd "$plugin" && ./install.sh)
done
```

### Update Individual Plugin

```bash
cd luxor-claude-marketplace
git pull origin main

# Re-install specific plugin
cd plugins/luxor-frontend-essentials
./install.sh
```

---

## Support

Having issues? Check:

1. **Prerequisites** - Ensure Claude Code >= 2.0.0
2. **Permissions** - Scripts must be executable
3. **Path** - Using correct absolute paths
4. **Restart** - Always restart Claude Code after installation

Still stuck?
- Open an issue: [GitHub Issues](https://github.com/luxor/luxor-claude-marketplace/issues)
- Check discussions: [GitHub Discussions](https://github.com/luxor/luxor-claude-marketplace/discussions)

---

**Happy Installing! 🚀**

Last Updated: 2025-10-18
