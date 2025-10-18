---
name: claude-sdk-integration-patterns
description: Expert integration patterns for Claude API and TypeScript SDK covering Messages API, streaming responses, tool use, error handling, token optimization, and production-ready implementations for building AI-powered applications
---

# Claude SDK Integration Patterns

Production-ready patterns for integrating Claude API and TypeScript SDK into applications. Master streaming responses, tool execution, error handling, and optimization strategies for AI-powered features.

## When to Use This Skill

Use this skill when you need to:
- Integrate Claude API into Node.js/TypeScript applications
- Implement streaming conversations with real-time responses
- Build applications with Claude tool use (function calling)
- Handle API errors gracefully with retry logic
- Optimize token usage and manage costs
- Deploy Claude-powered features to production
- Build multi-turn conversations with context management
- Implement message batching for high-volume processing

## Core Concepts

### Messages API Fundamentals

The Claude Messages API is the primary interface for conversational AI:

**Key Components:**
- **Model Selection**: Choose appropriate model (Opus, Sonnet, Haiku)
- **Messages Array**: Conversation history with user/assistant roles
- **Max Tokens**: Control response length
- **System Prompts**: Guide model behavior
- **Streaming**: Real-time response generation

### SDK Architecture

The TypeScript SDK provides:
- Type-safe API client
- Streaming helpers for real-time responses
- Tool execution framework
- Error handling utilities
- Message batch processing
- Event-driven architecture

## Installation and Setup

```bash
# Install the SDK
npm install @anthropic-ai/sdk

# Or with yarn
yarn add @anthropic-ai/sdk
```

```typescript
import Anthropic from '@anthropic-ai/sdk';

// Initialize client
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});
```

## Messages API Patterns

### Pattern 1: Basic Message Creation

```typescript
const message = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Hello, Claude!' }
  ],
});

console.log(message.content);
```

**When to use:**
- Simple question-answer interactions
- One-off API calls
- Synchronous workflows

### Pattern 2: Multi-Turn Conversations

```typescript
const messages = [
  { role: 'user', content: 'What is TypeScript?' },
  { role: 'assistant', content: 'TypeScript is a typed superset of JavaScript...' },
  { role: 'user', content: 'Give me an example' },
];

const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages,
});
```

**When to use:**
- Chatbots and conversational UIs
- Multi-step workflows
- Context-dependent interactions

### Pattern 3: System Prompts

```typescript
const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: 'You are a helpful Python programming assistant. Provide concise, tested code examples.',
  messages: [
    { role: 'user', content: 'How do I read a CSV file?' }
  ],
});
```

**When to use:**
- Specialized assistants
- Role-playing scenarios
- Consistent behavior across conversations

## Streaming Patterns

### Pattern 4: Basic Streaming

```typescript
const stream = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
    process.stdout.write(event.delta.text);
  }
}
```

**When to use:**
- Real-time user interfaces
- Long-form content generation
- Interactive experiences

### Pattern 5: Streaming with Event Handlers

```typescript
const stream = anthropic.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Explain quantum computing' }],
})
  .on('text', (text) => {
    console.log(text);
  })
  .on('message', (message) => {
    console.log('Complete message:', message);
  })
  .on('error', (error) => {
    console.error('Stream error:', error);
  });

const finalMessage = await stream.finalMessage();
```

**When to use:**
- Real-time UIs (chatbots, live editors)
- Progress indicators
- Partial result processing

### Pattern 6: Streaming with Abort Control

```typescript
const stream = anthropic.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Long task...' }],
});

// Abort after timeout
setTimeout(() => stream.abort(), 5000);

try {
  await stream.done();
} catch (error) {
  if (error instanceof Anthropic.APIUserAbortError) {
    console.log('Stream aborted by user');
  }
}
```

**When to use:**
- User-cancellable operations
- Timeout handling
- Resource management

## Tool Use Patterns

### Pattern 7: Tool Definition with Zod

```typescript
import { betaZodTool } from '@anthropic-ai/sdk/helpers/zod';
import { z } from 'zod';

const weatherTool = betaZodTool({
  name: 'get_weather',
  inputSchema: z.object({
    location: z.string(),
    unit: z.enum(['celsius', 'fahrenheit']).default('fahrenheit'),
  }),
  description: 'Get current weather for a location',
  run: async (input) => {
    // Call weather API
    return `Weather in ${input.location}: 72°F, sunny`;
  },
});
```

**When to use:**
- Type-safe tool definitions
- Input validation
- Clear tool contracts

### Pattern 8: Tool Runner for Automatic Execution

```typescript
const finalMessage = await anthropic.beta.messages.toolRunner({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1000,
  messages: [
    { role: 'user', content: 'What\'s the weather in San Francisco?' }
  ],
  tools: [weatherTool],
});

console.log(finalMessage.content);
```

**When to use:**
- Automated tool execution
- AI agents with function calling
- Complex multi-step workflows

### Pattern 9: Streaming Tool Execution

```typescript
const runner = anthropic.beta.messages.toolRunner({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1000,
  messages: [{ role: 'user', content: 'Check weather and calculate travel time' }],
  tools: [weatherTool, travelTimeTool],
  stream: true,
});

for await (const messageStream of runner) {
  for await (const event of messageStream) {
    console.log('Event:', event);
  }
  console.log('Message:', await messageStream.finalMessage());
}
```

**When to use:**
- Real-time tool execution feedback
- Multi-tool workflows
- Interactive AI agents

## Error Handling Patterns

### Pattern 10: Comprehensive Error Handling

```typescript
async function createMessage(prompt: string) {
  try {
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }],
    });

    return message;
  } catch (error) {
    if (error instanceof Anthropic.APIError) {
      console.error('API Error:', {
        status: error.status,
        name: error.name,
        message: error.message,
        headers: error.headers,
      });

      // Handle specific errors
      if (error.status === 429) {
        // Rate limit - implement backoff
        console.log('Rate limited, waiting...');
        await new Promise(resolve => setTimeout(resolve, 60000));
        return createMessage(prompt); // Retry
      } else if (error.status === 401) {
        throw new Error('Invalid API key');
      } else if (error.status === 400) {
        throw new Error(`Bad request: ${error.message}`);
      }
    }

    throw error;
  }
}
```

**When to use:**
- Production applications
- Robust error recovery
- User-facing applications

### Pattern 11: Exponential Backoff Retry

```typescript
async function createWithRetry(
  params: Anthropic.MessageCreateParams,
  maxRetries = 3,
  baseDelay = 1000
): Promise<Anthropic.Message> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await anthropic.messages.create(params);
    } catch (error) {
      if (error instanceof Anthropic.APIError && error.status === 429) {
        // Rate limit - exponential backoff
        const delay = baseDelay * Math.pow(2, attempt);
        console.log(`Retry attempt ${attempt + 1} after ${delay}ms`);
        await new Promise(resolve => setTimeout(resolve, delay));
      } else {
        throw error;
      }
    }
  }

  throw new Error('Max retries exceeded');
}
```

**When to use:**
- High-volume applications
- Rate limit handling
- Network reliability

## Token Optimization Patterns

### Pattern 12: Token Counting

```typescript
import { encode } from 'gpt-tokenizer';

function estimateTokens(text: string): number {
  // Approximate token count (Claude uses similar tokenization to GPT)
  return encode(text).length;
}

function optimizePrompt(userMessage: string, maxTokens: number = 1024): string {
  const tokens = estimateTokens(userMessage);

  if (tokens > maxTokens) {
    // Truncate or summarize
    return userMessage.slice(0, maxTokens * 4); // Rough char estimate
  }

  return userMessage;
}
```

**When to use:**
- Cost optimization
- Token budget management
- Large input handling

### Pattern 13: Context Window Management

```typescript
interface ConversationMessage {
  role: 'user' | 'assistant';
  content: string;
  tokens?: number;
}

class ConversationManager {
  private messages: ConversationMessage[] = [];
  private maxContextTokens = 100000;

  addMessage(role: 'user' | 'assistant', content: string) {
    const tokens = estimateTokens(content);
    this.messages.push({ role, content, tokens });
    this.pruneIfNeeded();
  }

  private pruneIfNeeded() {
    const totalTokens = this.messages.reduce((sum, msg) => sum + (msg.tokens || 0), 0);

    if (totalTokens > this.maxContextTokens) {
      // Remove oldest messages (keep system prompt if present)
      this.messages = this.messages.slice(-10); // Keep last 10 messages
    }
  }

  getMessages() {
    return this.messages.map(({ role, content }) => ({ role, content }));
  }
}
```

**When to use:**
- Long conversations
- Context management
- Cost control

## Message Batching Patterns

### Pattern 14: Batch Processing

```typescript
const batchResult = await anthropic.messages.batches.create({
  requests: [
    {
      custom_id: 'request-1',
      params: {
        model: 'claude-sonnet-4-5-20250929',
        max_tokens: 1024,
        messages: [{ role: 'user', content: 'Summarize this article...' }],
      },
    },
    {
      custom_id: 'request-2',
      params: {
        model: 'claude-sonnet-4-5-20250929',
        max_tokens: 1024,
        messages: [{ role: 'user', content: 'Translate this text...' }],
      },
    },
  ],
});

// Poll for results
const batch = await anthropic.messages.batches.retrieve(batchResult.id);
```

**When to use:**
- Bulk processing
- Offline workflows
- Cost optimization (lower batch pricing)

## Production Patterns

### Pattern 15: Request Timeout Configuration

```typescript
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  timeout: 60000, // 60 seconds
  maxRetries: 3,
});
```

**When to use:**
- Production deployments
- Network reliability
- Resource management

### Pattern 16: Custom Headers and Metadata

```typescript
const message = await anthropic.messages.create(
  {
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{ role: 'user', content: 'Hello' }],
  },
  {
    headers: {
      'anthropic-beta': 'max-tokens-3-5-sonnet-2024-07-15',
    },
  }
);
```

**When to use:**
- Beta features
- Custom tracking
- A/B testing

## Best Practices

### API Key Management

1. **Never hardcode API keys**
   ```typescript
   // ❌ Bad
   const anthropic = new Anthropic({ apiKey: 'sk-ant-...' });

   // ✅ Good
   const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
   ```

2. **Use environment variables**
   ```bash
   # .env file
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   ```

### Model Selection

1. **Choose appropriate model for task:**
   - **Opus**: Most capable, complex reasoning
   - **Sonnet**: Balanced performance/speed
   - **Haiku**: Fastest, simple tasks

2. **Use latest model versions:**
   ```typescript
   model: 'claude-sonnet-4-5-20250929' // Latest
   ```

### Streaming Considerations

1. **Always use streaming for:**
   - User-facing applications
   - Long-form content (>500 tokens)
   - Real-time interactions

2. **Avoid streaming for:**
   - Backend batch processing
   - Deterministic outputs needed upfront
   - Simple API integrations

### Error Handling

1. **Always catch API errors**
2. **Implement retry logic for transient failures**
3. **Log errors for debugging**
4. **Provide user-friendly error messages**

### Token Management

1. **Estimate tokens before API calls**
2. **Set appropriate max_tokens**
3. **Monitor token usage**
4. **Implement context pruning for long conversations**

## Troubleshooting

### Issue: Rate Limit Errors (429)

**Solution:**
- Implement exponential backoff
- Use message batching for bulk operations
- Upgrade to higher rate limit tier

### Issue: Timeout Errors

**Solution:**
- Use streaming for long responses
- Increase timeout configuration
- Reduce max_tokens

### Issue: Invalid API Key (401)

**Solution:**
- Verify environment variable is set
- Check API key format (starts with `sk-ant-`)
- Ensure key hasn't been rotated

### Issue: Context Length Exceeded

**Solution:**
- Implement conversation pruning
- Summarize older messages
- Use appropriate context window limits

## Resources

- [Anthropic API Documentation](https://docs.anthropic.com)
- [TypeScript SDK GitHub](https://github.com/anthropics/anthropic-sdk-typescript)
- [Claude API Pricing](https://anthropic.com/pricing)
- [Model Comparison](https://docs.anthropic.com/claude/docs/models-overview)

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Compatibility**: @anthropic-ai/sdk 0.30.0+
**Research Source**: Context7 - Anthropic TypeScript SDK (106 code snippets, Trust Score 8.8)
