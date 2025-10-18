---
description: Quick reference for available workflows - list, preview, and execute multi-agent orchestrations
allowed-tools: Read(~/.claude/docs/WORKFLOW-ORCHESTRATION-GUIDE.md), Glob(**/.claude/workflows/*.yaml), Read(**/.claude/workflows/*.yaml)
---

# /workflows

List available workflows and execute multi-agent orchestrations.

## Usage

```bash
/workflows                    # List all available workflows
/workflows <name>             # Show workflow details and execute
/workflows --help             # View full orchestration guide
```

## Available Workflows

### 📋 List Current Workflows

Search for workflow files and display:

```bash
find ~/.claude/workflows -name "*.yaml" 2>/dev/null
find .claude/workflows -name "*.yaml" 2>/dev/null
```

For each workflow found, show:
- **Name** and description
- **Steps** (count and agent sequence)
- **Estimated**: tokens and time
- **Tags**: workflow categories
- **Execute**: `/orch <name>` command

### 🎯 Quick Workflow Reference

| Workflow | Purpose | Agents | Time |
|----------|---------|--------|------|
| **api-development** | API design → implement → test → docs | api-architect, code-craftsman, test-engineer, docs-generator | ~46 min, 60K tokens |
| **frontend-feature-complete** | React component with tests | frontend-architect, code-craftsman, test-engineer, docs-generator | ~50 min, 62K tokens |
| **bug-investigation-fix** | Locate → analyze → fix → test | project-orchestrator, debug-detective, code-craftsman, test-engineer | ~40 min, 58K tokens |
| **research-to-documentation** | Deep research → docs | deep-researcher (x2), docs-generator | ~55 min, 70K tokens |
| **claude-sdk-integration** | SDK research → integration | deep-researcher, api-architect, code-craftsman, test-engineer, docs-generator | ~65 min, 75K tokens |
| **mcp-integration-complete** | MCP server integration | mcp-integration-wizard (x2), code-craftsman, docs-generator | ~50 min, 68K tokens |

### 🚀 Quick Actions

When user provides a workflow name, show:

1. **Workflow Summary**
   ```
   📋 Workflow: api-development
   Description: Complete API development pipeline
   Steps: 4
   Estimated: 60,000 tokens, ~46 minutes
   ```

2. **Execution Steps**
   ```
   Steps:
   1. api-architect: Design REST API with OpenAPI
   2. code-craftsman: Implement endpoints
   3. test-engineer: Create test suite
   4. docs-generator: Generate documentation
   ```

3. **Quick Execute Options**
   ```
   Execute:
   • /orch api-development                    # Run now
   • /orch api-development --dry-run         # Preview first
   • /orch api-development --param spec="..."  # With parameters
   ```

### 📚 Full Guide

For comprehensive documentation:
- **Location**: `~/.claude/docs/WORKFLOW-ORCHESTRATION-GUIDE.md`
- **Read guide**: When user asks `--help` or questions about workflows
- **Covers**: All agents, creating custom workflows, advanced patterns, troubleshooting

### 🛠️ Quick Commands

```bash
# Workflow Management
/wflw --list                           # List all workflows
/wflw --generate <name> "s1" → "s2"   # Create new workflow
/wflw --show <name>                    # View workflow YAML
/wflw --validate <name>                # Check syntax

# Execution
/orch <name>                           # Execute workflow
/orch <name> --dry-run                 # Preview without running
/orch <name> --verbose                 # Detailed output
/orch <name> --budget 100000           # Custom token limit
```

### 💡 Common Patterns

**API Development**
```bash
/workflows api-development
# Then: /orch api-development --param spec="user auth with JWT"
```

**Bug Fix**
```bash
/workflows bug-investigation-fix
# Then: /orch bug-investigation-fix --param issue="memory leak in service"
```

**Research**
```bash
/workflows research-to-documentation
# Then: /orch research-to-documentation --param topic="PostgreSQL vs MongoDB"
```

**Integration**
```bash
/workflows mcp-integration-complete
# Then: /orch mcp-integration-complete --param server="filesystem"
```

---

## Implementation

1. **If no arguments**: List all workflows with quick summary table
2. **If workflow name provided**: Show details + execution options
3. **If --help**: Read and display full guide from `~/.claude/docs/WORKFLOW-ORCHESTRATION-GUIDE.md`
4. **If questions**: Read guide to answer accurately

Keep it fast - just glob for YAML files and show the table. Don't read every file unless user asks for specific workflow details.
