---
description: Deep agent profiling - analyze agent capabilities, performance, and optimal use cases
allowed-tools: Read(**/.claude/agents/**), Glob(**/.claude/agents/*.md), Grep(**), WebSearch, WebFetch(domain:docs.anthropic.com), Task(*)
---

# /aprof

Generate comprehensive profiles for agents including capabilities, optimal use cases, performance metrics, and integration patterns.

## Usage

```bash
# Profile specific agent
/aprof <agent-name>

# Profile multiple agents
/aprof <agent-1> <agent-2> <agent-3>

# Profile all agents
/aprof --all

# Profile by category
/aprof --category <research|coding|testing|devops|documentation>

# Generate comparison report
/aprof --compare <agent-1> <agent-2>

# Update agent profiles
/aprof --update <agent-name>

# Export profile as markdown
/aprof <agent-name> --export [path]
```

## Arguments

- `<agent-name>`: Name of agent to profile (e.g., `api-architect`, `code-craftsman`)
- `--all`: Profile all available agents
- `--category <type>`: Profile agents by category
- `--compare <agents>`: Generate comparison report between multiple agents
- `--update <agent>`: Refresh profile data for specific agent
- `--export [path]`: Export profile to markdown file (defaults to `docs/agents/<agent-name>.md`)

## What It Does

The `/aprof` command performs deep analysis of agent capabilities, creating comprehensive profiles that help you understand when and how to use each agent effectively.

### Single Agent Profiling

When profiling a single agent, the command:

1. **Reads Agent Definition**
   - Locates agent file in `.claude/agents/`
   - Parses agent description, tools, and capabilities
   - Identifies agent type and specialization

2. **Analyzes Capabilities**
   - Lists specific tasks the agent excels at
   - Identifies limitations and constraints
   - Documents required tools and permissions
   - Maps capability overlaps with other agents

3. **Performance Analysis**
   - Typical token usage ranges
   - Average execution time
   - Quality indicators
   - Success rate metrics

4. **Use Case Documentation**
   - Optimal scenarios for agent use
   - Common workflows involving agent
   - Integration patterns with other agents
   - Example prompts and invocations

5. **Best Practices**
   - When to use this agent vs alternatives
   - How to craft effective prompts
   - Common pitfalls to avoid
   - Optimal parameter configurations

6. **Integration Mapping**
   - Which agents commonly precede this one
   - Which agents commonly follow this one
   - Workflow patterns involving this agent
   - Data handoff requirements

### Multi-Agent Profiling

When profiling multiple agents or using `--all`:

1. **Batch Analysis**
   - Profiles each agent individually
   - Identifies capability overlaps
   - Maps complementary agents
   - Creates relationship graph

2. **Category Organization**
   - Groups agents by primary function
   - Identifies specialists vs generalists
   - Documents niche capabilities
   - Creates capability matrix

3. **Comparison Insights**
   - When to choose agent A vs agent B
   - Capability gaps between similar agents
   - Performance trade-offs
   - Use case decision trees

### Comparison Mode

When using `--compare`:

1. **Side-by-Side Analysis**
   - Capability comparison table
   - Performance metric comparison
   - Tool requirements comparison
   - Use case overlap identification

2. **Decision Framework**
   - When to use each agent
   - Scenarios favoring one over another
   - Complementary vs redundant capabilities
   - Workflow optimization recommendations

3. **Performance Comparison**
   - Token efficiency comparison
   - Quality trade-offs
   - Execution speed comparison
   - Context window utilization

### Update Mode

When using `--update`:

1. **Refreshes Agent Data**
   - Re-reads agent definition
   - Updates capability analysis
   - Refreshes performance metrics
   - Updates integration patterns

2. **Validates Profile**
   - Checks for outdated information
   - Verifies tool permissions
   - Updates best practices
   - Refreshes examples

### Export Mode

When using `--export`:

1. **Generates Markdown Documentation**
   - Complete agent profile
   - Formatted for human readability
   - Includes examples and use cases
   - Contains performance metrics

2. **Creates Reference Documentation**
   - Saves to `docs/agents/` by default
   - Includes front matter metadata
   - Formatted for documentation sites
   - Contains searchable sections

## Output Format

### Single Agent Profile

```markdown
# Agent Profile: api-architect

## Overview
**Type**: API Design & Database Architecture
**Specialization**: REST APIs, OpenAPI, Database Schema Design
**Token Range**: 14K-20K per invocation
**Average Time**: 12-16 minutes

## Description
Expert agent for designing RESTful APIs, creating database schemas, and generating API specifications. Excels at ensuring scalability, security, and adherence to industry best practices.

## Core Capabilities
- ✅ REST API endpoint design
- ✅ OpenAPI 3.0 specification generation
- ✅ Database schema design (SQL/NoSQL)
- ✅ API versioning strategies
- ✅ Authentication/authorization design
- ✅ Rate limiting and caching strategies
- ✅ Data model optimization
- ✅ Migration planning

## Tool Requirements
- Read (for analyzing existing APIs)
- Write (for creating specifications)
- WebSearch (for researching best practices)
- WebFetch (for analyzing API documentation)

## Optimal Use Cases

### 1. New API Design
**When**: Starting a new API project from scratch
**Why**: Ensures proper architecture from the start
**Example Prompt**:
```
Design a REST API for a task management system with user authentication,
project management, and real-time collaboration features.
```

### 2. Database Schema Design
**When**: Need to design or refactor database structure
**Why**: Creates optimized, scalable schemas with proper relationships
**Example Prompt**:
```
Design a PostgreSQL schema for an e-commerce platform with products,
orders, customers, inventory, and payment processing.
```

### 3. OpenAPI Documentation
**When**: Need formal API specifications
**Why**: Generates comprehensive, standards-compliant documentation
**Example Prompt**:
```
Create OpenAPI 3.0 specification for our existing user management endpoints
with proper schemas, examples, and security definitions.
```

## Limitations
- ❌ Does not implement code (use `code-craftsman` for implementation)
- ❌ Does not test APIs (use `test-engineer` for testing)
- ❌ Does not deploy (use `deployment-orchestrator` for deployment)
- ⚠️ Focuses on design, not implementation details

## Integration Patterns

### Typical Workflow Sequences

**API Development Flow**:
1. `api-architect` → Design API architecture
2. `code-craftsman` → Implement endpoints
3. `test-engineer` → Create test suite
4. `docs-generator` → Generate documentation

**Database Migration Flow**:
1. `api-architect` → Design new schema
2. `practical-programmer` → Create migration scripts
3. `test-engineer` → Test migration
4. `docs-generator` → Document changes

### Complementary Agents
- **Before**: `deep-researcher` (research API patterns)
- **After**: `code-craftsman` (implement design)
- **Parallel**: `docs-generator` (document architecture)

### Alternative Agents
- `practical-programmer`: More implementation-focused, less design
- `code-craftsman`: Implementation rather than architecture
- `frontend-architect`: For UI/UX architecture (non-API)

## Performance Metrics

### Token Usage
- **Minimum**: 14,000 tokens (simple API design)
- **Average**: 16,000 tokens (typical REST API)
- **Maximum**: 20,000 tokens (complex microservice architecture)

### Time Estimates
- **Simple Design**: 10-12 minutes
- **Typical Project**: 12-16 minutes
- **Complex Architecture**: 16-20 minutes

### Quality Indicators
- ✅ Consistent design patterns
- ✅ Industry best practices
- ✅ Comprehensive documentation
- ✅ Scalability considerations
- ✅ Security-first approach

## Best Practices

### Effective Prompts
✅ **Good**: "Design a REST API for user authentication with JWT, including password reset, email verification, and role-based access control"
❌ **Bad**: "Make an auth API"

✅ **Good**: "Create a PostgreSQL schema for a blog platform with posts, comments, tags, and user relationships. Include indexes for common queries."
❌ **Bad**: "Database for blog"

### When to Use
- ✅ Starting new API projects
- ✅ Refactoring existing APIs
- ✅ Creating API specifications
- ✅ Designing database schemas
- ✅ Planning API versioning

### When NOT to Use
- ❌ Writing implementation code
- ❌ Testing APIs
- ❌ Deploying services
- ❌ Debugging runtime issues
- ❌ Performance optimization (use after design phase)

### Common Pitfalls
1. **Asking for implementation**: This agent designs, doesn't implement
   - Solution: Follow up with `code-craftsman`

2. **Vague requirements**: "Make an API" without specifics
   - Solution: Provide detailed requirements, features, and constraints

3. **Mixing concerns**: Asking for design + implementation + deployment
   - Solution: Use `/orch` or `/coord` for multi-phase work

4. **Ignoring constraints**: Not specifying technology stack or limitations
   - Solution: Explicitly state tech stack, scalability needs, and constraints

## Example Invocations

### Via Direct Task Call
```python
Task(
    prompt="Design a REST API for a movie recommendation system with user profiles, ratings, recommendations, and social features. Include OpenAPI specification.",
    subagent_type="api-architect"
)
```

### Via /orch Command
```bash
/orch "Design and implement movie recommendation API" --agents api-architect,code-craftsman,test-engineer
```

### Via Workflow
```yaml
# In .claude/workflows/api-development.yaml
- id: design-api
  description: Design REST API with OpenAPI
  suggested_agent: api-architect
  estimated_tokens: 16000
```

## Recent Updates
- Last profiled: 2025-10-12
- Agent version: 1.0
- Performance data: Based on 50+ invocations

## Related Agents
- `code-craftsman` - For implementing the designed API
- `test-engineer` - For testing API endpoints
- `docs-generator` - For API documentation
- `practical-programmer` - For pragmatic implementation decisions
- `deployment-orchestrator` - For deploying APIs

## Resources
- [REST API Best Practices](https://docs.anthropic.com)
- [OpenAPI Specification](https://spec.openapis.org)
- [Database Design Principles](https://docs.anthropic.com)
```

### Comparison Report

```markdown
# Agent Comparison: api-architect vs practical-programmer

## Overview
Both agents can contribute to API development, but with different focuses and strengths.

## Capability Comparison

| Capability | api-architect | practical-programmer |
|------------|---------------|---------------------|
| API Design | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Implementation | ⭐ | ⭐⭐⭐⭐⭐ |
| OpenAPI Specs | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Database Design | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Code Quality | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Architecture | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Pragmatism | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Best Practices | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## Performance Comparison

### Token Usage
- **api-architect**: 14K-20K (design-focused)
- **practical-programmer**: 16K-24K (implementation-focused)

### Time Estimates
- **api-architect**: 12-16 min (design phase)
- **practical-programmer**: 15-20 min (implementation phase)

### Quality
- **api-architect**: Excellent architecture, formal specs
- **practical-programmer**: Pragmatic, maintainable code

## When to Use Each

### Use api-architect when:
- ✅ Starting a new API project
- ✅ Need formal OpenAPI specification
- ✅ Designing database schema
- ✅ Architecture decisions needed
- ✅ Ensuring industry best practices

### Use practical-programmer when:
- ✅ Implementing designed APIs
- ✅ Refactoring existing code
- ✅ Solving practical coding problems
- ✅ Need working code quickly
- ✅ Balancing ideals with pragmatism

## Workflow Integration

### Sequential Pattern (Recommended)
```
api-architect → practical-programmer → test-engineer
     (design)     (implement)           (test)
```

### When to Use Together
Both agents shine in different phases:
1. `api-architect` designs the architecture
2. `practical-programmer` implements it pragmatically
3. Result: Well-designed, pragmatic, maintainable code

## Overlap Areas
Both agents can handle:
- API design (architect is more formal, programmer more pragmatic)
- Database schema (architect is more comprehensive)
- Architecture decisions (architect is more theoretical, programmer more practical)

## Decision Framework

```
Need formal specs + architecture? → api-architect
Need working code + pragmatism? → practical-programmer
Need both? → Use both sequentially (architect first)
```
```

## Examples

### Example 1: Profile Single Agent
```bash
/aprof code-craftsman
```

**Output**:
```markdown
# Agent Profile: code-craftsman

## Overview
**Type**: Code Implementation
**Specialization**: Writing clean, maintainable code across multiple languages
**Token Range**: 16K-24K per invocation
**Average Time**: 15-20 minutes

[Full profile with capabilities, use cases, limitations, integration patterns, etc.]
```

### Example 2: Compare Agents
```bash
/aprof --compare test-engineer practical-programmer
```

**Output**: Side-by-side comparison showing when to use each agent, capability differences, performance trade-offs, and workflow recommendations.

### Example 3: Profile by Category
```bash
/aprof --category research
```

**Output**: Profiles all research-focused agents (deep-researcher, mercurio-orchestrator, claude-sdk-expert, etc.)

### Example 4: Export Profile
```bash
/aprof frontend-architect --export docs/agents/frontend-architect.md
```

**Output**: Creates comprehensive markdown documentation in specified location.

### Example 5: Profile All Agents
```bash
/aprof --all
```

**Output**: Generates profiles for all available agents, organized by category with capability matrix.

## Integration with Other Commands

### With /orch
`/aprof` helps you choose optimal agents for orchestration:
```bash
# First, understand agent capabilities
/aprof api-architect code-craftsman

# Then orchestrate with knowledge
/orch "Build REST API" --agents api-architect,code-craftsman
```

### With /crew
`/crew` discovers agents, `/aprof` profiles them:
```bash
# Discover agents
/crew --type coding

# Profile discovered agents for detailed info
/aprof code-craftsman practical-programmer code-trimmer
```

### With /wflw
Use profiles to select optimal agents for workflow steps:
```bash
# Profile agents first
/aprof api-architect

# Use insights when generating workflow
/wflw --generate "API Development" --steps "design:api-architect,implement:code-craftsman"
```

### With /coord
Reference profiles during coordination sessions:
```bash
# Start coordination
/coord start "Build authentication system"

# Check agent profiles to make informed decisions
/aprof api-architect code-craftsman

# Proceed with coordination
/coord next
```

## Profile Storage

Profiles are generated on-demand and can be cached:

### Default Locations
- **Generated Profiles**: In-memory (not persisted by default)
- **Exported Profiles**: `docs/agents/<agent-name>.md`
- **Comparison Reports**: `docs/agents/comparisons/<agent-1>-vs-<agent-2>.md`

### Profile Cache
```yaml
# .claude/cache/agent-profiles.yaml
profiles:
  api-architect:
    last_updated: 2025-10-12T15:30:00Z
    token_avg: 16234
    success_rate: 0.95
    usage_count: 47

  code-craftsman:
    last_updated: 2025-10-12T15:31:00Z
    token_avg: 18567
    success_rate: 0.94
    usage_count: 89
```

## Profile Categories

Agents are automatically categorized:

### Research & Analysis
- deep-researcher
- mercurio-orchestrator
- claude-sdk-expert
- unix-command-master

### Code Development
- code-craftsman
- practical-programmer
- code-trimmer
- frontend-architect

### Testing & Quality
- test-engineer
- debug-detective

### DevOps & Deployment
- deployment-orchestrator
- devops-github-expert
- github-workflow-expert
- git-genius

### Documentation
- docs-generator
- doc-rag-builder

### Specialized
- api-architect
- mcp-integration-wizard
- astro-manager
- youtube-summarizer

## Use Cases

### 1. Learning Agent Capabilities
When new to the system, profile agents to understand what they can do.

### 2. Workflow Planning
Before creating workflows, profile candidate agents to select optimal ones.

### 3. Debugging Agent Selection
When tasks fail, profile agents to understand if you chose the right one.

### 4. Performance Optimization
Profile agents to understand token usage and time estimates for optimization.

### 5. Documentation
Export profiles as reference documentation for team members.

### 6. Agent Comparison
When multiple agents seem suitable, compare them to make informed choices.

## Performance Considerations

### Token Usage
- **Single Profile**: ~5K-8K tokens
- **Comparison (2 agents)**: ~10K-14K tokens
- **Category Profiling**: ~15K-25K tokens
- **All Agents**: ~50K-80K tokens

### Time Estimates
- **Single Profile**: 4-6 minutes
- **Comparison**: 8-12 minutes
- **Category**: 12-18 minutes
- **All Agents**: 30-45 minutes

## Related Commands

- `/crew` - Discover available agents
- `/orch` - Orchestrate agents based on profiles
- `/wflw` - Create workflows using agent insights
- `/coord` - Interactive coordination with agent knowledge
- `/context-budget` - Monitor token usage during profiling

## Tips for Best Results

1. **Start with Single Profiles**: Understand individual agents before comparing
2. **Use Comparisons Wisely**: Compare similar agents to make informed choices
3. **Export Important Profiles**: Save frequently-used agent profiles as reference
4. **Update Periodically**: Run `--update` to refresh performance metrics
5. **Category Profiling**: Use categories to quickly understand agent landscape
6. **Integrate with Planning**: Profile before planning complex workflows

## Philosophy

Understanding your agents is like understanding your team members—knowing their strengths, limitations, and optimal use cases leads to better task assignment and higher success rates. The `/aprof` command transforms vague awareness of available agents into deep, actionable knowledge for optimal agent selection and orchestration.
