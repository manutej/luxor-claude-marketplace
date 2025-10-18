# Asyncio Concurrency Patterns

Master Python's asyncio library and concurrent programming for building high-performance asynchronous applications.

## What is Asyncio?

Asyncio is Python's built-in framework for writing concurrent code using the async/await syntax. It enables you to write programs that handle thousands of I/O operations simultaneously without using threads or multiple processes.

**Key Benefits:**

- **High Concurrency**: Handle thousands of concurrent connections with minimal overhead
- **Efficient I/O**: Non-blocking I/O operations free up the CPU for other tasks
- **Simple Syntax**: Clean async/await syntax makes asynchronous code readable
- **Rich Ecosystem**: Libraries like aiohttp, aiofiles, asyncpg for async operations
- **Single-threaded**: Avoid complexity of thread synchronization and race conditions

## Quick Start

### Basic Async/Await

```python
import asyncio

async def say_hello():
    print('Hello')
    await asyncio.sleep(1)
    print('World')

# Run the coroutine
asyncio.run(say_hello())
```

### Concurrent Execution

```python
import asyncio

async def task(name, duration):
    print(f'{name} starting')
    await asyncio.sleep(duration)
    print(f'{name} finished')
    return f'{name} result'

async def main():
    # Run three tasks concurrently
    results = await asyncio.gather(
        task('Task 1', 2),
        task('Task 2', 1),
        task('Task 3', 3)
    )
    print(f'All results: {results}')

asyncio.run(main())
# Task 1, 2, 3 all run concurrently - total time ~3 seconds
```

### HTTP Requests with aiohttp

```python
import asyncio
import aiohttp

async def fetch(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

async def main():
    html = await fetch('http://python.org')
    print(f'Downloaded {len(html)} bytes')

asyncio.run(main())
```

## Core Concepts

### Event Loop

The event loop is the heart of asyncio - it schedules and executes asynchronous tasks:

```python
import asyncio

# Modern way (Python 3.7+)
asyncio.run(main())

# Manual loop management (older code)
loop = asyncio.get_event_loop()
loop.run_until_complete(main())
loop.close()
```

### Coroutines

Coroutines are functions defined with `async def` that can be paused and resumed:

```python
async def my_coroutine():
    # This is a coroutine
    await asyncio.sleep(1)
    return 'done'

# Calling a coroutine returns a coroutine object
coro = my_coroutine()

# You must await it or schedule it
result = await coro  # In async context
# or
result = asyncio.run(coro)  # From synchronous code
```

### Tasks

Tasks wrap coroutines and schedule them to run on the event loop:

```python
async def background_work():
    while True:
        print('Working...')
        await asyncio.sleep(1)

async def main():
    # Create task - starts immediately
    task = asyncio.create_task(background_work())

    # Do other work
    await asyncio.sleep(5)

    # Cancel background task
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        print('Task cancelled')
```

## Common Patterns

### Pattern 1: Parallel Requests

Fetch multiple URLs concurrently:

```python
import asyncio
import aiohttp

async def fetch_all(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [session.get(url) for url in urls]
        responses = await asyncio.gather(*tasks)

        contents = []
        for resp in responses:
            content = await resp.text()
            contents.append(content)
            await resp.release()

        return contents

urls = ['http://example.com', 'http://python.org', 'http://github.com']
results = asyncio.run(fetch_all(urls))
```

### Pattern 2: Rate Limiting

Control concurrency with semaphores:

```python
import asyncio
import aiohttp

async def fetch_with_limit(session, url, semaphore):
    async with semaphore:  # Only N requests at a time
        async with session.get(url) as resp:
            return await resp.text()

async def main():
    semaphore = asyncio.Semaphore(5)  # Max 5 concurrent requests

    urls = [f'http://api.example.com/item/{i}' for i in range(100)]

    async with aiohttp.ClientSession() as session:
        tasks = [
            fetch_with_limit(session, url, semaphore)
            for url in urls
        ]
        results = await asyncio.gather(*tasks)

    return results
```

### Pattern 3: Producer/Consumer

Coordinate work with queues:

```python
import asyncio

async def producer(queue, n):
    for i in range(n):
        await asyncio.sleep(0.1)
        await queue.put(f'item-{i}')
        print(f'Produced: item-{i}')
    await queue.put(None)  # Signal completion

async def consumer(queue, name):
    while True:
        item = await queue.get()
        if item is None:
            await queue.put(None)  # Propagate to other consumers
            break
        print(f'{name} consumed: {item}')
        await asyncio.sleep(0.2)

async def main():
    queue = asyncio.Queue()
    await asyncio.gather(
        producer(queue, 10),
        consumer(queue, 'Consumer-1'),
        consumer(queue, 'Consumer-2')
    )

asyncio.run(main())
```

### Pattern 4: Timeout Handling

Set timeouts for operations:

```python
import asyncio

async def slow_operation():
    await asyncio.sleep(10)
    return 'done'

async def main():
    try:
        result = await asyncio.wait_for(slow_operation(), timeout=5.0)
    except asyncio.TimeoutError:
        print('Operation timed out')
        result = None

    return result

asyncio.run(main())
```

### Pattern 5: Background Tasks

Run tasks in the background while handling requests:

```python
import asyncio

async def background_task():
    while True:
        print('Background work...')
        await asyncio.sleep(5)

async def main():
    # Start background task
    task = asyncio.create_task(background_task())

    # Main work
    await asyncio.sleep(20)

    # Cleanup
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        pass

asyncio.run(main())
```

## When to Use Asyncio

**Good Use Cases:**

- **Web Servers & APIs**: Handle many concurrent connections (aiohttp, FastAPI)
- **HTTP Clients**: Make many concurrent requests (web scraping, API clients)
- **WebSockets**: Real-time bidirectional communication
- **Database Operations**: Async database drivers (asyncpg, motor)
- **File I/O**: Reading/writing many files concurrently (aiofiles)
- **Chat Applications**: Handle multiple concurrent connections
- **Background Jobs**: Process tasks from queues
- **Real-time Data**: Streaming data, live updates
- **Microservices**: Service-to-service communication

**Not Ideal For:**

- **CPU-Intensive Work**: Use multiprocessing instead
- **Blocking Libraries**: Must use thread executors
- **Simple Scripts**: Overhead not worth it for simple tasks
- **Legacy Code**: If you can't use async libraries

## Performance Tips

### 1. Reuse Sessions

```python
# BAD - Creates new session per request
async def bad():
    for url in urls:
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as resp:
                data = await resp.text()

# GOOD - Reuse session
async def good():
    async with aiohttp.ClientSession() as session:
        for url in urls:
            async with session.get(url) as resp:
                data = await resp.text()
```

### 2. Use Gather for Concurrency

```python
# BAD - Sequential execution
async def bad():
    results = []
    for url in urls:
        result = await fetch(url)  # Waits for each
        results.append(result)

# GOOD - Concurrent execution
async def good():
    tasks = [fetch(url) for url in urls]
    results = await asyncio.gather(*tasks)  # All at once
```

### 3. Limit Concurrency

```python
# Control resource usage with semaphores
semaphore = asyncio.Semaphore(10)

async def limited_fetch(url):
    async with semaphore:
        return await fetch(url)
```

### 4. Proper Cleanup

```python
# Always clean up resources
async def main():
    async with aiohttp.ClientSession() as session:
        # Use session
        pass
    # Session closed automatically

    # Allow connections to close
    await asyncio.sleep(0)
```

## Common Pitfalls

### 1. Forgetting await

```python
# WRONG - Returns coroutine, doesn't execute
result = async_function()

# RIGHT - Executes and gets result
result = await async_function()
```

### 2. Blocking the Event Loop

```python
import time

# WRONG - Blocks entire event loop
async def bad():
    time.sleep(5)  # Everything stops!

# RIGHT - Yields control
async def good():
    await asyncio.sleep(5)  # Other tasks run
```

### 3. Creating Sessions Outside Event Loop

```python
# WRONG - Session created before loop exists
session = aiohttp.ClientSession()

async def fetch(url):
    async with session.get(url) as resp:
        return await resp.text()

# RIGHT - Create inside async function
async def fetch(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as resp:
            return await resp.text()
```

### 4. Not Handling Cancellation

```python
# WRONG - Doesn't cleanup on cancel
async def bad_task():
    while True:
        await asyncio.sleep(1)
        process()  # Resources may leak

# RIGHT - Handles cancellation
async def good_task():
    try:
        while True:
            await asyncio.sleep(1)
            process()
    except asyncio.CancelledError:
        cleanup()  # Cleanup resources
        raise
```

## Testing Async Code

### Using pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_fetch():
    result = await fetch_data()
    assert result == 'expected'

@pytest.mark.asyncio
async def test_with_fixture(aiohttp_client):
    app = create_app()
    client = await aiohttp_client(app)

    resp = await client.get('/')
    assert resp.status == 200

    data = await resp.json()
    assert data['key'] == 'value'
```

### Manual Testing

```python
import asyncio

def test_async_function():
    async def test_impl():
        result = await my_async_function()
        assert result == 'expected'

    asyncio.run(test_impl())
```

## Debugging

### Enable Debug Mode

```python
# Shows warnings about unawaited coroutines
asyncio.run(main(), debug=True)

# Or manually
import asyncio
import logging

logging.basicConfig(level=logging.DEBUG)
loop = asyncio.get_event_loop()
loop.set_debug(True)
```

### What Debug Mode Catches

- Coroutines that were never awaited
- Callbacks that take too long (> 100ms)
- Tasks destroyed while still pending
- Exceptions in callbacks

## Real-World Example: API Client

```python
import asyncio
import aiohttp
from typing import List, Dict

class AsyncAPIClient:
    def __init__(self, base_url: str, max_concurrent: int = 10):
        self.base_url = base_url
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.session = None

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self

    async def __aexit__(self, *args):
        await self.session.close()
        await asyncio.sleep(0)

    async def get(self, endpoint: str) -> Dict:
        """Make GET request with rate limiting"""
        async with self.semaphore:
            url = f'{self.base_url}/{endpoint}'
            async with self.session.get(url) as resp:
                resp.raise_for_status()
                return await resp.json()

    async def get_many(self, endpoints: List[str]) -> List[Dict]:
        """Fetch multiple endpoints concurrently"""
        tasks = [self.get(endpoint) for endpoint in endpoints]
        return await asyncio.gather(*tasks, return_exceptions=True)

# Usage
async def main():
    async with AsyncAPIClient('https://api.example.com', max_concurrent=5) as client:
        # Fetch single endpoint
        user = await client.get('users/123')

        # Fetch multiple endpoints concurrently
        endpoints = [f'users/{i}' for i in range(1, 11)]
        users = await client.get_many(endpoints)

        for user in users:
            if isinstance(user, Exception):
                print(f'Error: {user}')
            else:
                print(f"User: {user.get('name')}")

asyncio.run(main())
```

## Libraries to Know

### Core Async Libraries

- **aiohttp**: Async HTTP client/server framework
- **aiofiles**: Async file operations
- **asyncpg**: Async PostgreSQL driver
- **motor**: Async MongoDB driver
- **aiomysql**: Async MySQL driver
- **aioredis**: Async Redis client

### Web Frameworks

- **FastAPI**: Modern async web framework
- **Sanic**: Async web server
- **Quart**: Async Flask equivalent
- **Starlette**: ASGI framework

### Testing

- **pytest-asyncio**: Pytest plugin for async tests
- **aioresponses**: Mock aiohttp requests
- **asynctest**: Async mocking utilities

## Next Steps

1. **Read the Full SKILL.md**: Comprehensive guide with all patterns
2. **Check EXAMPLES.md**: 18+ practical examples with full code
3. **Practice**: Build a small async project (web scraper, API client)
4. **Learn aiohttp**: Most common async library for HTTP
5. **Study Real Projects**: Look at FastAPI, Sanic source code

## Resources

- **Official asyncio Docs**: https://docs.python.org/3/library/asyncio.html
- **aiohttp Documentation**: https://docs.aiohttp.org/
- **Real Python Tutorial**: https://realpython.com/async-io-python/
- **PEP 492**: https://www.python.org/dev/peps/pep-0492/

## Quick Reference

```python
# Run async function
asyncio.run(main())

# Create task
task = asyncio.create_task(coro())

# Run concurrently
results = await asyncio.gather(coro1(), coro2(), coro3())

# Timeout
result = await asyncio.wait_for(coro(), timeout=5.0)

# Semaphore (limit concurrency)
sem = asyncio.Semaphore(10)
async with sem:
    await operation()

# Queue (producer/consumer)
queue = asyncio.Queue()
await queue.put(item)
item = await queue.get()

# Lock (mutual exclusion)
lock = asyncio.Lock()
async with lock:
    # critical section
    pass

# Event (signaling)
event = asyncio.Event()
await event.wait()
event.set()

# Sleep (non-blocking)
await asyncio.sleep(1)
```

---

**Get Started**: Read SKILL.md for comprehensive coverage and EXAMPLES.md for practical code examples.
