# /call-claude

Generate and execute Claude SDK code for testing API features.

**Usage:**
```bash
/call-claude "<prompt>" [options]
```

**What this command does:**
You will help execute Claude SDK calls by:

1. Generating the appropriate SDK code based on the request
2. Using Bash to execute the code if possible
3. Showing the response and usage statistics
4. If execution isn't possible, providing copy-paste ready code

**Execution approach:**

1. **Check for SDK:**
   - Look for `node_modules/@anthropic-ai/sdk` or `anthropic` (Python)
   - Check for ANTHROPIC_API_KEY in environment

2. **Generate appropriate code:**
   - Use latest SDK patterns from /deep -ws if needed
   - Include requested features (streaming, tools, thinking, etc.)
   - Add error handling

3. **Execute via Bash:**
   ```bash
   # For Node.js
   node -e "
   const Anthropic = require('@anthropic-ai/sdk');
   // ... generated code
   "

   # For Python
   python3 -c "
   from anthropic import Anthropic
   # ... generated code
   "
   ```

4. **Display results:**
   - Show Claude's response
   - Display token usage
   - Show cost estimate
   - Report any errors

**Supported flags (parse from command):**
- `--stream` - Enable streaming
- `--thinking` - Enable extended thinking
- `--model <name>` - Specify model (sonnet/opus/haiku)
- `--tools <file>` - Load tool definitions from file
- `--cache "<prompt>"` - Enable prompt caching
- `--max-tokens <n>` - Set max tokens
- `--save <file>` - Save response to file
- `--debug` - Show debug info

**Example execution for: `/call-claude "Hello Claude" --stream`**

1. Generate code:
```javascript
const Anthropic = require('@anthropic-ai/sdk');
const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

async function main() {
  const stream = await client.messages.create({
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 1024,
    stream: true,
    messages: [{ role: 'user', content: 'Hello Claude' }]
  });

  for await (const event of stream) {
    if (event.type === 'content_block_delta') {
      process.stdout.write(event.delta.text);
    }
  }
}

main();
```

2. Execute via Bash:
```bash
node -e "<generated-code>"
```

3. Display result:
```
Streaming response...
Hello! I'm Claude, an AI assistant...

✓ Complete
Tokens: 12 input, 24 output
Cost: ~$0.0002
```

**If execution fails:**
- Explain why (missing SDK, API key, etc.)
- Provide installation instructions
- Give copy-paste ready code to run manually

**For complex requests:**
- Multi-turn conversations: Create a .js/.py file and execute it
- Tool use: Parse tool definitions, generate handler code
- Extended features: Research latest SDK patterns first

**Key principles:**
- Try to execute when possible
- Generate production-quality code
- Handle errors gracefully
- Show clear output and usage
- Provide manual alternatives if auto-execution fails
