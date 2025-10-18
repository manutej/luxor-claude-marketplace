# /deep

Perform comprehensive deep research on any topic with multi-source synthesis, pattern recognition, and structured output. This command leverages Claude's advanced reasoning with web search, document analysis, and extended thinking capabilities.

## Usage

```bash
# Research mode (default) - comprehensive research workflow
/deep -r "<topic or question>"
/deep -r "<topic>" --depth=<level> --sources=<type> --output=<format> --save=<file-path>

# Extended thinking mode - enhanced reasoning for complex analysis
/deep -t "<question or problem>"
/deep -t "<question>" --budget=<tokens>

# Direct web fetch - retrieve and analyze specific URLs
/deep -wf <url> "<analysis prompt>"
/deep -wf <url> "<prompt>" --save=<file-path>

# Web search mode - quick search and synthesis
/deep -ws "<search query>"
/deep -ws "<query>" --max-results=<number>

# Legacy format (defaults to research mode)
/deep "<topic or question>"

# Show help
/deep --help
```

## Flags (Mode Selection)

### Primary Modes
- **-r, --research**: Full research workflow with multi-source synthesis (default)
  - Combines web search, web fetch, pattern analysis, and synthesis
  - Best for: Industry research, technical documentation, comprehensive analysis
  - Can research any subject in depth using high-quality sources
  - Suitable for non-technical topics (industry trends, business models, etc.)
  - Uses: WebSearch → WebFetch → Extended Thinking → Synthesis

- **-t, --thinking**: Extended thinking mode for complex reasoning
  - Activates Claude's extended thinking with step-by-step reasoning
  - Best for: Complex problems, mathematical analysis, logical reasoning
  - Shows transparent reasoning process before final answer
  - Uses: Extended Thinking API with configurable token budget

- **-wf, --web-fetch**: Direct web content retrieval and analysis
  - Fetches and analyzes specific URLs or documents
  - Best for: Analyzing specific articles, documentation, or papers
  - Supports PDFs and complex web pages
  - Uses: WebFetch tool directly

- **-ws, --web-search**: Quick web search and summary
  - Fast search without deep analysis
  - Best for: Quick lookups, trending topics, current events
  - Uses: WebSearch tool with immediate synthesis

## Parameters

### Required
- **topic/question/url** (string): The subject to research, analyze, or retrieve
  - Research mode: Any topic (e.g., "fintech industry trends 2025")
  - Thinking mode: Complex question (e.g., "analyze trade-offs of event sourcing")
  - Web fetch mode: Full URL (e.g., "https://arxiv.org/pdf/paper.pdf")
  - Web search mode: Search query (e.g., "latest AI developments")

### Mode-Specific Parameters

#### Research Mode (-r)
- **--depth** (quick|standard|comprehensive|exhaustive): Research depth level
  - `quick`: 5-10 min, surface-level overview, 3-5 sources
  - `standard`: 15-20 min, balanced depth, 8-12 sources (default)
  - `comprehensive`: 30-45 min, deep analysis, 15-25 sources
  - `exhaustive`: 60+ min, thorough investigation, 30+ sources

- **--sources** (web|academic|technical|news|industry|all): Source type priority
  - `web`: General web sources, blogs, documentation
  - `academic`: Research papers, scholarly articles
  - `technical`: Technical docs, GitHub, Stack Overflow
  - `news`: Recent news, trends, current events
  - `industry`: Industry reports, market analysis, business insights
  - `all`: All source types (default)

- **--output** (summary|report|detailed|knowledge-map): Output format
  - `summary`: 1-2 pages, executive summary
  - `report`: 5-10 pages, comprehensive report (default)
  - `detailed`: 15+ pages, exhaustive analysis
  - `knowledge-map`: Visual concept map with relationships

#### Thinking Mode (-t)
- **--budget** (number): Token budget for thinking process
  - Minimum: 1024 tokens
  - Recommended: 4096 tokens for complex problems
  - Maximum: 10000 tokens for exhaustive reasoning
  - Default: 4096 tokens

- **--show-reasoning** (bool): Display step-by-step reasoning (default: true)
  - `true`: Shows transparent thinking blocks
  - `false`: Only shows final conclusions

#### Web Fetch Mode (-wf)
- **--format** (markdown|text|structured): Output format preference
  - `markdown`: Preserve markdown formatting (default)
  - `text`: Plain text extraction
  - `structured`: Extract structured data

- **--extract** (string): Specific information to extract
  - Example: `--extract="key findings, methodology"`

#### Web Search Mode (-ws)
- **--max-results** (number): Maximum search results to analyze
  - Range: 5-30 results
  - Default: 10 results

- **--recency** (day|week|month|year|any): Recency filter
  - `day`: Last 24 hours
  - `week`: Last 7 days
  - `month`: Last 30 days
  - `year`: Last 365 days
  - `any`: No recency filter (default)

### Universal Parameters
- **--save** (string): Save output to file path
  - Example: `--save=research/fintech-trends.md`
  - Auto-creates directory if needed
  - Appends if file exists (with timestamp)

- **--context** (string): Additional context for better results
  - Example: `--context="for creating agent documentation"`

## Examples

### Research Mode Examples (-r)

#### Example 1: Industry Research for Context Engineering
```bash
/deep -r "fintech industry trends and regulatory landscape 2025" --sources=industry --save=context/fintech-industry.md
```

**What happens:**
1. Researches fintech industry comprehensively (non-technical focus)
2. Gathers from industry reports, market analysis, regulatory updates
3. Identifies key trends, players, and regulatory considerations
4. Synthesizes into structured report for agent context engineering
5. Saves to context documentation for future agent use

**Use case:** Creating comprehensive industry context for specialized agents

#### Example 2: Technical Deep Dive
```bash
/deep -r "quantum computing applications" --depth=comprehensive --sources=academic
```

**What happens:**
1. Researches quantum computing applications
2. Focuses on academic papers and research
3. Analyzes 15-25 sources over 30-45 minutes
4. Synthesizes state-of-the-art findings
5. Includes sources and recommendations

#### Example 3: Business Model Research
```bash
/deep -r "SaaS pricing strategies for B2B" --sources=industry --output=detailed --context="for startup planning"
```

**What happens:**
1. Non-technical research on SaaS pricing models
2. Focuses on industry insights, case studies, best practices
3. Analyzes multiple pricing strategies and their outcomes
4. Provides detailed analysis with context for startup planning
5. Creates actionable recommendations

#### Example 4: Comparative Technical Analysis
```bash
/deep -r "compare Kubernetes vs Docker Swarm vs Nomad" --output=detailed --save=docs/orchestration-comparison.md
```

**What happens:**
1. Comprehensive comparison of container orchestrators
2. WebSearch discovers documentation and comparisons
3. WebFetch retrieves full technical docs
4. Extended thinking analyzes trade-offs
5. Synthesizes detailed comparison matrix

#### Example 5: Quick Industry Scan
```bash
/deep -r "AI trends in healthcare 2025" --depth=quick --sources=news --output=summary
```

**What happens:**
1. Quick scan of recent news and industry reports
2. Focuses on 2025 healthcare AI trends
3. 5-10 minute research window
4. Delivers concise summary format

### Thinking Mode Examples (-t)

#### Example 6: Complex Problem Analysis
```bash
/deep -t "analyze trade-offs between microservices and monolithic architecture for e-commerce platform" --budget=8192
```

**What happens:**
1. Activates extended thinking mode with 8192 token budget
2. Shows step-by-step reasoning process
3. Analyzes multiple dimensions (scalability, complexity, team structure)
4. Provides transparent reasoning before conclusions
5. Delivers well-reasoned recommendation

#### Example 7: Mathematical/Logical Reasoning
```bash
/deep -t "optimal database sharding strategy for 100M users" --budget=4096 --show-reasoning=true
```

**What happens:**
1. Extended thinking analyzes the problem space
2. Shows reasoning about growth patterns, query patterns
3. Evaluates multiple sharding strategies
4. Transparent thought process visible
5. Delivers optimized recommendation

### Web Fetch Mode Examples (-wf)

#### Example 8: Analyze Specific Documentation
```bash
/deep -wf https://docs.anthropic.com/claude/reference "extract key API capabilities for research workflows"
```

**What happens:**
1. Directly fetches Anthropic API documentation
2. Analyzes content based on prompt
3. Extracts API capabilities relevant to research
4. Returns focused analysis

#### Example 9: Research Paper Analysis
```bash
/deep -wf https://arxiv.org/pdf/2401.12345.pdf "summarize methodology and key findings" --save=research/paper-summary.md
```

**What happens:**
1. Fetches PDF research paper
2. Extracts methodology and findings
3. Creates structured summary
4. Saves for reference

### Web Search Mode Examples (-ws)

#### Example 10: Quick Current Events
```bash
/deep -ws "latest developments in LLM reasoning capabilities" --recency=week --max-results=15
```

**What happens:**
1. Searches for recent content (last week)
2. Analyzes top 15 results
3. Quick synthesis without deep dive
4. Returns summary of latest developments

#### Example 11: Trend Discovery
```bash
/deep -ws "emerging technologies in renewable energy" --recency=month
```

**What happens:**
1. Searches recent articles and news
2. Identifies trending technologies
3. Quick overview without exhaustive research
4. Fast results for trend awareness

### Combined Workflow Example

#### Example 12: Multi-Stage Research
```bash
# Stage 1: Quick discovery
/deep -ws "best practices for agent architecture" --max-results=20

# Stage 2: Deep research on findings
/deep -r "agent orchestration patterns" --depth=comprehensive --sources=technical

# Stage 3: Analyze specific resource
/deep -wf https://specific-resource.com/agent-patterns "extract implementation patterns"

# Stage 4: Complex reasoning
/deep -t "design optimal agent communication protocol for distributed system" --budget=8192

# Stage 5: Save comprehensive findings
/deep -r "agent architecture patterns" --output=detailed --save=docs/agent-architecture-research.md
```

### Legacy Format Example

#### Example 13: Backward Compatibility
```bash
# Still works - defaults to research mode
/deep "microservices architecture concepts" --output=knowledge-map
```

**What happens:**
1. Automatically uses research mode (-r)
2. Full backward compatibility maintained
3. All existing commands continue to work

## What It Does (Automated Workflow)

The `/deep` command operates differently based on the mode flag:

### Research Mode Workflow (-r, default)

Full research workflow with multi-source synthesis, suitable for any topic (technical or non-technical).

#### Phase 1: Scoping (30 seconds - 2 minutes)
1. Parses your research topic/question
2. Identifies key dimensions to investigate
3. Plans source strategy based on topic type and `--sources` flag
4. Sets research depth based on `--depth` parameter
5. Establishes success criteria

#### Phase 2: Discovery (5-60 minutes depending on depth)
1. **Web Search**: Uses Claude's WebSearch API to find relevant sources
   - Discovers documentation, articles, industry reports, and authoritative content
   - Identifies potential high-quality sources to analyze
   - Prioritizes based on source type (academic, technical, industry, news)
   - Adapts to both technical and non-technical topics

2. **Content Retrieval with WebFetch**: Uses Claude's WebFetch API for deep analysis
   - Retrieves full content from web pages and PDFs
   - Extracts comprehensive information from documentation sites
   - Supports citation tracking for source referencing
   - Caches content for efficient repeated access (15-minute cache)
   - Respects domain filtering for security (allowed/blocked domains)
   - Handles complex documents including research papers

3. **Multi-Source Gathering**: Systematically collects from:
   - Primary sources (documentation, research papers, industry reports) - via WebFetch
   - Secondary sources (analysis, commentary) - via WebSearch + WebFetch
   - Tertiary sources (summaries, comparisons) - via WebSearch
4. **Pattern Recognition**: Notes recurring themes and insights
5. **Source Evaluation**: Assesses credibility and relevance

#### Phase 3: Analysis with Extended Thinking (3-15 minutes)
1. **Extended Thinking Activation**: Uses Claude's extended thinking mode
   - Applies step-by-step reasoning to research findings
   - Cross-references information across sources
   - Identifies patterns and contradictions
2. **Comparative Analysis**: Compares alternatives if applicable
3. **Best Practices**: Extracts actionable recommendations
4. **Trade-off Evaluation**: Analyzes pros/cons/constraints
5. **Gap Analysis**: Identifies missing information or contradictions

#### Phase 4: Synthesis (2-10 minutes)
1. **Structure Creation**: Organizes findings hierarchically
2. **Narrative Development**: Creates coherent story
3. **Insight Generation**: Surfaces non-obvious connections
4. **Recommendation Formation**: Provides actionable next steps
5. **Citation**: Links all claims to sources
6. **Quality Check**: Verifies completeness and accuracy

#### Phase 5: Delivery
1. Formats output according to `--output` parameter
2. Saves to file if `--save` specified
3. Returns structured research report
4. Includes metadata (sources, confidence, limitations)

### Thinking Mode Workflow (-t)

Extended thinking mode for complex reasoning without web research.

#### Phase 1: Problem Understanding (30 seconds)
1. Parses the question or problem
2. Identifies complexity dimensions
3. Allocates thinking token budget
4. Establishes reasoning framework

#### Phase 2: Extended Thinking (2-20 minutes)
1. **Activates Claude Extended Thinking API**:
   - Sets `thinking.type` to "enabled"
   - Allocates `thinking.budget_tokens` (1024-10000)
   - Configures streaming for transparent reasoning
2. **Step-by-Step Reasoning**:
   - Shows transparent thought process
   - Explores multiple approaches
   - Evaluates trade-offs
   - Self-critiques reasoning
3. **Reasoning Output**: Returns thinking blocks followed by conclusion

#### Phase 3: Delivery
1. Shows reasoning blocks if `--show-reasoning=true`
2. Provides final conclusion and recommendations
3. Saves if `--save` specified

### Web Fetch Mode Workflow (-wf)

Direct content retrieval and analysis from specific URLs.

#### Phase 1: Retrieval (10 seconds - 2 minutes)
1. **Uses Claude's WebFetch API directly**:
   - Fetches content from specified URL
   - Handles web pages, PDFs, and documentation
   - Converts HTML to markdown
   - Extracts text from PDFs
   - Respects domain security settings

#### Phase 2: Analysis (1-5 minutes)
1. Processes content with provided analysis prompt
2. Extracts specific information based on `--extract` parameter
3. Formats according to `--format` parameter
4. Applies focused analysis to content

#### Phase 3: Delivery
1. Returns analysis results
2. Maintains citations to source URL
3. Saves if `--save` specified

### Web Search Mode Workflow (-ws)

Quick search and synthesis without deep research.

#### Phase 1: Search (10-30 seconds)
1. **Uses Claude's WebSearch API**:
   - Executes search query
   - Applies recency filter if specified
   - Retrieves top N results (controlled by `--max-results`)
   - Filters by domain if configured

#### Phase 2: Quick Synthesis (1-3 minutes)
1. Scans search results for key information
2. Identifies trends and common themes
3. Creates quick summary without deep analysis
4. Maintains source links

#### Phase 3: Delivery
1. Returns concise summary with sources
2. Fast turnaround (under 5 minutes total)
3. Saves if `--save` specified

## Research Process Explained

### How Depth Levels Work

- **Quick** (5-10 min):
  - 3-5 sources
  - Surface-level scan
  - Key findings only
  - Suitable for initial exploration

- **Standard** (15-20 min):
  - 8-12 sources
  - Balanced breadth and depth
  - Multiple perspectives
  - Good default for most research

- **Comprehensive** (30-45 min):
  - 15-25 sources
  - Deep analysis of each source
  - Pattern recognition across sources
  - Best for important decisions

- **Exhaustive** (60+ min):
  - 30+ sources
  - Thorough investigation
  - Academic rigor
  - For critical decisions or deep learning

### Source Selection Strategy

The agent prioritizes sources based on:
1. **Authority**: Official docs, research papers, expert blogs
2. **Recency**: Recent information prioritized for evolving topics
3. **Relevance**: Direct relevance to research question
4. **Diversity**: Multiple perspectives and viewpoints
5. **Credibility**: Established sources, peer-reviewed when possible

### Understanding the Modes and Tools

#### Mode Selection Guide

**Use Research Mode (-r) when:**
- Need comprehensive research on any topic (technical or non-technical)
- Want to understand an industry, technology, or domain
- Creating context documentation for agents
- Making informed decisions with multiple sources
- Building knowledge base documentation

**Use Thinking Mode (-t) when:**
- Need deep reasoning on a complex problem
- Want to see transparent thought process
- Analyzing trade-offs and design decisions
- Mathematical or logical problem solving
- No web research needed, just reasoning

**Use Web Fetch Mode (-wf) when:**
- Have specific URL to analyze
- Need to extract information from known document
- Analyzing research papers (PDFs)
- Focused analysis of single source
- Official documentation deep dive

**Use Web Search Mode (-ws) when:**
- Need quick overview of topic
- Discovering trending information
- Current events and news
- Fast reconnaissance before deeper research
- Time-sensitive queries

#### WebFetch vs WebSearch vs Extended Thinking

**WebSearch (Discovery):**
- Finds relevant sources across the web
- Returns search results with snippets
- Good for discovering what exists
- Fast and broad coverage
- Used in: Research mode (-r), Web Search mode (-ws)

**WebFetch (Retrieval):**
- Retrieves full content from specific URLs
- Handles web pages, PDFs, documentation
- Deep analysis of single source
- Supports caching for efficiency
- Used in: Research mode (-r), Web Fetch mode (-wf)

**Extended Thinking (Reasoning):**
- Step-by-step reasoning on complex problems
- Transparent thought process
- No web access, pure reasoning
- Token-budgeted thinking
- Used in: Thinking mode (-t), Research mode (-r) for synthesis

**Optimal Research Workflow:**
1. WebSearch (-ws flag) → Quick discovery of topic landscape
2. Research Mode (-r flag) → Deep dive with WebSearch + WebFetch + Thinking
3. Web Fetch (-wf flag) → Detailed analysis of specific resources
4. Thinking Mode (-t flag) → Complex reasoning on findings
5. Save results → Build knowledge repository

## Output Formats

### Summary Format
```markdown
# Research: [Topic]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Recommendations
- Recommendation 1
- Recommendation 2

## Sources
- [Source 1](url)
- [Source 2](url)
```

### Report Format (Default)
```markdown
# Research: [Topic]

## Executive Summary
[3-5 bullet points]

## Research Question
[Clear statement]

## Methodology
[Sources and approach]

## Findings
### Category 1
[Detailed findings]

### Category 2
[Detailed findings]

## Analysis
[Insights and patterns]

## Recommendations
[Actionable next steps]

## Sources
[Cited references]

## Confidence & Limitations
[What we know vs. don't know]
```

### Detailed Format
```markdown
[Same as Report but with:]
- Extended analysis sections
- More examples and case studies
- Deeper theoretical background
- Comprehensive source analysis
- Historical context
- Future trends and implications
```

### Knowledge Map Format
```markdown
# Knowledge Map: [Topic]

## Core Concepts
- Concept A
  - Sub-concept A1
  - Sub-concept A2
- Concept B
  - Relates to: Concept A
  - Prerequisite: Concept C

## Relationships
[Visual/textual representation of how concepts connect]

## Learning Path
[Recommended order for learning concepts]
```

## Integration Patterns

### Research → Documentation
```bash
# Research a topic then generate docs
/deep "API authentication patterns" --save=research/auth.md
# Then use docs-generator to create formal documentation
```

### Research → Implementation
```bash
# Research before building
/deep "React testing strategies" --depth=comprehensive
# Then use findings to guide test-engineer implementation
```

### Research → Decision Making
```bash
# Research for architectural decision
/deep "database options for time-series data" --output=detailed --save=decisions/database-choice.md
# Review with team and make informed decision
```

### Continuous Research
```bash
# Save research to build knowledge base
/deep "topic 1" --save=knowledge/topic1.md
/deep "topic 2" --save=knowledge/topic2.md
# Build comprehensive knowledge repository
```

## Implementation with Claude SDK

The `/deep` command is implemented using the Anthropic Claude SDK to orchestrate various API capabilities:

### API Features Used

#### 1. Messages API (Core)
```python
from anthropic import Anthropic

client = Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

# Basic message with tools
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=4096,
    messages=[{"role": "user", "content": "Research topic"}],
    tools=[...]  # WebSearch, WebFetch tools
)
```

#### 2. Extended Thinking Mode (-t flag)
```python
# Enable extended thinking for complex reasoning
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=8192,
    thinking={
        "type": "enabled",
        "budget_tokens": 4096  # Configurable via --budget
    },
    messages=[{"role": "user", "content": "Analyze complex problem"}]
)

# Extract thinking blocks
for block in message.content:
    if block.type == "thinking":
        print(f"Reasoning: {block.thinking}")
    elif block.type == "text":
        print(f"Answer: {block.text}")
```

#### 3. WebSearch Tool (-r, -ws flags)
```python
# WebSearch tool for discovering sources
tools = [{
    "type": "web_search",
    "name": "web_search",
    "description": "Search the web for information"
}]

# Used automatically by Claude when researching
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=4096,
    tools=tools,
    messages=[{"role": "user", "content": "Research fintech trends"}]
)
```

#### 4. WebFetch Tool (-r, -wf flags)
```python
# WebFetch tool for retrieving specific URLs
tools = [{
    "type": "web_fetch",
    "name": "web_fetch",
    "description": "Fetch and analyze web content"
}]

# Direct URL retrieval
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=4096,
    tools=tools,
    messages=[{
        "role": "user",
        "content": "Fetch and analyze https://docs.anthropic.com/api"
    }]
)
```

#### 5. Combined Research Workflow
```python
# Research mode combines all tools
def deep_research(topic, depth="standard", sources="all"):
    # Phase 1: Discovery with WebSearch
    search_message = client.messages.create(
        model="claude-sonnet-4",
        max_tokens=4096,
        tools=[{"type": "web_search"}],
        messages=[{
            "role": "user",
            "content": f"Search for: {topic}"
        }]
    )

    # Phase 2: Deep retrieval with WebFetch
    urls = extract_urls_from_search(search_message)
    fetch_messages = []
    for url in urls[:depth_to_source_count(depth)]:
        msg = client.messages.create(
            model="claude-sonnet-4",
            max_tokens=8192,
            tools=[{"type": "web_fetch"}],
            messages=[{
                "role": "user",
                "content": f"Fetch and analyze: {url}"
            }]
        )
        fetch_messages.append(msg)

    # Phase 3: Synthesis with Extended Thinking
    synthesis_message = client.messages.create(
        model="claude-sonnet-4",
        max_tokens=8192,
        thinking={
            "type": "enabled",
            "budget_tokens": 4096
        },
        messages=[{
            "role": "user",
            "content": f"Synthesize research findings on {topic}"
        }],
        # Include previous context
        system=build_research_context(search_message, fetch_messages)
    )

    return synthesis_message
```

### SDK Documentation References

For detailed implementation guidance, see:
- Messages API: https://docs.claude.com/en/api/messages
- Extended Thinking: https://docs.claude.com/en/docs/build-with-claude/extended-thinking
- Tool Use: https://docs.claude.com/en/docs/build-with-claude/tool-use
- Claude SDK (Python): https://github.com/anthropics/anthropic-sdk-python
- Claude SDK (TypeScript): https://github.com/anthropics/anthropic-sdk-typescript

## Configuration

Default settings in `.claude/research-config.yaml`:

```yaml
defaults:
  mode: research  # research, thinking, web-fetch, web-search
  depth: standard
  sources: all
  output: report
  thinking_budget: 4096

# Mode-specific settings
modes:
  research:
    default_depth: standard
    enable_thinking: true
    enable_websearch: true
    enable_webfetch: true

  thinking:
    min_budget: 1024
    max_budget: 10000
    default_budget: 4096
    show_reasoning: true

  web_fetch:
    default_format: markdown
    max_content_tokens: 10000

  web_search:
    default_max_results: 10
    default_recency: any

depth_settings:
  quick:
    sources: 5
    time_limit: 10
    thinking_budget: 2048
  standard:
    sources: 10
    time_limit: 20
    thinking_budget: 4096
  comprehensive:
    sources: 20
    time_limit: 45
    thinking_budget: 8192
  exhaustive:
    sources: 30
    time_limit: 90
    thinking_budget: 10000

source_preferences:
  academic:
    - scholar.google.com
    - arxiv.org
    - ieee.org
    - research papers
  technical:
    - official documentation
    - github.com
    - stackoverflow.com
    - developer blogs
  industry:
    - industry reports
    - market research
    - business publications
    - analyst reports
  news:
    - news outlets
    - tech news sites
    - industry publications
  web:
    - authoritative blogs
    - industry websites
    - community forums

# Claude API settings
api_settings:
  model: claude-sonnet-4
  max_tokens: 8192

  webfetch:
    max_content_tokens: 10000
    enable_citations: true
    cache_duration: 900  # 15 minutes
    allowed_domains:
      - docs.anthropic.com
      - docs.claude.com
      - github.com
      - arxiv.org
      - scholar.google.com
    blocked_domains:
      - suspicious-sites.com
      - unreliable-sources.net

  websearch:
    default_results: 10
    max_results: 30

  thinking:
    enabled_models:
      - claude-opus-4
      - claude-sonnet-4
    default_budget: 4096
```

## Tips for Best Results

### General Research Tips
1. **Be Specific**: "React testing best practices 2025" > "React testing"
2. **Use Comparison Format**: "Compare X vs Y vs Z" for decision-making
3. **Specify Context**: Add `--context` for targeted research
4. **Set Appropriate Depth**: Use `comprehensive` for important decisions
5. **Save Important Research**: Use `--save` to build knowledge base
6. **Iterate**: Start with `-ws` (quick), then `-r` (comprehensive) if needed

### Mode Selection Tips
7. **Start Quick**: Use `-ws` for initial discovery, then `-r` for depth
8. **Research Everything**: Use `-r` for both technical AND non-technical topics
9. **Think Complex**: Use `-t` when you need reasoning without web data
10. **Fetch Specific**: Use `-wf` when you already know the URL to analyze
11. **Combine Modes**: Run multiple modes sequentially for comprehensive coverage

### Source Strategy Tips
12. **Use Source Filters**:
   - `--sources=academic` for research papers
   - `--sources=industry` for business/market research
   - `--sources=technical` for implementation details
   - `--sources=news` for current events
13. **Industry Research**: Research mode works great for non-technical subjects
14. **Context Engineering**: Use `-r --sources=industry` to build agent context docs

### Workflow Tips
15. **Multi-Stage Research**: Combine `-ws` → `-r` → `-wf` → `-t` for complete analysis
16. **Trust Extended Thinking**: Let Claude reason through complexity in research mode
17. **Leverage Caching**: WebFetch caches for 15 min, so re-analyze sources quickly
18. **Build Knowledge Base**: Consistently use `--save` to accumulate research

### API Implementation Tips
19. **Extended Thinking Budget**: Higher budgets (8192+) for complex reasoning
20. **Token Management**: Research mode uses significant tokens; monitor usage
21. **Streaming**: Enable streaming for real-time progress on long research
22. **Tool Orchestration**: Research mode automatically orchestrates WebSearch, WebFetch, and Thinking

## Error Handling

### Vague Topics
```bash
/deep "technology"

⚠️  Topic too vague
Suggestion: Be more specific, e.g.:
- "emerging AI technologies in 2025"
- "blockchain technology use cases"
- "quantum computing basics"
```

### No Results Found
```bash
/deep "very niche topic xyz123"

⚠️  Limited sources found (< 3)
Researching with available sources...
Note: Results may be limited. Consider:
- Broadening the topic
- Checking spelling
- Using alternative terms
```

### Source Access Issues
```bash
⚠️  Some sources inaccessible
Continuing with available sources (15/20)...
Research quality may be slightly reduced.
```

## Help Output

When you run `/deep --help`, you'll see this condensed guide:

```
/deep - Deep research with multi-source synthesis and extended thinking

USAGE:
  /deep -r "<topic>"                    # Research mode (default)
  /deep -t "<question>"                 # Extended thinking mode
  /deep -wf <url> "<prompt>"            # Web fetch mode
  /deep -ws "<query>"                   # Web search mode
  /deep --help                          # Show this help

MODES:
  -r, --research      Full research with WebSearch + WebFetch + Thinking
                      • Use for: Any topic (technical or non-technical)
                      • Research industries, technologies, business models
                      • Perfect for creating agent context documentation

  -t, --thinking      Extended thinking for complex reasoning
                      • Use for: Problem analysis, trade-off evaluation
                      • Shows transparent step-by-step reasoning
                      • No web access, pure reasoning mode

  -wf, --web-fetch    Retrieve and analyze specific URLs
                      • Use for: Documentation, PDFs, research papers
                      • Deep analysis of known sources

  -ws, --web-search   Quick search and synthesis
                      • Use for: Fast overview, trend discovery
                      • Current events, quick lookups

RESEARCH MODE OPTIONS:
  --depth=<level>     quick | standard | comprehensive | exhaustive
  --sources=<type>    web | academic | technical | news | industry | all
  --output=<format>   summary | report | detailed | knowledge-map
  --save=<path>       Save to file

THINKING MODE OPTIONS:
  --budget=<tokens>   1024-10000 (default: 4096)
  --show-reasoning    true | false (default: true)

WEB FETCH OPTIONS:
  --format=<type>     markdown | text | structured
  --extract=<info>    Specific information to extract

WEB SEARCH OPTIONS:
  --max-results=<n>   5-30 (default: 10)
  --recency=<time>    day | week | month | year | any

UNIVERSAL OPTIONS:
  --save=<path>       Save output to file
  --context=<text>    Additional context for better results

QUICK EXAMPLES:
  # Industry research for agent context
  /deep -r "fintech industry 2025" --sources=industry --save=context/fintech.md

  # Complex reasoning
  /deep -t "optimal database sharding for 100M users" --budget=8192

  # Analyze specific documentation
  /deep -wf https://docs.anthropic.com/api "extract key capabilities"

  # Quick trend search
  /deep -ws "latest AI developments" --recency=week

WORKFLOW:
  1. Quick discovery:  /deep -ws "topic"
  2. Deep research:    /deep -r "topic" --depth=comprehensive
  3. Analyze sources:  /deep -wf <url> "extract findings"
  4. Complex reasoning: /deep -t "analyze problem"
  5. Save knowledge:   Add --save=<path> to any command

For full documentation, see: .claude/commands/deep.md
```

## Related Commands

- `/help` - List all available commands
- `/agent --list` - List all agents including deep-researcher
- Task tool - Invoke deep-researcher agent directly for custom workflows

## Version History

- v1.0: Initial deep research command
- v1.1: Added depth levels and source filtering
- v1.2: Added knowledge map output format
- v1.3: Enhanced comparative analysis capabilities
- v2.0: **Major update** - Added flag-based modes for clarity
  - New `-r` flag for research mode (default)
  - New `-t` flag for extended thinking mode
  - New `-wf` flag for web fetch mode
  - New `-ws` flag for web search mode
  - Added `industry` source type for non-technical research
  - Enhanced for context engineering documentation
  - Comprehensive Claude SDK implementation guide
  - Full backward compatibility maintained

## Quick Reference

### Command Cheat Sheet

```bash
# Quick search
/deep -ws "topic"

# Full research (default)
/deep -r "topic" --depth=comprehensive

# Complex reasoning
/deep -t "problem" --budget=8192

# Analyze URL
/deep -wf https://url.com "extract key points"

# Industry research for agents
/deep -r "fintech industry 2025" --sources=industry --save=context/fintech.md
```

### Flag Summary

| Flag | Purpose | Best For | Tools Used |
|------|---------|----------|------------|
| `-r` | Full research | Any topic, industry/technical analysis | WebSearch + WebFetch + Thinking |
| `-t` | Extended thinking | Complex reasoning, no web needed | Extended Thinking API |
| `-wf` | Web fetch | Specific URL analysis | WebFetch |
| `-ws` | Web search | Quick overview, discovery | WebSearch |

### Parameter Quick Reference

| Parameter | Applies To | Values | Default |
|-----------|------------|--------|---------|
| `--depth` | `-r` | quick, standard, comprehensive, exhaustive | standard |
| `--sources` | `-r` | web, academic, technical, news, industry, all | all |
| `--output` | `-r` | summary, report, detailed, knowledge-map | report |
| `--budget` | `-t` | 1024-10000 (tokens) | 4096 |
| `--max-results` | `-ws` | 5-30 (results) | 10 |
| `--format` | `-wf` | markdown, text, structured | markdown |
| `--save` | All | file path | none |
| `--context` | All | context string | none |

### Mode Selection Decision Tree

```
Need web research?
├─ No → Use -t (thinking mode)
└─ Yes
   ├─ Have specific URL? → Use -wf (web fetch)
   ├─ Need quick overview? → Use -ws (web search)
   └─ Need comprehensive analysis? → Use -r (research mode)
      ├─ Technical topic? → --sources=technical
      ├─ Industry/business? → --sources=industry
      ├─ Academic research? → --sources=academic
      └─ Current events? → --sources=news
```

## Philosophy

Good research isn't about collecting information—it's about synthesizing understanding. The `/deep` command provides multiple pathways to knowledge:

- **Research Mode (-r)**: Transforms curiosity into comprehensive knowledge through multi-source synthesis. Works for any topic, technical or non-technical.

- **Thinking Mode (-t)**: Reveals transparent reasoning processes, showing how complex problems are decomposed and analyzed.

- **Web Fetch Mode (-wf)**: Enables deep analysis of specific authoritative sources, perfect for when you know exactly what you need.

- **Web Search Mode (-ws)**: Provides rapid reconnaissance for quick decisions and trend awareness.

Together, these modes enable you to build a comprehensive knowledge foundation, make informed decisions, and deeply understand any domain—from technology to business, from theory to practice.

Every research session adds to your knowledge repository, compounding over time into expertise.
