---
description: Generate and manage workflow YAML files for agent orchestration
allowed-tools: Read(**/.claude/workflows/**), Write(**/.claude/workflows/**), Glob(**/.claude/workflows/*.yaml), Grep(**)
---

# /wflw

Generate and manage reusable workflow YAML files that define sequential agent pipelines.

## Usage

```bash
# Generate new workflow YAML
/wflw --generate <name> "step1" → "step2" → "step3"

# List available workflows
/wflw --list

# Show workflow definition
/wflw --show <name>

# Edit workflow
/wflw --edit <name>

# Delete workflow
/wflw --delete <name>

# Validate workflow syntax
/wflw --validate <name>
```

## Arguments

- `--generate <name> "<step1>" → "<step2>" ...`: Create new workflow YAML file
- `--list`: Show all workflow files in .claude/workflows/
- `--show <name>`: Display workflow YAML contents
- `--edit <name>`: Open workflow for editing
- `--delete <name>`: Remove workflow file
- `--validate <name>`: Check workflow syntax and agent references

## What It Does

The `/wflw` command is a workflow YAML generator and manager. It creates structured workflow files that can be executed by `/orch` or other orchestration tools.

### Generate Workflow
1. Parses workflow steps from arguments (separated by → or ->)
2. Analyzes each step to suggest optimal agent
3. Generates YAML structure with:
   - Workflow metadata (name, created date, description)
   - Step definitions with suggested agents
   - Dependencies between steps
   - Estimated resource requirements
4. Saves to `.claude/workflows/<name>.yaml`
5. Validates syntax before saving

### List Workflows
1. Uses Glob to find all `.yaml` files in `.claude/workflows/`
2. Reads metadata from each file
3. Displays organized list with:
   - Workflow name and description
   - Number of steps
   - Suggested agents
   - Created/modified dates
4. Shows usage statistics if available

### Show Workflow
1. Reads workflow YAML file
2. Pretty-prints the structure
3. Shows:
   - All steps with descriptions
   - Suggested agents per step
   - Dependencies
   - Estimated resources
4. Provides execution command

### Validate Workflow
1. Parses YAML syntax
2. Checks all referenced agents exist
3. Validates dependency references
4. Verifies required fields present
5. Reports any issues found

## Workflow YAML Format

Workflows are saved in `.claude/workflows/<name>.yaml`:

```yaml
# api-development.yaml
name: api-development
description: Complete API development pipeline from design to deployment
created: 2025-10-12T14:30:00Z
version: 1.0

steps:
  - id: design-api
    description: Design REST API with OpenAPI specification
    suggested_agent: api-architect
    estimated_tokens: 16000
    estimated_time_minutes: 12
    inputs: []
    outputs:
      - openapi_spec
      - api_design_doc

  - id: implement-endpoints
    description: Implement Express.js endpoints from design
    suggested_agent: code-craftsman
    estimated_tokens: 18000
    estimated_time_minutes: 14
    depends_on:
      - design-api
    inputs:
      - openapi_spec
    outputs:
      - source_code
      - implementation_files

  - id: create-tests
    description: Create comprehensive test suite
    suggested_agent: test-engineer
    estimated_tokens: 14000
    estimated_time_minutes: 11
    depends_on:
      - implement-endpoints
    inputs:
      - source_code
      - openapi_spec
    outputs:
      - test_files
      - coverage_report

  - id: generate-docs
    description: Generate API documentation
    suggested_agent: docs-generator
    estimated_tokens: 12000
    estimated_time_minutes: 9
    depends_on:
      - design-api
      - implement-endpoints
    inputs:
      - openapi_spec
      - source_code
    outputs:
      - api_documentation

metadata:
  total_steps: 4
  total_estimated_tokens: 60000
  total_estimated_time_minutes: 46
  tags:
    - api
    - backend
    - development
  author: user

execution:
  strategy: sequential  # or parallel where possible
  optimization: balanced  # or speed, tokens, quality
```

## Examples

### Example 1: Generate Simple Workflow
```bash
/wflw --generate api-development "Design REST API with OpenAPI" → "Implement Express.js endpoints" → "Create comprehensive tests" → "Generate API documentation"
```

**Output**:
```
✅ Workflow Generated: api-development

📋 Steps Defined:
  1. Design REST API with OpenAPI
     → Suggested agent: api-architect
     → Estimated: 16K tokens, ~12 min
     → Outputs: openapi_spec, api_design_doc

  2. Implement Express.js endpoints
     → Suggested agent: code-craftsman
     → Estimated: 18K tokens, ~14 min
     → Depends on: step 1
     → Inputs: openapi_spec
     → Outputs: source_code

  3. Create comprehensive tests
     → Suggested agent: test-engineer
     → Estimated: 14K tokens, ~11 min
     → Depends on: step 2
     → Inputs: source_code, openapi_spec
     → Outputs: test_files

  4. Generate API documentation
     → Suggested agent: docs-generator
     → Estimated: 12K tokens, ~9 min
     → Depends on: steps 1, 2
     → Inputs: openapi_spec, source_code
     → Outputs: api_documentation

📊 Workflow Summary:
  Total steps: 4
  Total estimated tokens: 60K
  Total estimated time: 46 minutes
  Execution strategy: sequential

💾 Saved to: .claude/workflows/api-development.yaml

▶️  Execute with: /orch --workflow api-development
📝 Edit: /wflw --edit api-development
👁️  View: /wflw --show api-development
```

### Example 2: List Workflows
```bash
/wflw --list
```

**Output**:
```
📚 Available Workflows (.claude/workflows/)

┌─────────────────────┬───────┬──────────────────────────┬─────────────┐
│ Name                │ Steps │ Description              │ Modified    │
├─────────────────────┼───────┼──────────────────────────┼─────────────┤
│ api-development     │ 4     │ Complete API pipeline    │ 2 hours ago │
│ feature-complete    │ 5     │ Feature from start to    │ 1 day ago   │
│                     │       │ deployment               │             │
│ research-to-docs    │ 3     │ Research and document    │ 3 days ago  │
│ security-audit-fix  │ 4     │ Security audit and       │ 1 week ago  │
│                     │       │ remediation              │             │
│ deploy-pipeline     │ 6     │ Full deployment workflow │ 2 weeks ago │
└─────────────────────┴───────┴──────────────────────────┴─────────────┘

Total: 5 workflows

Commands:
  📋 Show details: /wflw --show <name>
  ✏️  Edit workflow: /wflw --edit <name>
  ▶️  Execute: /orch --workflow <name>
  🗑️  Delete: /wflw --delete <name>

💡 Tip: Use /orch --workflow <name> to execute any workflow
```

### Example 3: Show Workflow Details
```bash
/wflw --show api-development
```

**Output**:
```
📋 Workflow: api-development

Description: Complete API development pipeline from design to deployment
Created: 2025-10-12 14:30
Version: 1.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Steps:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  design-api
    Design REST API with OpenAPI specification

    Agent: api-architect
    Estimated: 16,000 tokens | ~12 min

    Inputs: (none - starting step)
    Outputs:
      • openapi_spec
      • api_design_doc

2️⃣  implement-endpoints
    Implement Express.js endpoints from design

    Agent: code-craftsman
    Estimated: 18,000 tokens | ~14 min

    Depends on: design-api
    Inputs:
      • openapi_spec (from step 1)
    Outputs:
      • source_code
      • implementation_files

3️⃣  create-tests
    Create comprehensive test suite

    Agent: test-engineer
    Estimated: 14,000 tokens | ~11 min

    Depends on: implement-endpoints
    Inputs:
      • source_code (from step 2)
      • openapi_spec (from step 1)
    Outputs:
      • test_files
      • coverage_report

4️⃣  generate-docs
    Generate API documentation

    Agent: docs-generator
    Estimated: 12,000 tokens | ~9 min

    Depends on: design-api, implement-endpoints
    Inputs:
      • openapi_spec (from step 1)
      • source_code (from step 2)
    Outputs:
      • api_documentation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
  Total steps: 4
  Estimated tokens: 60,000
  Estimated time: 46 minutes
  Strategy: sequential (with parallel opportunities)

🏷️  Tags: api, backend, development

📄 File: .claude/workflows/api-development.yaml

▶️  Execute: /orch --workflow api-development
✏️  Edit: /wflw --edit api-development
✅ Validate: /wflw --validate api-development
```

### Example 4: Validate Workflow
```bash
/wflw --validate api-development
```

**Output**:
```
✅ Workflow Validation: api-development

Checking YAML syntax... ✅ Valid
Checking required fields... ✅ All present
Checking agent references... ✅ All agents exist
  • api-architect: Found
  • code-craftsman: Found
  • test-engineer: Found
  • docs-generator: Found

Checking dependencies... ✅ Valid
  • Step 2 depends on step 1: Valid
  • Step 3 depends on step 2: Valid
  • Step 4 depends on steps 1, 2: Valid
  • No circular dependencies detected

Checking data flow... ✅ Consistent
  • openapi_spec: Produced by step 1, used by steps 2, 3, 4
  • source_code: Produced by step 2, used by steps 3, 4
  • All inputs have corresponding outputs

Optimization Suggestions:
  💡 Steps 1 and 3 could potentially run in parallel
  💡 Consider splitting generate-docs to run partially in parallel

Overall: ✅ Workflow is valid and executable

▶️  Ready to execute: /orch --workflow api-development
```

### Example 5: Generate Complex Workflow with Parallel Steps
```bash
/wflw --generate security-review "scan for vulnerabilities" → "analyze dependencies" → "review authentication" → "generate security report"
```

**Generated YAML includes**:
```yaml
name: security-review
description: Comprehensive security review workflow

steps:
  - id: scan-vulnerabilities
    description: Scan for security vulnerabilities
    suggested_agent: debug-detective
    can_parallelize: true  # Can run with other scans

  - id: analyze-dependencies
    description: Analyze dependencies for known vulnerabilities
    suggested_agent: practical-programmer
    can_parallelize: true  # Can run with other scans

  - id: review-authentication
    description: Review authentication and authorization
    suggested_agent: practical-programmer
    depends_on:
      - scan-vulnerabilities
    can_parallelize: false

  - id: generate-report
    description: Generate comprehensive security report
    suggested_agent: docs-generator
    depends_on:
      - scan-vulnerabilities
      - analyze-dependencies
      - review-authentication

execution:
  strategy: parallel_where_possible
  parallel_groups:
    - [scan-vulnerabilities, analyze-dependencies]  # Run together
    - [review-authentication]  # Sequential
    - [generate-report]  # Final step
```

## Directory Structure

```
.claude/
├── workflows/
│   ├── api-development.yaml
│   ├── feature-complete.yaml
│   ├── research-to-docs.yaml
│   ├── security-audit-fix.yaml
│   └── deploy-pipeline.yaml
└── workflows/
    └── templates/
        ├── basic-feature.yaml.template
        ├── api-project.yaml.template
        └── research-project.yaml.template
```

## Workflow Templates

You can create templates in `.claude/workflows/templates/`:

```yaml
# basic-feature.yaml.template
name: ${FEATURE_NAME}
description: ${FEATURE_DESCRIPTION}

steps:
  - id: design
    description: Design ${FEATURE_NAME}
    suggested_agent: ${DESIGN_AGENT}

  - id: implement
    description: Implement ${FEATURE_NAME}
    suggested_agent: code-craftsman
    depends_on: [design]

  - id: test
    description: Test ${FEATURE_NAME}
    suggested_agent: test-engineer
    depends_on: [implement]
```

Generate from template:
```bash
/wflw --from-template basic-feature --name user-profile --design-agent frontend-architect
```

## Integration Points

### With /orch
- `/orch --workflow <name>` executes workflow YAML
- `/orch` can suggest saving as workflow
- Shared workflow validation logic

### With /crew
- Uses agent catalog to suggest agents
- Validates agent references
- Shows agent capabilities per step

### With /context-budget
- Includes token estimates in YAML
- Helps plan resource usage
- Tracks actual vs estimated tokens

## Tips for Best Results

1. **Descriptive Names**: Use clear workflow names like `api-development` not `workflow1`
2. **Document Steps**: Add detailed step descriptions in YAML
3. **Tag Workflows**: Use tags for easy filtering
4. **Version Workflows**: Update version number when modifying
5. **Validate Before Executing**: Run `--validate` to catch issues
6. **Use Templates**: Create templates for common patterns
7. **Estimate Resources**: Include token/time estimates
8. **Define Data Flow**: Specify inputs/outputs clearly

## Error Handling

### Invalid YAML Syntax
```
❌ Validation Failed: api-development

Error at line 12:
  - id: implement-endpoints
    description Implement endpoints  # Missing colon

Expected: "description: Implement endpoints"

Fix the YAML syntax and run /wflw --validate again
```

### Missing Agent Reference
```
❌ Validation Failed: api-development

Agent not found: "api-architectt" (step 1)

Did you mean: "api-architect"?

Available agents:
  - api-architect
  - code-craftsman
  - test-engineer

Update the YAML file and validate again
```

### Circular Dependency
```
❌ Validation Failed: bad-workflow

Circular dependency detected:
  Step 2 depends on step 3
  Step 3 depends on step 4
  Step 4 depends on step 2

Workflows must be acyclic (no circular dependencies)

Review dependencies and update the YAML file
```

## Related Commands

- `/orch --workflow <name>` - Execute workflow
- `/crew` - Discover agents for workflow steps
- `/context-budget` - Estimate workflow token cost
- `/coord` - Alternative for interactive coordination

## Version History

- v1.0: Initial workflow YAML generator
- v1.1: Added validation
- v1.2: Template support
- v1.3: Parallel execution hints

## Philosophy

Workflows are reusable patterns. When you discover an effective sequence of agent tasks, codify it as a YAML workflow. The `/wflw` command makes it easy to capture, manage, and share these patterns—turning successful one-time executions into repeatable, maintainable pipelines.

Think of `/wflw` as your workflow library manager, where `/orch` is the execution engine that brings these workflows to life.
