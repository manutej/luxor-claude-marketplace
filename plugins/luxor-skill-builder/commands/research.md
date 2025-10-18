# /research

Conduct comprehensive technical research and generate detailed documentation in project `docs/` folders. This command performs deep analysis of codebases, APIs, systems, and technologies, then synthesizes findings into structured, actionable research documents.

## Usage

```bash
/research <topic> [options]
/research "<detailed-research-request>"
/research --codebase <path>
/research --api <api-name>
/research --compare "<option1> vs <option2>"
```

## Parameters

### Required
- `topic` (string): The research topic or question to investigate
  - Can be a technology, system, API, architecture, or comparison
  - Be specific for better results

### Optional Flags
- `--codebase <path>`: Focus research on specific codebase/directory
- `--api <name>`: Research specific API or SDK
- `--output <filename>`: Custom output filename (default: auto-generated)
- `--format <type>`: Document format - `comprehensive` (default), `quickstart`, `comparison`
- `--compare`: Generate comparison analysis between options
- `--external-only`: Research only external sources (no codebase analysis)
- `--internal-only`: Research only project codebase (no web search)

## Examples

### Example 1: New SDK Research
```bash
/research "Claude SDK architecture and integration"
```
**What it does**:
1. Searches web for Claude SDK official documentation
2. Reviews getting started guides and API references
3. Analyzes example code and repositories
4. Creates comprehensive analysis in `docs/CLAUDE-SDK-ANALYSIS.md`
5. Includes installation, architecture, API reference, examples, best practices

**Output**: `docs/CLAUDE-SDK-ANALYSIS.md` (comprehensive report)

### Example 2: Codebase Analysis
```bash
/research --codebase ./src/auth "authentication system architecture"
```
**What it does**:
1. Maps authentication directory structure
2. Reads auth middleware, routes, and models
3. Traces login/logout flows
4. Identifies security measures and session management
5. Creates architecture diagram and documentation
6. Adds security recommendations

**Output**: `docs/AUTHENTICATION-ARCHITECTURE.md`

### Example 3: API Integration Research
```bash
/research --api "Stripe Payment API" "integration guide for Node.js"
```
**What it does**:
1. Researches Stripe API documentation
2. Reviews authentication and webhook handling
3. Finds best practices for error handling
4. Creates step-by-step integration guide
5. Includes code examples and troubleshooting

**Output**: `docs/STRIPE-API-INTEGRATION-GUIDE.md`

### Example 4: Technology Comparison
```bash
/research --compare "PostgreSQL vs MongoDB for LUXOR project requirements"
```
**What it does**:
1. Researches both database technologies
2. Analyzes LUXOR's specific requirements
3. Compares ACID vs eventual consistency
4. Evaluates performance and scalability
5. Creates decision matrix with pros/cons
6. Provides recommendation with rationale

**Output**: `docs/DATABASE-SELECTION-ANALYSIS.md`

### Example 5: System Design Documentation
```bash
/research "microservices architecture for tax collection system"
```
**What it does**:
1. Researches microservices patterns and best practices
2. Analyzes tax collection domain requirements
3. Designs service boundaries and communication
4. Creates architecture diagrams
5. Documents API contracts and data flows
6. Includes deployment and scaling strategies

**Output**: `docs/SYSTEM-DESIGN.md`

### Example 6: Existing Feature Analysis
```bash
/research --codebase ./src/billing "billing system implementation and improvement opportunities"
```
**What it does**:
1. Analyzes existing billing code structure
2. Maps payment processing flows
3. Identifies current patterns and anti-patterns
4. Documents architecture and dependencies
5. Suggests improvements and refactoring opportunities
6. Creates comprehensive documentation

**Output**: `docs/BILLING-SYSTEM-ANALYSIS.md`

### Example 7: Quick Start Guide
```bash
/research --format quickstart "Redis caching implementation"
```
**What it does**:
1. Researches Redis basics and Node.js integration
2. Creates condensed quick-start guide
3. Includes minimal setup steps
4. Provides basic code examples
5. Links to comprehensive resources

**Output**: `docs/REDIS-QUICKSTART.md` (shorter format)

### Example 8: Performance Optimization Research
```bash
/research "Next.js performance optimization techniques"
```
**What it does**:
1. Researches official Next.js performance docs
2. Finds community best practices
3. Analyzes caching strategies, code splitting, SSR vs SSG
4. Documents profiling and measurement techniques
5. Provides actionable optimization checklist

**Output**: `docs/NEXTJS-PERFORMANCE-OPTIMIZATION.md`

### Example 9: Security Analysis
```bash
/research --codebase ./src "security vulnerabilities and hardening"
```
**What it does**:
1. Scans codebase for common security patterns
2. Researches OWASP Top 10 and relevant CVEs
3. Identifies potential vulnerabilities
4. Documents security best practices
5. Creates security hardening checklist
6. Suggests remediation strategies

**Output**: `docs/SECURITY-ANALYSIS.md`

### Example 10: Multi-Source Integration Research
```bash
/research "integrate Auth0 with existing PostgreSQL user management"
```
**What it does**:
1. Researches Auth0 documentation and SDKs
2. Analyzes existing user management code
3. Designs integration strategy
4. Documents migration approach
5. Creates implementation roadmap
6. Includes testing strategy

**Output**: `docs/AUTH0-INTEGRATION-IMPLEMENTATION-GUIDE.md`

## What It Does (Step-by-Step)

### Phase 1: Discovery & Scoping (1-2 minutes)
1. **Parse Research Request**
   - Identify research topic and scope
   - Determine if codebase analysis needed
   - Plan information gathering strategy
   - Define key questions to answer

2. **Locate Resources**
   - Use Glob to find relevant project files
   - Identify external documentation sources
   - Plan web search queries
   - Determine document structure

### Phase 2: Information Gathering (5-10 minutes)
3. **Codebase Analysis** (if applicable)
   - Map project structure with Glob
   - Read key files and modules
   - Trace code flows and patterns
   - Identify dependencies and integration points
   - Extract configuration patterns

4. **External Research**
   - WebSearch for official documentation
   - WebFetch specific documentation pages
   - Research best practices and case studies
   - Review technical specifications
   - Find code examples and tutorials

5. **Evidence Collection**
   - Capture relevant code snippets
   - Bookmark documentation references
   - Screenshot architecture diagrams
   - Note configuration examples
   - Record API endpoints and parameters

### Phase 3: Analysis & Synthesis (3-5 minutes)
6. **Pattern Identification**
   - Identify common patterns and anti-patterns
   - Extract reusable code patterns
   - Recognize architectural approaches
   - Note best practices

7. **Information Organization**
   - Structure findings logically
   - Create outline for documentation
   - Organize code examples by topic
   - Plan diagram placements

### Phase 4: Documentation Creation (5-10 minutes)
8. **Write Comprehensive Document**
   - Executive summary with key findings
   - Table of contents for navigation
   - Detailed technical sections
   - Architecture diagrams (ASCII/Mermaid)
   - Code examples with explanations
   - Best practices section
   - Integration guide (if applicable)
   - Troubleshooting guide
   - References and citations

9. **Quality Assurance**
   - Verify code examples accuracy
   - Check external links validity
   - Ensure technical claims have evidence
   - Review formatting and structure
   - Generate/update table of contents

10. **Finalization**
    - Save to `docs/` folder with appropriate naming
    - Report output location
    - Summarize key findings
    - Suggest next steps

## Document Structure Generated

The `/research` command generates comprehensive documentation following this structure:

```markdown
# [Topic] - Comprehensive Analysis

## Executive Summary
- Key findings (2-3 paragraphs)
- Main recommendations
- Strategic value

## Table of Contents
[Auto-generated navigation]

## Overview
- Context and background
- Research scope and objectives
- Methodology used

## Architecture/System Design
- Component diagrams
- Data flow illustrations
- Design patterns identified

## Core Components
- Detailed component breakdown
- Interfaces and contracts
- Dependencies

## API Reference (if applicable)
- Endpoints and methods
- Parameters and responses
- Authentication
- Code examples

## Integration Guide
- Step-by-step setup
- Configuration examples
- Testing integration
- Common pitfalls

## Code Examples
- Practical, runnable examples
- Explanation of each example
- Edge cases covered

## Best Practices
- Recommended patterns
- Conventions to follow
- Things to avoid

## Performance Considerations
- Optimization strategies
- Bottlenecks to watch
- Scaling approaches

## Security Considerations
- Authentication/authorization
- Data protection
- Vulnerability mitigation

## Troubleshooting Guide
- Common issues and solutions
- Debugging techniques
- Error messages explained

## Implementation Roadmap
- Phased approach
- Milestones and dependencies
- Estimated timelines

## Testing Strategy
- Unit testing approach
- Integration testing
- E2E testing scenarios

## References
- Official documentation links
- Source code repositories
- Community resources
- Related reading

## Appendix
- Glossary of terms
- Additional technical details
- FAQ
```

## Output Location and Naming

### Default Location
```
<project-root>/docs/[TOPIC]-[TYPE].md
```

### Naming Conventions
- UPPERCASE for main words
- Hyphens for multi-word topics
- Descriptive type suffix
- Examples:
  - `CLAUDE-SDK-ANALYSIS.md`
  - `AUTHENTICATION-ARCHITECTURE.md`
  - `DATABASE-COMPARISON.md`
  - `API-INTEGRATION-GUIDE.md`

### Custom Output
```bash
# Specify custom location
/research "topic" --output custom-name.md

# Output to subdirectory
/research "topic" --output docs/architecture/custom-name.md
```

## Integration Points

### Works With Other Agents
```bash
# Research → Implementation workflow
/research "topic"           # Creates comprehensive research doc
# (Review findings)
# Implementation based on research

# Research → Documentation workflow
/research --api "API-name"  # Creates integration guide
# Then use docs-generator for API reference

# Research → Testing workflow
/research --codebase ./src  # Analyzes codebase
# test-engineer uses findings to create test suite
```

### Common Command Chains
```bash
# Full analysis workflow
/research "authentication system" && /research "security hardening"

# Compare then implement
/research --compare "option1 vs option2"
# Review comparison, make decision
# Implement chosen option
```

## Research Quality Standards

Every research document includes:
- ✅ Executive summary with key insights
- ✅ Comprehensive table of contents
- ✅ Evidence-based technical analysis
- ✅ Practical code examples (tested)
- ✅ Architecture diagrams where relevant
- ✅ Best practices from authoritative sources
- ✅ Troubleshooting section
- ✅ References and citations
- ✅ Actionable next steps

## Configuration

### Default Settings
```yaml
# Automatically configured in .claude/settings.local.json
research:
  output_dir: docs/
  format: comprehensive
  include_toc: true
  include_diagrams: true
  verify_examples: true
  max_depth: deep  # deep | medium | shallow
```

### Permissions Required
```json
{
  "permissions": {
    "allow": [
      "WebSearch(*)",
      "WebFetch(*)",
      "Read(<project-path>/**)",
      "Glob(*)",
      "Grep(*)",
      "Write(<project-path>/docs/**)",
      "Bash(node:*)",  // For testing code examples
      "Task(*)"  // For delegating sub-research tasks
    ]
  }
}
```

## Tips for Best Results

### Be Specific
```bash
✅ /research "integrate Stripe webhooks with Express.js and handle payment events"
❌ /research "payments"
```

### Provide Context
```bash
✅ /research --codebase ./src/auth "OAuth2 implementation and security improvements"
❌ /research "auth"
```

### Use Comparison for Decisions
```bash
✅ /research --compare "REST vs GraphQL for our microservices API"
❌ /research "APIs"
```

### Leverage Format Options
```bash
# For quick reference
/research --format quickstart "Redis setup"

# For comprehensive analysis
/research --format comprehensive "Redis caching strategy"
```

## Troubleshooting

### Issue: Research takes too long
**Solution**: Use narrower scope or `--external-only` flag
```bash
/research --external-only "quick overview of X"
```

### Issue: Output not in expected location
**Solution**: Verify current directory and use absolute paths
```bash
/research "topic" --output /absolute/path/to/docs/FILE.md
```

### Issue: Missing codebase analysis
**Solution**: Explicitly specify codebase path
```bash
/research --codebase ./src "topic"
```

### Issue: Document too technical/not technical enough
**Solution**: Specify audience in request
```bash
/research "topic for senior engineers with deep technical detail"
/research "topic with high-level overview for stakeholders"
```

## Advanced Usage

### Batch Research
```bash
# Research multiple related topics
/research "authentication system" && \
/research "authorization patterns" && \
/research "session management"
```

### Update Existing Research
```bash
# Research updates to previously documented topic
/research "updates to Claude SDK since v1.0" --output docs/CLAUDE-SDK-ANALYSIS.md
# Will update existing document with new findings
```

### Focused Deep Dive
```bash
# Research specific aspect
/research --codebase ./src/payments "error handling patterns and improvements"
```

## Related Commands

- `/meta-agent` - Generate custom research agent specifications
- `/agent` - Create specialized research agents
- `docs-generator` agent - Generate API documentation
- `test-engineer` agent - Create testing strategies

## Version History

- v1.0: Initial research command with comprehensive documentation
- v1.1: Added comparison mode and format options
- v1.2: Enhanced codebase analysis with pattern recognition
- v1.3: Improved external research with multi-source validation

## Philosophy

The `/research` command embodies these principles:

**Depth over speed**: Thorough understanding before documentation.

**Evidence-based**: Every claim backed by code, docs, or authoritative sources.

**Actionable insights**: Focus on practical, implementable recommendations.

**Comprehensive coverage**: Address how, why, when, and what could go wrong.

**Living documentation**: Create docs teams will actually use and maintain.

**Continuous learning**: Each research session improves the agent's pattern library.

---

**Ready to research?**

```bash
# Start your first deep research
/research "your research topic here"
```

The deep-researcher agent will systematically investigate your topic and generate comprehensive, actionable documentation in your project's `docs/` folder.
