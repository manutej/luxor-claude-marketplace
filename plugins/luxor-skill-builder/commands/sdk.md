# /sdk

Quick Claude SDK reference lookup using rapid web search.

**Usage:**
```bash
/sdk "<question or parameter>"
/sdk --api <api-name>
/sdk --error <code>
```

**What this command does:**
You will provide a quick, concise Claude SDK reference by:

1. Using `/deep -ws` to search official Anthropic documentation
2. Targeting: docs.anthropic.com, github.com/anthropics
3. Extracting the specific answer requested
4. Returning in terminal format (not saving to file)

**Output format:**
- Direct answer (1-3 paragraphs or code block)
- Code example if relevant
- Link to official docs
- Keep it brief and actionable

**Examples of what to return:**

For parameter questions:
```
Parameter: stream
Type: boolean
Default: false

const message = await client.messages.create({
  stream: true,  // Enable streaming
  ...
});

Docs: https://docs.anthropic.com/claude/reference/messages-streaming
```

For error questions:
```
Error 429: Rate Limit Exceeded
Cause: Too many requests

Quick fix:
await new Promise(r => setTimeout(r, 60000));

Docs: https://docs.anthropic.com/claude/reference/errors
```

For API reference:
```
Messages API - Required Parameters:
- model: 'claude-3-5-sonnet-20241022'
- messages: [{ role: 'user', content: '...' }]
- max_tokens: 1024

Docs: https://docs.anthropic.com/claude/reference/messages_post
```

**Key principles:**
- Speed over depth (30-60 seconds max)
- Terminal output only
- Code examples when helpful
- Always link to official docs
- If complex, suggest using claude-sdk-expert agent instead
