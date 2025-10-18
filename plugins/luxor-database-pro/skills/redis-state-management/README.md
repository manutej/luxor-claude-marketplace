# Redis State Management Skill

> **Master Redis for high-performance state management in distributed systems**

This comprehensive skill provides everything you need to implement production-ready Redis patterns for caching, sessions, pub/sub messaging, distributed locks, and complex data structures.

## What is Redis?

Redis (Remote Dictionary Server) is an open-source, in-memory data structure store that can be used as a database, cache, message broker, and streaming engine. It provides microsecond-level performance, rich data structures, and built-in replication and persistence.

## Why This Skill?

Modern applications require:
- **Fast data access**: Sub-millisecond response times
- **Distributed state**: Shared state across multiple servers
- **Real-time features**: Live updates, notifications, messaging
- **Scalability**: Handle millions of operations per second
- **Reliability**: Data persistence and high availability

Redis solves these challenges elegantly, and this skill teaches you how to use it effectively.

## Core Use Cases

### 1. **Caching**
Dramatically improve application performance by caching frequently accessed data:
- Page caching for web applications
- API response caching
- Database query result caching
- Computed value caching
- Session storage

**Performance Impact**: Reduce database load by 80-95%, decrease response times from seconds to milliseconds.

### 2. **Session Management**
Store and manage user sessions in distributed environments:
- Web application sessions
- Mobile app sessions
- API authentication tokens
- User preference storage
- Shopping cart data

**Benefits**: Share sessions across multiple servers, automatic expiration, fast access.

### 3. **Real-Time Messaging**
Build real-time features with pub/sub patterns:
- Live chat applications
- Notification systems
- Event broadcasting
- Activity feeds
- Real-time dashboards

**Capabilities**: Fan-out messaging, pattern matching, consumer groups for parallel processing.

### 4. **Distributed Locking**
Coordinate distributed processes safely:
- Prevent duplicate job execution
- Ensure single-instance operations
- Coordinate resource access
- Implement critical sections
- Handle distributed transactions

**Reliability**: Redlock algorithm support, automatic lock expiration, deadlock prevention.

### 5. **Data Structures**
Leverage Redis's rich data types:
- **Leaderboards**: Sorted sets for rankings
- **Counters**: Atomic increment/decrement
- **Queues**: Reliable job queues
- **Tags**: Set operations for filtering
- **Time series**: Sorted sets with timestamps
- **Geospatial**: Location-based queries

## Key Features Covered

### Caching Strategies
- **Cache-aside** (lazy loading): Load data on demand
- **Write-through**: Update cache on writes
- **Write-behind**: Async database updates
- **Cache invalidation**: Smart expiration patterns
- **Multi-level caching**: Local + Redis caching

### Session Patterns
- Distributed session storage
- Sliding expiration windows
- Session tracking across devices
- User activity logging
- Concurrent session management

### Pub/Sub Messaging
- Channel subscriptions
- Pattern-based subscriptions
- Message handlers and callbacks
- Background thread processing
- Async/await support
- Sharded pub/sub for scaling

### Distributed Locks
- Simple lock implementation
- Auto-renewing locks
- Redlock algorithm (multiple Redis instances)
- Deadlock prevention
- Lock timeouts and recovery

### Performance Optimization
- Connection pooling
- Pipelining for batch operations
- Transactions with WATCH
- Lua scripts for atomic operations
- RESP3 protocol with client-side caching

### Production Patterns
- High availability with Sentinel
- Redis Cluster for horizontal scaling
- SSL/TLS encryption
- Authentication and security
- Error handling and retries
- Monitoring and metrics

## When to Use This Skill

Use this skill when you're:

✅ Building web applications that need to scale
✅ Implementing user authentication and sessions
✅ Adding real-time features to your application
✅ Optimizing database performance with caching
✅ Building microservices that need shared state
✅ Implementing rate limiting or throttling
✅ Creating leaderboards, counters, or analytics
✅ Coordinating distributed processes
✅ Building job queues or task schedulers
✅ Implementing geospatial features

## Quick Start

### Basic Setup

```python
import redis

# Connect to Redis
r = redis.Redis(
    host='localhost',
    port=6379,
    db=0,
    decode_responses=True  # Auto-decode bytes to strings
)

# Test connection
r.ping()  # Returns True if connected
```

### Simple Caching Example

```python
import json

def get_user(user_id: int) -> dict:
    """Get user with caching."""
    cache_key = f"user:{user_id}"

    # Try cache first
    cached = r.get(cache_key)
    if cached:
        return json.loads(cached)

    # Cache miss - load from database
    user = database.get_user(user_id)

    # Cache for 1 hour
    r.setex(cache_key, 3600, json.dumps(user))

    return user
```

### Session Management Example

```python
import uuid

def create_session(user_id: int) -> str:
    """Create user session."""
    session_id = str(uuid.uuid4())
    session_key = f"session:{session_id}"

    session_data = {
        "user_id": user_id,
        "created_at": time.time()
    }

    # Store session with 30 minute TTL
    r.setex(session_key, 1800, json.dumps(session_data))

    return session_id

def get_session(session_id: str) -> dict:
    """Get session and refresh TTL."""
    session_key = f"session:{session_id}"
    session_data = r.get(session_key)

    if session_data:
        # Refresh TTL on access (sliding expiration)
        r.expire(session_key, 1800)
        return json.loads(session_data)

    return None
```

### Pub/Sub Example

```python
# Publisher
def publish_notification(user_id: int, message: str):
    """Publish notification."""
    channel = f"user:{user_id}:notifications"
    r.publish(channel, json.dumps({
        "message": message,
        "timestamp": time.time()
    }))

# Subscriber
def listen_for_notifications(user_id: int):
    """Listen for user notifications."""
    pubsub = r.pubsub()
    channel = f"user:{user_id}:notifications"
    pubsub.subscribe(channel)

    for message in pubsub.listen():
        if message['type'] == 'message':
            data = json.loads(message['data'])
            print(f"Notification: {data['message']}")
```

### Distributed Lock Example

```python
import time
import uuid

def acquire_lock(resource_id: str, timeout: int = 10) -> str:
    """Acquire distributed lock."""
    lock_key = f"lock:{resource_id}"
    identifier = str(uuid.uuid4())

    # Try to acquire lock
    if r.set(lock_key, identifier, nx=True, ex=timeout):
        return identifier

    return None

def release_lock(resource_id: str, identifier: str) -> bool:
    """Release lock if we own it."""
    lock_key = f"lock:{resource_id}"

    # Use Lua script for atomic check-and-delete
    lua_script = """
    if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
    else
        return 0
    end
    """

    result = r.eval(lua_script, 1, lock_key, identifier)
    return result == 1

# Usage
lock_id = acquire_lock("resource:123")
if lock_id:
    try:
        # Critical section - only one process at a time
        process_resource()
    finally:
        release_lock("resource:123", lock_id)
```

## Data Structure Examples

### Leaderboard (Sorted Set)

```python
# Add scores
r.zadd('leaderboard', {'alice': 1500, 'bob': 2000, 'charlie': 1800})

# Get top 10 players (highest scores first)
top_players = r.zrevrange('leaderboard', 0, 9, withscores=True)

# Get player rank
rank = r.zrevrank('leaderboard', 'alice')  # 0-indexed

# Get player score
score = r.zscore('leaderboard', 'alice')

# Increment score
r.zincrby('leaderboard', 100, 'alice')
```

### Job Queue (List)

```python
# Add job to queue
r.rpush('job_queue', json.dumps({
    'type': 'send_email',
    'data': {'to': 'user@example.com'}
}))

# Process jobs (blocking)
while True:
    # Block for up to 5 seconds waiting for job
    result = r.blpop('job_queue', timeout=5)
    if result:
        _, job_data = result
        job = json.loads(job_data)
        process_job(job)
```

### Tags (Set)

```python
# Add tags to post
r.sadd('post:123:tags', 'python', 'redis', 'tutorial')

# Get all tags
tags = r.smembers('post:123:tags')

# Check if tag exists
has_tag = r.sismember('post:123:tags', 'python')

# Find common tags between posts
common = r.sinter('post:123:tags', 'post:456:tags')
```

### User Profile (Hash)

```python
# Set user profile
r.hset('user:123', mapping={
    'name': 'Alice',
    'email': 'alice@example.com',
    'age': '30'
})

# Get single field
name = r.hget('user:123', 'name')

# Get all fields
profile = r.hgetall('user:123')

# Increment field
r.hincrby('user:123', 'login_count', 1)
```

## Architecture Patterns

### Microservices with Redis

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Service A  │◄────►│    Redis    │◄────►│  Service B  │
│   (API)     │      │   (State)   │      │  (Worker)   │
└─────────────┘      └─────────────┘      └─────────────┘
       │                     │                     │
       │                     │                     │
       ▼                     ▼                     ▼
  Web Clients          Pub/Sub Events       Background Jobs
```

**Benefits:**
- Shared session storage across services
- Inter-service communication via pub/sub
- Centralized caching layer
- Distributed job queues
- Real-time event distribution

### Cache Hierarchy

```
Client Request
       │
       ▼
┌─────────────┐
│ Local Cache │ ◄── In-memory (LRU)
└──────┬──────┘
       │ miss
       ▼
┌─────────────┐
│   Redis     │ ◄── Distributed cache
└──────┬──────┘
       │ miss
       ▼
┌─────────────┐
│  Database   │ ◄── Source of truth
└─────────────┘
```

**Latency:**
- Local: <1ms
- Redis: 1-5ms
- Database: 10-100ms+

## Performance Considerations

### Do's ✅
- Use connection pools
- Enable pipelining for batch operations
- Set appropriate TTLs on all keys
- Use Lua scripts for complex atomic operations
- Monitor memory usage
- Implement proper error handling
- Use compression for large values
- Leverage appropriate data structures

### Don'ts ❌
- Don't use Redis as primary database (unless using persistence)
- Don't store very large values (>1MB)
- Don't use KEYS command in production (use SCAN)
- Don't forget to set expiration on temporary data
- Don't use blocking operations in web requests
- Don't ignore connection pool configuration
- Don't bypass connection pooling
- Don't store sensitive data without encryption

## Production Checklist

- [ ] Configure connection pooling
- [ ] Set up Redis persistence (RDB/AOF)
- [ ] Enable authentication
- [ ] Configure SSL/TLS for production
- [ ] Set up Redis Sentinel for HA
- [ ] Implement proper error handling
- [ ] Configure memory limits and eviction policies
- [ ] Set up monitoring and alerting
- [ ] Plan backup and recovery strategy
- [ ] Document key naming conventions
- [ ] Implement rate limiting for Redis operations
- [ ] Test failover scenarios

## Common Patterns at a Glance

| Pattern | Use Case | Data Structure |
|---------|----------|----------------|
| Cache-aside | API responses, computed values | String |
| Session store | User sessions, shopping carts | Hash/String |
| Leaderboard | Rankings, high scores | Sorted Set |
| Rate limiting | API throttling, abuse prevention | String + TTL |
| Job queue | Background tasks, async processing | List |
| Pub/Sub | Real-time notifications, chat | Pub/Sub |
| Distributed lock | Resource coordination | String + Lua |
| Activity feed | Recent activities, timeline | List/Stream |
| Tags/Categories | Filtering, search | Set |
| Counters | Views, likes, analytics | String (INCR) |
| Geospatial | Location search, nearby | Geo |
| Time series | Metrics, events | Sorted Set/Stream |

## Learning Path

1. **Basics** (Start here)
   - Connect to Redis
   - Basic string operations
   - Understanding TTL and expiration
   - Simple caching patterns

2. **Intermediate**
   - Hash, List, Set operations
   - Session management
   - Pub/Sub messaging
   - Connection pooling

3. **Advanced**
   - Distributed locks
   - Transactions and Lua scripts
   - Pipelining and performance
   - Redis Streams
   - Cluster and Sentinel

4. **Production**
   - High availability setup
   - Monitoring and metrics
   - Security and encryption
   - Backup and disaster recovery

## Additional Resources

- **SKILL.md**: Complete technical reference with all patterns
- **EXAMPLES.md**: 15+ detailed real-world examples
- [Redis Documentation](https://redis.io/docs/)
- [redis-py GitHub](https://github.com/redis/redis-py)
- [Redis University](https://university.redis.com/)
- [Redis Commands Reference](https://redis.io/commands/)

## Getting Help

For questions or issues:
1. Check SKILL.md for detailed pattern documentation
2. Review EXAMPLES.md for similar use cases
3. Consult redis-py documentation
4. Search Redis Stack Overflow questions

---

**Ready to build high-performance applications?** Start with the Quick Start examples above, then dive into SKILL.md for comprehensive patterns and EXAMPLES.md for real-world implementations.
