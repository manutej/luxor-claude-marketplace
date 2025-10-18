---
description: Create agent from /meta-agent specification
args:
  - name: spec_source
    description: Specification YAML (inline string or @file.yaml)
  - name: flags
    description: Optional --help, --dry-run, --overwrite
allowed-tools: Read(**/.claude/**), Write(**/.claude/agents/*.md), Glob(**/.claude/agents/*.md), Grep(**), TodoWrite
---

# Create Agent

Create agent file from specification: $ARGUMENTS

## Existing Agents (reference patterns)
<!-- Dynamic listing disabled: !`ls -1 .claude/agents/ | head -10` -->
Use Glob tool to list agents if needed.

## Your Task

Parse the specification and create `.claude/agents/<name>.md` agent definition file.

### 1. Parse Specification

Extract from $ARGUMENTS:
- Load YAML (inline or from @file path)
- Extract: agent name, type, capabilities, responsibilities, examples
- Validate: required fields, no conflicts, proper agent structure

### 2. Generate Agent File

Create `.claude/agents/<name>.md` with:

**Frontmatter (optional for agents):**
```yaml
---
# Agent metadata if needed
---
```

**Body Structure:**
```markdown
# Agent Name

Brief description of agent's purpose and specialized capabilities.

## Core Responsibilities

- Primary responsibility 1
- Primary responsibility 2
- Primary responsibility 3

## When to Use This Agent

**Use this agent for:**
- Specific scenario 1
- Specific scenario 2
- Specific scenario 3

**Don't use for:**
- Wrong scenario 1
- Wrong scenario 2

**Invocation:** Task() or via /command-name

## Implementation Approach

### Phase 1: [Phase Name]
1. What agent does in this phase
2. Tools used
3. Outputs generated

### Phase 2: [Phase Name]
1. Next phase actions
2. Validation performed
3. Results produced

[More phases as needed]

## Examples

[6-10 high-quality examples - see below]

## Integration Patterns

### Sequential Workflows
How this agent works in sequence with others

### Parallel Workflows
When this agent can run concurrently

### Command Integration
Slash commands that invoke this agent

## Quality Standards

- Output requirements
- Validation criteria
- Best practices

## Output Format

What the agent produces when complete
```

### 3. Generate Examples (CRITICAL)

**Create 6-10 comprehensive examples** covering:

**Sources for examples:**
1. **Spec examples** (copy from specification)
2. **Primary capabilities** (one per major capability)
3. **Use cases** (different scenarios)
4. **Integration patterns** (with other agents/commands)
5. **Complex workflows** (multi-step processes)

**Example template:**
```markdown
### Example N: [Clear, Specific Description]

**Task:**
\`\`\`
Task(
  prompt="Detailed task description with context",
  subagent_type="agent-name"
)
\`\`\`

**Process:**
- What agent does step-by-step
- Tools and capabilities used
- Intermediate outputs

**Output:**
- Final deliverables
- Files created
- Analysis provided

**Use case:** When you need this specific capability
```

**Coverage checklist:**
- ✓ Basic agent invocation (1 example)
- ✓ Each core responsibility (1 example per responsibility)
- ✓ Complex workflow (1-2 examples)
- ✓ Integration with other agents (1-2 examples)
- ✓ Integration with commands (1 example)
- ✓ Edge case or advanced usage (1 example)

### 4. Agent Type Considerations

**Task-Invoked Agent** (most common):
- Self-contained workflow
- Invoked via Task() tool
- Specialized domain expertise
- Example structure from spec

**Command-Driven Tool** (hybrid):
- Has associated slash command
- Can be invoked directly or via Task()
- More user-facing
- Include command integration section

### 5. Handle Flags

Parse from $ARGUMENTS:
- `--help`: Show usage guide and examples (don't create file)
- `--dry-run`: Preview without creating file
- `--overwrite`: Replace existing agent
- Default: Create new agent with 6-10 examples

**If `--help` flag detected:**
Show comprehensive help text:
```
📖 /agent - Create Agent from Specification

USAGE:
  /agent @spec-file.yaml [flags]
  /agent "<yaml-string>" [flags]

ARGUMENTS:
  spec_source    Agent specification YAML (inline or @file path)

FLAGS:
  --help         Show this help message
  --dry-run      Preview without creating file
  --overwrite    Replace existing agent file

EXAMPLES:
  # Create from file
  /agent @specs/security-analyzer.spec.yaml

  # Preview before creating
  /agent "<yaml>" --dry-run

  # Replace existing agent
  /agent @specs/updated-agent.spec.yaml --overwrite

WORKFLOW:
  1. Generate spec: /meta-agent "agent description"
  2. Review specification output
  3. Create agent: /agent "<spec>"
  4. Test: Task("task", subagent_type="agent-name")

AGENT vs COMMAND:
  • Agent: Task-invoked, multi-phase workflow, specialized expertise
  • Command: User-facing, direct invocation, parameterized

See Examples section for detailed patterns.
```
Then EXIT without creating file.

### 6. Validation

Before writing:
- ✓ Clear core responsibilities defined
- ✓ Implementation approach with phases
- ✓ At least 4 examples (warn if fewer)
- ✓ Examples cover major responsibilities
- ✓ Integration patterns specified
- ✓ No conflicts (unless --overwrite)

### 7. Create File & Confirm

Write to: `.claude/agents/<name>.md`

Confirm with:
```
✅ Agent created: .claude/agents/<name>.md

📊 Generated:
  - N core responsibilities
  - M implementation phases
  - K examples
  - P integration patterns

🎯 Test: Task("task description", subagent_type="<name>")
```

## Examples

### Example 1: Research Agent (Standard Pattern)

**Input:**
```bash
/agent @specs/claude-sdk-expert.spec.yaml
```

**Spec contains:**
```yaml
agent:
  name: claude-sdk-expert
  type: task-invoked
  description: Claude SDK and Anthropic API expert
capabilities:
  primary:
    - sdk_research
    - api_integration_guidance
    - implementation_patterns
  research_modes:
    - /deep with web search
    - documentation analysis
responsibilities:
  - Research Claude SDK capabilities
  - Provide implementation guidance
  - Generate integration examples
```

**Generated agent:**
```markdown
# claude-sdk-expert

Expert agent specializing in Claude SDK, Anthropic APIs, and AI integration patterns. Conducts comprehensive research using /deep command and provides implementation guidance.

## Core Responsibilities

- Research Claude SDK architecture and capabilities using web search
- Analyze Anthropic API documentation comprehensively
- Provide implementation guidance for SDK integration
- Generate tested code examples and best practices
- Document integration patterns and common pitfalls

## When to Use This Agent

**Use this agent for:**
- Integrating Claude SDK into applications
- Understanding Anthropic API features and limits
- Building AI-powered features with Claude
- Researching Claude best practices and patterns
- Troubleshooting SDK integration issues

**Don't use for:**
- General web research (use deep-researcher)
- Non-Claude API integration (use appropriate agent)
- Frontend-specific work (use frontend-architect)

**Invocation:** Task() with specific SDK questions

## Implementation Approach

### Phase 1: Research & Discovery
1. Use /deep command with web search for latest docs
2. Focus on docs.anthropic.com and official sources
3. Analyze SDK documentation comprehensively
4. Identify relevant API features for task

### Phase 2: Analysis & Synthesis
1. Extract key SDK capabilities
2. Identify implementation patterns
3. Note best practices and constraints
4. Consider integration requirements

### Phase 3: Documentation & Examples
1. Generate comprehensive integration guide
2. Create tested code examples
3. Document configuration and setup
4. Provide troubleshooting guidance

## Examples

### Example 1: Basic SDK Integration Research

**Task:**
\`\`\`
Task(
  prompt="Research how to integrate Claude SDK into a Node.js backend. Include authentication, message handling, and streaming.",
  subagent_type="claude-sdk-expert"
)
\`\`\`

**Process:**
- Uses /deep to research Claude SDK documentation
- Analyzes authentication methods
- Documents message API usage
- Explains streaming implementation

**Output:**
- Integration guide in docs/claude-sdk-integration.md
- Code examples for auth and messaging
- Configuration instructions
- Best practices documentation

**Use case:** Starting new Claude SDK integration

### Example 2: Advanced Feature Research

**Task:**
\`\`\`
Task(
  prompt="Research Claude extended thinking API. How to enable it, configure budget, and extract thinking blocks from responses.",
  subagent_type="claude-sdk-expert"
)
\`\`\`

**Process:**
- Researches extended thinking documentation
- Analyzes API parameters and configuration
- Studies thinking block extraction
- Creates implementation examples

**Output:**
- Extended thinking guide with code examples
- Token budget recommendations
- Error handling patterns

**Use case:** Implementing advanced Claude features

### Example 3: Tool Use Implementation

**Task:**
\`\`\`
Task(
  prompt="How to implement tool use with Claude SDK? Include tool definition, result handling, and multi-turn conversations.",
  subagent_type="claude-sdk-expert"
)
\`\`\`

**Process:**
- Researches tool use documentation thoroughly
- Analyzes tool definition schemas
- Documents result handling patterns
- Explains conversation flow

**Output:**
- Complete tool use implementation guide
- Tool definition templates
- Multi-turn conversation examples

**Use case:** Building Claude applications with tools

### Example 4: Integration with MCP

**Task:**
\`\`\`
Task(
  prompt="Research how Claude SDK integrates with MCP servers. Document connection patterns and tool discovery.",
  subagent_type="claude-sdk-expert"
)
\`\`\`

**Process:**
- Researches MCP protocol integration
- Analyzes SDK MCP support
- Documents connection patterns
- Explains tool discovery flow

**Output:**
- MCP integration guide
- Connection examples
- Tool discovery documentation

**Use case:** Connecting Claude SDK to MCP servers

### Example 5: Sequential Workflow with Other Agents

**Task:**
\`\`\`
# Phase 1: Research
Task(
  prompt="Research Claude streaming API implementation",
  subagent_type="claude-sdk-expert"
)

# Phase 2: Implementation
Task(
  prompt="Implement streaming endpoint based on research",
  subagent_type="code-craftsman"
)

# Phase 3: Testing
Task(
  prompt="Create tests for streaming implementation",
  subagent_type="test-engineer"
)
\`\`\`

**Process:**
- claude-sdk-expert researches streaming API
- code-craftsman implements based on research
- test-engineer creates test suite
- Sequential dependencies maintained

**Use case:** Full feature implementation workflow

### Example 6: Error Troubleshooting

**Task:**
\`\`\`
Task(
  prompt="We're getting rate limit errors from Claude API. Research rate limits, implement retry logic with exponential backoff, and document best practices.",
  subagent_type="claude-sdk-expert"
)
\`\`\`

**Process:**
- Researches Claude API rate limits
- Analyzes error responses
- Designs retry strategy
- Documents implementation

**Output:**
- Rate limit documentation
- Retry logic implementation
- Error handling patterns
- Monitoring recommendations

**Use case:** Troubleshooting production issues

## Integration Patterns

### Sequential Workflows

**Research → Implementation → Testing:**
```
claude-sdk-expert → code-craftsman → test-engineer
```
Common for new feature development

**Research → Documentation:**
```
claude-sdk-expert → docs-generator
```
For creating SDK documentation

### Parallel Workflows

**Multiple Research Topics:**
```
claude-sdk-expert (streaming) || claude-sdk-expert (tools)
```
Can research different SDK topics in parallel

### Command Integration

**Via /deep command:**
```
/deep -r "Claude SDK streaming implementation" --sources=technical
```
Agent uses /deep internally for research

**Direct invocation:**
```
Task(..., subagent_type="claude-sdk-expert")
```
Standard agent invocation

## Quality Standards

- All research cites official Anthropic documentation
- Code examples are tested and functional
- Implementation guides include error handling
- Best practices backed by documentation
- Configuration examples are complete
- Integration patterns are realistic

## Output Format

Produces comprehensive documentation including:
- SDK integration guide (markdown)
- Code examples (tested)
- Configuration templates
- Best practices documentation
- Troubleshooting guide
- Links to official documentation
```

**Style:** Standard agent, 6 comprehensive examples

### Example 2: Specialized Technical Agent

**Input:**
```bash
/agent @specs/api-architect.spec.yaml
```

**Spec contains:**
```yaml
agent:
  name: api-architect
  type: task-invoked
  description: RESTful API and database schema designer
capabilities:
  - api_endpoint_design
  - openapi_specification
  - database_schema_design
  - rest_best_practices
responsibilities:
  - Design API structure
  - Create OpenAPI specs
  - Design database schemas
  - Document API patterns
```

**Generated agent highlights:**
```markdown
# api-architect

Design RESTful APIs and create database schemas with OpenAPI specifications.

## Core Responsibilities

- Design RESTful API endpoint structure
- Create OpenAPI 3.0 specifications
- Design database schemas with proper indexing
- Apply REST best practices and security patterns
- Document API authentication and authorization

## Examples

### Example 1: Basic API Design

**Task:**
\`\`\`
Task(
  prompt="Design REST API for user management including registration, authentication, and profile management",
  subagent_type="api-architect"
)
\`\`\`

**Process:**
- Analyzes user management requirements
- Designs endpoint structure
- Creates OpenAPI specification
- Designs database schema
- Documents authentication flow

**Output:**
- OpenAPI spec in docs/api/users.yaml
- Database schema in db/schema/users.sql
- API design document with rationale

### Example 2: Database Schema Design

**Task:**
\`\`\`
Task(
  prompt="Design PostgreSQL schema for e-commerce platform with products, orders, and inventory tracking. Include proper indexes and constraints.",
  subagent_type="api-architect"
)
\`\`\`

**Process:**
- Analyzes data relationships
- Designs normalized schema
- Adds appropriate indexes
- Defines foreign key constraints
- Plans for scalability

**Output:**
- Complete PostgreSQL schema
- Migration files
- Index optimization guide

[...more examples covering API design, integration, workflows]
```

### Example 3: Orchestration Agent (Complex)

**Input:**
```bash
/agent @specs/mercurio-orchestrator.spec.yaml
```

**Spec contains:**
```yaml
agent:
  name: mercurio-orchestrator
  type: task-invoked
  model: opus  # Higher-tier model
  description: Strategic multi-dimensional research and synthesis
capabilities:
  - comprehensive_research_synthesis
  - multi_source_integration
  - ethical_awareness
  - strategic_coordination
  - holistic_understanding
```

**Generated agent highlights:**
```markdown
# mercurio-orchestrator

Comprehensive research synthesis, strategic orchestration of complex multi-dimensional tasks, and deep knowledge integration that balances intellectual rigor with ethical awareness.

## Core Responsibilities

- Synthesize research from multiple diverse sources
- Create holistic understanding across dimensions
- Coordinate complex multi-phase research
- Balance technical, ethical, and practical considerations
- Generate strategic insights with moral awareness

## When to Use This Agent

**Use this agent for:**
- Beginning major research projects requiring synthesis
- Complex decisions needing multiple perspectives
- Coordinating multiple research streams
- Ethical implications analysis
- Building comprehensive knowledge maps

**Don't use for:**
- Simple single-topic research (use deep-researcher)
- Pure technical implementation (use code-craftsman)
- Quick lookups (use /deep -ws)

**Invocation:** Task() for complex, strategic work

## Implementation Approach

### Phase 1: Knowledge Mapping
1. Analyze research dimensions
2. Identify knowledge domains
3. Map relationships and dependencies
4. Plan synthesis strategy

### Phase 2: Multi-Source Research
1. Coordinate deep-researcher agents if needed
2. Gather information across dimensions
3. Track ethical considerations
4. Maintain source quality standards

### Phase 3: Synthesis & Integration
1. Integrate findings across domains
2. Identify patterns and connections
3. Balance perspectives ethically
4. Create holistic understanding

### Phase 4: Strategic Documentation
1. Generate NOUS.md knowledge synthesis
2. Document decision frameworks
3. Provide strategic recommendations
4. Include ethical considerations

## Examples

### Example 1: New Research Project

**Task:**
\`\`\`
Task(
  prompt="I need to understand quantum computing and its implications for cryptography. Create comprehensive knowledge map covering technical foundations, current state, ethical implications, and practical constraints.",
  subagent_type="mercurio-orchestrator"
)
\`\`\`

**Process:**
- Maps knowledge landscape (technical, ethical, practical)
- Coordinates research across dimensions
- Synthesizes findings in NOUS.md
- Balances technical depth with accessibility
- Includes ethical and security considerations

**Output:**
- NOUS.md with multi-dimensional synthesis
- Knowledge map showing relationships
- Strategic recommendations
- Ethical considerations documented

**Use case:** Starting major research initiative

### Example 2: Complex Decision Analysis

**Task:**
\`\`\`
Task(
  prompt="Evaluate whether to implement AI feature in healthcare product. Consider technical feasibility, ethical implications, regulatory constraints, user impact, and business viability.",
  subagent_type="mercurio-orchestrator"
)
\`\`\`

**Process:**
- Analyzes across five dimensions
- Researches each dimension deeply
- Considers ethical implications prominently
- Balances stakeholder perspectives
- Provides evidence-based recommendation

**Output:**
- Multi-dimensional analysis document
- Ethical impact assessment
- Risk and opportunity matrix
- Strategic recommendation with reasoning

**Use case:** High-stakes decisions requiring wisdom

[...more examples covering coordination, synthesis, ethical analysis]
```

### Example 4: Dry Run Preview

**Input:**
```bash
/agent @specs/test-agent.spec.yaml --dry-run
```

**What happens:**
- Parse specification completely
- Generate full agent file content
- **DO NOT write to disk**
- Show preview with statistics

**Output:**
```
🔍 DRY RUN MODE - Preview Only

Agent: test-agent
Output: .claude/agents/test-agent.md
Status: ✓ Valid

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PREVIEW: First 100 lines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# test-agent

Description of agent...

[preview continues]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics:
  Core responsibilities: 5
  Implementation phases: 3
  Examples: 8
  Integration patterns: 4

✅ Validation: All checks passed

To create: Remove --dry-run flag
```

**Use case:** Review before committing

### Example 5: Overwrite Existing Agent

**Input:**
```bash
/agent @specs/updated-agent.spec.yaml --overwrite
```

**What happens:**
- Check if agent file exists
- Create backup
- Generate new version
- Show changes

**Output:**
```
⚠️ Overwriting existing agent

Backup: .claude/agents/test-agent.md.backup

Changes detected:
  + Added new capability: streaming support
  + Updated implementation approach
  + Added 2 new examples
  ~ Modified existing examples for clarity

✅ Agent updated: .claude/agents/test-agent.md

Test: Task("test task", subagent_type="test-agent")
```

**Use case:** Iterating on agent design

### Example 6: Integration with /meta-agent

**Complete workflow:**
```bash
# Step 1: Generate specification
/meta-agent "agent for security vulnerability analysis in code"

# Output: Detailed agent specification YAML

# Step 2: Review specification
# (Verify capabilities, responsibilities, examples)

# Step 3: Create agent
/agent "<paste-specification-here>"

# Step 4: Test agent
Task(
  prompt="Analyze src/ for security vulnerabilities",
  subagent_type="security-analyzer"
)
```

**What happens:**
- /meta-agent analyzes intent and learns from patterns
- Generates agent specification with structure
- /agent transforms spec to agent definition
- Agent ready for Task() invocation

**Use case:** Complete agent creation workflow

## Agent vs Command Decision

From specification, determine optimal type:

**Create Agent when:**
- Self-contained multi-phase workflow
- Specialized domain expertise required
- Complex analysis or synthesis needed
- Invoked programmatically via Task()
- **Spec indicates:** `type: task-invoked`

**Create Command when:**
- User-facing interface needed
- Frequent direct invocation
- Parameterized execution required
- Quick utility or tool
- **Spec indicates:** `type: command-driven`

**Hybrid approach:**
- Agent file + Command file
- Command invokes agent internally
- Example: /ctx7 command invokes context7-doc-reviewer agent

## Quality Standards

Every agent you create must have:

✅ **Core Responsibilities:**
- 3-6 clear, specific responsibilities
- Focused scope
- Actionable descriptions

✅ **When to Use:**
- Clear guidance on appropriate scenarios
- Explicit anti-patterns (when NOT to use)
- Invocation method specified

✅ **Implementation Approach:**
- Broken into logical phases
- Each phase explains process
- Tools and capabilities noted
- Outputs defined per phase

✅ **Examples (6-10):**
- Each example shows Task() invocation
- Explains process step-by-step
- Documents outputs clearly
- Includes use case context
- Covers different scenarios

✅ **Integration Patterns:**
- Sequential workflow examples
- Parallel execution scenarios
- Command integration if applicable

✅ **Quality Standards:**
- Output requirements clear
- Validation criteria specified
- Best practices documented

## Your Response

After creating the agent file:

**If successful:**
```
✅ Agent created: .claude/agents/<name>.md

📊 Generated:
  - N core responsibilities
  - M implementation phases
  - K examples covering different scenarios
  - P integration patterns

🎯 Test the agent:
  Task(
    prompt="test task description",
    subagent_type="<name>"
  )

💡 Next: Test with real use cases and refine
```

**If dry-run:**
```
🔍 DRY RUN - Preview shown above

To create: Remove --dry-run flag
```

**If errors:**
```
❌ Error: <specific issue>

Resolution: <how to fix>
```

Now create the agent file from the specification!
