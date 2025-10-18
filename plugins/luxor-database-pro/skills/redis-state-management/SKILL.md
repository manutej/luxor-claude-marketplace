---
name: redis-state-management
description: Comprehensive guide for Redis state management including caching strategies, session management, pub/sub patterns, distributed locks, and data structures
tags: [redis, state-management, caching, pub-sub, distributed-systems, sessions]
tier: tier-1
---

# Redis State Management

A comprehensive skill for mastering Redis state management patterns in distributed systems. This skill covers caching strategies, session management, pub/sub messaging, distributed locks, data structures, and production-ready patterns using redis-py.

## When to Use This Skill

Use this skill when:

- Implementing high-performance caching layers for web applications
- Managing user sessions in distributed environments
- Building real-time messaging and event distribution systems
- Coordinating distributed processes with locks and synchronization
- Storing and querying structured data with Redis data structures
- Optimizing application performance with Redis
- Scaling applications horizontally with shared state
- Implementing rate limiting, counters, and analytics
- Building microservices with Redis as a communication layer
- Managing temporary data with automatic expiration (TTL)
- Implementing leaderboards, queues, and real-time features

## Core Concepts

### Redis Fundamentals

**Redis** (Remote Dictionary Server) is an in-memory data structure store used as:
- **Database**: Persistent key-value storage
- **Cache**: High-speed data layer
- **Message Broker**: Pub/sub and stream messaging
- **Session Store**: Distributed session management

**Key Characteristics:**
- In-memory storage (microsecond latency)
- Optional persistence (RDB snapshots, AOF logs)
- Rich data structures beyond key-value
- Atomic operations on complex data types
- Built-in replication and clustering
- Pub/sub messaging support
- Lua scripting for complex operations
- Pipelining for batch operations

### Redis Data Structures

Redis provides multiple data types for different use cases:

1. **Strings**: Simple key-value pairs, binary safe
   - Use for: Cache values, counters, flags, JSON objects
   - Max size: 512 MB
   - Commands: SET, GET, INCR, APPEND

2. **Hashes**: Field-value maps (objects)
   - Use for: User profiles, configuration objects, small entities
   - Efficient for storing objects with multiple fields
   - Commands: HSET, HGET, HMGET, HINCRBY

3. **Lists**: Ordered collections (linked lists)
   - Use for: Queues, activity feeds, recent items
   - Operations at head/tail are O(1)
   - Commands: LPUSH, RPUSH, LPOP, RPOP, LRANGE

4. **Sets**: Unordered unique collections
   - Use for: Tags, unique visitors, relationships
   - Set operations: union, intersection, difference
   - Commands: SADD, SMEMBERS, SISMEMBER, SINTER

5. **Sorted Sets**: Ordered sets with scores
   - Use for: Leaderboards, time-series, priority queues
   - Range queries by score or rank
   - Commands: ZADD, ZRANGE, ZRANGEBYSCORE, ZRANK

6. **Streams**: Append-only logs with consumer groups
   - Use for: Event sourcing, activity logs, message queues
   - Built-in consumer group support
   - Commands: XADD, XREAD, XREADGROUP

### Connection Management

**Connection Pools:**
Redis connections are expensive to create. Always use connection pools:

```python
import redis

# Connection pool (recommended)
pool = redis.ConnectionPool(host='localhost', port=6379, db=0, max_connections=10)
r = redis.Redis(connection_pool=pool)

# Direct connection (avoid in production)
r = redis.Redis(host='localhost', port=6379, db=0)
```

**Best Practices:**
- Use connection pools for all applications
- Set appropriate max_connections based on workload
- Enable decode_responses=True for string data
- Configure socket_timeout and socket_keepalive
- Handle connection errors with retries

### Data Persistence

Redis offers two persistence mechanisms:

**RDB (Redis Database)**: Point-in-time snapshots
- Compact binary format
- Fast restart times
- Lower disk I/O
- Potential data loss between snapshots

**AOF (Append-Only File)**: Log of write operations
- Better durability (fsync policies)
- Larger files, slower restarts
- Can be automatically rewritten/compacted
- Minimal data loss potential

**Hybrid Approach**: RDB + AOF for best of both worlds

### RESP 3 Protocol

Redis Serialization Protocol version 3 offers:
- Client-side caching support
- Better data type support
- Push notifications
- Performance improvements

```python
import redis
from redis.cache import CacheConfig

# Enable RESP3 with client-side caching
r = redis.Redis(host='localhost', port=6379, protocol=3,
                cache_config=CacheConfig())
```

## Caching Strategies

### Cache-Aside (Lazy Loading)

**Pattern**: Application checks cache first, loads from database on miss

```python
import redis
import json
from typing import Optional, Dict, Any

r = redis.Redis(decode_responses=True)

def get_user(user_id: int) -> Optional[Dict[str, Any]]:
    """Cache-aside pattern for user data."""
    cache_key = f"user:{user_id}"

    # Try cache first
    cached_data = r.get(cache_key)
    if cached_data:
        return json.loads(cached_data)

    # Cache miss - load from database
    user_data = database.get_user(user_id)  # Your DB query
    if user_data:
        # Store in cache with 1 hour TTL
        r.setex(cache_key, 3600, json.dumps(user_data))

    return user_data
```

**Advantages:**
- Only requested data is cached (efficient memory usage)
- Cache failures don't break the application
- Simple to implement

**Disadvantages:**
- Cache miss penalty (latency spike)
- Thundering herd on popular items
- Stale data until cache expiration

### Write-Through Cache

**Pattern**: Write to cache and database simultaneously

```python
def update_user(user_id: int, user_data: Dict[str, Any]) -> bool:
    """Write-through pattern for user updates."""
    cache_key = f"user:{user_id}"

    # Write to database first
    success = database.update_user(user_id, user_data)

    if success:
        # Update cache immediately
        r.setex(cache_key, 3600, json.dumps(user_data))

    return success
```

**Advantages:**
- Cache always consistent with database
- No read penalty for recently written data

**Disadvantages:**
- Write latency increases
- Unused data may be cached
- Extra cache write overhead

### Write-Behind (Write-Back) Cache

**Pattern**: Write to cache immediately, sync to database asynchronously

```python
import redis
import json
from queue import Queue
from threading import Thread

r = redis.Redis(decode_responses=True)
write_queue = Queue()

def async_writer():
    """Background worker to sync cache to database."""
    while True:
        user_id, user_data = write_queue.get()
        try:
            database.update_user(user_id, user_data)
        except Exception as e:
            # Log error, potentially retry
            print(f"Failed to write user {user_id}: {e}")
        finally:
            write_queue.task_done()

# Start background writer
Thread(target=async_writer, daemon=True).start()

def update_user_fast(user_id: int, user_data: Dict[str, Any]):
    """Write-behind pattern for fast writes."""
    cache_key = f"user:{user_id}"

    # Write to cache immediately (fast)
    r.setex(cache_key, 3600, json.dumps(user_data))

    # Queue database write (async)
    write_queue.put((user_id, user_data))
```

**Advantages:**
- Minimal write latency
- Can batch database writes
- Handles write spikes

**Disadvantages:**
- Risk of data loss if cache fails
- Complex error handling
- Consistency challenges

### Cache Invalidation Strategies

**Time-based Expiration (TTL):**

```python
# Set key with expiration
r.setex("session:abc123", 1800, session_data)  # 30 minutes

# Or set TTL on existing key
r.expire("user:profile:123", 3600)  # 1 hour

# Check remaining TTL
ttl = r.ttl("user:profile:123")
```

**Event-based Invalidation:**

```python
def update_product(product_id: int, product_data: dict):
    """Invalidate cache on update."""
    # Update database
    database.update_product(product_id, product_data)

    # Invalidate related caches
    r.delete(f"product:{product_id}")
    r.delete(f"product_list:category:{product_data['category']}")
    r.delete("products:featured")
```

**Pattern-based Invalidation:**

```python
# Delete all keys matching pattern
def invalidate_user_cache(user_id: int):
    """Invalidate all cache entries for a user."""
    pattern = f"user:{user_id}:*"

    # Find and delete matching keys
    for key in r.scan_iter(match=pattern, count=100):
        r.delete(key)
```

### Cache Stampede Prevention

**Problem**: Multiple requests simultaneously miss cache and query database

**Solution 1: Probabilistic Early Expiration**

```python
import time
import random

def get_with_early_expiration(key: str, ttl: int = 3600, beta: float = 1.0):
    """Prevent stampede with probabilistic early recomputation."""
    value = r.get(key)

    if value is None:
        # Cache miss - compute and cache
        value = compute_value(key)
        r.setex(key, ttl, value)
        return value

    # Check if we should recompute early
    current_time = time.time()
    delta = current_time - float(r.get(f"{key}:timestamp") or 0)
    expiry = ttl * random.random() * beta

    if delta > expiry:
        # Recompute in background
        value = compute_value(key)
        r.setex(key, ttl, value)
        r.set(f"{key}:timestamp", current_time)

    return value
```

**Solution 2: Locking**

```python
from contextlib import contextmanager

@contextmanager
def cache_lock(key: str, timeout: int = 10):
    """Acquire lock for cache computation."""
    lock_key = f"{key}:lock"
    identifier = str(time.time())

    # Try to acquire lock
    if r.set(lock_key, identifier, nx=True, ex=timeout):
        try:
            yield True
        finally:
            # Release lock
            if r.get(lock_key) == identifier:
                r.delete(lock_key)
    else:
        yield False

def get_with_lock(key: str):
    """Use lock to prevent stampede."""
    value = r.get(key)

    if value is None:
        with cache_lock(key) as acquired:
            if acquired:
                # We got the lock - compute value
                value = compute_value(key)
                r.setex(key, 3600, value)
            else:
                # Someone else is computing - wait and retry
                time.sleep(0.1)
                value = r.get(key) or compute_value(key)

    return value
```

## Session Management

### Distributed Session Storage

**Basic Session Management:**

```python
import redis
import json
import uuid
from datetime import datetime, timedelta

r = redis.Redis(decode_responses=True)

class SessionManager:
    def __init__(self, ttl: int = 1800):
        """Session manager with Redis backend.

        Args:
            ttl: Session timeout in seconds (default 30 minutes)
        """
        self.ttl = ttl

    def create_session(self, user_id: int, data: dict = None) -> str:
        """Create new session and return session ID."""
        session_id = str(uuid.uuid4())
        session_key = f"session:{session_id}"

        session_data = {
            "user_id": user_id,
            "created_at": datetime.utcnow().isoformat(),
            "data": data or {}
        }

        r.setex(session_key, self.ttl, json.dumps(session_data))
        return session_id

    def get_session(self, session_id: str) -> dict:
        """Retrieve session data and refresh TTL."""
        session_key = f"session:{session_id}"
        session_data = r.get(session_key)

        if session_data:
            # Refresh TTL on access (sliding expiration)
            r.expire(session_key, self.ttl)
            return json.loads(session_data)

        return None

    def update_session(self, session_id: str, data: dict) -> bool:
        """Update session data."""
        session_key = f"session:{session_id}"
        session_data = self.get_session(session_id)

        if session_data:
            session_data["data"].update(data)
            r.setex(session_key, self.ttl, json.dumps(session_data))
            return True

        return False

    def delete_session(self, session_id: str) -> bool:
        """Delete session (logout)."""
        session_key = f"session:{session_id}"
        return r.delete(session_key) > 0
```

### Session with Hash Storage

**More efficient for session objects:**

```python
class HashSessionManager:
    """Session manager using Redis hashes for better performance."""

    def __init__(self, ttl: int = 1800):
        self.ttl = ttl

    def create_session(self, user_id: int, **kwargs) -> str:
        """Create session using hash."""
        session_id = str(uuid.uuid4())
        session_key = f"session:{session_id}"

        # Store as hash for efficient field access
        session_fields = {
            "user_id": str(user_id),
            "created_at": datetime.utcnow().isoformat(),
            **{k: str(v) for k, v in kwargs.items()}
        }

        r.hset(session_key, mapping=session_fields)
        r.expire(session_key, self.ttl)

        return session_id

    def get_field(self, session_id: str, field: str) -> str:
        """Get single session field efficiently."""
        session_key = f"session:{session_id}"
        value = r.hget(session_key, field)

        if value:
            r.expire(session_key, self.ttl)  # Refresh TTL

        return value

    def set_field(self, session_id: str, field: str, value: str) -> bool:
        """Update single session field."""
        session_key = f"session:{session_id}"

        if r.exists(session_key):
            r.hset(session_key, field, value)
            r.expire(session_key, self.ttl)
            return True

        return False

    def get_all(self, session_id: str) -> dict:
        """Get all session fields."""
        session_key = f"session:{session_id}"
        data = r.hgetall(session_key)

        if data:
            r.expire(session_key, self.ttl)

        return data
```

### User Activity Tracking

```python
def track_user_activity(user_id: int, action: str):
    """Track user activity with automatic expiration."""
    activity_key = f"user:{user_id}:activity"
    timestamp = datetime.utcnow().isoformat()

    # Add activity to list
    r.lpush(activity_key, json.dumps({"action": action, "timestamp": timestamp}))

    # Keep only last 100 activities
    r.ltrim(activity_key, 0, 99)

    # Set expiration (30 days)
    r.expire(activity_key, 2592000)

def get_recent_activity(user_id: int, limit: int = 10) -> list:
    """Get recent user activities."""
    activity_key = f"user:{user_id}:activity"
    activities = r.lrange(activity_key, 0, limit - 1)

    return [json.loads(a) for a in activities]
```

## Pub/Sub Patterns

### Basic Publisher/Subscriber

**Publisher:**

```python
import redis

r = redis.Redis(decode_responses=True)

def publish_event(channel: str, message: dict):
    """Publish event to channel."""
    import json
    r.publish(channel, json.dumps(message))

# Example usage
publish_event("notifications", {
    "type": "user_signup",
    "user_id": 12345,
    "timestamp": datetime.utcnow().isoformat()
})
```

**Subscriber:**

```python
import redis
import json

def handle_message(message):
    """Process received message."""
    data = json.loads(message['data'])
    print(f"Received: {data}")

# Initialize pubsub
r = redis.Redis(decode_responses=True)
p = r.pubsub()

# Subscribe to channels
p.subscribe('notifications', 'alerts')

# Listen for messages
for message in p.listen():
    if message['type'] == 'message':
        handle_message(message)
```

### Pattern-Based Subscriptions

```python
# Subscribe to multiple channels with patterns
p = r.pubsub()
p.psubscribe('user:*', 'notification:*')

# Get messages from pattern subscriptions
for message in p.listen():
    if message['type'] == 'pmessage':
        channel = message['channel']
        pattern = message['pattern']
        data = message['data']
        print(f"Pattern {pattern} matched {channel}: {data}")
```

### Async Pub/Sub with Background Thread

```python
import redis
import time

r = redis.Redis(decode_responses=True)
p = r.pubsub()

def message_handler(message):
    """Handle messages in background thread."""
    print(f"Handler received: {message['data']}")

# Subscribe with handler
p.subscribe(**{'notifications': message_handler, 'alerts': message_handler})

# Run in background thread
thread = p.run_in_thread(sleep_time=0.001)

# Publish some messages
r.publish('notifications', 'Hello!')
r.publish('alerts', 'Warning!')

time.sleep(1)

# Stop background thread
thread.stop()
```

### Async Pub/Sub with asyncio

```python
import asyncio
import redis.asyncio as redis

async def reader(channel: redis.client.PubSub):
    """Async message reader."""
    while True:
        message = await channel.get_message(ignore_subscribe_messages=True, timeout=None)
        if message is not None:
            print(f"Received: {message}")

            # Stop on specific message
            if message["data"].decode() == "STOP":
                break

async def pubsub_example():
    """Async pub/sub example."""
    r = await redis.from_url("redis://localhost")

    async with r.pubsub() as pubsub:
        # Subscribe to channels
        await pubsub.subscribe("channel:1", "channel:2")

        # Create reader task
        reader_task = asyncio.create_task(reader(pubsub))

        # Publish messages
        await r.publish("channel:1", "Hello")
        await r.publish("channel:2", "World")
        await r.publish("channel:1", "STOP")

        # Wait for reader to finish
        await reader_task

    await r.close()

# Run async example
asyncio.run(pubsub_example())
```

### Sharded Pub/Sub (Redis 7.0+)

```python
from redis.cluster import RedisCluster, ClusterNode

# Connect to cluster
rc = RedisCluster(startup_nodes=[
    ClusterNode('localhost', 6379),
    ClusterNode('localhost', 6380)
])

# Create sharded pubsub
p = rc.pubsub()
p.ssubscribe('foo')

# Get message from specific node
message = p.get_sharded_message(target_node=ClusterNode('localhost', 6379))
```

## Distributed Locks

### Simple Lock Implementation

```python
import redis
import time
import uuid

class RedisLock:
    """Simple distributed lock using Redis."""

    def __init__(self, redis_client: redis.Redis, key: str, timeout: int = 10):
        self.redis = redis_client
        self.key = f"lock:{key}"
        self.timeout = timeout
        self.identifier = str(uuid.uuid4())

    def acquire(self, blocking: bool = True, timeout: float = None) -> bool:
        """Acquire lock."""
        end_time = time.time() + (timeout or self.timeout)

        while True:
            # Try to set lock with NX (only if not exists) and EX (expiration)
            if self.redis.set(self.key, self.identifier, nx=True, ex=self.timeout):
                return True

            if not blocking:
                return False

            if timeout and time.time() > end_time:
                return False

            # Wait before retry
            time.sleep(0.01)

    def release(self) -> bool:
        """Release lock only if we own it."""
        # Use Lua script for atomic check-and-delete
        lua_script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """

        result = self.redis.eval(lua_script, 1, self.key, self.identifier)
        return result == 1

    def __enter__(self):
        """Context manager support."""
        self.acquire()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager cleanup."""
        self.release()

# Usage example
r = redis.Redis()
lock = RedisLock(r, "resource:123", timeout=5)

with lock:
    # Critical section - only one process at a time
    print("Processing resource 123")
    process_resource()
```

### Advanced Lock with Auto-Renewal

```python
import threading

class RenewableLock:
    """Distributed lock with automatic renewal."""

    def __init__(self, redis_client: redis.Redis, key: str, timeout: int = 10):
        self.redis = redis_client
        self.key = f"lock:{key}"
        self.timeout = timeout
        self.identifier = str(uuid.uuid4())
        self.renewal_thread = None
        self.stop_renewal = threading.Event()

    def _renew_lock(self):
        """Background task to renew lock."""
        while not self.stop_renewal.is_set():
            time.sleep(self.timeout / 3)  # Renew at 1/3 of timeout

            # Renew only if we still own the lock
            lua_script = """
            if redis.call("get", KEYS[1]) == ARGV[1] then
                return redis.call("expire", KEYS[1], ARGV[2])
            else
                return 0
            end
            """

            result = self.redis.eval(lua_script, 1, self.key,
                                   self.identifier, self.timeout)

            if result == 0:
                # We lost the lock
                self.stop_renewal.set()

    def acquire(self, blocking: bool = True, timeout: float = None) -> bool:
        """Acquire lock and start auto-renewal."""
        if self.redis.set(self.key, self.identifier, nx=True, ex=self.timeout):
            # Start renewal thread
            self.stop_renewal.clear()
            self.renewal_thread = threading.Thread(target=self._renew_lock, daemon=True)
            self.renewal_thread.start()
            return True

        return False

    def release(self) -> bool:
        """Release lock and stop renewal."""
        self.stop_renewal.set()

        lua_script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """

        result = self.redis.eval(lua_script, 1, self.key, self.identifier)
        return result == 1
```

### Redlock Algorithm (Multiple Redis Instances)

```python
class Redlock:
    """Redlock algorithm for distributed locking across multiple Redis instances."""

    def __init__(self, redis_instances: list):
        """
        Args:
            redis_instances: List of Redis client connections
        """
        self.instances = redis_instances
        self.quorum = len(redis_instances) // 2 + 1

    def acquire(self, resource: str, ttl: int = 10000) -> tuple:
        """
        Acquire lock across multiple Redis instances.

        Returns:
            (success: bool, lock_identifier: str)
        """
        identifier = str(uuid.uuid4())
        start_time = int(time.time() * 1000)

        # Try to acquire lock on all instances
        acquired = 0
        for instance in self.instances:
            try:
                if instance.set(f"lock:{resource}", identifier,
                              nx=True, px=ttl):
                    acquired += 1
            except Exception:
                pass

        # Calculate elapsed time
        elapsed = int(time.time() * 1000) - start_time
        validity_time = ttl - elapsed - 100  # drift compensation

        # Check if we got quorum
        if acquired >= self.quorum and validity_time > 0:
            return True, identifier
        else:
            # Release locks if we didn't get quorum
            self._release_all(resource, identifier)
            return False, None

    def _release_all(self, resource: str, identifier: str):
        """Release lock on all instances."""
        lua_script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """

        for instance in self.instances:
            try:
                instance.eval(lua_script, 1, f"lock:{resource}", identifier)
            except Exception:
                pass
```

## Data Structures and Operations

### Working with Hashes

```python
# User profile storage
def save_user_profile(user_id: int, profile: dict):
    """Save user profile as hash."""
    key = f"user:profile:{user_id}"
    r.hset(key, mapping=profile)
    r.expire(key, 86400)  # 24 hour TTL

def get_user_profile(user_id: int) -> dict:
    """Get complete user profile."""
    key = f"user:profile:{user_id}"
    return r.hgetall(key)

def update_user_field(user_id: int, field: str, value: str):
    """Update single profile field."""
    key = f"user:profile:{user_id}"
    r.hset(key, field, value)

# Example usage
save_user_profile(123, {
    "username": "alice",
    "email": "alice@example.com",
    "age": "30"
})

# Atomic increment
r.hincrby("user:profile:123", "login_count", 1)
```

### Working with Lists

```python
# Job queue implementation
def enqueue_job(queue_name: str, job_data: dict):
    """Add job to queue."""
    key = f"queue:{queue_name}"
    r.rpush(key, json.dumps(job_data))

def dequeue_job(queue_name: str, timeout: int = 0) -> dict:
    """Get job from queue (blocking)."""
    key = f"queue:{queue_name}"

    if timeout > 0:
        # Blocking pop with timeout
        result = r.blpop(key, timeout=timeout)
        if result:
            _, job_data = result
            return json.loads(job_data)
    else:
        # Non-blocking pop
        job_data = r.lpop(key)
        if job_data:
            return json.loads(job_data)

    return None

# Activity feed
def add_to_feed(user_id: int, activity: dict):
    """Add activity to user feed."""
    key = f"feed:{user_id}"
    r.lpush(key, json.dumps(activity))
    r.ltrim(key, 0, 99)  # Keep only latest 100 items
    r.expire(key, 604800)  # 7 days

def get_feed(user_id: int, start: int = 0, end: int = 19) -> list:
    """Get user feed with pagination."""
    key = f"feed:{user_id}"
    items = r.lrange(key, start, end)
    return [json.loads(item) for item in items]
```

### Working with Sets

```python
# Tags and relationships
def add_tags(item_id: int, tags: list):
    """Add tags to item."""
    key = f"item:{item_id}:tags"
    r.sadd(key, *tags)

def get_tags(item_id: int) -> set:
    """Get all tags for item."""
    key = f"item:{item_id}:tags"
    return r.smembers(key)

def find_items_with_all_tags(tags: list) -> set:
    """Find items having all specified tags."""
    keys = [f"item:*:tags" for _ in tags]
    # This is simplified - in practice, you'd need to track item IDs differently
    return r.sinter(*keys)

# Online users tracking
def user_online(user_id: int):
    """Mark user as online."""
    r.sadd("users:online", user_id)
    r.expire(f"user:{user_id}:heartbeat", 60)

def user_offline(user_id: int):
    """Mark user as offline."""
    r.srem("users:online", user_id)

def get_online_users() -> set:
    """Get all online users."""
    return r.smembers("users:online")

def get_online_count() -> int:
    """Get count of online users."""
    return r.scard("users:online")
```

### Working with Sorted Sets

```python
# Leaderboard implementation
def update_score(leaderboard: str, user_id: int, score: float):
    """Update user score in leaderboard."""
    key = f"leaderboard:{leaderboard}"
    r.zadd(key, {user_id: score})

def get_leaderboard(leaderboard: str, start: int = 0, end: int = 9) -> list:
    """Get top players (descending order)."""
    key = f"leaderboard:{leaderboard}"
    # ZREVRANGE for descending order (highest scores first)
    return r.zrevrange(key, start, end, withscores=True)

def get_user_rank(leaderboard: str, user_id: int) -> int:
    """Get user's rank (0-indexed)."""
    key = f"leaderboard:{leaderboard}"
    # ZREVRANK for descending rank
    rank = r.zrevrank(key, user_id)
    return rank if rank is not None else -1

def get_user_score(leaderboard: str, user_id: int) -> float:
    """Get user's score."""
    key = f"leaderboard:{leaderboard}"
    score = r.zscore(key, user_id)
    return score if score is not None else 0.0

def get_score_range(leaderboard: str, min_score: float, max_score: float) -> list:
    """Get users within score range."""
    key = f"leaderboard:{leaderboard}"
    return r.zrangebyscore(key, min_score, max_score, withscores=True)

# Time-based sorted set (activity stream)
def add_activity(user_id: int, activity: str):
    """Add timestamped activity."""
    key = f"user:{user_id}:activities"
    timestamp = time.time()
    r.zadd(key, {activity: timestamp})

    # Keep only last 24 hours
    cutoff = timestamp - 86400
    r.zremrangebyscore(key, '-inf', cutoff)

def get_recent_activities(user_id: int, count: int = 10) -> list:
    """Get recent activities."""
    key = f"user:{user_id}:activities"
    # Get most recent (highest timestamps)
    return r.zrevrange(key, 0, count - 1, withscores=True)
```

### Working with Streams

```python
# Event stream
def add_event(stream_key: str, event_data: dict) -> str:
    """Add event to stream."""
    # Returns auto-generated ID (timestamp-sequence)
    event_id = r.xadd(stream_key, event_data)
    return event_id

def read_events(stream_key: str, count: int = 10, start_id: str = '0') -> list:
    """Read events from stream."""
    events = r.xread({stream_key: start_id}, count=count)

    # events format: [(stream_name, [(id, data), (id, data), ...])]
    if events:
        _, event_list = events[0]
        return event_list

    return []

# Consumer groups
def create_consumer_group(stream_key: str, group_name: str):
    """Create consumer group for stream."""
    try:
        r.xgroup_create(name=stream_key, groupname=group_name, id='0')
    except redis.ResponseError as e:
        if "BUSYGROUP" not in str(e):
            raise

def read_from_group(stream_key: str, group_name: str,
                   consumer_name: str, count: int = 10) -> list:
    """Read events as consumer in group."""
    # Read new messages with '>'
    events = r.xreadgroup(
        groupname=group_name,
        consumername=consumer_name,
        streams={stream_key: '>'},
        count=count,
        block=5000  # 5 second timeout
    )

    if events:
        _, event_list = events[0]
        return event_list

    return []

def acknowledge_event(stream_key: str, group_name: str, event_id: str):
    """Acknowledge processed event."""
    r.xack(stream_key, group_name, event_id)

# Example: Processing events with consumer group
def process_events(stream_key: str, group_name: str, consumer_name: str):
    """Process events from stream."""
    create_consumer_group(stream_key, group_name)

    while True:
        events = read_from_group(stream_key, group_name, consumer_name, count=10)

        for event_id, event_data in events:
            try:
                # Process event
                process_event(event_data)

                # Acknowledge successful processing
                acknowledge_event(stream_key, group_name, event_id)
            except Exception as e:
                print(f"Failed to process event {event_id}: {e}")
                # Event remains unacknowledged for retry
```

## Performance Optimization

### Pipelining for Batch Operations

```python
# Without pipelining (slow - multiple round trips)
for i in range(1000):
    r.set(f"key:{i}", f"value:{i}")

# With pipelining (fast - single round trip)
pipe = r.pipeline()
for i in range(1000):
    pipe.set(f"key:{i}", f"value:{i}")
results = pipe.execute()

# Pipelining with reads
pipe = r.pipeline()
for i in range(100):
    pipe.get(f"key:{i}")
values = pipe.execute()

# Builder pattern with pipeline
class DataLoader:
    def __init__(self):
        self.pipeline = r.pipeline()

    def add_user(self, user_id: int, user_data: dict):
        """Add user data."""
        self.pipeline.hset(f"user:{user_id}", mapping=user_data)
        return self

    def add_to_set(self, set_name: str, value: str):
        """Add to set."""
        self.pipeline.sadd(set_name, value)
        return self

    def execute(self):
        """Execute all pipelined commands."""
        return self.pipeline.execute()

# Usage
loader = DataLoader()
results = (loader
    .add_user(1, {"name": "Alice", "email": "alice@example.com"})
    .add_user(2, {"name": "Bob", "email": "bob@example.com"})
    .add_to_set("active_users", "1")
    .add_to_set("active_users", "2")
    .execute())
```

### Transactions with WATCH

```python
# Optimistic locking with WATCH
def transfer_credits(from_user: int, to_user: int, amount: int) -> bool:
    """Transfer credits between users with optimistic locking."""

    with r.pipeline() as pipe:
        while True:
            try:
                # Watch the keys we're going to modify
                pipe.watch(f"user:{from_user}:credits", f"user:{to_user}:credits")

                # Get current values
                from_credits = int(pipe.get(f"user:{from_user}:credits") or 0)
                to_credits = int(pipe.get(f"user:{to_user}:credits") or 0)

                # Check if transfer is possible
                if from_credits < amount:
                    pipe.unwatch()
                    return False

                # Start transaction
                pipe.multi()
                pipe.set(f"user:{from_user}:credits", from_credits - amount)
                pipe.set(f"user:{to_user}:credits", to_credits + amount)

                # Execute transaction
                pipe.execute()
                return True

            except redis.WatchError:
                # Key was modified by another client - retry
                continue

# Lua scripts for atomic operations
increment_script = """
local current = redis.call('GET', KEYS[1])
if not current then
    current = 0
end
local new_val = tonumber(current) + tonumber(ARGV[1])
redis.call('SET', KEYS[1], new_val)
return new_val
"""

# Register and use Lua script
increment = r.register_script(increment_script)
new_value = increment(keys=['counter:views'], args=[1])
```

### Lua Scripts for Complex Operations

```python
# Rate limiting with Lua
rate_limit_script = """
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local current = redis.call('INCR', key)

if current == 1 then
    redis.call('EXPIRE', key, window)
end

if current > limit then
    return 0
else
    return 1
end
"""

rate_limiter = r.register_script(rate_limit_script)

def is_allowed(user_id: int, limit: int = 100, window: int = 60) -> bool:
    """Check if user is within rate limit."""
    key = f"rate_limit:{user_id}"
    result = rate_limiter(keys=[key], args=[limit, window])
    return result == 1

# Get-or-set pattern with Lua
get_or_set_script = """
local value = redis.call('GET', KEYS[1])
if value then
    return value
else
    redis.call('SET', KEYS[1], ARGV[1])
    redis.call('EXPIRE', KEYS[1], ARGV[2])
    return ARGV[1]
end
"""

get_or_set = r.register_script(get_or_set_script)

def get_or_compute(key: str, compute_fn, ttl: int = 3600):
    """Get value from cache or compute and cache it."""
    value = get_or_set(keys=[key], args=["__COMPUTING__", ttl])

    if value == "__COMPUTING__":
        # We set the placeholder - compute the real value
        computed = compute_fn()
        r.setex(key, ttl, computed)
        return computed

    return value
```

## Production Patterns

### High Availability with Sentinel

```python
from redis.sentinel import Sentinel

# Connect to Sentinel
sentinel = Sentinel([
    ('sentinel1', 26379),
    ('sentinel2', 26379),
    ('sentinel3', 26379)
], socket_timeout=0.5)

# Get master connection
master = sentinel.master_for('mymaster', socket_timeout=0.5)

# Get replica connection (for read-only operations)
replica = sentinel.slave_for('mymaster', socket_timeout=0.5)

# Use master for writes
master.set('key', 'value')

# Use replica for reads (optional, for load distribution)
value = replica.get('key')
```

### Async Redis with asyncio

```python
import asyncio
import redis.asyncio as redis

async def async_redis_operations():
    """Async Redis operations example."""
    # Create async connection
    r = await redis.from_url("redis://localhost")

    try:
        # Async operations
        await r.set("async_key", "async_value")
        value = await r.get("async_key")
        print(f"Value: {value}")

        # Async pipeline
        async with r.pipeline(transaction=True) as pipe:
            await pipe.set("key1", "value1")
            await pipe.set("key2", "value2")
            await pipe.get("key1")
            results = await pipe.execute()

        print(f"Pipeline results: {results}")

    finally:
        await r.close()

# Run async operations
asyncio.run(async_redis_operations())
```

### Connection Pool Configuration

```python
# Production-ready connection pool
pool = redis.ConnectionPool(
    host='localhost',
    port=6379,
    db=0,
    max_connections=50,           # Max pool size
    socket_timeout=5,             # Socket timeout
    socket_connect_timeout=5,     # Connection timeout
    socket_keepalive=True,        # Keep TCP connection alive
    socket_keepalive_options={
        socket.TCP_KEEPIDLE: 60,
        socket.TCP_KEEPINTVL: 10,
        socket.TCP_KEEPCNT: 3
    },
    retry_on_timeout=True,        # Retry on timeout
    health_check_interval=30,     # Health check every 30s
    decode_responses=True         # Auto-decode bytes to strings
)

r = redis.Redis(connection_pool=pool)
```

### Error Handling and Resilience

```python
import redis
from redis.exceptions import ConnectionError, TimeoutError
import time

class ResilientRedisClient:
    """Redis client with retry logic and circuit breaker."""

    def __init__(self, max_retries: int = 3, backoff: float = 0.1):
        self.redis = redis.Redis(
            host='localhost',
            port=6379,
            socket_timeout=5,
            retry_on_timeout=True
        )
        self.max_retries = max_retries
        self.backoff = backoff

    def get_with_retry(self, key: str, default=None):
        """Get value with exponential backoff retry."""
        for attempt in range(self.max_retries):
            try:
                return self.redis.get(key) or default
            except (ConnectionError, TimeoutError) as e:
                if attempt == self.max_retries - 1:
                    # Log error and return default
                    print(f"Redis error after {self.max_retries} attempts: {e}")
                    return default

                # Exponential backoff
                wait_time = self.backoff * (2 ** attempt)
                time.sleep(wait_time)

    def set_with_retry(self, key: str, value: str, ttl: int = None) -> bool:
        """Set value with retry logic."""
        for attempt in range(self.max_retries):
            try:
                if ttl:
                    return self.redis.setex(key, ttl, value)
                else:
                    return self.redis.set(key, value)
            except (ConnectionError, TimeoutError) as e:
                if attempt == self.max_retries - 1:
                    print(f"Redis error after {self.max_retries} attempts: {e}")
                    return False

                wait_time = self.backoff * (2 ** attempt)
                time.sleep(wait_time)
```

### Monitoring and Metrics

```python
def get_redis_info(section: str = None) -> dict:
    """Get Redis server information."""
    return r.info(section=section)

def monitor_memory_usage():
    """Monitor Redis memory usage."""
    info = r.info('memory')

    used_memory = info['used_memory_human']
    peak_memory = info['used_memory_peak_human']
    memory_fragmentation = info['mem_fragmentation_ratio']

    print(f"Used Memory: {used_memory}")
    print(f"Peak Memory: {peak_memory}")
    print(f"Fragmentation Ratio: {memory_fragmentation}")

    return info

def monitor_stats():
    """Monitor Redis statistics."""
    info = r.info('stats')

    total_connections = info['total_connections_received']
    total_commands = info['total_commands_processed']
    ops_per_sec = info['instantaneous_ops_per_sec']

    print(f"Total Connections: {total_connections}")
    print(f"Total Commands: {total_commands}")
    print(f"Ops/sec: {ops_per_sec}")

    return info

def get_slow_log(count: int = 10):
    """Get slow query log."""
    slow_log = r.slowlog_get(count)

    for entry in slow_log:
        print(f"Command: {entry['command']}")
        print(f"Duration: {entry['duration']} microseconds")
        print(f"Time: {entry['start_time']}")
        print("---")

    return slow_log
```

## Best Practices

### Key Naming Conventions

Use consistent, hierarchical naming:

```python
# Good naming patterns
user:123:profile              # User profile data
user:123:sessions:abc         # User session
cache:product:456             # Cached product
queue:emails:pending          # Email queue
lock:resource:789             # Resource lock
counter:api:requests:daily    # Daily API request counter
leaderboard:global:score      # Global leaderboard

# Avoid
u123                          # Too cryptic
user_profile_123              # Underscores less common
123:user                      # Wrong hierarchy
```

### Memory Management

```python
# Set TTL on all temporary data
r.setex("temp:data", 3600, value)  # Expires in 1 hour

# Limit collection sizes
r.lpush("activity_log", entry)
r.ltrim("activity_log", 0, 999)  # Keep only 1000 items

# Use appropriate data structures
# Hash is more memory-efficient than multiple keys
r.hset("user:123", mapping={"name": "Alice", "email": "alice@example.com"})
# vs
r.set("user:123:name", "Alice")
r.set("user:123:email", "alice@example.com")

# Monitor memory usage
if r.info('memory')['used_memory'] > threshold:
    # Implement eviction or cleanup
    cleanup_old_data()
```

### Security

```python
# Use authentication
r = redis.Redis(
    host='localhost',
    port=6379,
    password='your-secure-password',
    username='your-username'  # Redis 6+
)

# Use SSL/TLS for production
pool = redis.ConnectionPool(
    host='redis.example.com',
    port=6380,
    connection_class=redis.SSLConnection,
    ssl_cert_reqs='required',
    ssl_ca_certs='/path/to/ca-cert.pem'
)

# Credential provider pattern
from redis import UsernamePasswordCredentialProvider

creds_provider = UsernamePasswordCredentialProvider("username", "password")
r = redis.Redis(
    host="localhost",
    port=6379,
    credential_provider=creds_provider
)
```

### Testing

```python
import fakeredis
import pytest

@pytest.fixture
def redis_client():
    """Provide fake Redis client for testing."""
    return fakeredis.FakeRedis(decode_responses=True)

def test_caching(redis_client):
    """Test caching logic."""
    # Test cache miss
    assert redis_client.get("test_key") is None

    # Test cache set
    redis_client.setex("test_key", 60, "test_value")
    assert redis_client.get("test_key") == "test_value"

    # Test expiration
    assert redis_client.ttl("test_key") <= 60

def test_session_management(redis_client):
    """Test session operations."""
    session_manager = SessionManager(redis_client)

    # Create session
    session_id = session_manager.create_session(user_id=123)
    assert session_id is not None

    # Get session
    session = session_manager.get_session(session_id)
    assert session['user_id'] == 123

    # Delete session
    assert session_manager.delete_session(session_id) is True
    assert session_manager.get_session(session_id) is None
```

## Examples

### Example 1: User Session Management with Redis

```python
import redis
import json
import uuid
from datetime import datetime, timedelta

class UserSessionManager:
    """Complete user session management with Redis."""

    def __init__(self, redis_client: redis.Redis, ttl: int = 1800):
        self.redis = redis_client
        self.ttl = ttl

    def create_session(self, user_id: int, user_data: dict = None) -> str:
        """Create new user session."""
        session_id = str(uuid.uuid4())
        session_key = f"session:{session_id}"

        session_data = {
            "user_id": user_id,
            "created_at": datetime.utcnow().isoformat(),
            "last_accessed": datetime.utcnow().isoformat(),
            "data": user_data or {}
        }

        # Store session with TTL
        self.redis.setex(session_key, self.ttl, json.dumps(session_data))

        # Track user's active sessions
        self.redis.sadd(f"user:{user_id}:sessions", session_id)

        return session_id

    def get_session(self, session_id: str) -> dict:
        """Get session and refresh TTL."""
        session_key = f"session:{session_id}"
        session_data = self.redis.get(session_key)

        if session_data:
            session = json.loads(session_data)
            session['last_accessed'] = datetime.utcnow().isoformat()

            # Refresh TTL
            self.redis.setex(session_key, self.ttl, json.dumps(session))

            return session

        return None

    def delete_session(self, session_id: str) -> bool:
        """Delete session."""
        session = self.get_session(session_id)
        if not session:
            return False

        user_id = session['user_id']

        # Remove session
        self.redis.delete(f"session:{session_id}")

        # Remove from user's session set
        self.redis.srem(f"user:{user_id}:sessions", session_id)

        return True

    def delete_all_user_sessions(self, user_id: int):
        """Delete all sessions for a user."""
        sessions_key = f"user:{user_id}:sessions"
        session_ids = self.redis.smembers(sessions_key)

        for session_id in session_ids:
            self.redis.delete(f"session:{session_id}")

        self.redis.delete(sessions_key)

    def get_user_sessions(self, user_id: int) -> list:
        """Get all active sessions for a user."""
        sessions_key = f"user:{user_id}:sessions"
        session_ids = self.redis.smembers(sessions_key)

        sessions = []
        for session_id in session_ids:
            session = self.get_session(session_id)
            if session:
                session['session_id'] = session_id
                sessions.append(session)

        return sessions

# Usage
r = redis.Redis(decode_responses=True)
session_mgr = UserSessionManager(r)

# Create session
session_id = session_mgr.create_session(
    user_id=123,
    user_data={"role": "admin", "permissions": ["read", "write"]}
)

# Get session
session = session_mgr.get_session(session_id)
print(f"User ID: {session['user_id']}")

# List all user sessions
sessions = session_mgr.get_user_sessions(123)
print(f"Active sessions: {len(sessions)}")

# Logout (delete session)
session_mgr.delete_session(session_id)
```

### Example 2: Real-Time Leaderboard

```python
import redis
import time

class Leaderboard:
    """Real-time leaderboard using Redis sorted sets."""

    def __init__(self, redis_client: redis.Redis, name: str):
        self.redis = redis_client
        self.key = f"leaderboard:{name}"

    def add_score(self, player_id: str, score: float):
        """Add or update player score."""
        self.redis.zadd(self.key, {player_id: score})

    def increment_score(self, player_id: str, increment: float):
        """Increment player score."""
        self.redis.zincrby(self.key, increment, player_id)

    def get_top(self, count: int = 10) -> list:
        """Get top players."""
        # ZREVRANGE for highest scores first
        players = self.redis.zrevrange(self.key, 0, count - 1, withscores=True)

        return [
            {
                "rank": idx + 1,
                "player_id": player_id,
                "score": score
            }
            for idx, (player_id, score) in enumerate(players)
        ]

    def get_rank(self, player_id: str) -> dict:
        """Get player rank and score."""
        score = self.redis.zscore(self.key, player_id)
        if score is None:
            return None

        # ZREVRANK for rank (0-indexed, highest first)
        rank = self.redis.zrevrank(self.key, player_id)

        return {
            "player_id": player_id,
            "rank": rank + 1 if rank is not None else None,
            "score": score
        }

    def get_around(self, player_id: str, count: int = 5) -> list:
        """Get players around a specific player."""
        rank = self.redis.zrevrank(self.key, player_id)
        if rank is None:
            return []

        # Get players before and after
        start = max(0, rank - count)
        end = rank + count

        players = self.redis.zrevrange(self.key, start, end, withscores=True)

        return [
            {
                "rank": start + idx + 1,
                "player_id": pid,
                "score": score,
                "is_current": pid == player_id
            }
            for idx, (pid, score) in enumerate(players)
        ]

    def get_total_players(self) -> int:
        """Get total number of players."""
        return self.redis.zcard(self.key)

    def remove_player(self, player_id: str) -> bool:
        """Remove player from leaderboard."""
        return self.redis.zrem(self.key, player_id) > 0

# Usage
r = redis.Redis(decode_responses=True)
leaderboard = Leaderboard(r, "global")

# Add scores
leaderboard.add_score("alice", 1500)
leaderboard.add_score("bob", 2000)
leaderboard.add_score("charlie", 1800)
leaderboard.increment_score("alice", 200)  # alice now at 1700

# Get top 10
top_players = leaderboard.get_top(10)
for player in top_players:
    print(f"#{player['rank']}: {player['player_id']} - {player['score']}")

# Get player rank
alice_stats = leaderboard.get_rank("alice")
print(f"Alice is rank {alice_stats['rank']} with {alice_stats['score']} points")

# Get players around alice
nearby = leaderboard.get_around("alice", count=2)
for player in nearby:
    marker = " <-- YOU" if player['is_current'] else ""
    print(f"#{player['rank']}: {player['player_id']} - {player['score']}{marker}")
```

### Example 3: Distributed Rate Limiter

```python
import redis
import time

class RateLimiter:
    """Distributed rate limiter using Redis."""

    def __init__(self, redis_client: redis.Redis):
        self.redis = redis_client

        # Lua script for atomic rate limiting
        self.rate_limit_script = self.redis.register_script("""
            local key = KEYS[1]
            local limit = tonumber(ARGV[1])
            local window = tonumber(ARGV[2])

            local current = redis.call('INCR', key)

            if current == 1 then
                redis.call('EXPIRE', key, window)
            end

            if current > limit then
                return {0, limit, current - 1}
            else
                return {1, limit, current}
            end
        """)

    def check_rate_limit(self, identifier: str, limit: int, window: int) -> dict:
        """
        Check if request is within rate limit.

        Args:
            identifier: User ID, IP address, or API key
            limit: Maximum requests allowed
            window: Time window in seconds

        Returns:
            dict with allowed (bool), limit, current, remaining
        """
        key = f"rate_limit:{identifier}:{int(time.time() // window)}"

        allowed, max_limit, current = self.rate_limit_script(
            keys=[key],
            args=[limit, window]
        )

        return {
            "allowed": bool(allowed),
            "limit": max_limit,
            "current": current,
            "remaining": max(0, max_limit - current),
            "reset_at": (int(time.time() // window) + 1) * window
        }

    def sliding_window_check(self, identifier: str, limit: int, window: int) -> dict:
        """
        Sliding window rate limiter using sorted sets.
        More accurate but slightly more expensive.
        """
        key = f"rate_limit:sliding:{identifier}"
        now = time.time()
        window_start = now - window

        # Remove old entries
        self.redis.zremrangebyscore(key, 0, window_start)

        # Count current requests
        current = self.redis.zcard(key)

        if current < limit:
            # Add new request
            self.redis.zadd(key, {str(now): now})
            self.redis.expire(key, window)

            return {
                "allowed": True,
                "limit": limit,
                "current": current + 1,
                "remaining": limit - current - 1
            }
        else:
            return {
                "allowed": False,
                "limit": limit,
                "current": current,
                "remaining": 0
            }

# Usage
r = redis.Redis(decode_responses=True)
limiter = RateLimiter(r)

# API rate limiting: 100 requests per minute
user_id = "user_123"
result = limiter.check_rate_limit(user_id, limit=100, window=60)

if result["allowed"]:
    print(f"Request allowed. {result['remaining']} requests remaining.")
    # Process request
else:
    print(f"Rate limit exceeded. Try again at {result['reset_at']}")
    # Return 429 Too Many Requests

# More accurate sliding window
result = limiter.sliding_window_check(user_id, limit=100, window=60)
```

### Example 4: Distributed Job Queue

```python
import redis
import json
import time
import uuid
from typing import Optional, Callable

class JobQueue:
    """Distributed job queue with Redis."""

    def __init__(self, redis_client: redis.Redis, queue_name: str = "default"):
        self.redis = redis_client
        self.queue_name = queue_name
        self.queue_key = f"queue:{queue_name}"
        self.processing_key = f"queue:{queue_name}:processing"

    def enqueue(self, job_type: str, payload: dict, priority: int = 0) -> str:
        """
        Add job to queue.

        Args:
            job_type: Type of job (for routing to workers)
            payload: Job data
            priority: Higher priority = processed first (0 = normal)

        Returns:
            job_id
        """
        job_id = str(uuid.uuid4())

        job_data = {
            "id": job_id,
            "type": job_type,
            "payload": payload,
            "enqueued_at": time.time(),
            "attempts": 0
        }

        # Add to queue (use ZADD for priority queue)
        score = -priority  # Negative for higher priority first
        self.redis.zadd(self.queue_key, {json.dumps(job_data): score})

        return job_id

    def dequeue(self, timeout: int = 0) -> Optional[dict]:
        """
        Get next job from queue.

        Args:
            timeout: Block for this many seconds (0 = no blocking)

        Returns:
            Job data or None
        """
        # Get highest priority job (lowest score)
        jobs = self.redis.zrange(self.queue_key, 0, 0)

        if not jobs:
            if timeout > 0:
                time.sleep(min(timeout, 1))
                return self.dequeue(timeout - 1)
            return None

        job_json = jobs[0]

        # Move to processing set atomically
        pipe = self.redis.pipeline()
        pipe.zrem(self.queue_key, job_json)
        pipe.zadd(self.processing_key, {job_json: time.time()})
        pipe.execute()

        job_data = json.loads(job_json)
        job_data['attempts'] += 1

        return job_data

    def complete(self, job_data: dict):
        """Mark job as completed."""
        job_json = json.dumps({
            k: v for k, v in job_data.items()
            if k != 'attempts'
        })

        # Remove from processing
        self.redis.zrem(self.processing_key, job_json)

    def retry(self, job_data: dict, delay: int = 0):
        """Retry failed job."""
        job_json = json.dumps({
            k: v for k, v in job_data.items()
            if k != 'attempts'
        })

        # Remove from processing
        self.redis.zrem(self.processing_key, job_json)

        # Re-enqueue with delay
        if delay > 0:
            time.sleep(delay)

        self.redis.zadd(self.queue_key, {job_json: 0})

    def get_stats(self) -> dict:
        """Get queue statistics."""
        return {
            "queued": self.redis.zcard(self.queue_key),
            "processing": self.redis.zcard(self.processing_key)
        }

# Worker example
class Worker:
    """Job worker."""

    def __init__(self, queue: JobQueue, handlers: dict):
        self.queue = queue
        self.handlers = handlers

    def process_jobs(self):
        """Process jobs from queue."""
        print("Worker started. Waiting for jobs...")

        while True:
            job = self.queue.dequeue(timeout=5)

            if job:
                print(f"Processing job {job['id']} (type: {job['type']})")

                try:
                    # Get handler for job type
                    handler = self.handlers.get(job['type'])

                    if handler:
                        handler(job['payload'])
                        self.queue.complete(job)
                        print(f"Job {job['id']} completed")
                    else:
                        print(f"No handler for job type: {job['type']}")
                        self.queue.complete(job)

                except Exception as e:
                    print(f"Job {job['id']} failed: {e}")

                    if job['attempts'] < 3:
                        # Retry with exponential backoff
                        delay = 2 ** job['attempts']
                        print(f"Retrying in {delay}s...")
                        self.queue.retry(job, delay=delay)
                    else:
                        print(f"Job {job['id']} failed permanently")
                        self.queue.complete(job)

# Usage
r = redis.Redis(decode_responses=True)
queue = JobQueue(r, "email_queue")

# Enqueue jobs
job_id = queue.enqueue("send_email", {
    "to": "user@example.com",
    "subject": "Welcome!",
    "body": "Thanks for signing up."
}, priority=1)

# Define handlers
def send_email_handler(payload):
    print(f"Sending email to {payload['to']}")
    # Email sending logic here
    time.sleep(1)  # Simulate work

handlers = {
    "send_email": send_email_handler
}

# Start worker
worker = Worker(queue, handlers)
# worker.process_jobs()  # This blocks - run in separate process
```

### Example 5: Real-Time Event Streaming

```python
import redis
import json
import time
from typing import Callable, Optional

class EventStream:
    """Real-time event streaming with Redis Streams."""

    def __init__(self, redis_client: redis.Redis, stream_name: str):
        self.redis = redis_client
        self.stream_name = stream_name

    def publish(self, event_type: str, data: dict) -> str:
        """Publish event to stream."""
        event = {
            "type": event_type,
            "data": json.dumps(data),
            "timestamp": time.time()
        }

        # Add to stream (returns auto-generated ID)
        event_id = self.redis.xadd(self.stream_name, event, maxlen=10000)
        return event_id

    def read_events(self, last_id: str = '0', count: int = 10) -> list:
        """Read events from stream."""
        events = self.redis.xread(
            {self.stream_name: last_id},
            count=count,
            block=1000  # 1 second timeout
        )

        if not events:
            return []

        _, event_list = events[0]

        return [
            {
                "id": event_id,
                "type": event_data[b'type'].decode(),
                "data": json.loads(event_data[b'data'].decode()),
                "timestamp": float(event_data[b'timestamp'])
            }
            for event_id, event_data in event_list
        ]

    def create_consumer_group(self, group_name: str):
        """Create consumer group for parallel processing."""
        try:
            self.redis.xgroup_create(
                name=self.stream_name,
                groupname=group_name,
                id='0',
                mkstream=True
            )
        except redis.ResponseError as e:
            if "BUSYGROUP" not in str(e):
                raise

    def consume_events(self, group_name: str, consumer_name: str,
                      count: int = 10) -> list:
        """Consume events as part of consumer group."""
        events = self.redis.xreadgroup(
            groupname=group_name,
            consumername=consumer_name,
            streams={self.stream_name: '>'},
            count=count,
            block=5000
        )

        if not events:
            return []

        _, event_list = events[0]

        return [
            {
                "id": event_id,
                "type": event_data[b'type'].decode(),
                "data": json.loads(event_data[b'data'].decode()),
                "timestamp": float(event_data[b'timestamp'])
            }
            for event_id, event_data in event_list
        ]

    def acknowledge(self, group_name: str, event_id: str):
        """Acknowledge processed event."""
        self.redis.xack(self.stream_name, group_name, event_id)

    def get_pending(self, group_name: str) -> list:
        """Get pending (unacknowledged) events."""
        pending = self.redis.xpending_range(
            name=self.stream_name,
            groupname=group_name,
            min='-',
            max='+',
            count=100
        )

        return pending

# Usage Example: Activity Feed
r = redis.Redis()
activity_stream = EventStream(r, "user_activity")

# Publish events
activity_stream.publish("user_signup", {
    "user_id": 123,
    "email": "alice@example.com"
})

activity_stream.publish("post_created", {
    "user_id": 123,
    "post_id": 456,
    "title": "My First Post"
})

# Read events (simple consumer)
last_id = '0'
while True:
    events = activity_stream.read_events(last_id, count=10)

    for event in events:
        print(f"Event: {event['type']}")
        print(f"Data: {event['data']}")
        last_id = event['id']

    if not events:
        break

# Consumer group example
activity_stream.create_consumer_group("processors")

# Worker consuming events
while True:
    events = activity_stream.consume_events(
        group_name="processors",
        consumer_name="worker-1",
        count=10
    )

    for event in events:
        try:
            # Process event
            process_event(event)

            # Acknowledge
            activity_stream.acknowledge("processors", event['id'])
        except Exception as e:
            print(f"Failed to process event {event['id']}: {e}")
            # Event remains unacknowledged for retry
```

### Example 6: Cache-Aside Pattern with Multi-Level Caching

```python
import redis
import json
import hashlib
from typing import Optional, Any, Callable

class MultiLevelCache:
    """Multi-level caching with Redis and local cache."""

    def __init__(self, redis_client: redis.Redis,
                 local_cache_size: int = 100,
                 local_ttl: int = 60,
                 redis_ttl: int = 3600):
        self.redis = redis_client
        self.local_cache = {}
        self.local_cache_size = local_cache_size
        self.local_ttl = local_ttl
        self.redis_ttl = redis_ttl

    def _make_key(self, namespace: str, key: str) -> str:
        """Generate cache key."""
        return f"cache:{namespace}:{key}"

    def get(self, namespace: str, key: str,
            compute_fn: Optional[Callable] = None) -> Optional[Any]:
        """
        Get value from cache with fallback to compute function.

        Lookup order: Local cache → Redis → Compute function
        """
        cache_key = self._make_key(namespace, key)

        # Level 1: Local cache
        if cache_key in self.local_cache:
            entry = self.local_cache[cache_key]
            if time.time() < entry['expires_at']:
                return entry['value']
            else:
                del self.local_cache[cache_key]

        # Level 2: Redis cache
        redis_value = self.redis.get(cache_key)
        if redis_value:
            value = json.loads(redis_value)

            # Populate local cache
            self._set_local(cache_key, value)

            return value

        # Level 3: Compute function
        if compute_fn:
            value = compute_fn()
            if value is not None:
                self.set(namespace, key, value)
            return value

        return None

    def set(self, namespace: str, key: str, value: Any):
        """Set value in both cache levels."""
        cache_key = self._make_key(namespace, key)
        serialized = json.dumps(value)

        # Set in Redis
        self.redis.setex(cache_key, self.redis_ttl, serialized)

        # Set in local cache
        self._set_local(cache_key, value)

    def _set_local(self, key: str, value: Any):
        """Set value in local cache with LRU eviction."""
        # Simple LRU: remove oldest if at capacity
        if len(self.local_cache) >= self.local_cache_size:
            # Remove oldest entry
            oldest_key = min(
                self.local_cache.keys(),
                key=lambda k: self.local_cache[k]['expires_at']
            )
            del self.local_cache[oldest_key]

        self.local_cache[key] = {
            'value': value,
            'expires_at': time.time() + self.local_ttl
        }

    def delete(self, namespace: str, key: str):
        """Delete from all cache levels."""
        cache_key = self._make_key(namespace, key)

        # Delete from Redis
        self.redis.delete(cache_key)

        # Delete from local cache
        if cache_key in self.local_cache:
            del self.local_cache[cache_key]

    def invalidate_namespace(self, namespace: str):
        """Invalidate all keys in namespace."""
        pattern = f"cache:{namespace}:*"

        # Delete from Redis
        for key in self.redis.scan_iter(match=pattern, count=100):
            self.redis.delete(key)

        # Delete from local cache
        to_delete = [
            k for k in self.local_cache.keys()
            if k.startswith(f"cache:{namespace}:")
        ]
        for k in to_delete:
            del self.local_cache[k]

# Usage
r = redis.Redis(decode_responses=True)
cache = MultiLevelCache(r)

def get_user(user_id: int) -> dict:
    """Get user with multi-level caching."""
    return cache.get(
        namespace="users",
        key=str(user_id),
        compute_fn=lambda: database.query_user(user_id)
    )

# First call: Queries database, caches result
user = get_user(123)

# Second call: Returns from local cache (fastest)
user = get_user(123)

# Update user
def update_user(user_id: int, data: dict):
    database.update_user(user_id, data)

    # Invalidate cache
    cache.delete("users", str(user_id))

# Invalidate all user caches
cache.invalidate_namespace("users")
```

### Example 7: Geo-Location with Redis

```python
import redis

class GeoLocation:
    """Geo-spatial indexing and queries with Redis."""

    def __init__(self, redis_client: redis.Redis, index_name: str):
        self.redis = redis_client
        self.key = f"geo:{index_name}"

    def add_location(self, location_id: str, longitude: float, latitude: float):
        """Add location to geo index."""
        self.redis.geoadd(self.key, longitude, latitude, location_id)

    def add_locations(self, locations: list):
        """Batch add locations.

        Args:
            locations: List of (location_id, longitude, latitude) tuples
        """
        self.redis.geoadd(self.key, *[
            item for loc in locations
            for item in (loc[1], loc[2], loc[0])
        ])

    def get_position(self, location_id: str) -> tuple:
        """Get coordinates of a location."""
        result = self.redis.geopos(self.key, location_id)
        if result and result[0]:
            return result[0]  # (longitude, latitude)
        return None

    def find_nearby(self, longitude: float, latitude: float,
                   radius: float, unit: str = 'km', count: int = None) -> list:
        """
        Find locations within radius.

        Args:
            longitude: Center longitude
            latitude: Center latitude
            radius: Search radius
            unit: Distance unit ('m', 'km', 'mi', 'ft')
            count: Maximum results
        """
        args = {
            'longitude': longitude,
            'latitude': latitude,
            'radius': radius,
            'unit': unit,
            'withdist': True,
            'withcoord': True,
            'sort': 'ASC'
        }

        if count:
            args['count'] = count

        results = self.redis.georadius(self.key, **args)

        return [
            {
                'location_id': location_id,
                'distance': distance,
                'coordinates': (longitude, latitude)
            }
            for location_id, distance, (longitude, latitude) in results
        ]

    def find_nearby_member(self, location_id: str, radius: float,
                          unit: str = 'km', count: int = None) -> list:
        """Find locations near an existing member."""
        args = {
            'member': location_id,
            'radius': radius,
            'unit': unit,
            'withdist': True,
            'sort': 'ASC'
        }

        if count:
            args['count'] = count

        results = self.redis.georadiusbymember(self.key, **args)

        return [
            {
                'location_id': loc_id,
                'distance': distance
            }
            for loc_id, distance in results
            if loc_id != location_id  # Exclude self
        ]

    def distance_between(self, location_id1: str, location_id2: str,
                        unit: str = 'km') -> float:
        """Calculate distance between two locations."""
        return self.redis.geodist(self.key, location_id1, location_id2, unit)

# Usage Example: Restaurant finder
r = redis.Redis(decode_responses=True)
restaurants = GeoLocation(r, "restaurants")

# Add restaurants
restaurants.add_locations([
    ("rest1", -122.4194, 37.7749),  # San Francisco
    ("rest2", -122.4068, 37.7849),
    ("rest3", -122.4312, 37.7652),
])

# Find restaurants near coordinates
nearby = restaurants.find_nearby(
    longitude=-122.4194,
    latitude=37.7749,
    radius=5,
    unit='km',
    count=10
)

for restaurant in nearby:
    print(f"{restaurant['location_id']}: {restaurant['distance']:.2f} km away")

# Find restaurants near a specific restaurant
similar = restaurants.find_nearby_member("rest1", radius=2, unit='km')

# Get distance between two restaurants
distance = restaurants.distance_between("rest1", "rest2", unit='km')
print(f"Distance: {distance:.2f} km")
```

## Quick Reference

### Common Operations

```python
# Connection
r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

# Strings
r.set('key', 'value')
r.setex('key', 3600, 'value')  # With TTL
r.get('key')
r.incr('counter')

# Hashes
r.hset('user:123', 'name', 'Alice')
r.hset('user:123', mapping={'name': 'Alice', 'age': 30})
r.hget('user:123', 'name')
r.hgetall('user:123')

# Lists
r.lpush('queue', 'item')
r.rpush('queue', 'item')
r.lpop('queue')
r.lrange('queue', 0, -1)

# Sets
r.sadd('tags', 'python', 'redis')
r.smembers('tags')
r.sismember('tags', 'python')

# Sorted Sets
r.zadd('leaderboard', {'alice': 100, 'bob': 200})
r.zrange('leaderboard', 0, -1, withscores=True)
r.zrank('leaderboard', 'alice')

# Expiration
r.expire('key', 3600)
r.ttl('key')

# Pipelining
pipe = r.pipeline()
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
results = pipe.execute()
```

### Time Complexity

- GET, SET: O(1)
- HGET, HSET: O(1)
- LPUSH, RPUSH, LPOP, RPOP: O(1)
- SADD, SREM, SISMEMBER: O(1)
- ZADD, ZREM: O(log(N))
- ZRANGE, ZREVRANGE: O(log(N)+M) where M is result size
- SCAN, SSCAN, HSCAN, ZSCAN: O(1) per iteration

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: State Management, Distributed Systems, Performance Optimization
**Compatible With**: redis-py, Redis 6.0+, Redis 7.0+
