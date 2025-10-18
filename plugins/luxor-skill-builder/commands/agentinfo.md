# /agentinfo

List all available agents with their descriptions, capabilities, and usage examples.

## Available Agents

### practical-programmer
**Description**: Pragmatic programmer following "The Pragmatic Programmer" philosophy—caring about craft, thinking critically, providing solutions (not excuses), and building modular, maintainable code that delights users.

**Model**: Sonnet
**Color**: Cyan

**Core Principles**:
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple)
- SOLID
- YAGNI (You Aren't Gonna Need It)
- Broken Windows Theory

**Focus Areas**:
- Modular architecture with orthogonal components
- Clean, self-documenting code
- User-centric development
- Continuous improvement and learning

**When to Use**:
- Building new features with clean architecture
- Refactoring code to follow best practices
- Applying design patterns pragmatically
- Creating modular, reusable components
- Fixing "broken windows" in codebase

**Example**:
```
user: "I need to build a notification system that's flexible and maintainable"
assistant: "I'll use the practical-programmer agent to design a pragmatic solution with modular architecture, following DRY principles and ensuring it's easy to extend and test."
```

---

### claude-sdk-expert
**Description**: Expert agent specializing in Claude SDK, Anthropic APIs, and AI integration patterns. Conducts comprehensive research using /deep command and provides implementation guidance.

**Model**: Sonnet
**Priority Domains**: docs.anthropic.com, github.com/anthropics

**Research Modes**: /deep -ws, /deep -r, /deep -wf, /deep -t

**When to Use**:
- Integrating Claude SDK into applications
- Understanding Anthropic API capabilities
- Building AI-powered features
- Researching Claude best practices

---

### deep-researcher
**Description**: Comprehensive research and documentation agent using web search, web fetch, extended thinking, and synthesis capabilities.

**Model**: Sonnet

**Capabilities**:
- Web search for discovering sources
- Web fetch for deep content analysis
- Extended thinking for synthesis
- Structured documentation generation

**When to Use**:
- Researching technical topics in depth
- Analyzing industry trends
- Creating comprehensive documentation
- Synthesizing information from multiple sources

---

### git-genius
**Description**: Expert Git operations assistance with comprehensive git command knowledge, intelligent workflow management, error recovery, and git best practice enforcement.

**Model**: Sonnet

**Capabilities**:
- All git commands (basic to advanced)
- Rebase, bisect, submodules, hooks
- Error recovery and troubleshooting
- Workflow management
- Best practice enforcement

**When to Use**:
- Complex git operations
- Git workflow setup and optimization
- Recovering from git errors
- Learning advanced git techniques

---

### unix-command-master
**Description**: Expert-level Unix command knowledge backed by comprehensive web research. Uses /deep command to research Unix commands and provides tested, secure guidance.

**Model**: Sonnet

**Capabilities**:
- Unix command research and mastery
- Shell scripting patterns
- Command pipeline debugging
- Security and performance guidance
- Cross-platform compatibility analysis

**When to Use**:
- Learning advanced Unix commands
- Debugging shell scripts
- Optimizing command pipelines
- Security-focused command usage

---

### mcp-integration-wizard
**Description**: Comprehensive guidance on MCP (Model Context Protocol) integration and custom MCP server development with step-by-step documentation.

**Model**: Sonnet

**Capabilities**:
- MCP server integration guides
- Custom MCP server development
- Configuration examples
- Implementation documentation

**When to Use**:
- Integrating MCP servers into Claude Code
- Building custom MCP servers
- Troubleshooting MCP configurations
- Learning MCP architecture

---

## How to Use Agents

Agents are invoked using the Task tool:

```
Task(
  subagent_type: "agent-name",
  prompt: "Detailed description of what you need the agent to do"
)
```

**Example**:
```
Task(
  subagent_type: "practical-programmer",
  prompt: "Refactor this authentication module to follow DRY principles and fix broken windows. Make it modular and testable."
)
```

---

## Agent Selection Guide

| Need | Recommended Agent |
|------|------------------|
| Clean, modular code with best practices | practical-programmer |
| Claude SDK integration | claude-sdk-expert |
| Deep research on any topic | deep-researcher |
| Git operations and workflows | git-genius |
| Unix command expertise | unix-command-master |
| MCP integration | mcp-integration-wizard |

---

## Creating New Agents

Use the `/meta-agent` command to analyze intent and generate agent specifications:

```bash
/meta-agent "your agent description"
```

Then use `/agent` to create the agent from the specification.

See `/meta-agent --help` for more details.
