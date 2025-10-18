---
description: Quick Context7 Library Documentation Lookup
allowed-tools: Read(/Users/manu/Documents/LUXOR/**), Write(/Users/manu/Documents/LUXOR/docs/**/*.md), Edit(/Users/manu/Documents/LUXOR/docs/**/*.md), Glob(**/*.md), Grep(/Users/manu/Documents/LUXOR/**), WebFetch(github.com, npmjs.com, nodejs.org, developer.mozilla.org, docs.anthropic.com, docs.claude.com, vercel.com, nextjs.org, reactjs.org, postgresql.org, mongodb.com, *.github.io), WebSearch, Bash(npm:*, git:clone:*, cat:*, ls:*, find:*, grep:*, head:*, tail:*), Task(context7-doc-reviewer), SlashCommand(/deep:*)
---

# /ctx7 - Quick Context7 Library Documentation Lookup

Quick access to Context7 library documentation with the context7-doc-reviewer agent.

## Usage

```bash
/ctx7 <library-name> [options]
```

## Parameters

- `library-name` (required): Name or partial identifier of the library to review
- `--topic=<focus>`: Focus documentation on specific topic (e.g., authentication, routing)
- `--tokens=<count>`: Documentation token limit (default: 5000)
- `--compare=<library2>`: Compare with another library
- `--version=<version>`: Specific version to review
- `--quick`: Generate concise summary instead of full documentation
- `--output=<path>`: Custom output path (default: docs/)

## What It Does

This command automatically invokes the `context7-doc-reviewer` agent to:

1. **Resolve Library ID** using Context7 MCP server
2. **Fetch Documentation** comprehensively from Context7
3. **Analyze Patterns** and extract key insights
4. **Generate Documentation** with examples and best practices

## Examples

### Basic Library Review

```bash
/ctx7 express
```

**Result:**
- Resolves "express" to `/expressjs/express`
- Fetches comprehensive Express.js documentation
- Generates `docs/EXPRESS-CONTEXT7-REVIEW.md`
- Includes installation, routing, middleware, and best practices

### Focused Topic Research

```bash
/ctx7 supabase --topic=authentication
```

**Result:**
- Resolves Supabase library ID
- Focuses documentation fetch on authentication
- Generates `docs/SUPABASE-AUTHENTICATION-GUIDE.md`
- Covers auth methods, JWT, session management, RLS

### Library Comparison

```bash
/ctx7 prisma --compare=drizzle
```

**Result:**
- Resolves both Prisma and Drizzle
- Fetches documentation for both libraries
- Generates comparison matrix
- Provides recommendation with evidence
- Output: `docs/PRISMA-VS-DRIZZLE-COMPARISON.md`

### Version-Specific Review

```bash
/ctx7 next.js --version=v15.0.0
```

**Result:**
- Resolves Next.js v15.0.0 specifically
- Fetches version-specific documentation
- Highlights version-specific features
- Output: `docs/NEXTJS-V15-REVIEW.md`

### Quick Summary Mode

```bash
/ctx7 fastify --quick
```

**Result:**
- Generates concise summary instead of full guide
- Shows key features, installation, basic usage
- Faster turnaround for quick reference
- Output: Terminal display (not saved unless --output specified)

### Higher Token Limit

```bash
/ctx7 langchain --tokens=10000
```

**Result:**
- Fetches more comprehensive documentation (10k tokens)
- Useful for complex libraries requiring deep analysis
- Generates more detailed guide

### Custom Output Location

```bash
/ctx7 mongodb --output=docs/database/
```

**Result:**
- Saves documentation to custom path
- Useful for organizing by category
- Output: `docs/database/MONGODB-CONTEXT7-REVIEW.md`

## Integration with Other Commands

### Sequential Workflow

```bash
# Step 1: Review library documentation
/ctx7 express

# Step 2: Generate API wrapper design
/agent api-architect "Design Express wrapper API"

# Step 3: Generate tests
/agent test-engineer "Create tests for Express integration"
```

### Parallel Research

```bash
# Research library + ecosystem in parallel
# Terminal 1:
/ctx7 prisma

# Terminal 2 (simultaneously):
/agent deep-researcher "Research PostgreSQL ecosystem"
```

## Command Behavior

### Library Resolution

The command automatically handles library ID resolution:

```yaml
ambiguous_library:
  scenario: "Multiple matches found"
  behavior: |
    Shows top 3 matches with trust scores
    Asks user to select or refine search
  example: |
    Found multiple matches for "react":
    1. /facebook/react (Trust: 10, Snippets: 500) ✓ Recommended
    2. /react-community/react-router (Trust: 9, Snippets: 200)
    3. /react-native-community/react-native (Trust: 9, Snippets: 300)

    Selected: /facebook/react (highest trust and coverage)

exact_match:
  scenario: "Single clear match"
  behavior: "Automatically proceeds with fetch and documentation"

no_match:
  scenario: "No libraries found"
  behavior: |
    Suggests similar library names
    Offers to search Context7 differently
```

### Documentation Generation

```yaml
full_mode:
  trigger: "Default (no --quick flag)"
  output: "Complete integration guide in docs/"
  sections:
    - Executive summary
    - Installation and setup
    - API reference
    - Code examples
    - Best practices
    - Troubleshooting
  duration: "10-20 minutes"

quick_mode:
  trigger: "--quick flag"
  output: "Concise summary (terminal or file)"
  sections:
    - Brief overview
    - Installation
    - Basic usage example
    - Key features
    - Links to full docs
  duration: "2-5 minutes"
```

### Topic Filtering

```yaml
topic_parameter:
  usage: "--topic=<focus-area>"
  effect: |
    Narrows Context7 documentation fetch to specific topic
    Generates focused guide instead of full library review

  examples:
    authentication:
      - Auth methods and patterns
      - JWT handling
      - Session management
      - Security best practices

    routing:
      - Route definitions
      - Path parameters
      - Route matching
      - Middleware integration

    configuration:
      - Setup options
      - Environment variables
      - Configuration files
      - Initialization patterns

    deployment:
      - Production setup
      - Performance tuning
      - Monitoring
      - Scaling strategies
```

### Comparison Mode

```yaml
compare_parameter:
  usage: "--compare=<library2>"
  behavior: |
    Fetches documentation for both libraries
    Generates comparison matrix
    Provides evidence-based recommendation

  output_structure:
    - Executive summary with recommendation
    - Feature comparison matrix
    - Trust score comparison
    - Documentation quality comparison
    - Code example side-by-side
    - Use case recommendations
    - Migration considerations

  example_comparison:
    command: "/ctx7 express --compare=fastify"
    analysis:
      - Performance characteristics
      - Plugin ecosystem
      - TypeScript support
      - Learning curve
      - Community support (trust scores)
    recommendation: "Based on your use case..."
```

## Error Handling

### Common Issues

```yaml
library_not_found:
  error: "Library 'xyz' not found in Context7"
  response: |
    Suggests similar library names from Context7
    Offers to search with different terms
    Provides link to Context7 catalog

ambiguous_request:
  error: "Multiple matches found, need clarification"
  response: |
    Lists top matches with trust scores
    Asks user to specify or refine
    Can continue with recommended match if user approves

mcp_server_unavailable:
  error: "Cannot connect to Context7 MCP server"
  response: |
    Checks MCP server configuration
    Provides troubleshooting steps
    Falls back to alternative research methods if available

token_limit_exceeded:
  error: "Documentation exceeds token limit"
  response: |
    Suggests using --topic to narrow focus
    Offers to fetch in sections
    Recommends higher --tokens value
```

## Output Files

### Default Naming Convention

```yaml
single_library:
  pattern: "[LIBRARY-NAME]-CONTEXT7-REVIEW.md"
  examples:
    - EXPRESS-CONTEXT7-REVIEW.md
    - NEXTJS-CONTEXT7-REVIEW.md
    - SUPABASE-CONTEXT7-REVIEW.md

focused_topic:
  pattern: "[LIBRARY-NAME]-[TOPIC]-GUIDE.md"
  examples:
    - SUPABASE-AUTHENTICATION-GUIDE.md
    - EXPRESS-ROUTING-PATTERNS.md
    - NEXTJS-DEPLOYMENT-GUIDE.md

comparison:
  pattern: "[LIBRARY1]-VS-[LIBRARY2]-COMPARISON.md"
  examples:
    - PRISMA-VS-DRIZZLE-COMPARISON.md
    - EXPRESS-VS-FASTIFY-COMPARISON.md
    - REACT-VS-VUE-COMPARISON.md

version_specific:
  pattern: "[LIBRARY-NAME]-[VERSION]-REVIEW.md"
  examples:
    - NEXTJS-V15-REVIEW.md
    - REACT-18-FEATURES.md
```

### Custom Output Location

```bash
# Organize by category
/ctx7 mongodb --output=docs/databases/
/ctx7 redis --output=docs/databases/
/ctx7 express --output=docs/web-frameworks/

# Project-specific documentation
/ctx7 supabase --output=docs/backend/
/ctx7 next.js --output=docs/frontend/
```

## Performance Optimization

```yaml
token_limits:
  quick_review: 3000
  standard_review: 5000
  comprehensive_review: 8000
  deep_dive: 10000+

recommendations:
  simple_library: "5000 tokens sufficient"
  complex_framework: "8000-10000 tokens recommended"
  focused_topic: "3000-5000 tokens optimal"
  comparison: "5000 per library (10000 total)"
```

## Tips & Best Practices

### When to Use /ctx7

✓ **DO use /ctx7 when:**
- Need quick library documentation review
- Starting new library integration
- Comparing library alternatives
- Researching authentication/routing patterns
- Need version-specific documentation
- Building integration guide for team

✗ **DON'T use /ctx7 when:**
- Library not in Context7 catalog (use /agent deep-researcher)
- Need custom codebase analysis (use other agents)
- Debugging existing implementation (use debug-detective)
- Writing tests (use test-engineer)

### Optimal Workflows

```yaml
exploration_phase:
  workflow:
    - /ctx7 <library1> --quick
    - /ctx7 <library2> --quick
    - /ctx7 <winner> (full review)
  goal: "Quick comparison before deep dive"

integration_phase:
  workflow:
    - /ctx7 <library> --topic=authentication
    - /ctx7 <library> --topic=configuration
    - /ctx7 <library> (full review)
  goal: "Focused research on integration needs"

decision_phase:
  workflow:
    - /ctx7 <option1> --compare=<option2>
    - Review comparison documentation
    - Make informed choice
  goal: "Evidence-based library selection"
```

### Combining with Other Tools

```bash
# Full integration workflow
/ctx7 prisma                           # 1. Review library
/agent api-architect "Design Prisma wrapper"  # 2. Design API
/agent test-engineer "Test Prisma integration" # 3. Create tests
/agent docs-generator "Document Prisma API"    # 4. Final docs
```

## Flags Summary

| Flag | Type | Description | Example |
|------|------|-------------|---------|
| `--topic` | string | Focus on specific topic | `--topic=authentication` |
| `--tokens` | number | Documentation token limit | `--tokens=10000` |
| `--compare` | string | Compare with another library | `--compare=drizzle` |
| `--version` | string | Specific version | `--version=v15.0.0` |
| `--quick` | boolean | Concise summary mode | `--quick` |
| `--output` | path | Custom output location | `--output=docs/db/` |

## Examples Gallery

### Express.js Full Review
```bash
/ctx7 express
```
→ `docs/EXPRESS-CONTEXT7-REVIEW.md` (comprehensive guide)

### Supabase Authentication Focus
```bash
/ctx7 supabase --topic=authentication --tokens=8000
```
→ `docs/SUPABASE-AUTHENTICATION-GUIDE.md` (focused guide)

### Prisma vs Drizzle Comparison
```bash
/ctx7 prisma --compare=drizzle
```
→ `docs/PRISMA-VS-DRIZZLE-COMPARISON.md` (comparison matrix)

### Next.js v15 Specific
```bash
/ctx7 next.js --version=v15.0.0
```
→ `docs/NEXTJS-V15-REVIEW.md` (version-specific)

### Quick Fastify Overview
```bash
/ctx7 fastify --quick
```
→ Terminal summary (not saved)

### Langchain Deep Dive
```bash
/ctx7 langchain --tokens=10000 --output=docs/ai/
```
→ `docs/ai/LANGCHAIN-CONTEXT7-REVIEW.md` (comprehensive)

## Related Commands

- `/agent context7-doc-reviewer` - Direct agent invocation with full control
- `/agent deep-researcher` - Broader research beyond Context7
- `/agent api-architect` - Design API wrappers for libraries
- `/agent docs-generator` - Generate API documentation

## Implementation

This command is a convenience wrapper that invokes the `context7-doc-reviewer` agent with streamlined syntax. It maps command-line flags to agent parameters and handles common use cases with sensible defaults.

**Under the hood:**
```typescript
/ctx7 express --topic=routing --tokens=8000

// Translates to:
Task({
  subagent_type: "context7-doc-reviewer",
  prompt: `Review Express.js documentation with focus on routing.
           Use 8000 token limit for comprehensive coverage.
           Generate integration guide in docs/`
})
```

## Version History

- **v1.0** - Initial Context7 quick lookup command
- **v1.1** - Added comparison mode (--compare)
- **v1.2** - Added quick summary mode (--quick)
- **v1.3** - Added version-specific reviews (--version)
- **v1.4** - Added custom output paths (--output)

Your fastest path to comprehensive library documentation using Context7 MCP server.
