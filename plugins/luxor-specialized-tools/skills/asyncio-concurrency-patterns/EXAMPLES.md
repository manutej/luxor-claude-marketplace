# Asyncio Concurrency Patterns - Practical Examples

Comprehensive collection of real-world asyncio examples covering concurrency patterns, error handling, performance optimization, and production-ready code.

## Table of Contents

1. [HTTP Client Examples](#http-client-examples)
2. [WebSocket Examples](#websocket-examples)
3. [Database Examples](#database-examples)
4. [Queue & Task Processing](#queue--task-processing)
5. [Concurrency Control](#concurrency-control)
6. [Error Handling & Retry Logic](#error-handling--retry-logic)
7. [Background Tasks](#background-tasks)
8. [Testing Examples](#testing-examples)
9. [Performance Examples](#performance-examples)
10. [Production Patterns](#production-patterns)

---

## HTTP Client Examples

### Example 1: Basic Concurrent HTTP Requests

Fetch multiple URLs concurrently and compare performance with sequential approach.

```python
import asyncio
import aiohttp
import time

async def fetch_url(session, url):
    """Fetch a single URL and return status and content length"""
    async with session.get(url) as response:
        content = await response.text()
        return {
            'url': url,
            'status': response.status,
            'length': len(content),
            'content_type': response.headers.get('content-type', '')
        }

async def fetch_all_concurrent(urls):
    """Fetch all URLs concurrently"""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
    return results

async def fetch_all_sequential(urls):
    """Fetch all URLs sequentially (for comparison)"""
    results = []
    async with aiohttp.ClientSession() as session:
        for url in urls:
            result = await fetch_url(session, url)
            results.append(result)
    return results

async def main():
    urls = [
        'http://python.org',
        'http://docs.python.org',
        'http://pypi.org',
        'http://github.com/python',
        'http://www.python.org/dev/peps/'
    ]

    # Concurrent approach
    start = time.perf_counter()
    concurrent_results = await fetch_all_concurrent(urls)
    concurrent_time = time.perf_counter() - start

    print("=== Concurrent Results ===")
    for result in concurrent_results:
        print(f"{result['url']}: {result['status']} ({result['length']} bytes)")
    print(f"Concurrent time: {concurrent_time:.2f}s\n")

    # Sequential approach
    start = time.perf_counter()
    sequential_results = await fetch_all_sequential(urls)
    sequential_time = time.perf_counter() - start

    print("=== Sequential Results ===")
    for result in sequential_results:
        print(f"{result['url']}: {result['status']} ({result['length']} bytes)")
    print(f"Sequential time: {sequential_time:.2f}s")

    print(f"\nSpeedup: {sequential_time / concurrent_time:.2f}x faster")

if __name__ == '__main__':
    asyncio.run(main())
```

### Example 2: Rate-Limited API Client

Production-ready API client with rate limiting and error handling.

```python
import asyncio
import aiohttp
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class APIResponse:
    url: str
    status: int
    data: Any
    timestamp: datetime
    error: Optional[str] = None

class RateLimitedAPIClient:
    """
    API client with configurable rate limiting and retry logic
    """

    def __init__(
        self,
        base_url: str,
        max_concurrent: int = 10,
        requests_per_second: float = 5.0,
        timeout: int = 30
    ):
        self.base_url = base_url.rstrip('/')
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.rate_limiter = asyncio.Semaphore(int(requests_per_second))
        self.min_interval = 1.0 / requests_per_second
        self.timeout = aiohttp.ClientTimeout(total=timeout)
        self.session: Optional[aiohttp.ClientSession] = None
        self.request_count = 0
        self.error_count = 0

    async def __aenter__(self):
        self.session = aiohttp.ClientSession(timeout=self.timeout)
        return self

    async def __aexit__(self, *args):
        if self.session:
            await self.session.close()
            await asyncio.sleep(0)

    async def _rate_limit(self):
        """Enforce rate limiting"""
        async with self.rate_limiter:
            await asyncio.sleep(self.min_interval)

    async def get(self, endpoint: str, params: Optional[Dict] = None) -> APIResponse:
        """
        Make GET request with rate limiting and error handling
        """
        async with self.semaphore:
            await self._rate_limit()

            url = f'{self.base_url}/{endpoint.lstrip("/")}'
            timestamp = datetime.now()

            try:
                async with self.session.get(url, params=params) as resp:
                    self.request_count += 1

                    if resp.status == 200:
                        data = await resp.json()
                        return APIResponse(
                            url=str(resp.url),
                            status=resp.status,
                            data=data,
                            timestamp=timestamp
                        )
                    else:
                        self.error_count += 1
                        return APIResponse(
                            url=str(resp.url),
                            status=resp.status,
                            data=None,
                            timestamp=timestamp,
                            error=f'HTTP {resp.status}'
                        )

            except asyncio.TimeoutError:
                self.error_count += 1
                return APIResponse(
                    url=url,
                    status=0,
                    data=None,
                    timestamp=timestamp,
                    error='Timeout'
                )
            except Exception as e:
                self.error_count += 1
                return APIResponse(
                    url=url,
                    status=0,
                    data=None,
                    timestamp=timestamp,
                    error=str(e)
                )

    async def get_many(self, endpoints: List[str]) -> List[APIResponse]:
        """Fetch multiple endpoints concurrently"""
        tasks = [self.get(endpoint) for endpoint in endpoints]
        return await asyncio.gather(*tasks)

    def get_stats(self) -> Dict[str, int]:
        """Get client statistics"""
        return {
            'total_requests': self.request_count,
            'total_errors': self.error_count,
            'success_rate': (
                (self.request_count - self.error_count) / self.request_count * 100
                if self.request_count > 0 else 0
            )
        }

async def main():
    # Example: Fetch GitHub user data
    async with RateLimitedAPIClient(
        'https://api.github.com',
        max_concurrent=5,
        requests_per_second=2.0
    ) as client:

        # Fetch multiple users
        users = ['python', 'django', 'flask', 'requests', 'aiohttp']
        endpoints = [f'users/{user}' for user in users]

        print("Fetching user data...")
        results = await client.get_many(endpoints)

        print("\n=== Results ===")
        for result in results:
            if result.error:
                print(f"❌ {result.url}: {result.error}")
            else:
                user_data = result.data
                print(f"✓ {user_data.get('login', 'unknown')}: "
                      f"{user_data.get('public_repos', 0)} repos, "
                      f"{user_data.get('followers', 0)} followers")

        print(f"\n=== Stats ===")
        stats = client.get_stats()
        print(f"Total requests: {stats['total_requests']}")
        print(f"Errors: {stats['total_errors']}")
        print(f"Success rate: {stats['success_rate']:.1f}%")

if __name__ == '__main__':
    asyncio.run(main())
```

### Example 3: Streaming Large Downloads

Handle large file downloads with progress tracking.

```python
import asyncio
import aiohttp
from pathlib import Path
from typing import Optional

class DownloadProgress:
    def __init__(self, total_size: int):
        self.total_size = total_size
        self.downloaded = 0
        self.start_time = asyncio.get_event_loop().time()

    def update(self, chunk_size: int):
        self.downloaded += chunk_size
        elapsed = asyncio.get_event_loop().time() - self.start_time
        speed = self.downloaded / elapsed if elapsed > 0 else 0
        percent = (self.downloaded / self.total_size * 100) if self.total_size > 0 else 0

        print(f"\rProgress: {percent:.1f}% | "
              f"{self.downloaded / 1024 / 1024:.2f} MB / "
              f"{self.total_size / 1024 / 1024:.2f} MB | "
              f"Speed: {speed / 1024 / 1024:.2f} MB/s", end='')

async def download_file(
    url: str,
    destination: Path,
    chunk_size: int = 8192,
    show_progress: bool = True
) -> bool:
    """
    Download file with progress tracking

    Args:
        url: URL to download from
        destination: Path to save file
        chunk_size: Size of chunks to download
        show_progress: Whether to show progress

    Returns:
        True if successful, False otherwise
    """
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as resp:
                if resp.status != 200:
                    print(f"Error: HTTP {resp.status}")
                    return False

                total_size = int(resp.headers.get('content-length', 0))
                progress = DownloadProgress(total_size) if show_progress else None

                with open(destination, 'wb') as f:
                    async for chunk in resp.content.iter_chunked(chunk_size):
                        f.write(chunk)
                        if progress:
                            progress.update(len(chunk))

                if show_progress:
                    print()  # New line after progress

                return True

    except Exception as e:
        print(f"\nError downloading file: {e}")
        return False

async def download_multiple(downloads: dict):
    """
    Download multiple files concurrently

    Args:
        downloads: Dict mapping URLs to destination paths
    """
    tasks = [
        download_file(url, Path(dest), show_progress=False)
        for url, dest in downloads.items()
    ]

    results = await asyncio.gather(*tasks, return_exceptions=True)

    print("\n=== Download Summary ===")
    for (url, dest), result in zip(downloads.items(), results):
        if isinstance(result, Exception):
            print(f"❌ {url}: {result}")
        elif result:
            print(f"✓ {url} -> {dest}")
        else:
            print(f"❌ {url}: Failed")

async def main():
    # Example: Download a single file
    url = 'http://ipv4.download.thinkbroadband.com/10MB.zip'
    await download_file(url, Path('test_download.zip'))

    # Example: Download multiple files
    # downloads = {
    #     'http://example.com/file1.zip': 'file1.zip',
    #     'http://example.com/file2.zip': 'file2.zip',
    # }
    # await download_multiple(downloads)

if __name__ == '__main__':
    asyncio.run(main())
```

---

## WebSocket Examples

### Example 4: WebSocket Client with Reconnection

Robust WebSocket client with automatic reconnection and heartbeat.

```python
import asyncio
import aiohttp
from typing import Optional, Callable
from datetime import datetime

class WebSocketClient:
    """
    WebSocket client with automatic reconnection and heartbeat
    """

    def __init__(
        self,
        url: str,
        heartbeat_interval: float = 30.0,
        reconnect_interval: float = 5.0,
        max_reconnect_attempts: int = 5
    ):
        self.url = url
        self.heartbeat_interval = heartbeat_interval
        self.reconnect_interval = reconnect_interval
        self.max_reconnect_attempts = max_reconnect_attempts

        self.ws: Optional[aiohttp.ClientWebSocketResponse] = None
        self.session: Optional[aiohttp.ClientSession] = None
        self.should_run = False
        self.reconnect_count = 0

        self.on_message: Optional[Callable] = None
        self.on_connect: Optional[Callable] = None
        self.on_disconnect: Optional[Callable] = None

    async def connect(self):
        """Establish WebSocket connection"""
        self.session = aiohttp.ClientSession()
        self.ws = await self.session.ws_connect(self.url)
        self.reconnect_count = 0

        print(f"[{datetime.now()}] Connected to {self.url}")

        if self.on_connect:
            await self.on_connect()

    async def disconnect(self):
        """Close WebSocket connection"""
        if self.ws:
            await self.ws.close()

        if self.session:
            await self.session.close()

        print(f"[{datetime.now()}] Disconnected")

        if self.on_disconnect:
            await self.on_disconnect()

    async def send(self, message: str):
        """Send message to WebSocket"""
        if self.ws and not self.ws.closed:
            await self.ws.send_str(message)

    async def _heartbeat(self):
        """Send periodic heartbeat"""
        while self.should_run:
            try:
                await asyncio.sleep(self.heartbeat_interval)
                if self.ws and not self.ws.closed:
                    await self.ws.ping()
            except Exception as e:
                print(f"Heartbeat error: {e}")

    async def _receive_messages(self):
        """Receive and process messages"""
        try:
            async for msg in self.ws:
                if msg.type == aiohttp.WSMsgType.TEXT:
                    if self.on_message:
                        await self.on_message(msg.data)
                elif msg.type == aiohttp.WSMsgType.ERROR:
                    print(f"WebSocket error: {self.ws.exception()}")
                    break
        except Exception as e:
            print(f"Error receiving messages: {e}")

    async def run(self):
        """Run WebSocket client with reconnection"""
        self.should_run = True

        while self.should_run:
            try:
                await self.connect()

                # Start heartbeat and message receiver
                await asyncio.gather(
                    self._heartbeat(),
                    self._receive_messages()
                )

            except Exception as e:
                print(f"Connection error: {e}")

            finally:
                await self.disconnect()

            # Reconnection logic
            if self.should_run:
                self.reconnect_count += 1

                if self.reconnect_count >= self.max_reconnect_attempts:
                    print("Max reconnection attempts reached")
                    break

                print(f"Reconnecting in {self.reconnect_interval}s... "
                      f"(attempt {self.reconnect_count}/{self.max_reconnect_attempts})")
                await asyncio.sleep(self.reconnect_interval)

    async def stop(self):
        """Stop WebSocket client"""
        self.should_run = False
        await self.disconnect()

# Example usage
async def main():
    client = WebSocketClient('wss://echo.websocket.org')

    # Set up handlers
    async def on_message(message):
        print(f"Received: {message}")

    async def on_connect():
        print("Connected! Sending test message...")
        await client.send("Hello WebSocket!")

    client.on_message = on_message
    client.on_connect = on_connect

    # Run client (with automatic stop after 30 seconds for demo)
    client_task = asyncio.create_task(client.run())

    await asyncio.sleep(30)
    await client.stop()
    await client_task

if __name__ == '__main__':
    asyncio.run(main())
```

### Example 5: WebSocket Server with Multiple Event Sources

Handle WebSocket connections with parallel event sources (based on aiohttp documentation).

```python
import asyncio
from aiohttp import web
from collections import defaultdict
from typing import Set

class WebSocketServer:
    """
    WebSocket server handling multiple event sources
    """

    def __init__(self):
        self.app = web.Application()
        self.websockets: defaultdict[str, Set] = defaultdict(set)

        # Setup routes
        self.app.router.add_get('/ws/{channel}', self.websocket_handler)
        self.app.on_startup.append(self.on_startup)
        self.app.on_cleanup.append(self.on_cleanup)

    async def on_startup(self, app):
        """Initialize background tasks on startup"""
        # Start broadcast task
        app['broadcast_task'] = asyncio.create_task(self.broadcast_loop())
        print("Server started, broadcast task running")

    async def on_cleanup(self, app):
        """Cleanup on shutdown"""
        # Cancel broadcast task
        app['broadcast_task'].cancel()
        with asyncio.suppress(asyncio.CancelledError):
            await app['broadcast_task']

        # Close all websockets
        for channel, ws_set in self.websockets.items():
            for ws in ws_set:
                await ws.close()

        print("Server cleanup complete")

    async def broadcast_loop(self):
        """
        Background task that broadcasts messages to all connected clients
        Simulates reading from Redis, Kafka, etc.
        """
        counter = 0
        try:
            while True:
                await asyncio.sleep(2)
                counter += 1

                # Broadcast to all channels
                message = f"Broadcast message {counter}"
                await self.broadcast_to_channel('general', message)

        except asyncio.CancelledError:
            print("Broadcast task cancelled")
            raise

    async def broadcast_to_channel(self, channel: str, message: str):
        """Send message to all clients in a channel"""
        if channel not in self.websockets:
            return

        dead_sockets = set()

        for ws in self.websockets[channel]:
            try:
                if not ws.closed:
                    await ws.send_str(message)
                else:
                    dead_sockets.add(ws)
            except Exception as e:
                print(f"Error sending to websocket: {e}")
                dead_sockets.add(ws)

        # Remove dead sockets
        self.websockets[channel] -= dead_sockets

    async def websocket_handler(self, request):
        """
        Handle WebSocket connections with parallel event sources
        """
        channel = request.match_info['channel']
        ws = web.WebSocketResponse()
        await ws.prepare(request)

        # Register websocket
        self.websockets[channel].add(ws)
        print(f"Client connected to channel: {channel}")

        # Create background task for this connection (e.g., Redis subscription)
        task = asyncio.create_task(
            self.read_external_events(ws, channel)
        )

        try:
            # Handle incoming messages from client
            async for msg in ws:
                if msg.type == web.WSMsgType.TEXT:
                    # Echo back to sender
                    await ws.send_str(f"Echo: {msg.data}")

                    # Broadcast to all in channel
                    await self.broadcast_to_channel(
                        channel,
                        f"User message: {msg.data}"
                    )

                elif msg.type == web.WSMsgType.ERROR:
                    print(f'WebSocket error: {ws.exception()}')

        finally:
            # Cleanup
            task.cancel()
            with asyncio.suppress(asyncio.CancelledError):
                await task

            self.websockets[channel].discard(ws)
            print(f"Client disconnected from channel: {channel}")

        return ws

    async def read_external_events(self, ws, channel):
        """
        Simulate reading from external event source (Redis, Kafka, etc.)
        and sending to WebSocket
        """
        try:
            counter = 0
            while True:
                await asyncio.sleep(5)
                counter += 1

                # Simulate external event
                message = f"External event {counter} for {channel}"
                if not ws.closed:
                    await ws.send_str(message)

        except asyncio.CancelledError:
            print(f"External event reader cancelled for {channel}")
            raise

    def run(self, host='0.0.0.0', port=8080):
        """Run the server"""
        web.run_app(self.app, host=host, port=port)

# Example usage
if __name__ == '__main__':
    server = WebSocketServer()
    server.run()
```

---

## Database Examples

### Example 6: Connection Pool Management

Async database connection pool with proper resource management.

```python
import asyncio
from typing import Any, Optional
from contextlib import asynccontextmanager

class AsyncConnectionPool:
    """
    Async database connection pool
    """

    def __init__(self, size: int = 10, max_overflow: int = 5):
        self.size = size
        self.max_overflow = max_overflow
        self.pool = asyncio.Queue(maxsize=size + max_overflow)
        self.current_size = 0
        self.in_use = 0
        self._lock = asyncio.Lock()

    async def init(self):
        """Initialize connection pool"""
        for i in range(self.size):
            conn = await self._create_connection(i)
            await self.pool.put(conn)
            self.current_size += 1

        print(f"Connection pool initialized with {self.size} connections")

    async def _create_connection(self, conn_id: int):
        """Create a database connection (simulated)"""
        await asyncio.sleep(0.1)  # Simulate connection time
        return {
            'id': conn_id,
            'connected': True,
            'queries_executed': 0,
            'created_at': asyncio.get_event_loop().time()
        }

    async def acquire(self) -> dict:
        """Acquire connection from pool"""
        try:
            # Try to get existing connection
            conn = self.pool.get_nowait()
            self.in_use += 1
            return conn
        except asyncio.QueueEmpty:
            # Pool is empty, create overflow connection if allowed
            async with self._lock:
                if self.current_size < self.size + self.max_overflow:
                    conn = await self._create_connection(self.current_size)
                    self.current_size += 1
                    self.in_use += 1
                    return conn

            # Wait for connection to become available
            conn = await self.pool.get()
            self.in_use += 1
            return conn

    async def release(self, conn: dict):
        """Release connection back to pool"""
        if conn['connected']:
            await self.pool.put(conn)
            self.in_use -= 1

    @asynccontextmanager
    async def connection(self):
        """Context manager for acquiring/releasing connections"""
        conn = await self.acquire()
        try:
            yield conn
        finally:
            await self.release(conn)

    async def execute(self, query: str) -> Any:
        """Execute query using pooled connection"""
        async with self.connection() as conn:
            # Simulate query execution
            await asyncio.sleep(0.05)
            conn['queries_executed'] += 1
            return f"Query '{query}' executed on connection {conn['id']}"

    async def close(self):
        """Close all connections"""
        print("Closing connection pool...")

        while not self.pool.empty():
            try:
                conn = self.pool.get_nowait()
                conn['connected'] = False
            except asyncio.QueueEmpty:
                break

        self.current_size = 0
        print("All connections closed")

    def get_stats(self) -> dict:
        """Get pool statistics"""
        return {
            'total_connections': self.current_size,
            'available': self.pool.qsize(),
            'in_use': self.in_use,
            'max_size': self.size + self.max_overflow
        }

async def worker(pool: AsyncConnectionPool, worker_id: int, num_queries: int):
    """Worker that executes queries"""
    for i in range(num_queries):
        result = await pool.execute(f'SELECT * FROM table_{worker_id} WHERE id={i}')
        print(f'Worker {worker_id}: {result}')
        await asyncio.sleep(0.1)

async def main():
    # Create and initialize pool
    pool = AsyncConnectionPool(size=5, max_overflow=3)
    await pool.init()

    print("\n=== Starting Workers ===")
    # Run multiple workers concurrently
    await asyncio.gather(*[
        worker(pool, i, 5) for i in range(10)
    ])

    print("\n=== Pool Stats ===")
    stats = pool.get_stats()
    for key, value in stats.items():
        print(f"{key}: {value}")

    # Cleanup
    await pool.close()

if __name__ == '__main__':
    asyncio.run(main())
```

---

## Queue & Task Processing

### Example 7: Advanced Producer-Consumer Pattern

Multi-producer, multi-consumer with priority queue and monitoring.

```python
import asyncio
import random
from enum import IntEnum
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional

class Priority(IntEnum):
    LOW = 3
    NORMAL = 2
    HIGH = 1
    URGENT = 0

@dataclass(order=True)
class Task:
    priority: int
    task_id: int = field(compare=False)
    data: str = field(compare=False)
    created_at: datetime = field(default_factory=datetime.now, compare=False)
    processed_at: Optional[datetime] = field(default=None, compare=False)

class TaskProcessor:
    def __init__(
        self,
        num_producers: int = 3,
        num_consumers: int = 5,
        max_queue_size: int = 100
    ):
        self.queue = asyncio.PriorityQueue(maxsize=max_queue_size)
        self.num_producers = num_producers
        self.num_consumers = num_consumers

        self.produced_count = 0
        self.consumed_count = 0
        self.error_count = 0
        self.running = False

    async def producer(self, producer_id: int, num_tasks: int):
        """Produce tasks with random priorities"""
        for i in range(num_tasks):
            # Random delay
            await asyncio.sleep(random.uniform(0.05, 0.2))

            # Create task with random priority
            priority = random.choice(list(Priority))
            task = Task(
                priority=priority.value,
                task_id=self.produced_count,
                data=f'Producer-{producer_id}-Task-{i}'
            )

            await self.queue.put(task)
            self.produced_count += 1

            print(f"📥 Producer {producer_id} created {task.data} "
                  f"(Priority: {priority.name})")

        print(f"Producer {producer_id} finished")

    async def consumer(self, consumer_id: int):
        """Consume and process tasks"""
        while self.running:
            try:
                # Wait for task with timeout
                task = await asyncio.wait_for(
                    self.queue.get(),
                    timeout=1.0
                )

                # Process task
                task.processed_at = datetime.now()
                processing_time = random.uniform(0.1, 0.5)
                await asyncio.sleep(processing_time)

                # Simulate occasional errors
                if random.random() < 0.1:  # 10% error rate
                    raise Exception("Processing error")

                self.consumed_count += 1
                wait_time = (task.processed_at - task.created_at).total_seconds()

                print(f"✅ Consumer {consumer_id} processed {task.data} "
                      f"(waited {wait_time:.2f}s, processed in {processing_time:.2f}s)")

            except asyncio.TimeoutError:
                # No tasks available
                continue
            except Exception as e:
                self.error_count += 1
                print(f"❌ Consumer {consumer_id} error: {e}")

        print(f"Consumer {consumer_id} stopped")

    async def monitor(self):
        """Monitor queue and processing stats"""
        while self.running:
            await asyncio.sleep(2)

            stats = self.get_stats()
            print(f"\n📊 Stats: Produced={stats['produced']}, "
                  f"Consumed={stats['consumed']}, "
                  f"Errors={stats['errors']}, "
                  f"Queue={stats['queue_size']}\n")

    async def run(self, tasks_per_producer: int = 10):
        """Run the task processor"""
        self.running = True

        # Start monitor
        monitor_task = asyncio.create_task(self.monitor())

        # Start all producers
        producer_tasks = [
            asyncio.create_task(self.producer(i, tasks_per_producer))
            for i in range(self.num_producers)
        ]

        # Start all consumers
        consumer_tasks = [
            asyncio.create_task(self.consumer(i))
            for i in range(self.num_consumers)
        ]

        # Wait for all producers to finish
        await asyncio.gather(*producer_tasks)

        # Wait for queue to be empty
        await self.queue.join()

        # Stop consumers and monitor
        self.running = False
        await asyncio.sleep(1.5)  # Give consumers time to stop

        # Cancel any remaining tasks
        monitor_task.cancel()
        for task in consumer_tasks:
            task.cancel()

        print("\n=== Final Stats ===")
        stats = self.get_stats()
        for key, value in stats.items():
            print(f"{key}: {value}")

    def get_stats(self) -> dict:
        """Get processing statistics"""
        return {
            'produced': self.produced_count,
            'consumed': self.consumed_count,
            'errors': self.error_count,
            'queue_size': self.queue.qsize(),
            'success_rate': (
                (self.consumed_count / (self.consumed_count + self.error_count) * 100)
                if (self.consumed_count + self.error_count) > 0
                else 0
            )
        }

async def main():
    processor = TaskProcessor(
        num_producers=3,
        num_consumers=5,
        max_queue_size=50
    )

    await processor.run(tasks_per_producer=10)

if __name__ == '__main__':
    asyncio.run(main())
```

---

## Concurrency Control

### Example 8: Semaphore for Resource Limiting

Control access to limited resources with semaphores.

```python
import asyncio
import random
from datetime import datetime

class ResourcePool:
    """
    Manage limited resources with semaphore
    """

    def __init__(self, max_resources: int = 5):
        self.semaphore = asyncio.Semaphore(max_resources)
        self.max_resources = max_resources
        self.active_count = 0
        self.total_acquired = 0

    async def acquire_resource(self, user_id: int, duration: float):
        """
        Acquire resource, use it, then release

        Args:
            user_id: ID of the user acquiring resource
            duration: How long to hold the resource
        """
        print(f"[{datetime.now().strftime('%H:%M:%S')}] "
              f"User {user_id} waiting for resource... "
              f"(Active: {self.active_count}/{self.max_resources})")

        async with self.semaphore:
            self.active_count += 1
            self.total_acquired += 1

            print(f"[{datetime.now().strftime('%H:%M:%S')}] "
                  f"✓ User {user_id} acquired resource "
                  f"(Active: {self.active_count}/{self.max_resources})")

            try:
                # Use resource
                await asyncio.sleep(duration)
                result = f"User {user_id} completed work in {duration:.2f}s"

            finally:
                self.active_count -= 1
                print(f"[{datetime.now().strftime('%H:%M:%S')}] "
                      f"User {user_id} released resource "
                      f"(Active: {self.active_count}/{self.max_resources})")

            return result

async def main():
    # Create pool with 5 resources
    pool = ResourcePool(max_resources=5)

    # Simulate 20 users trying to access resources
    tasks = [
        pool.acquire_resource(
            user_id=i,
            duration=random.uniform(1.0, 3.0)
        )
        for i in range(20)
    ]

    results = await asyncio.gather(*tasks)

    print("\n=== Results ===")
    for result in results:
        print(result)

    print(f"\nTotal acquisitions: {pool.total_acquired}")

if __name__ == '__main__':
    asyncio.run(main())
```

### Example 9: Lock for Shared State

Protect shared state with async locks.

```python
import asyncio
from dataclasses import dataclass, field
from typing import List

@dataclass
class BankAccount:
    """Thread-safe bank account using async lock"""
    balance: float = 0.0
    transactions: List[dict] = field(default_factory=list)
    _lock: asyncio.Lock = field(default_factory=asyncio.Lock)

    async def deposit(self, amount: float, description: str = ""):
        """Deposit money (thread-safe)"""
        async with self._lock:
            # Critical section
            old_balance = self.balance
            await asyncio.sleep(0.01)  # Simulate processing time
            self.balance += amount

            self.transactions.append({
                'type': 'deposit',
                'amount': amount,
                'description': description,
                'old_balance': old_balance,
                'new_balance': self.balance
            })

            print(f"💰 Deposited ${amount:.2f}: ${old_balance:.2f} -> ${self.balance:.2f}")

    async def withdraw(self, amount: float, description: str = ""):
        """Withdraw money (thread-safe)"""
        async with self._lock:
            # Critical section
            if self.balance < amount:
                print(f"❌ Insufficient funds: ${self.balance:.2f} < ${amount:.2f}")
                return False

            old_balance = self.balance
            await asyncio.sleep(0.01)  # Simulate processing time
            self.balance -= amount

            self.transactions.append({
                'type': 'withdrawal',
                'amount': amount,
                'description': description,
                'old_balance': old_balance,
                'new_balance': self.balance
            })

            print(f"💸 Withdrew ${amount:.2f}: ${old_balance:.2f} -> ${self.balance:.2f}")
            return True

    async def get_balance(self) -> float:
        """Get current balance (thread-safe)"""
        async with self._lock:
            return self.balance

async def customer_transactions(account: BankAccount, customer_id: int):
    """Simulate customer making random transactions"""
    import random

    for i in range(5):
        await asyncio.sleep(random.uniform(0.05, 0.2))

        if random.choice([True, False]):
            amount = random.uniform(10, 100)
            await account.deposit(amount, f"Customer {customer_id} deposit {i}")
        else:
            amount = random.uniform(10, 50)
            await account.withdraw(amount, f"Customer {customer_id} withdrawal {i}")

async def main():
    # Create account with initial balance
    account = BankAccount(balance=1000.0)

    print(f"Initial balance: ${account.balance:.2f}\n")

    # Simulate multiple customers accessing account concurrently
    await asyncio.gather(*[
        customer_transactions(account, i)
        for i in range(10)
    ])

    final_balance = await account.get_balance()

    print(f"\n=== Summary ===")
    print(f"Final balance: ${final_balance:.2f}")
    print(f"Total transactions: {len(account.transactions)}")

    deposits = sum(t['amount'] for t in account.transactions if t['type'] == 'deposit')
    withdrawals = sum(t['amount'] for t in account.transactions if t['type'] == 'withdrawal')

    print(f"Total deposits: ${deposits:.2f}")
    print(f"Total withdrawals: ${withdrawals:.2f}")
    print(f"Expected balance: ${1000 + deposits - withdrawals:.2f}")

if __name__ == '__main__':
    asyncio.run(main())
```

---

## Error Handling & Retry Logic

### Example 10: Exponential Backoff Retry

Implement retry logic with exponential backoff.

```python
import asyncio
import random
from typing import TypeVar, Callable, Any
from dataclasses import dataclass

T = TypeVar('T')

@dataclass
class RetryStats:
    total_attempts: int = 0
    successful: int = 0
    failed: int = 0
    total_delay: float = 0.0

async def retry_with_exponential_backoff(
    coro_func: Callable[..., Any],
    *args,
    max_retries: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    exponential_base: float = 2.0,
    jitter: bool = True,
    **kwargs
) -> tuple[Any, RetryStats]:
    """
    Retry async function with exponential backoff

    Args:
        coro_func: Async function to retry
        max_retries: Maximum number of retry attempts
        base_delay: Initial delay between retries (seconds)
        max_delay: Maximum delay between retries (seconds)
        exponential_base: Base for exponential backoff
        jitter: Add random jitter to prevent thundering herd

    Returns:
        Tuple of (result, stats)
    """
    stats = RetryStats()

    for attempt in range(max_retries + 1):
        stats.total_attempts += 1

        try:
            result = await coro_func(*args, **kwargs)
            stats.successful += 1
            return result, stats

        except Exception as e:
            if attempt == max_retries:
                # Final attempt failed
                stats.failed += 1
                raise

            # Calculate delay with exponential backoff
            delay = min(base_delay * (exponential_base ** attempt), max_delay)

            # Add jitter
            if jitter:
                delay = delay * (0.5 + random.random() * 0.5)

            stats.total_delay += delay

            print(f"⚠️  Attempt {attempt + 1} failed: {e}")
            print(f"   Retrying in {delay:.2f}s...")

            await asyncio.sleep(delay)

# Example: Flaky API call
async def unstable_api_call(success_rate: float = 0.3) -> dict:
    """Simulate an unstable API that sometimes fails"""
    await asyncio.sleep(0.1)  # Simulate network delay

    if random.random() > success_rate:
        raise ConnectionError("API temporarily unavailable")

    return {"status": "success", "data": "Important data"}

async def main():
    print("=== Testing Retry with Exponential Backoff ===\n")

    # Test with different configurations
    configs = [
        {'max_retries': 3, 'base_delay': 1.0},
        {'max_retries': 5, 'base_delay': 0.5, 'exponential_base': 1.5},
        {'max_retries': 4, 'base_delay': 2.0, 'jitter': False},
    ]

    for i, config in enumerate(configs, 1):
        print(f"--- Configuration {i} ---")
        print(f"Config: {config}\n")

        try:
            result, stats = await retry_with_exponential_backoff(
                unstable_api_call,
                success_rate=0.4,
                **config
            )

            print(f"\n✓ Success!")
            print(f"Result: {result}")
            print(f"Stats: {stats}\n")

        except Exception as e:
            print(f"\n❌ Failed after all retries: {e}\n")

if __name__ == '__main__':
    asyncio.run(main())
```

---

## Background Tasks

### Example 11: Application with Background Tasks

Manage background tasks with application lifecycle (aiohttp pattern).

```python
import asyncio
from contextlib import suppress
from datetime import datetime

class Application:
    """
    Application with managed background tasks
    """

    def __init__(self):
        self.tasks = []
        self.should_exit = False
        self.data_processor_count = 0
        self.cleanup_count = 0

    async def data_processor(self):
        """Background task that processes data"""
        print("[DataProcessor] Started")

        try:
            while not self.should_exit:
                # Simulate data processing
                await asyncio.sleep(2)
                self.data_processor_count += 1
                print(f"[DataProcessor] Processed batch {self.data_processor_count}")

        except asyncio.CancelledError:
            print("[DataProcessor] Cancelled, cleaning up...")
            raise

    async def cleanup_task(self):
        """Background task that performs periodic cleanup"""
        print("[CleanupTask] Started")

        try:
            while not self.should_exit:
                await asyncio.sleep(5)
                self.cleanup_count += 1
                print(f"[CleanupTask] Cleanup {self.cleanup_count} completed")

        except asyncio.CancelledError:
            print("[CleanupTask] Cancelled")
            raise

    async def heartbeat(self):
        """Background task that sends heartbeat"""
        print("[Heartbeat] Started")

        try:
            while not self.should_exit:
                await asyncio.sleep(1)
                print(f"[Heartbeat] {datetime.now().strftime('%H:%M:%S')}")

        except asyncio.CancelledError:
            print("[Heartbeat] Cancelled")
            raise

    async def startup(self):
        """Start background tasks"""
        print("\n=== Application Startup ===")

        self.tasks = [
            asyncio.create_task(self.data_processor()),
            asyncio.create_task(self.cleanup_task()),
            asyncio.create_task(self.heartbeat())
        ]

        print(f"Started {len(self.tasks)} background tasks\n")

    async def shutdown(self):
        """Stop background tasks gracefully"""
        print("\n=== Application Shutdown ===")
        self.should_exit = True

        # Cancel all tasks
        for task in self.tasks:
            task.cancel()

        # Wait for all tasks to complete cancellation
        results = await asyncio.gather(*self.tasks, return_exceptions=True)

        # Report cancellation results
        for i, result in enumerate(results):
            if isinstance(result, asyncio.CancelledError):
                print(f"Task {i} cancelled successfully")
            elif isinstance(result, Exception):
                print(f"Task {i} raised exception: {result}")

        print("Shutdown complete\n")

    async def run(self, duration: int = 10):
        """Run application for specified duration"""
        await self.startup()

        # Run for specified duration
        await asyncio.sleep(duration)

        await self.shutdown()

        # Print stats
        print("=== Statistics ===")
        print(f"Data batches processed: {self.data_processor_count}")
        print(f"Cleanups performed: {self.cleanup_count}")

async def main():
    app = Application()
    await app.run(duration=12)

if __name__ == '__main__':
    asyncio.run(main())
```

---

## Testing Examples

### Example 12: Testing Async Code with pytest-asyncio

```python
import asyncio
import pytest
from typing import List

# Code to test
class AsyncCache:
    def __init__(self):
        self.cache = {}
        self.lock = asyncio.Lock()

    async def get(self, key: str):
        async with self.lock:
            await asyncio.sleep(0.01)  # Simulate I/O
            return self.cache.get(key)

    async def set(self, key: str, value: any):
        async with self.lock:
            await asyncio.sleep(0.01)  # Simulate I/O
            self.cache[key] = value

    async def delete(self, key: str):
        async with self.lock:
            await asyncio.sleep(0.01)  # Simulate I/O
            return self.cache.pop(key, None)

# Tests
@pytest.fixture
async def cache():
    """Fixture providing a cache instance"""
    return AsyncCache()

@pytest.mark.asyncio
async def test_cache_set_get(cache):
    """Test basic set/get operations"""
    await cache.set('key1', 'value1')
    result = await cache.get('key1')
    assert result == 'value1'

@pytest.mark.asyncio
async def test_cache_get_missing(cache):
    """Test getting non-existent key"""
    result = await cache.get('nonexistent')
    assert result is None

@pytest.mark.asyncio
async def test_cache_delete(cache):
    """Test delete operation"""
    await cache.set('key1', 'value1')
    deleted = await cache.delete('key1')
    assert deleted == 'value1'

    result = await cache.get('key1')
    assert result is None

@pytest.mark.asyncio
async def test_concurrent_access(cache):
    """Test concurrent cache access"""
    async def worker(cache, worker_id, iterations):
        for i in range(iterations):
            await cache.set(f'key_{worker_id}_{i}', f'value_{worker_id}_{i}')
            value = await cache.get(f'key_{worker_id}_{i}')
            assert value == f'value_{worker_id}_{i}'

    # Run 10 workers concurrently
    await asyncio.gather(*[
        worker(cache, i, 10) for i in range(10)
    ])

    # Verify all keys exist
    for worker_id in range(10):
        for i in range(10):
            key = f'key_{worker_id}_{i}'
            value = await cache.get(key)
            assert value == f'value_{worker_id}_{i}'

# Run tests with: pytest -v test_async_cache.py
```

---

## Performance Examples

### Example 13: Performance Comparison - Sequential vs Concurrent

```python
import asyncio
import aiohttp
import time
from typing import List

async def fetch_sequential(urls: List[str]) -> List[dict]:
    """Fetch URLs sequentially"""
    results = []

    async with aiohttp.ClientSession() as session:
        for url in urls:
            try:
                async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
                    results.append({
                        'url': url,
                        'status': resp.status,
                        'size': len(await resp.text())
                    })
            except Exception as e:
                results.append({'url': url, 'error': str(e)})

    return results

async def fetch_concurrent(urls: List[str]) -> List[dict]:
    """Fetch URLs concurrently"""
    async def fetch_one(session, url):
        try:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
                return {
                    'url': url,
                    'status': resp.status,
                    'size': len(await resp.text())
                }
        except Exception as e:
            return {'url': url, 'error': str(e)}

    async with aiohttp.ClientSession() as session:
        tasks = [fetch_one(session, url) for url in urls]
        results = await asyncio.gather(*tasks)

    return results

async def benchmark():
    """Compare sequential vs concurrent performance"""
    urls = [
        'http://python.org',
        'http://docs.python.org',
        'http://pypi.org',
        'http://github.com/python',
        'http://www.python.org/dev/peps/',
        'http://discuss.python.org',
        'http://peps.python.org',
        'http://wiki.python.org',
    ] * 2  # 16 total requests

    print(f"Benchmarking with {len(urls)} URLs...\n")

    # Sequential
    print("=== Sequential Execution ===")
    start = time.perf_counter()
    seq_results = await fetch_sequential(urls)
    seq_time = time.perf_counter() - start

    successful = sum(1 for r in seq_results if 'error' not in r)
    print(f"Time: {seq_time:.2f}s")
    print(f"Successful: {successful}/{len(urls)}\n")

    # Concurrent
    print("=== Concurrent Execution ===")
    start = time.perf_counter()
    conc_results = await fetch_concurrent(urls)
    conc_time = time.perf_counter() - start

    successful = sum(1 for r in conc_results if 'error' not in r)
    print(f"Time: {conc_time:.2f}s")
    print(f"Successful: {successful}/{len(urls)}\n")

    # Results
    print("=== Results ===")
    print(f"Sequential: {seq_time:.2f}s")
    print(f"Concurrent: {conc_time:.2f}s")
    print(f"Speedup: {seq_time / conc_time:.2f}x faster")
    print(f"Time saved: {seq_time - conc_time:.2f}s")

if __name__ == '__main__':
    asyncio.run(benchmark())
```

---

## Production Patterns

### Example 14: Circuit Breaker Pattern

Prevent cascading failures with circuit breaker.

```python
import asyncio
from enum import Enum
from datetime import datetime, timedelta
from typing import Optional, Callable

class CircuitState(Enum):
    CLOSED = "closed"          # Normal operation
    OPEN = "open"              # Failing, reject requests
    HALF_OPEN = "half_open"    # Testing recovery

class CircuitBreaker:
    """
    Circuit breaker for protecting against cascading failures
    """

    def __init__(
        self,
        failure_threshold: int = 5,
        success_threshold: int = 2,
        timeout: float = 60.0,
        expected_exception: type = Exception
    ):
        self.failure_threshold = failure_threshold
        self.success_threshold = success_threshold
        self.timeout = timeout
        self.expected_exception = expected_exception

        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time: Optional[datetime] = None

    async def call(self, func: Callable, *args, **kwargs):
        """
        Execute function with circuit breaker protection
        """
        if self.state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self.state = CircuitState.HALF_OPEN
                print(f"🔄 Circuit breaker entering HALF_OPEN state")
            else:
                raise Exception("Circuit breaker is OPEN")

        try:
            result = await func(*args, **kwargs)
            self._on_success()
            return result

        except self.expected_exception as e:
            self._on_failure()
            raise

    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset"""
        return (
            self.last_failure_time is not None and
            datetime.now() - self.last_failure_time >= timedelta(seconds=self.timeout)
        )

    def _on_success(self):
        """Handle successful call"""
        self.failure_count = 0

        if self.state == CircuitState.HALF_OPEN:
            self.success_count += 1

            if self.success_count >= self.success_threshold:
                self.state = CircuitState.CLOSED
                self.success_count = 0
                print(f"✓ Circuit breaker CLOSED (recovered)")

    def _on_failure(self):
        """Handle failed call"""
        self.failure_count += 1
        self.last_failure_time = datetime.now()

        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN
            print(f"⚠️  Circuit breaker OPEN (too many failures)")

    def get_state(self) -> dict:
        """Get current circuit breaker state"""
        return {
            'state': self.state.value,
            'failure_count': self.failure_count,
            'success_count': self.success_count,
            'last_failure': self.last_failure_time
        }

# Example usage
async def flaky_service(failure_rate: float = 0.5):
    """Simulate a flaky service"""
    import random
    await asyncio.sleep(0.1)

    if random.random() < failure_rate:
        raise ConnectionError("Service unavailable")

    return "Success"

async def main():
    breaker = CircuitBreaker(
        failure_threshold=3,
        success_threshold=2,
        timeout=5.0
    )

    print("=== Testing Circuit Breaker ===\n")

    for i in range(30):
        try:
            result = await breaker.call(flaky_service, failure_rate=0.6)
            print(f"Request {i}: {result} - State: {breaker.state.value}")

        except Exception as e:
            print(f"Request {i}: Failed ({e}) - State: {breaker.state.value}")

        await asyncio.sleep(0.5)

    print(f"\n=== Final State ===")
    state = breaker.get_state()
    for key, value in state.items():
        print(f"{key}: {value}")

if __name__ == '__main__':
    asyncio.run(main())
```

### Example 15: Graceful Shutdown

Handle shutdown signals gracefully.

```python
import asyncio
import signal
from contextlib import suppress

class GracefulApplication:
    """
    Application with graceful shutdown handling
    """

    def __init__(self):
        self.shutdown_event = asyncio.Event()
        self.tasks = []

    async def worker(self, name: str):
        """Long-running worker task"""
        print(f"[{name}] Started")

        try:
            counter = 0
            while not self.shutdown_event.is_set():
                await asyncio.sleep(1)
                counter += 1
                print(f"[{name}] Working... ({counter})")

        except asyncio.CancelledError:
            print(f"[{name}] Received cancellation")
            # Cleanup logic here
            await asyncio.sleep(0.5)  # Simulate cleanup
            print(f"[{name}] Cleanup complete")
            raise

    def handle_signal(self, sig):
        """Handle shutdown signals"""
        print(f"\n⚠️  Received signal {signal.Signals(sig).name}")
        print("Initiating graceful shutdown...")
        self.shutdown_event.set()

    async def run(self):
        """Run application with signal handling"""
        # Setup signal handlers
        loop = asyncio.get_running_loop()

        for sig in (signal.SIGTERM, signal.SIGINT):
            loop.add_signal_handler(
                sig,
                lambda s=sig: self.handle_signal(s)
            )

        # Start workers
        print("=== Application Starting ===\n")
        self.tasks = [
            asyncio.create_task(self.worker(f'Worker-{i}'))
            for i in range(3)
        ]

        # Wait for shutdown signal
        await self.shutdown_event.wait()

        # Graceful shutdown
        print("\n=== Graceful Shutdown ===")

        # Give tasks time to finish current work
        print("Waiting for tasks to complete current work...")
        await asyncio.sleep(2)

        # Cancel tasks
        print("Cancelling tasks...")
        for task in self.tasks:
            task.cancel()

        # Wait for all cancellations
        results = await asyncio.gather(*self.tasks, return_exceptions=True)

        # Report results
        for i, result in enumerate(results):
            if isinstance(result, asyncio.CancelledError):
                print(f"✓ Task {i} cancelled successfully")
            elif isinstance(result, Exception):
                print(f"✗ Task {i} raised: {result}")

        print("\n=== Shutdown Complete ===")

async def main():
    app = GracefulApplication()
    await app.run()

if __name__ == '__main__':
    print("Press Ctrl+C to trigger graceful shutdown\n")
    asyncio.run(main())
```

---

## Additional Resources

- **Official asyncio Documentation**: https://docs.python.org/3/library/asyncio.html
- **aiohttp Documentation**: https://docs.aiohttp.org/
- **Real Python asyncio Tutorial**: https://realpython.com/async-io-python/
- **pytest-asyncio**: https://github.com/pytest-dev/pytest-asyncio

---

**Total Examples**: 15 comprehensive, production-ready examples
**Coverage**: HTTP clients, WebSockets, databases, queues, concurrency control, error handling, background tasks, testing, performance, and production patterns
