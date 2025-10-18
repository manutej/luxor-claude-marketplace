# /docrag

Query documentation RAG (Retrieval-Augmented Generation) systems or manage RAG sources. Get expert answers from indexed documentation with accurate citations.

## Usage

```bash
/docrag "<query>" [--source=<name>]     # Query RAG system(s)
/docrag --list                          # List available RAG sources
/docrag --build <url> [--name=<name>]   # Build new RAG from documentation
/docrag --update <source>               # Update existing RAG
/docrag --help                          # Show this help
```

## Parameters

- `query` (string, required for query mode): Natural language question about documentation
- `--source=<name>` (optional): Which RAG source to query (default: all sources)
- `--list` (flag): Display all available RAG sources with statistics
- `--build <url>` (flag + URL): Build new RAG from documentation website
- `--name=<name>` (optional with --build): Custom name for RAG source
- `--update <source>` (flag + source name): Refresh/update existing RAG
- `--help` (flag): Display this help documentation

## Examples

### Query RAG Systems

```bash
# Query all available RAG sources
/docrag "How do I implement tool calling?"

# Output:
# Found relevant information in mcp:
#
# ## Tool Calling in MCP Servers
#
# To implement tool calling in an MCP server, you need to:
#
# 1. **Define Tool Schema**
#    Tools must be defined with a JSON schema specifying inputs and outputs.
#    [Source: MCP Protocol > Tool Schema]
#
# 2. **Register Tools**
#    ```typescript
#    server.registerTool({
#      name: "get_weather",
#      description: "Get weather for a location",
#      inputSchema: { ... }
#    });
#    ```
#    [Source: Implementing Tools > Registration]
#
# **References:**
# - [MCP Protocol > Tool Calling](https://modelcontextprotocol.io/docs/protocol#tools)
# - [Implementing Tools > Tool Schema](https://modelcontextprotocol.io/docs/tools/schema)
```

### Query Specific Source

```bash
# Query only MCP documentation
/docrag "What are the security best practices?" --source=mcp

# Query only Anthropic documentation
/docrag "How do I stream responses?" --source=anthropic

# Query internal wiki
/docrag "What is the deployment process?" --source=company-wiki
```

### List Available Sources

```bash
/docrag --list

# Output:
# Available Documentation RAG Sources:
#
# 1. **mcp** (Model Context Protocol)
#    - Source: https://modelcontextprotocol.io
#    - Last updated: 2 days ago
#    - Pages: 456 | Chunks: 2,387
#    - Status: ✅ Up to date
#
# 2. **anthropic** (Anthropic Claude Documentation)
#    - Source: https://docs.anthropic.com
#    - Last updated: 15 days ago
#    - Pages: 834 | Chunks: 4,521
#    - Status: ⚠️  Consider updating (>14 days)
#
# 3. **company-wiki** (Internal Documentation)
#    - Source: https://wiki.company.internal
#    - Last updated: 1 day ago
#    - Pages: 234 | Chunks: 1,102
#    - Status: ✅ Up to date
#
# Usage:
#   /docrag "<query>" --source=mcp        Query specific source
#   /docrag "<query>"                      Query all sources
#   /docrag --update <source>              Refresh documentation
#   /docrag --build <url>                  Build new RAG source
```

### Build New RAG

```bash
# Build RAG from documentation URL
/docrag --build https://modelcontextprotocol.io

# Output:
# Building RAG from modelcontextprotocol.io...
#
# ✓ Discovery complete: 456 pages found
#   → Scraping content... (125/456 pages)
#   → Scraping content... (250/456 pages)
#   → Scraping content... (456/456 pages)
# ✓ Content extraction complete
#   → Chunking content... (1,200/2,387 chunks)
# ✓ Chunking complete: 2,387 chunks created
#   → Generating embeddings... (800/2,387 embeddings)
# ✓ Embeddings complete
#   → Building vector database...
# ✓ Vector database created
#   → Validating RAG system...
# ✓ Validation complete: All test queries passed
# ✓ RAG build complete!
#
#   Source: modelcontextprotocol.io
#   Pages: 456
#   Chunks: 2,387
#   Storage: 127 MB
#   Build time: 28 minutes
#
#   Usage: /docrag "<query>" --source=mcp

# Build with custom name
/docrag --build https://docs.stripe.com --name=stripe-api

# Build from internal documentation
/docrag --build https://wiki.company.internal --name=internal-docs
```

### Update Existing RAG

```bash
# Update stale documentation
/docrag --update mcp

# Output:
# Updating MCP Documentation RAG...
#
# Last update: 30 days ago
# Checking for changes...
#
# Changes detected:
#   ✅ 12 pages updated
#   ✅ 3 new pages added
#   ✅ 1 page removed
#
# Re-processing changed content...
#   → Chunking updates... (47 new chunks)
#   → Generating embeddings... (47/47 embeddings)
#   → Updating vector database...
#
# ✓ Update complete!
#
#   Total chunks: 2,340 → 2,387 (+47)
#   Database updated: docs/rag/mcp/vectors.db
#   New content includes:
#     - "Advanced Tool Patterns"
#     - "MCP Security Best Practices"
#     - "Multi-Tool Workflows"
#
# Usage: /docrag "<query>" --source=mcp
```

## What It Does

The `/docrag` command provides a query interface to documentation RAG systems. It operates in different modes based on the command structure.

### Mode 1: Query Mode (Default)

When a query string is provided:

```yaml
Process:
  1. Parse query and --source parameter
  2. Load vector database(s):
     - If --source specified: Load docs/rag/<source>/vectors.db
     - If no --source: Load all available RAG sources
  3. Generate query embedding (using Claude API)
  4. Perform similarity search in vector database
  5. Retrieve top-k relevant chunks (k=5 default)
  6. Extract metadata and construct context
  7. Generate answer using Claude with retrieved context
  8. Format response with citations
  9. Display to user

Query Embedding:
  Model: Same as RAG embeddings (Claude, OpenAI, or local)
  Input: User's natural language query
  Output: Vector embedding for similarity search

Similarity Search:
  Algorithm: Cosine similarity
  Top-k: 5 chunks (most relevant)
  Threshold: 0.7 minimum similarity score
  Metadata filtering: By source if --source specified

Context Construction:
  For each retrieved chunk:
    - Chunk text
    - Source URL
    - Page title
    - Section path
    - Similarity score

Answer Generation:
  Model: Claude (Sonnet)
  System prompt:
    "You are an expert documentation assistant. Use the provided
    documentation excerpts to answer the user's question accurately.
    Always cite sources with URLs. If information is not in the
    provided context, say so."

  Context: Retrieved chunks
  Query: User's question
  Output: Comprehensive answer with citations

Response Format:
  - Clear, structured answer
  - Inline citations [Source: <section>]
  - References section with URLs
  - Related topics if applicable
```

**Example Query Flow:**

```yaml
User Query: "How do I implement tool calling in MCP?"

Step 1 - Generate Query Embedding:
  Input: "How do I implement tool calling in MCP?"
  Output: [0.123, -0.456, 0.789, ...] (1536-dim vector)

Step 2 - Similarity Search:
  Search in: docs/rag/mcp/vectors.db
  Top 5 Results:
    1. chunk-0234: "MCP Protocol > Tools > Tool Schema" (similarity: 0.92)
    2. chunk-0235: "Implementing Tools > Registration" (similarity: 0.89)
    3. chunk-0312: "Example: Weather Tool" (similarity: 0.85)
    4. chunk-0236: "Tool Execution Flow" (similarity: 0.83)
    5. chunk-0237: "Error Handling in Tools" (similarity: 0.80)

Step 3 - Construct Context:
  Context = [
    {text: <chunk-0234 content>, url: <source URL>, title: <page title>},
    {text: <chunk-0235 content>, url: <source URL>, title: <page title>},
    ...
  ]

Step 4 - Generate Answer with Claude:
  System: "Expert documentation assistant..."
  Context: Retrieved chunks
  Query: "How do I implement tool calling in MCP?"

  Claude Output:
    "To implement tool calling in an MCP server, you need to:

    1. **Define Tool Schema**
       Tools must be defined with a JSON schema...
       [Source: MCP Protocol > Tool Schema]

    2. **Register Tools**
       ```typescript
       server.registerTool({...});
       ```
       [Source: Implementing Tools > Registration]

    **References:**
    - [MCP Protocol > Tool Calling](https://modelcontextprotocol.io/...)
    - [Implementing Tools > Tool Schema](https://modelcontextprotocol.io/...)"

Step 5 - Display to User:
  Format and display answer with citations
```

### Mode 2: List Mode

When `--list` flag is provided:

```yaml
Process:
  1. Scan docs/rag/ directory for subdirectories
  2. For each subdirectory:
     - Read index.json for metadata
     - Extract statistics (pages, chunks, last_updated)
     - Calculate status (up to date, needs update)
     - Format for display
  3. Sort by name or last_updated
  4. Display summary table

Status Determination:
  ✅ Up to date: last_updated < 7 days ago
  ⚠️  Consider updating: 7-30 days ago
  ❌ Outdated: last_updated > 30 days ago

Output Format:
  For each source:
    - Name and description
    - Source URL
    - Last updated (relative time)
    - Statistics (pages, chunks)
    - Status indicator

  Usage hints at bottom
```

### Mode 3: Build Mode

When `--build <url>` is provided:

```yaml
Process:
  1. Parse URL and optional --name parameter
  2. Validate URL is accessible
  3. Determine source name:
     - Use --name if provided
     - Extract from domain if not (modelcontextprotocol.io → "mcp")
     - Validate name is unique (or append suffix)
  4. Invoke doc-rag-builder agent:
     - Pass URL and source name
     - Monitor progress
     - Display progress updates
  5. Wait for completion
  6. Report build statistics
  7. Provide usage instructions

Agent Invocation:
  Use Task tool to launch doc-rag-builder agent
  Pass parameters:
    - documentation_url: <user-provided URL>
    - source_name: <determined name>
    - output_path: docs/rag/<source-name>/

  Monitor:
    - Discovery progress
    - Scraping progress
    - Chunking progress
    - Embedding progress
    - Validation results

Error Handling:
  - URL not accessible: Report error, suggest alternatives
  - Name collision: Suggest alternative name or overwrite
  - Build failure: Report specific error, cleanup partial build
```

### Mode 4: Update Mode

When `--update <source>` is provided:

```yaml
Process:
  1. Validate source exists in docs/rag/<source>/
  2. Read existing index.json
  3. Check last_updated timestamp
  4. Invoke doc-rag-builder agent for incremental update:
     - Pass existing RAG location
     - Request incremental update
     - Monitor progress
  5. Agent detects changes:
     - Modified pages
     - New pages
     - Deleted pages
  6. Agent re-processes only changed content
  7. Agent updates vector database incrementally
  8. Report changes and statistics

Incremental Update:
  Advantages:
    - Faster than full rebuild
    - Preserves existing embeddings
    - Only charges for new embeddings

  Process:
    - Load existing index
    - Check documentation for changes (If-Modified-Since)
    - Re-chunk and re-embed only changed pages
    - Update vector DB incrementally
    - Update index.json with new timestamp

  Report:
    - X pages updated
    - Y pages added
    - Z pages removed
    - Total chunks: old → new (+delta)
```

## Query Response Format

Queries return structured answers with citations:

### Basic Response Format

```markdown
## [Topic from Query]

[Comprehensive answer based on retrieved documentation context]

### Key Points
- Point 1 [Source: <section>]
- Point 2 [Source: <section>]
- Point 3 [Source: <section>]

### Code Examples
```language
[Code example from documentation]
```
[Source: <section>]

### References
- [<Page Title>](<Full URL>)
- [<Page Title>](<Full URL>)
- [<Page Title>](<Full URL>)

### Related Topics
- [Related topic 1]
- [Related topic 2]
```

### Example Response

```markdown
## Tool Calling in MCP Servers

To implement tool calling in an MCP server, you need to define tool schemas, register tools, and handle tool execution.

### Key Steps

1. **Define Tool Schema**
   Tools must be defined with a JSON schema specifying inputs and outputs.
   [Source: MCP Protocol > Tool Schema]

2. **Register Tools**
   Register tools with your MCP server using the `registerTool` method:
   ```typescript
   server.registerTool({
     name: "get_weather",
     description: "Get weather for a location",
     inputSchema: {
       type: "object",
       properties: {
         location: { type: "string" }
       }
     }
   });
   ```
   [Source: Implementing Tools > Registration]

3. **Handle Tool Calls**
   Implement the tool execution logic:
   ```typescript
   server.handleToolCall(async (name, args) => {
     if (name === "get_weather") {
       return await fetchWeather(args.location);
     }
   });
   ```
   [Source: Example: Weather Tool]

### Error Handling

Always validate inputs and handle errors gracefully to provide meaningful error messages to clients.
[Source: Error Handling in Tools]

### References
- [MCP Protocol Overview > Tool Calling](https://modelcontextprotocol.io/docs/protocol#tools)
- [Implementing Tools > Tool Schema](https://modelcontextprotocol.io/docs/tools/schema)
- [Example: Weather Tool](https://modelcontextprotocol.io/docs/examples/weather)
- [Error Handling in Tools](https://modelcontextprotocol.io/docs/errors)

### Related Topics
- Server implementation patterns
- Tool input validation
- Asynchronous tool execution
```

## Multi-Source Queries

When querying without `--source`, the command searches all available RAG sources:

```yaml
Process:
  1. Load all RAG sources from docs/rag/
  2. Generate query embedding once
  3. Search each source's vector database
  4. Collect top-k results from each source
  5. Rank all results by similarity score
  6. Select top-5 overall (across all sources)
  7. Group results by source for context
  8. Generate answer with multi-source citations

Result Grouping:
  Sources mentioned:
    - Source 1: 3 chunks
    - Source 2: 2 chunks

  Answer format:
    "Based on MCP documentation and Anthropic guides..."
    [Source: MCP > Tool Schema]
    [Source: Anthropic > Function Calling]

Conflict Handling:
  If sources have conflicting information:
    - Present both perspectives
    - Note the difference
    - Cite each source clearly
    - Let user decide

Example:
  "MCP recommends approach A [Source: MCP], while Anthropic
  documentation suggests approach B [Source: Anthropic]. Both are
  valid depending on your use case."
```

## Performance Characteristics

### Query Performance

```yaml
Single Source Query:
  Vector search: ~50ms
  Query embedding: ~50ms
  Claude answer generation: 1-3 seconds
  Total: 2-4 seconds

Multi-Source Query:
  Vector search per source: ~50ms × N sources
  Query embedding: ~50ms (once)
  Claude answer generation: 1-3 seconds
  Total: 2-5 seconds (for 3-5 sources)

Large RAG (10,000+ chunks):
  Vector search: ~100ms (still fast with proper indexing)
  Other steps: same
```

### Build Performance

See doc-rag-builder agent documentation for build time estimates by documentation size.

## Error Handling

### Common Query Issues

**No Relevant Results:**
```yaml
Cause: Query doesn't match indexed content

Response:
  "I couldn't find relevant information in the [source] documentation
  about [query topic]. This might be because:

  1. The information isn't covered in the indexed documentation
  2. The query needs to be more specific
  3. The RAG needs updating (documentation changed)

  Try:
  - Rephrasing your query
  - Checking another source: /docrag --list
  - Updating the RAG: /docrag --update <source>"
```

**Low Similarity Scores:**
```yaml
Cause: Weak matches, results below threshold

Response:
  "I found some potentially related information, but the match isn't
  strong. Here's what I found:

  [Lower confidence answer with citations]

  For better results, try:
  - More specific query terms
  - Different phrasing
  - Checking if this topic is covered: /docrag --list"
```

**Source Not Found:**
```yaml
Cause: --source specified but doesn't exist

Response:
  "RAG source 'xyz' not found.

  Available sources:
  - mcp
  - anthropic
  - company-wiki

  Use: /docrag --list to see all sources
  Or:  /docrag --build <url> to create new source"
```

### Common Build Issues

**URL Not Accessible:**
```yaml
Error: "Cannot access https://docs.example.com (HTTP 403)"

Suggested Actions:
  - Check if URL is correct
  - Verify no authentication required
  - Check robots.txt restrictions
  - Try alternative documentation source
```

**Build Interrupted:**
```yaml
Error: "Build interrupted at embedding phase"

Recovery:
  - Cleanup partial build: rm -rf docs/rag/<source>/.temp
  - Retry build: /docrag --build <url>
  - Agent will resume from checkpoints if available
```

## Storage Location

```
docs/rag/
  ├── mcp/                          # MCP documentation RAG
  │   ├── vectors.db                # Vector database (ChromaDB)
  │   ├── index.json                # Metadata and statistics
  │   ├── citations.json            # Chunk ID → URL mappings
  │   └── README.md                 # Source-specific usage guide
  ├── anthropic/                    # Anthropic documentation RAG
  │   ├── vectors.db
  │   ├── index.json
  │   ├── citations.json
  │   └── README.md
  └── [user-defined-sources]/       # Any custom sources
      └── ...
```

## Integration with Doc-RAG-Builder Agent

The `/docrag` command works in tandem with the doc-rag-builder agent:

```yaml
Division of Responsibilities:

doc-rag-builder agent (building):
  - Scrape documentation websites
  - Chunk content intelligently
  - Generate embeddings
  - Build vector databases
  - Create indices and citations
  - Validate quality

/docrag command (querying):
  - Parse user queries
  - Generate query embeddings
  - Search vector databases
  - Retrieve relevant chunks
  - Generate answers with Claude
  - Format responses with citations
  - Manage RAG sources (list, update)

Workflow:
  1. User: /docrag --build <url>
  2. Command invokes doc-rag-builder agent
  3. Agent builds RAG → docs/rag/<source>/
  4. User: /docrag "<query>" --source=<source>
  5. Command queries built RAG
  6. User gets answer with citations
```

## Best Practices

### Query Formulation

**Good Queries:**
- "How do I implement authentication?"
- "What are the configuration options for X?"
- "Show me an example of Y"
- "What's the difference between A and B?"

**Avoid:**
- Too vague: "tell me about the docs"
- Too specific: "line 47 of file X" (not in RAG)
- Multiple questions: "How do A and B and also C?"

### Source Management

**Regular Updates:**
```bash
# Check which sources need updating
/docrag --list

# Update stale sources
/docrag --update mcp
/docrag --update anthropic
```

**Multiple Versions:**
```bash
# Build separate RAGs for different versions
/docrag --build https://v1.docs.example.com --name=example-v1
/docrag --build https://v2.docs.example.com --name=example-v2

# Query specific version
/docrag "new features" --source=example-v2
```

### Query Refinement

If first query doesn't get good results:

1. **Rephrase:** Use different terminology
2. **Be more specific:** Add context or constraints
3. **Try related terms:** Use synonyms or related concepts
4. **Check source:** Ensure querying correct RAG source

## Advanced Usage

### Batch Queries

```bash
# Query multiple sources for comparison
/docrag "authentication methods" --source=mcp
/docrag "authentication methods" --source=anthropic

# Compare responses for comprehensive understanding
```

### Research Workflows

```bash
# Build research context
/docrag --build https://docs.technology-a.com --name=tech-a
/docrag --build https://docs.technology-b.com --name=tech-b

# Compare approaches
/docrag "deployment strategies" --source=tech-a
/docrag "deployment strategies" --source=tech-b

# Make informed decision based on both sources
```

## Limitations

**Temporal Limitations:**
- RAG is static snapshot, not real-time
- Information may be outdated if not updated regularly
- Solution: Use `/docrag --update` regularly

**Context Window:**
- Limited to top-k chunks (default 5)
- Very long answers may need multiple queries
- Solution: Ask more specific questions

**Visual Content:**
- Cannot interpret diagrams or images
- Only text and code are indexed
- Solution: RAG includes image URLs and captions

**Cross-References:**
- May not capture all relationships between topics
- Solution: Use follow-up queries for related topics

## Related Commands

- `/meta-agent` - Generate agent specifications
- `/deep` - Deep research on topics
- `/research` - Research and synthesize information

## Help & Troubleshooting

### Get Help

```bash
/docrag --help                    # Show this documentation
```

### Check Status

```bash
/docrag --list                    # See all sources and status
```

### Verify Installation

```bash
# Check if RAG directory exists
ls docs/rag/

# Check specific source
ls docs/rag/mcp/
```

### Debug Query Issues

```bash
# Test with simple query
/docrag "what is this documentation about?" --source=mcp

# If that works, try more complex queries
# If not, check:
#   1. RAG exists: /docrag --list
#   2. Vector DB intact: ls docs/rag/mcp/vectors.db
#   3. Rebuild if needed: /docrag --build <url>
```

## Version History

- v1.0: Initial implementation (query, list, build)
- v1.1: Added incremental updates (--update)
- v1.2: Multi-source query support
- v1.3: Enhanced citation formatting
- v1.4: Performance optimizations

## Philosophy

The `/docrag` command transforms documentation from static websites into conversational, queryable knowledge bases. Instead of searching through hundreds of pages, users can ask natural language questions and get accurate, cited answers in seconds.

**Key Principles:**

1. **Accuracy**: Always cite sources, never hallucinate
2. **Transparency**: Show where information comes from
3. **Flexibility**: Work with any documentation source
4. **Speed**: Fast similarity search, quick responses
5. **Maintainability**: Easy updates, clear status reporting

Your queries should enable developers to find information faster, understand concepts better, and build with confidence using accurate, up-to-date documentation.
