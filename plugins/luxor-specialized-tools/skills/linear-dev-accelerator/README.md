# Linear Development Accelerator Skill

A comprehensive Claude skill for accelerating software development using Linear project management with MCP server integration.

## Overview

This skill transforms Claude into a Linear project management expert, enabling rapid setup and management of software development projects across frontend, full-stack, and mobile applications. Built from extensive research of Linear's MCP server API and development best practices, this skill provides battle-tested workflows and automation patterns.

## What This Skill Does

The Linear Development Accelerator skill teaches Claude to:

- **Set up projects rapidly**: Complete project structures with proper organization, labels, and workflows
- **Manage issues intelligently**: Create, update, and track issues with best-practice templates and workflows
- **Coordinate team workflows**: Organize sprints/cycles, assign work, and track progress across teams
- **Integrate with development tools**: Connect Linear with GitHub, CI/CD, and deployment workflows
- **Automate project management**: Batch operations, smart filtering, and efficient issue management
- **Follow development best practices**: Proven patterns for frontend, backend, full-stack, and mobile projects

## When to Use This Skill

Use this skill when:

- Starting a new software development project
- Setting up Linear project management
- Managing development workflows (frontend, backend, mobile, full-stack)
- Organizing sprints/cycles and tracking progress
- Creating and managing issues, bugs, and features
- Coordinating between teams (frontend ↔️ backend, iOS ↔️ Android)
- Integrating Linear with GitHub and CI/CD pipelines
- Automating repetitive project management tasks

## Skill Contents

### Core Documentation

- **SKILL.md**: Complete Linear MCP server reference with:
  - Comprehensive tool catalog (all Linear MCP tools documented)
  - Development workflow patterns (feature dev, bug tracking, sprint planning)
  - Accelerated development strategies
  - Best practices for issues, projects, and team collaboration
  - Integration guides for GitHub, CI/CD, Slack
  - Quick reference and troubleshooting

### Practical Examples

#### 1. Frontend Project Setup (`examples/frontend-project-setup.md`)
Complete workflow for React/TypeScript frontend projects:
- Project creation with detailed description
- Epic and feature issue breakdown
- Design system implementation tracking
- Cycle organization (sprints)
- Daily workflow queries
- Progress tracking patterns

**Use this for**: React, Vue, Angular, or any frontend framework projects

#### 2. Mobile App Workflow (`examples/mobile-app-workflow.md`)
End-to-end mobile development tracking:
- iOS and Android project organization
- Platform-specific issue labeling (ios, android, shared)
- Native integration tracking (CallKit, ConnectionService)
- Bug tracking with device information
- App Store and Play Store submission checklists
- Release management workflows

**Use this for**: Flutter, React Native, or native iOS/Android projects

#### 3. Full-Stack API Development (`examples/full-stack-api-development.md`)
Coordinating backend and frontend development:
- API-first development approach
- Parallel backend/frontend work coordination
- Integration point tracking
- API documentation workflows
- Testing strategies (backend + frontend + E2E)
- Deployment coordination

**Use this for**: Node.js + React, Python + Vue, or any full-stack projects

## Key Features

### 1. Complete MCP Tool Reference
Every Linear MCP server tool documented with:
- Required and optional parameters
- Return data structures
- Usage examples
- Common patterns
- Error handling

**Tools covered**:
- Issue management (list, create, update, get)
- Project management (list, create, update, get)
- Labels and categorization
- Workflow and status management
- Collaboration (comments, documents)
- Team and user management
- Cycle/sprint planning

### 2. Development Workflow Patterns
Proven patterns for:
- **Feature Development**: From idea to deployment with proper tracking
- **Bug Triage**: Efficient bug handling and resolution workflows
- **Sprint Planning**: Organizing work into cycles with team coordination
- **Project Setup**: Complete project initialization for new applications
- **GitHub Integration**: Linking Linear issues with PRs and deployments

### 3. Accelerated Development Strategies
- **Batch Issue Creation**: Set up entire projects efficiently
- **Smart Filtering**: Reduce cognitive load with focused queries
- **Template-Based Issues**: Consistent issue creation with templates
- **Automated Updates**: CI/CD integration for status updates
- **Cross-Functional Coordination**: Organize frontend/backend/mobile work

### 4. Best Practices
Comprehensive guidance on:
- **Issue Creation**: Clear titles, rich descriptions, proper labeling
- **Project Organization**: Right-sizing projects, label taxonomy
- **Workflow Management**: Limiting WIP, updating status, completing issues
- **Team Collaboration**: Clear ownership, communication, celebrations
- **Label Taxonomy**: Recommended categorization system

### 5. Integration Patterns
Connect Linear with:
- **GitHub**: Branch naming, PR linking, auto-status updates
- **CI/CD**: Test results, deployment tracking, automated comments
- **Slack**: Notifications, updates, team communication

## How to Use This Skill

### Installation

1. Copy the `linear-dev-accelerator` folder to your Claude skills directory
2. Claude will automatically detect and load the skill when relevant

### Invoking the Skill

The skill activates automatically when you:
- Mention Linear project management
- Ask about setting up development projects
- Request help with issue tracking
- Discuss sprint/cycle planning
- Need development workflow guidance

### Example Usage

```
You: "I'm starting a new React e-commerce project and want to set it up in Linear"

Claude: [Activates linear-dev-accelerator skill]
Based on the Linear Development Accelerator skill, I'll help you set up a complete
React e-commerce project in Linear. Let me create:

1. The main project with proper description and timeline
2. Epic issues for major features (product catalog, cart, checkout)
3. Child issues for individual components
4. Proper labeling (frontend, react, ui, feature)
5. Organization into sprints/cycles

[Proceeds to use Linear MCP tools with skill knowledge]
```

```
You: "How should I track a mobile app with both iOS and Android development?"

Claude: [Activates linear-dev-accelerator skill]
For mobile apps with both platforms, I recommend the platform-specific tracking
pattern from the skill. Let me set up:

1. Project with iOS and Android tracking
2. Platform-specific labels (ios, android, shared)
3. Separate issues for platform-specific work
4. Integration issues for coordinating across platforms

[Uses mobile-app-workflow.md patterns]
```

## Examples Directory

The `examples/` directory contains three comprehensive workflow guides:

1. **frontend-project-setup.md**: React/TypeScript project from scratch
2. **mobile-app-workflow.md**: Flutter chat app with iOS + Android
3. **full-stack-api-development.md**: Node.js API + React frontend

Each example includes:
- Complete Linear MCP tool usage
- Real-world project scenarios
- Copy-paste ready workflows
- Best practices in action
- Daily workflow queries

## Skill Capabilities

With this skill, Claude can:

### Project Management
- Create comprehensive project structures
- Set up epic issues with child tasks
- Organize work into cycles/sprints
- Track progress and generate reports
- Manage project documentation

### Issue Management
- Create issues with rich templates
- Update issue status and properties
- Add detailed comments and context
- Link issues with PRs and deployments
- Track dependencies and blockers

### Team Coordination
- Assign work to team members
- Track workload across teams
- Coordinate frontend/backend work
- Manage cross-platform development
- Facilitate daily standups

### Development Workflows
- GitHub integration patterns
- CI/CD automation
- Release management
- Bug triage processes
- Testing coordination

### Automation
- Batch issue creation
- Smart filtering queries
- Automated status updates
- Template-based workflows
- Metrics and reporting

## Quick Start

### For Frontend Projects
See `examples/frontend-project-setup.md` for complete React project setup

### For Mobile Projects
See `examples/mobile-app-workflow.md` for iOS + Android app tracking

### For Full-Stack Projects
See `examples/full-stack-api-development.md` for coordinated API + frontend development

## Advanced Usage

### Custom Workflows
Adapt the patterns in SKILL.md to your team's specific needs:
- Modify label taxonomies
- Adjust workflow states
- Customize issue templates
- Create team-specific queries

### Integration Development
Use the MCP tool reference to build custom integrations:
- Automated issue creation from logs
- Status updates from CI/CD
- Metrics dashboards
- Custom reporting tools

### Team Onboarding
Use the skill documentation to onboard teams:
- Share best practices
- Standardize workflows
- Document conventions
- Train on Linear usage

## Resources

### Linear Documentation
- [Linear Docs](https://linear.app/docs)
- [Linear API Reference](https://developers.linear.app/docs)
- [Linear Blog](https://linear.app/blog)

### Claude Skills
- [Claude Skills Announcement](https://www.anthropic.com/news/skills)
- [Skills Repository](https://github.com/anthropics/skills)

### MCP Servers
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Linear MCP Server](https://github.com/linear/linear-mcp)

## Skill Metadata

- **Version**: 1.0.0
- **Category**: Project Management, Development Acceleration
- **Compatible With**: Linear MCP Server, GitHub, CI/CD pipelines
- **Last Updated**: October 2025
- **Research Sources**: Linear MCP Server API, Linear Documentation, Real-world development workflows

## Contributing

This skill is based on:
- Comprehensive Linear MCP server exploration
- Real-world project management patterns
- Software development best practices
- Feedback from production usage

Suggestions for improvements are welcome!

## License

This skill is provided as-is for use with Claude Code and Claude API.

---

**Build faster. Ship better. Accelerate development with Linear + Claude.**
