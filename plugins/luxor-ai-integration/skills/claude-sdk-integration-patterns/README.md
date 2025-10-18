# Claude SDK Integration Patterns

Production-ready integration patterns for the Anthropic Claude TypeScript SDK.

## Overview

This skill provides comprehensive guidance for integrating Claude API into Node.js/TypeScript applications with streaming, tool use, error handling, and production best practices.

## Installation

```bash
npm install @anthropic-ai/sdk
```

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});
```

## Quick Start

```typescript
// Basic message
const message = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello!' }],
});

// Streaming
const stream = anthropic.messages.stream({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Write a story' }],
}).on('text', (text) => console.log(text));

await stream.finalMessage();
```

## Key Features

- ✅ Messages API patterns
- ✅ Streaming responses
- ✅ Tool use (function calling)
- ✅ Error handling with retry logic
- ✅ Token optimization
- ✅ Message batching
- ✅ Production deployment patterns

## When to Use

- Building chatbots or conversational UIs
- Integrating AI features into applications
- Implementing AI agents with tool use
- Processing bulk content with batching
- Optimizing API costs and performance

## Documentation

- **SKILL.md**: Complete integration patterns and examples
- **Context7 Research**: 106 code snippets from official SDK

---

**Enhances:** claude-sdk-expert, mcp-integration-wizard
**Workflows:** claude-sdk-integration
