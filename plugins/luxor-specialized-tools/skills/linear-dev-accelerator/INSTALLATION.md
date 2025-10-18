# Linear Development Accelerator - Installation Guide

## Quick Start

The Linear Development Accelerator skill is ready to use with Claude Code or Claude API.

## Installation for Claude Code

### Option 1: Direct Copy (Recommended)

1. Locate your Claude Code skills directory:
   - macOS: `~/Library/Application Support/Claude/skills/`
   - Linux: `~/.config/Claude/skills/`
   - Windows: `%APPDATA%\Claude\skills\`

2. Copy the `linear-dev-accelerator` folder to the skills directory:
   ```bash
   cp -r /Users/manu/Documents/LUXOR/linear-dev-accelerator ~/Library/Application\ Support/Claude/skills/
   ```

3. Restart Claude Code (if running)

4. The skill will activate automatically when you discuss:
   - Linear project management
   - Software development workflows
   - Issue tracking and sprint planning
   - Project setup for web or mobile apps

### Option 2: Symlink (For Development)

If you want to continue editing the skill:

```bash
ln -s /Users/manu/Documents/LUXOR/linear-dev-accelerator ~/Library/Application\ Support/Claude/skills/linear-dev-accelerator
```

## Verification

Test that the skill is installed correctly:

1. Open Claude Code
2. Type: "Help me set up a new React project in Linear"
3. Claude should reference the Linear Development Accelerator skill

## Prerequisites

### Linear MCP Server

This skill requires the Linear MCP server to be configured:

1. **Install Linear MCP Server**:
   ```bash
   npm install -g @linear/mcp-server
   ```

2. **Configure in Claude Code**:
   Add to your MCP server configuration:
   ```json
   {
     "linear": {
       "command": "npx",
       "args": ["-y", "@linear/mcp-server"],
       "env": {
         "LINEAR_API_KEY": "your-linear-api-key"
       }
     }
   }
   ```

3. **Get Linear API Key**:
   - Go to Linear Settings → API
   - Create new Personal API Key
   - Copy and add to configuration

## Skill Structure

```
linear-dev-accelerator/
├── SKILL.md                              # Core skill knowledge base
├── README.md                             # Documentation
├── INSTALLATION.md                       # This file
└── examples/
    ├── frontend-project-setup.md         # React/frontend workflows
    ├── mobile-app-workflow.md            # iOS/Android workflows
    └── full-stack-api-development.md     # Full-stack workflows
```

## Using the Skill

### Activation

The skill activates automatically when you:
- Mention "Linear" in context of project management
- Ask about setting up development projects
- Request help with issue tracking or sprint planning
- Discuss software development workflows

### Example Prompts

**Frontend Project**:
```
"I'm starting a new e-commerce frontend in React.
Set it up in Linear with proper project structure."
```

**Mobile App**:
```
"Help me organize a Flutter chat app project in Linear
with separate tracking for iOS and Android."
```

**Full-Stack Project**:
```
"Set up Linear project management for a Node.js API
with React frontend, including coordination between teams."
```

**Issue Management**:
```
"Create a bug report template in Linear for our team"
```

**Sprint Planning**:
```
"Help me plan the next 2-week sprint for my frontend team"
```

## Customization

### Editing the Skill

1. Edit `SKILL.md` to customize:
   - Label taxonomies
   - Workflow patterns
   - Issue templates
   - Best practices

2. Add new examples in `examples/` directory

3. Update `README.md` with your customizations

### Team-Specific Adaptations

Create team-specific versions:

```bash
cp -r linear-dev-accelerator linear-dev-accelerator-frontend
# Edit linear-dev-accelerator-frontend/SKILL.md for frontend-specific patterns

cp -r linear-dev-accelerator linear-dev-accelerator-mobile
# Edit linear-dev-accelerator-mobile/SKILL.md for mobile-specific patterns
```

## Troubleshooting

### Skill Not Activating

1. **Check skill location**: Ensure folder is in correct skills directory
2. **Restart Claude Code**: Close and reopen application
3. **Check SKILL.md format**: Verify YAML frontmatter is correct
4. **Use explicit activation**: Mention "using the Linear Development Accelerator skill"

### MCP Server Issues

1. **Verify installation**:
   ```bash
   npx @linear/mcp-server --version
   ```

2. **Check API key**: Ensure LINEAR_API_KEY is set correctly

3. **Test connection**: Try a simple Linear operation:
   ```
   "List my Linear teams"
   ```

4. **Review logs**: Check Claude Code logs for MCP connection errors

### Skill Updates

To update the skill with improvements:

1. Pull latest changes
2. Copy updated files to skills directory
3. Restart Claude Code

## Tips for Maximum Effectiveness

1. **Use Specific Prompts**: Reference project type (frontend, mobile, full-stack)
2. **Provide Context**: Mention tech stack (React, Flutter, Node.js)
3. **Reference Examples**: "Use the mobile app workflow from the skill"
4. **Combine with /deep**: For research-heavy tasks, combine skill with /deep command
5. **Leverage Templates**: Ask Claude to use templates from the skill

## Support

For issues or questions:
- Review the examples in `examples/` directory
- Check `SKILL.md` for comprehensive reference
- Consult Linear documentation: https://linear.app/docs
- Check Linear MCP server docs: https://github.com/linear/linear-mcp

## What's Next

After installation:

1. **Explore Examples**: Read through the three example workflows
2. **Test on Real Project**: Use skill to set up an actual project
3. **Customize for Your Team**: Adapt templates and patterns
4. **Share with Team**: Document team-specific conventions
5. **Iterate and Improve**: Refine based on real-world usage

## Version Information

- **Skill Version**: 1.0.0
- **Release Date**: October 2025
- **Compatible With**: Claude Code, Claude API with MCP support
- **Linear MCP Server**: All versions

## License

This skill is provided as-is for use with Claude applications.

---

**Ready to accelerate? Start using the Linear Development Accelerator skill today!**
