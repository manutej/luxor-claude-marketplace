---
description: Enhanced agent discovery and management with search, stats, and comparison
allowed-tools: Read(**/.claude/agents/**), Glob(**/.claude/agents/*.md), Grep(**)
---

# /crew

Discover, search, and analyze available agents with advanced filtering, statistics, and performance metrics.

## Usage

```bash
# List all agents
/crew

# Search by capability
/crew --search "API design"
/crew --search "performance optimization"

# Filter by type
/crew --by-type research
/crew --by-type implementation
/crew --by-type orchestration

# Show statistics
/crew --stats
/crew --stats --by-usage
/crew --stats --by-performance

# Compare agents
/crew --compare "code-craftsman" "practical-programmer"
```

## Arguments

- No arguments: List all available agents
- `--search "<capability>"`: Search agents by capability description
- `--by-type <type>`: Filter agents by category (research, coding, testing, deployment, orchestration, documentation)
- `--stats`: Show usage and performance statistics
- `--stats --by-usage`: Sort statistics by usage frequency
- `--stats --by-performance`: Sort statistics by efficiency
- `--compare "<agent1>" "<agent2>"`: Compare two agents side-by-side

## What It Does

The `/crew` command provides comprehensive agent management capabilities.

### Standard Listing Mode
1. Uses Glob to find all `.md` files in `.claude/agents/` directories
2. Reads agent definition files with Read tool
3. Extracts frontmatter (name, description, model, color)
4. Groups agents by type (research, coding, testing, deployment, etc.)
5. Calculates average token usage from logs (if available)
6. Displays organized listing with usage indicators

### Search Mode
1. Parses search query from arguments
2. Uses Grep to search agent descriptions, capabilities, and examples
3. Reads matching agent files fully
4. Ranks by relevance score (0-100)
5. Displays matches with context highlights
6. Suggests related agents based on patterns

### Statistics Mode
1. Analyzes agent invocation history (from logs if available)
2. Calculates usage frequency per agent
3. Measures average token consumption per invocation
4. Tracks success rates and common failures
5. Generates performance report with rankings
6. Identifies optimization opportunities

### Comparison Mode
1. Reads both agent definition files
2. Extracts capabilities, model, typical usage
3. Compares side-by-side:
   - Core capabilities and strengths
   - Average token usage
   - Best use cases
   - Performance characteristics
4. Suggests when to use each agent
5. Identifies complementary usage patterns

## Examples

### Example 1: Basic Listing
```bash
/crew
```

**Output**:
```
🤖 Available Agents (28 total)

📚 Research & Documentation (5 agents)
  ├─ deep-researcher (sonnet)
  │  Comprehensive research using web search and synthesis
  │  Average tokens: 25K | Usage: High
  │
  ├─ claude-sdk-expert (sonnet)
  │  Expert in Claude SDK and Anthropic APIs
  │  Average tokens: 15K | Usage: Medium
  │
  └─ doc-rag-builder (sonnet)
     Scrape docs and build RAG systems
     Average tokens: 20K | Usage: Medium

💻 Code Development (7 agents)
  ├─ code-craftsman (sonnet)
  │  Write clean, maintainable code
  │  Average tokens: 18K | Usage: Very High
  │
  ├─ practical-programmer (sonnet)
  │  Pragmatic programmer following best practices
  │  Average tokens: 16K | Usage: High
  │
  └─ frontend-architect (sonnet)
     React and frontend expertise
     Average tokens: 20K | Usage: High

🧪 Testing & Quality (4 agents)
  ├─ test-engineer (sonnet)
  │  Comprehensive test suite creation
  │  Average tokens: 14K | Usage: High
  │
  └─ debug-detective (sonnet)
     Complex bug investigation and root cause analysis
     Average tokens: 22K | Usage: Medium

🎭 Orchestration (3 agents)
  ├─ mercurio-orchestrator (opus)
  │  Multi-dimensional research and task coordination
  │  Average tokens: 45K | Usage: Low
  │
  └─ project-orchestrator (opus)
     Comprehensive project tracking and management
     Average tokens: 35K | Usage: Medium

🚀 Deployment (2 agents)
  ├─ deployment-orchestrator (sonnet)
  │  Deploy microservices to cloud platforms
  │  Average tokens: 18K | Usage: Medium
  │
  └─ devops-github-expert (sonnet)
     GitHub operations and CI/CD
     Average tokens: 16K | Usage: High

💡 Tip: Use /crew --search "<capability>" to find specific agents
📊 Use /crew --stats for detailed analytics
🔍 Use /crew --compare <agent1> <agent2> to compare agents
```

### Example 2: Capability Search
```bash
/crew --search "API design and documentation"
```

**Output**:
```
🔍 Agent Search: "API design and documentation"

Top Matches:

1. api-architect (Relevance: 98%)
   Description: Design RESTful APIs and create OpenAPI specs
   Capabilities:
     ✓ API endpoint design
     ✓ OpenAPI documentation
     ✓ Database schema design
     ✓ REST best practices
   Model: sonnet | Avg tokens: 16K | Usage: High

   Example usage:
     Task("Design user management API", subagent_type="api-architect")

2. docs-generator (Relevance: 75%)
   Description: Generate comprehensive API documentation
   Capabilities:
     ✓ API reference docs
     ✓ JSDoc comments
     ✓ Technical documentation
   Model: sonnet | Avg tokens: 12K | Usage: Medium

   Example usage:
     Task("Document authentication API", subagent_type="docs-generator")

3. practical-programmer (Relevance: 62%)
   Description: Build maintainable, well-documented code
   Capabilities:
     ✓ Clean architecture
     ✓ Self-documenting code
     ✓ Best practices
   Model: sonnet | Avg tokens: 16K | Usage: High

💡 Recommendation: Use api-architect for comprehensive API design
   Then use docs-generator for detailed documentation

🔗 Common workflow:
   1. api-architect designs API structure
   2. code-craftsman implements endpoints
   3. docs-generator creates documentation
   4. test-engineer adds API tests
```

### Example 3: Usage Statistics
```bash
/crew --stats
```

**Output**:
```
📊 Agent Usage Statistics (Last 30 days)

⭐ Most Used Agents:
1. code-craftsman         247 invocations  │████████████████████│ 100%
2. practical-programmer   186 invocations  │███████████████     │ 75%
3. test-engineer          142 invocations  │███████████         │ 57%
4. deep-researcher        98 invocations   │███████             │ 40%
5. frontend-architect     87 invocations   │███████             │ 35%

📈 Performance Metrics:

Agent                    Success  Avg Tokens  Avg Time  Efficiency
code-craftsman           94%      18,234      12 min    ★★★★★
practical-programmer     96%      16,890      10 min    ★★★★★
test-engineer            91%      14,567      8 min     ★★★★★
deep-researcher          89%      25,123      25 min    ★★★★
api-architect            93%      16,234      11 min    ★★★★★
frontend-architect       92%      20,456      15 min    ★★★★
deployment-orchestrator  88%      18,345      13 min    ★★★★
debug-detective          85%      22,678      18 min    ★★★

💰 Context Window Efficiency:

Most Efficient (tokens per task):
1. test-engineer         14,567 tokens  ★★★★★
2. practical-programmer  16,890 tokens  ★★★★★
3. api-architect         16,234 tokens  ★★★★★

Highest Resource Usage (may benefit from optimization):
1. mercurio-orchestrator 45,234 tokens  (complex multi-phase tasks)
2. project-orchestrator  35,678 tokens  (comprehensive analysis)
3. deep-researcher       25,123 tokens  (extensive research)

🎯 Recommendation Summary:
  ✓ code-craftsman: Highly reliable for general coding tasks
  ✓ practical-programmer: Best for refactoring and clean code
  ✓ test-engineer: Most efficient for test creation
  ✓ deep-researcher: Use with --optimize-context for large research
  ⚠ Consider breaking large tasks for opus model agents

📅 Report generated: 2025-10-12
💾 Data source: .claude/logs/agent-usage.json
```

### Example 4: Agent Comparison
```bash
/crew --compare "code-craftsman" "practical-programmer"
```

**Output**:
```
🔍 Agent Comparison: code-craftsman vs practical-programmer

┌─────────────────────────┬───────────────────────────┬──────────────────────────┐
│ Attribute               │ code-craftsman            │ practical-programmer     │
├─────────────────────────┼───────────────────────────┼──────────────────────────┤
│ Model                   │ sonnet                    │ sonnet                   │
│ Avg Token Usage         │ 18,234                    │ 16,890 (7% more efficient)│
│ Success Rate            │ 94%                       │ 96%                      │
│ Avg Completion Time     │ 12 min                    │ 10 min                   │
│ Usage Frequency         │ Very High (247/month)     │ High (186/month)         │
└─────────────────────────┴───────────────────────────┴──────────────────────────┘

🎯 Core Capabilities:

code-craftsman:
  ✓ Write new code from scratch
  ✓ Implement features and functions
  ✓ Clean, maintainable code
  ✓ Cross-language support
  ✓ Solve programming challenges

practical-programmer:
  ✓ Refactor existing code
  ✓ Apply design patterns (DRY, SOLID, KISS)
  ✓ Fix "broken windows"
  ✓ Modular architecture
  ✓ Pragmatic solutions

🏆 Best Use Cases:

Use code-craftsman when:
  - Writing new features from scratch
  - Implementing algorithms
  - Creating new modules or services
  - Need general-purpose coding
  - Building prototypes

Use practical-programmer when:
  - Refactoring existing code
  - Applying design patterns
  - Improving code quality
  - Fixing technical debt
  - Building maintainable systems

🔗 Complementary Usage:
  1. code-craftsman writes initial implementation
  2. practical-programmer refactors for maintainability
  3. test-engineer adds comprehensive tests

💡 Recommendation:
  - Both are excellent general-purpose coding agents
  - code-craftsman: Slightly higher usage, great for new code
  - practical-programmer: More efficient, best for refactoring
  - Consider task nature when choosing
```

### Example 5: Filter by Type
```bash
/crew --by-type research
```

**Output**:
```
📚 Research Agents (5 agents)

1. deep-researcher (sonnet)
   Comprehensive research using web search and extended thinking
   Capabilities:
     - Web search for source discovery
     - Web fetch for content analysis
     - Extended thinking for synthesis
     - Structured documentation
   Average tokens: 25K | Usage: High
   Best for: Multi-source research, technical documentation

2. claude-sdk-expert (sonnet)
   Expert in Claude SDK and Anthropic APIs
   Capabilities:
     - Claude SDK integration
     - API documentation research
     - Implementation patterns
     - Best practices
   Average tokens: 15K | Usage: Medium
   Best for: Claude/Anthropic API integration

3. mcp-integration-wizard (sonnet)
   MCP integration and custom server development
   Capabilities:
     - MCP server integration
     - Configuration examples
     - Implementation guides
   Average tokens: 18K | Usage: Low
   Best for: MCP protocol integration

4. unix-command-master (sonnet)
   Unix command research and shell scripting
   Capabilities:
     - Command research with /deep
     - Shell scripting patterns
     - Cross-platform compatibility
   Average tokens: 14K | Usage: Medium
   Best for: Unix/bash command expertise

5. mercurio-orchestrator (opus)
   Multi-dimensional research and synthesis
   Capabilities:
     - Comprehensive knowledge synthesis
     - Multi-source integration
     - Ethical awareness
     - Strategic coordination
   Average tokens: 45K | Usage: Low
   Best for: Complex research requiring deep synthesis

💡 Tip: Use /orch to coordinate multiple research agents
```

## Integration Points

### With /orch
- Provides agent catalog for orchestration
- Supplies capability information for matching
- Shares usage statistics for optimization
- Enables intelligent agent selection

### With /aprof
- Links to detailed agent profiles
- Provides quick overview before deep dive
- Shares performance metrics
- Enables drill-down analysis

### With /context-budget
- Shares token usage statistics
- Helps identify resource-intensive agents
- Supports optimization decisions
- Tracks per-agent consumption

## Filter Options

### By Type
- `research` - Research and documentation agents
- `coding` - Code development and implementation
- `testing` - Test creation and quality assurance
- `deployment` - Deployment and DevOps
- `orchestration` - Coordination and management
- `documentation` - Documentation generation

### Search Patterns
- Capability keywords: "API design", "testing", "deployment"
- Technology focus: "React", "Python", "Kubernetes"
- Task type: "refactor", "analyze", "create"
- Domain: "frontend", "backend", "security"

## Tips for Best Results

1. **Start with Listing**: Get familiar with available agents
2. **Use Search**: Find agents by capability keywords
3. **Check Stats**: Understand usage patterns before choosing
4. **Compare Similar**: Compare agents when multiple match
5. **Filter by Type**: Narrow down by task category
6. **Review Examples**: Check agent descriptions for usage examples

## Related Commands

- `/orch` - Orchestrate multiple agents intelligently
- `/aprof <agent>` - Deep agent profile and analysis
- `/context-budget --agent <name>` - Per-agent token usage
- `/wflw` - Create workflows with specific agents
- `/agents` - Built-in Claude Code agent listing (unchanged)

## Version History

- v1.0: Initial crew management command
- v1.1: Added search and filtering
- v1.2: Usage statistics integration
- v1.3: Agent comparison feature

## Philosophy

Effective agent orchestration starts with knowing your crew. The `/crew` command provides comprehensive visibility into available agents, their capabilities, and performance characteristics—enabling you to make informed decisions about which agents to use for each task.

Think of `/crew` as your agent roster and analytics dashboard combined.
