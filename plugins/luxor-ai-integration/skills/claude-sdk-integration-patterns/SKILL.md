---
name: "ai-sdk-integration-patterns"
description: "TypeScript SDK integration patterns for the Anthropic Messages API covering streaming responses, tool use with Zod schemas, error handling with retry logic, token optimization, and message batching. Use when building AI-powered applications with the Anthropic SDK, implementing streaming chat UIs, adding function calling, or optimizing API costs."
---

# Anthropic SDK Integration Patterns

Production-ready TypeScript patterns for the Anthropic Messages API: streaming, tool use, error handling, batching, and token optimization.

## Setup

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  timeout: 60000,
  maxRetries: 3,
});
```

## Messages API

```typescript
// Basic message
const message = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello!' }],
});

// With system prompt and multi-turn conversation
const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  system: 'You are a helpful Python programming assistant.',
  messages: [
    { role: 'user', content: 'What is TypeScript?' },
    { role: 'assistant', content: 'TypeScript is a typed superset of JavaScript...' },
    { role: 'user', content: 'Give me an example' },
  ],
});
```

## Streaming

```typescript
// Event-based streaming
const stream = anthropic.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
})
  .on('text', (text) => process.stdout.write(text))
  .on('error', (error) => console.error('Stream error:', error));

const finalMessage = await stream.finalMessage();

// Streaming with abort control
const stream = anthropic.messages.stream({ model: 'claude-sonnet-4-5-20250929', max_tokens: 1024, messages });
setTimeout(() => stream.abort(), 5000);
try {
  await stream.done();
} catch (error) {
  if (error instanceof Anthropic.APIUserAbortError) console.log('Stream aborted');
}
```

## Tool Use with Zod

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
  run: async (input) => `Weather in ${input.location}: 72°F, sunny`,
});

// Automatic tool execution with toolRunner
const finalMessage = await anthropic.beta.messages.toolRunner({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1000,
  messages: [{ role: 'user', content: "What's the weather in San Francisco?" }],
  tools: [weatherTool],
});
```

## Error Handling with Retry

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
      if (error instanceof Anthropic.APIError) {
        if (error.status === 429) {
          const delay = baseDelay * Math.pow(2, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
        if (error.status === 401) throw new Error('Invalid API key');
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}
```

## Message Batching

```typescript
const batchResult = await anthropic.messages.batches.create({
  requests: [
    { custom_id: 'req-1', params: { model: 'claude-sonnet-4-5-20250929', max_tokens: 1024, messages: [{ role: 'user', content: 'Summarize...' }] } },
    { custom_id: 'req-2', params: { model: 'claude-sonnet-4-5-20250929', max_tokens: 1024, messages: [{ role: 'user', content: 'Translate...' }] } },
  ],
});

// Poll for results
const batch = await anthropic.messages.batches.retrieve(batchResult.id);
```

## Context Window Management

```typescript
class ConversationManager {
  private messages: Array<{ role: 'user' | 'assistant'; content: string; tokens: number }> = [];
  private maxTokens = 100000;

  addMessage(role: 'user' | 'assistant', content: string) {
    this.messages.push({ role, content, tokens: Math.ceil(content.length / 4) });
    while (this.messages.reduce((sum, m) => sum + m.tokens, 0) > this.maxTokens) {
      this.messages.shift();
    }
  }

  getMessages() {
    return this.messages.map(({ role, content }) => ({ role, content }));
  }
}
```

## Best Practices

1. **API keys**: Always use environment variables, never hardcode
2. **Model selection**: Opus for complex reasoning, Sonnet for balanced tasks, Haiku for speed
3. **Streaming**: Use for user-facing applications and long-form content; skip for batch processing
4. **Token management**: Set appropriate `max_tokens`, implement context pruning for long conversations
5. **Error handling**: Always catch `Anthropic.APIError`, implement retry for 429 (rate limit) errors
