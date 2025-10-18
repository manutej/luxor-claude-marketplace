# /orch - Orchestrate Multi-Agent Workflows

**Version:** 1.0.0
**Category:** Orchestration
**Status:** Specification

---

## Overview

The `/orch` command is the primary orchestration interface for executing multi-agent workflows. Like a whale pod leader coordinating complex group behaviors, `/orch` manages the execution of pre-defined workflow templates or custom multi-agent sequences.

## Purpose

Coordinate execution of multiple specialized agents in a structured workflow to accomplish complex tasks that no single agent could achieve alone.

## Syntax

```bash
/orch <workflow-name> [flags] [parameters]
```

### Flags

- `-d, --dry-run` - Preview execution plan without running
- `-b, --budget <tokens>` - Override default token budget
- `-v, --verbose` - Show detailed execution information
- `-s, --summary-only` - Return only final summary
- `--profile` - Profile performance and token usage

### Parameters

- `<workflow-name>` - Name of workflow template (required)
- `--param key=value` - Pass parameters to workflow
- `--context <file>` - Additional context file

## Available Workflows

```
Development Workflows:
├─ api-development
├─ frontend-feature-complete
└─ code-refactoring-pipeline

Maintenance Workflows:
├─ bug-investigation-fix
└─ github-workflow-setup

Integration Workflows:
├─ claude-sdk-integration
├─ mcp-integration-complete
└─ unix-command-mastery

Research Workflows:
├─ research-to-documentation
└─ youtube-content-analysis

Management Workflows:
└─ project-status-review
```

## Examples

### Example 1: API Development

```bash
/orch api-development --param spec="user authentication with JWT"
```

**What happens:**
1. **api-architect** - Designs RESTful API structure
2. **code-craftsman** - Implements endpoints
3. **test-engineer** - Creates comprehensive tests
4. **docs-generator** - Generates API documentation

**Estimated tokens:** 60,000
**Estimated time:** 5-8 minutes

### Example 2: Bug Investigation

```bash
/orch bug-investigation-fix --param issue="memory leak in user service" --verbose
```

**What happens:**
1. **project-orchestrator** - Analyzes codebase and locates issue
2. **debug-detective** - Performs root cause analysis
3. **code-craftsman** - Implements fix
4. **test-engineer** - Validates fix with tests

**Estimated tokens:** 58,000
**Estimated time:** 4-7 minutes

### Example 3: Dry Run Preview

```bash
/orch frontend-feature-complete --dry-run
```

**Output:**
```
Workflow: frontend-feature-complete
Steps: 4
Estimated tokens: 62,000
Estimated time: 5-7 minutes

Execution Plan:
├─ Step 1: frontend-architect (15,000 tokens)
│   └─ Design React component architecture
├─ Step 2: code-craftsman (20,000 tokens)
│   └─ Implement components with TypeScript
├─ Step 3: test-engineer (15,000 tokens)
│   └─ Create Jest/RTL tests
└─ Step 4: docs-generator (12,000 tokens)
    └─ Generate component documentation

Would execute. Use without --dry-run to proceed.
```

### Example 4: Custom Token Budget

```bash
/orch research-to-documentation --budget 80000
```

Allows more extensive research and documentation generation.

### Example 5: With Additional Context

```bash
/orch code-refactoring-pipeline --context project-requirements.md
```

Includes additional context file for refactoring guidance.

## How It Works

### Execution Flow

```
User: /orch api-development

1. Command Processor
   ├─ Parse command and flags
   ├─ Validate workflow exists
   ├─ Load workflow YAML
   └─ Check permissions

2. Orchestrator Initialization
   ├─ Validate workflow structure
   ├─ Verify agent availability
   ├─ Calculate token budget
   ├─ Build execution graph
   └─ Initialize workflow state

3. Sequential Execution
   ├─ Step 1: Execute first agent
   │   ├─ Load agent specification
   │   ├─ Build context (task + workflow state)
   │   ├─ Execute with Task tool
   │   ├─ Capture output
   │   └─ Update workflow state
   │
   ├─ Step 2: Execute second agent (depends on Step 1)
   │   ├─ Load agent specification
   │   ├─ Build context (task + step 1 output + state)
   │   ├─ Execute with Task tool
   │   ├─ Capture output
   │   └─ Update workflow state
   │
   └─ ... continue for all steps

4. Result Aggregation
   ├─ Collect all step outputs
   ├─ Generate workflow summary
   ├─ Calculate actual vs estimated tokens
   ├─ Report execution metrics
   └─ Return comprehensive result

5. Monitoring & Logging
   ├─ Log execution trace
   ├─ Track token usage
   ├─ Measure performance
   └─ Update metrics
```

### Workflow State Management

The orchestrator maintains state throughout execution:

```python
workflow_state = {
    "workflow_name": "api-development",
    "start_time": "2025-10-13T10:00:00Z",
    "parameters": {"spec": "user authentication with JWT"},
    "steps_completed": [],
    "current_step": "design",
    "outputs": {
        "design": {...},
        "implement": {...},
        # etc.
    },
    "tokens_used": 0,
    "tokens_estimated": 60000,
    "status": "in_progress"
}
```

## Integration Points

### With /crew
```bash
# Discover agents used in workflow
/crew --workflow api-development
```

### With /context-budget
```bash
# Check if workflow fits in current context
/context-budget --workflow api-development
```

### With /wflw
```bash
# Generate custom workflow, then execute
/wflw "Create API with React frontend"
# Saves to custom-workflow.yaml
/orch custom-workflow
```

### With /aprof
```bash
# Profile agents before orchestration
/aprof code-craftsman
/orch api-development
```

## Error Handling

### Workflow Not Found
```bash
/orch non-existent-workflow
# Error: Workflow 'non-existent-workflow' not found
# Available workflows: api-development, bug-investigation-fix, ...
```

### Agent Not Available
```bash
/orch api-development
# Error: Agent 'api-architect' specified in step 1 not found
# Please check .claude/agents/ directory
```

### Token Budget Exceeded
```bash
/orch research-to-documentation
# Warning: Estimated tokens (70,000) exceeds default budget (50,000)
# Use --budget flag to override or optimize workflow
```

### Step Failure
```bash
/orch api-development
# Step 2 (code-craftsman) failed with error: ...
# Workflow halted. Previous steps completed:
# - Step 1 (api-architect): ✅ Success
```

## Performance Considerations

### Token Usage

Typical workflow token usage:
- **Small workflow** (2-3 steps): 30K-50K tokens
- **Medium workflow** (4-5 steps): 50K-80K tokens
- **Large workflow** (6+ steps): 80K-120K tokens

### Execution Time

Factors affecting execution time:
- Number of steps
- Complexity of each agent task
- Context size between steps
- Tool call overhead

Typical execution: **1-2 minutes per step**

### Optimization Tips

1. **Use dry-run** first to preview execution
2. **Optimize context passing** between steps
3. **Set appropriate token budget** for task complexity
4. **Profile workflows** to identify bottlenecks
5. **Cache common context** when possible

## Advanced Usage

### Custom Workflow Execution

```bash
# Create custom workflow
/wflw "Multi-step deployment pipeline" > deploy.yaml

# Edit deploy.yaml as needed

# Execute custom workflow
/orch deploy --workflow-file deploy.yaml
```

### Workflow Chaining

```bash
# Execute multiple workflows in sequence
/orch api-development && /orch github-workflow-setup
```

### Partial Execution

```bash
# Execute only specific steps
/orch api-development --steps 1,2,3
```

### Resume Failed Workflow

```bash
# Resume from last successful step
/orch api-development --resume
```

## Monitoring & Metrics

### Real-time Monitoring

During execution, `/orch` provides updates:

```
[/orch] Starting workflow: api-development
[/orch] Step 1/4: api-architect (designing API structure)
[/orch] Step 1/4: ✅ Complete (14,823 tokens, 1.2 min)
[/orch] Step 2/4: code-craftsman (implementing endpoints)
[/orch] Step 2/4: ✅ Complete (21,456 tokens, 2.1 min)
[/orch] Step 3/4: test-engineer (creating tests)
[/orch] Step 3/4: ✅ Complete (15,234 tokens, 1.5 min)
[/orch] Step 4/4: docs-generator (generating documentation)
[/orch] Step 4/4: ✅ Complete (9,123 tokens, 0.8 min)
[/orch] Workflow complete: 60,636 tokens, 5.6 minutes
```

### Post-Execution Summary

```
Workflow: api-development
Status: ✅ Success
Duration: 5 minutes 36 seconds

Token Usage:
├─ Estimated: 60,000
├─ Actual: 60,636
└─ Error: +1.1% (excellent)

Steps:
├─ api-architect: ✅ 14,823 tokens (1.2 min)
├─ code-craftsman: ✅ 21,456 tokens (2.1 min)
├─ test-engineer: ✅ 15,234 tokens (1.5 min)
└─ docs-generator: ✅ 9,123 tokens (0.8 min)

Outputs:
├─ API specification (OpenAPI 3.0)
├─ Implementation (TypeScript/Express)
├─ Test suite (Jest, 95% coverage)
└─ API documentation (Markdown)
```

## Best Practices

1. **Start with dry-run** to validate workflow before execution
2. **Use appropriate workflows** for task type
3. **Provide clear parameters** for workflow context
4. **Monitor token usage** to optimize budget
5. **Profile workflows** regularly to identify improvements
6. **Chain workflows** for complex multi-phase tasks
7. **Customize workflows** when templates don't fit
8. **Review outputs** from each step
9. **Learn from metrics** to improve future orchestrations
10. **Document custom workflows** for reuse

## Security & Permissions

### Required Permissions

```yaml
allowed-tools:
  - Task(*) # Execute any agent
  - Read(*) # Read workflow YAML
  - TodoWrite(*) # Track execution progress
  - Bash(git:*) # Git operations if needed
```

### Workflow Validation

Before execution, `/orch` validates:
- Workflow YAML syntax
- Agent references exist
- Step dependencies are valid
- No circular dependencies
- Token budget is reasonable
- User has necessary permissions

## Future Enhancements

### Planned Features

1. **Parallel Execution** - Execute independent steps concurrently
2. **Conditional Steps** - Execute steps based on previous outputs
3. **Dynamic Workflows** - Generate workflows from natural language
4. **Workflow Marketplace** - Share and discover community workflows
5. **Visual Workflow Editor** - GUI for workflow design
6. **Workflow Templates** - More pre-built templates
7. **Advanced Analytics** - Deep insights into workflow performance
8. **Workflow Versioning** - Track workflow evolution
9. **Rollback Support** - Undo workflow execution
10. **Workflow Scheduling** - Schedule recurring workflows

## Troubleshooting

### Common Issues

**Issue:** Workflow runs but produces poor results
**Solution:** Review agent specifications, improve task descriptions, add context

**Issue:** Token budget exceeded frequently
**Solution:** Use context compression, optimize workflow steps, increase budget

**Issue:** Workflow fails at specific step
**Solution:** Test agent individually, check dependencies, validate input

**Issue:** Slow execution
**Solution:** Profile workflow, optimize context passing, consider parallel execution

## Related Commands

- `/crew` - Discover available agents
- `/wflw` - Generate workflow templates
- `/coord` - Real-time interactive coordination
- `/context-budget` - Monitor token usage
- `/aprof` - Profile agent capabilities
- `/current` - Check project status

---

## 🌊 "Like a whale pod executing a coordinated hunt, /orch brings multiple agents together in perfect synchronization."

**Command Version:** 1.0.0
**Last Updated:** October 13, 2025
**Status:** Specification Phase

---

*Orchestrate with the elegance of nature's most intelligent communicators*
