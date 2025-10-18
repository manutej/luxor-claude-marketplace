# Context7 Documentation Snippets Used

This document lists all Context7 documentation snippets integrated into the asyncio-concurrency-patterns skill.

## Library Information
- **Library ID**: /aio-libs/aiohttp
- **Topic**: asyncio concurrency event loops coroutines tasks futures async patterns
- **Tokens**: 8000

## Snippets Integrated

### 1. WebSocket with Parallel Event Sources
**Source**: aiohttp FAQ
**Usage**: Example 5 in EXAMPLES.md - WebSocket Server with Multiple Event Sources

Demonstrates handling multiple event sources concurrently with WebSocket connections using `asyncio.create_task()` for background event handling.

```python
async def handler(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    task = asyncio.create_task(
        read_subscription(ws, request.app[redis_key]))
    try:
        async for msg in ws:
            # handle incoming messages
            ...
    finally:
        task.cancel()
```

### 2. Danger of Creating ClientSession Outside Event Loop
**Source**: aiohttp FAQ
**Usage**: SKILL.md - Common Pitfalls section

Critical pattern showing why creating ClientSession at module level causes issues.

**Pattern covered**: Creating session inside async functions to avoid event loop binding issues.

### 3. Correctly Creating ClientSession
**Source**: aiohttp FAQ
**Usage**: Multiple examples throughout SKILL.md and EXAMPLES.md

Standard pattern for proper ClientSession usage:

```python
async def main():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://python.org') as resp:
            print(await resp.text())

asyncio.run(main())
```

### 4. Run Task Concurrently with Handler
**Source**: aiohttp Web Advanced
**Usage**: SKILL.md - Task Management section

Pattern for running background tasks during request handling:

```python
async def handler(request):
    t = asyncio.create_task(get_some_data())
    # Do other work while data is being fetched
    data = await t
    return web.Response(text=data)
```

### 5. Event Loop Creation for Tests
**Source**: aiohttp Testing
**Usage**: EXAMPLES.md - Testing section

Patterns for managing event loops in tests:

```python
with loop_context() as loop:
    # Use the loop
    pass

loop = setup_test_loop()
try:
    # Use loop
finally:
    teardown_test_loop(loop)
```

### 6. Iterating Over WebSocket Messages
**Source**: aiohttp Web Reference
**Usage**: EXAMPLES.md - WebSocket examples

Standard pattern for WebSocket message iteration:

```python
ws = web.WebSocketResponse()
await ws.prepare(request)

async for msg in ws:
    print(msg.data)
```

### 7. Background Tasks with Application Lifecycle
**Source**: aiohttp Web Advanced
**Usage**: SKILL.md - Production Patterns, EXAMPLES.md Example 11

Managing background tasks with cleanup context:

```python
async def background_tasks(app):
    app[redis_listener] = asyncio.create_task(listen_to_redis(app))
    
    yield
    
    app[redis_listener].cancel()
    with contextlib.suppress(asyncio.CancelledError):
        await app[redis_listener]
```

### 8. Graceful Shutdown with Zero-Sleep
**Source**: aiohttp Client Advanced
**Usage**: SKILL.md - Performance Optimization

Proper cleanup pattern for HTTP connections:

```python
async def read_website():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://example.org/') as resp:
            await resp.read()
    # Zero-sleep to allow underlying connections to close
    await asyncio.sleep(0)
```

### 9. Request Handler Definition
**Source**: aiohttp Web Quickstart
**Usage**: SKILL.md - Core Concepts

Basic async handler pattern:

```python
async def handler(request):
    return web.Response()
```

### 10. Fetch Content Pattern
**Source**: aiohttp README
**Usage**: SKILL.md and README.md - Quick Start examples

Standard pattern for fetching web content:

```python
async def main():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://python.org') as response:
            print("Status:", response.status)
            html = await response.text()

asyncio.run(main())
```

### 11. WebSocket Receive Methods
**Source**: aiohttp Web Reference
**Usage**: SKILL.md and EXAMPLES.md - WebSocket patterns

Methods for receiving different message types:
- `receive_str()` - TEXT messages
- `receive_bytes()` - BINARY messages  
- `receive_json()` - JSON messages

### 12. Test Utilities
**Source**: aiohttp Testing
**Usage**: EXAMPLES.md - Testing section

Testing helper functions:
- `unused_port()` - Get unused port
- `loop_context()` - Event loop context manager
- `setup_test_loop()` - Create test loop
- `teardown_test_loop()` - Cleanup test loop

### 13. StreamResponse and Status Setting
**Source**: aiohttp Web Reference
**Usage**: SKILL.md - Async Context Managers

Pattern for configuring response headers and status:

```python
async def handler(request):
    resp = StreamResponse()
    resp.set_status(404, reason="Not Found")
    await resp.prepare(request)
    return resp
```

### 14. ClientSession Usage as Async Context Manager
**Source**: aiohttp Client Reference
**Usage**: Throughout all examples

Standard async context manager pattern:

```python
resp = await client_session.get(url)
async with resp:
    assert resp.status == 200
```

### 15. WebSocket Close Handling
**Source**: aiohttp CHANGES
**Usage**: EXAMPLES.md - WebSocket examples

Proper handling of WebSocket connection closure:

```python
async for msg in ws:
    if msg.type == web.WSMsgType.CLOSED:
        break
```

### 16. ContextVars Example
**Source**: aiohttp Web Advanced
**Usage**: SKILL.md - Advanced patterns

Context-local variables with asyncio:

```python
from contextvars import ContextVar

VAR = ContextVar('VAR', default='default')

async def handler(request):
    var = VAR.get()
    VAR.set('handler')
    # Modifications isolated to this request
```

### 17. Retry Middleware Pattern
**Source**: aiohttp Client Middleware Cookbook
**Usage**: EXAMPLES.md - Retry Logic example

Retry pattern for handling connection errors:

```python
async def retry_middleware(client, service, **kwargs):
    attempts = kwargs.pop('attempts', 3)
    for attempt in range(attempts):
        try:
            return await client.request(service, **kwargs)
        except aiohttp.ClientConnectionError as e:
            if attempt + 1 == attempts:
                raise
            await asyncio.sleep(0.1 * (attempt + 1))
```

### 18. Custom Async Access Logger
**Source**: aiohttp Logging
**Usage**: SKILL.md - Production Patterns

Creating custom async logger:

```python
from aiohttp.abc import AbstractAsyncAccessLogger

class AccessLogger(AbstractAsyncAccessLogger):
    async def log(self, request, response, time):
        logging_service = request.app['logging_service']
        await logging_service.log(f'{request.remote} '
                                f'"{request.method} {request.path} '
                                f'done in {time}s: {response.status}')
```

### 19. Background Task Spawning
**Source**: aiohttp Web Advanced
**Usage**: SKILL.md - Background Tasks

Using aiojobs for background tasks:

```python
from aiojobs.aiohttp import setup, spawn

async def handler(request):
    await spawn(request, write_data())
    return web.Response()

app = web.Application()
setup(app)
```

### 20. Gunicorn Worker Configuration
**Source**: aiohttp Web Advanced
**Usage**: SKILL.md - Production deployment

Running aiohttp with Gunicorn:

```shell
gunicorn my_app_module:my_web_app --bind localhost:8080 \
    --worker-class aiohttp.GunicornWebWorker
```

## Integration Summary

### Coverage Areas
1. **Event Loop Management**: Loop creation, policies, and lifecycle
2. **HTTP Client Patterns**: Session management, request patterns, cleanup
3. **WebSocket Handling**: Message iteration, parallel events, cleanup
4. **Background Tasks**: Lifecycle management, cancellation, cleanup
5. **Testing Patterns**: Test loop setup, utilities, fixtures
6. **Production Patterns**: Graceful shutdown, retry logic, logging
7. **Performance**: Zero-sleep cleanup, connection pooling
8. **Error Handling**: Exception handling, timeouts, retries

### Pattern Distribution
- **Core Patterns**: 8 snippets (Event loops, sessions, handlers)
- **WebSocket Patterns**: 4 snippets (Message handling, connections)
- **Background Tasks**: 3 snippets (Lifecycle, cleanup, spawning)
- **Testing**: 2 snippets (Loop management, utilities)
- **Production**: 3 snippets (Logging, deployment, retry)

### Code Examples Enhanced
- 20+ examples use Context7 patterns
- All production patterns validated against aiohttp docs
- Best practices aligned with official recommendations
- Common pitfalls based on official FAQ

## References
- aiohttp Documentation: https://docs.aiohttp.org/
- aiohttp GitHub: https://github.com/aio-libs/aiohttp
- Context7 Library: /aio-libs/aiohttp
