# Psycopg Skill - Customer Support Tech Enablement

## Introduction

Welcome to the **Psycopg Skill** for customer support technical enablement! This skill provides comprehensive guidance on using psycopg, the most popular PostgreSQL adapter for Python, in customer support contexts including data analysis, bulk operations, backend support tools, and database migrations.

## What is Psycopg?

Psycopg is the most widely used PostgreSQL database adapter for Python. It implements the Python Database API 2.0 specification and provides a robust, efficient, and feature-rich interface for PostgreSQL databases.

### Key Benefits for Customer Support Teams

1. **High Performance**: Optimized C implementation for fast data processing
2. **Connection Pooling**: Built-in support for handling multiple concurrent requests
3. **Async Support**: Native asyncio integration for modern Python applications
4. **Bulk Operations**: COPY protocol support for efficient data migration
5. **Type Safety**: Comprehensive Python type hints for better IDE support
6. **Security**: Parameterized queries prevent SQL injection attacks
7. **Reliability**: Battle-tested in production environments worldwide

## Why Psycopg3?

Psycopg3 is the latest major version with significant improvements over psycopg2:

- **Better async support**: Native asyncio implementation (not bolt-on)
- **Improved performance**: Up to 20-30% faster in many scenarios
- **Built-in connection pooling**: No need for external packages
- **Pipeline mode**: Send multiple queries without waiting for responses
- **Better type system**: More flexible and extensible
- **Modern Python**: Fully leverages Python 3.7+ features

## Installation

### Quick Start

For most customer support applications, install with all features:

```bash
# Complete installation with binary package and pooling
pip install "psycopg[binary,pool]"
```

### Installation Options

```bash
# Basic installation (pure Python)
pip install psycopg

# With binary package for better performance
pip install "psycopg[binary]"

# With connection pool support
pip install "psycopg[pool]"

# With C implementation (fastest, requires build tools)
pip install "psycopg[c]"

# Complete installation
pip install "psycopg[binary,pool,c]"
```

### Verify Installation

```python
import psycopg
print(psycopg.__version__)  # Should show 3.x.x

# Check connection
try:
    conn = psycopg.connect("postgresql://localhost/postgres")
    print("Connection successful!")
    conn.close()
except Exception as e:
    print(f"Connection failed: {e}")
```

## Quick Start Guide

### Basic Connection

```python
import psycopg

# Connect to PostgreSQL
with psycopg.connect(
    host="localhost",
    port=5432,
    dbname="support_db",
    user="support_user",
    password="your_password"
) as conn:
    # Create a cursor
    with conn.cursor() as cur:
        # Execute a query
        cur.execute("SELECT COUNT(*) FROM tickets WHERE status = %s", ('open',))
        count = cur.fetchone()[0]
        print(f"Open tickets: {count}")
```

### Using Connection Pool

```python
from psycopg_pool import ConnectionPool

# Create a global pool
pool = ConnectionPool(
    "postgresql://user:password@localhost/support_db",
    min_size=2,
    max_size=10
)

# Use in your application
def get_customer_info(customer_id):
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT name, email FROM customers WHERE customer_id = %s",
                (customer_id,)
            )
            return cur.fetchone()
```

### Async Operations

```python
import asyncio
import psycopg

async def fetch_tickets():
    async with await psycopg.AsyncConnection.connect(
        "postgresql://user:password@localhost/support_db"
    ) as conn:
        async with conn.cursor() as cur:
            await cur.execute("SELECT ticket_id, subject FROM tickets LIMIT 10")
            tickets = await cur.fetchall()
            return tickets

# Run the async function
tickets = asyncio.run(fetch_tickets())
print(tickets)
```

## Architecture Overview

### Components

```
┌─────────────────────────────────────────────────────────┐
│                  Your Application                       │
└─────────────────────┬───────────────────────────────────┘
                      │
          ┌───────────┴──────────┐
          │                      │
┌─────────▼────────┐   ┌────────▼──────────┐
│  psycopg         │   │  psycopg_pool     │
│  (Core Library)  │   │  (Connection Pool)│
└─────────┬────────┘   └────────┬──────────┘
          │                     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │    libpq            │
          │  (PostgreSQL C API) │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │  PostgreSQL Server  │
          └─────────────────────┘
```

### Key Classes

- **Connection**: Represents a database session
- **Cursor**: Executes queries and fetches results
- **ConnectionPool**: Manages multiple connections efficiently
- **AsyncConnection**: Async version of Connection
- **AsyncCursor**: Async version of Cursor

## Configuration

### Environment Variables

Create a `.env` file for configuration:

```bash
# Production database (read-only for support)
DB_HOST=prod-db.company.com
DB_PORT=5432
DB_NAME=support_analytics
DB_USER=support_readonly
DB_PASSWORD=secure_password

# Connection pool settings
POOL_MIN_SIZE=5
POOL_MAX_SIZE=20
POOL_TIMEOUT=30

# Application settings
LOG_LEVEL=INFO
```

### Loading Configuration

```python
from dotenv import load_dotenv
import os

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 5432)),
    'dbname': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
}

POOL_CONFIG = {
    'min_size': int(os.getenv('POOL_MIN_SIZE', 2)),
    'max_size': int(os.getenv('POOL_MAX_SIZE', 10)),
    'timeout': int(os.getenv('POOL_TIMEOUT', 30)),
}
```

## Common Use Cases in Customer Support

### 1. Ticket Analytics

```python
def get_ticket_metrics(days=7):
    """Get ticket metrics for the last N days."""
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    status,
                    COUNT(*) as count,
                    AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600) as avg_hours
                FROM tickets
                WHERE created_at > NOW() - INTERVAL '%s days'
                GROUP BY status
            """, (days,))
            return cur.fetchall()
```

### 2. Customer Data Export

```python
def export_customer_data(customer_id, output_file):
    """Export all customer data to CSV."""
    with pool.connection() as conn:
        with conn.cursor() as cur:
            query = """
                SELECT t.ticket_id, t.subject, t.status, t.created_at
                FROM tickets t
                WHERE t.customer_id = %s
                ORDER BY t.created_at DESC
            """
            with cur.copy(f"COPY ({query}) TO STDOUT CSV HEADER") as copy:
                with open(output_file, 'w') as f:
                    for data in copy:
                        f.write(data)
```

### 3. Bulk Data Migration

```python
def migrate_tickets_from_csv(csv_file):
    """Migrate tickets from CSV file."""
    with pool.connection() as conn:
        with conn.cursor() as cur:
            with open(csv_file, 'r') as f:
                with cur.copy(
                    "COPY tickets (customer_id, subject, description) FROM STDIN CSV HEADER"
                ) as copy:
                    copy.write(f.read())
            print(f"Migrated {cur.rowcount} tickets")
```

### 4. Real-Time Support Dashboard

```python
async def get_dashboard_data():
    """Fetch all dashboard data concurrently."""
    async with await psycopg.AsyncConnection.connect(**DB_CONFIG) as conn:
        # Execute multiple queries concurrently
        async with conn.cursor() as cur:
            # Get open tickets
            await cur.execute("SELECT COUNT(*) FROM tickets WHERE status = 'open'")
            open_tickets = (await cur.fetchone())[0]

            # Get average response time
            await cur.execute("""
                SELECT AVG(EXTRACT(EPOCH FROM (first_response_at - created_at))/60)
                FROM tickets
                WHERE first_response_at IS NOT NULL
                AND created_at > NOW() - INTERVAL '24 hours'
            """)
            avg_response = (await cur.fetchone())[0]

            return {
                'open_tickets': open_tickets,
                'avg_response_minutes': float(avg_response) if avg_response else 0
            }
```

## Psycopg2 vs Psycopg3 Comparison

### Key Differences

| Feature | Psycopg2 | Psycopg3 |
|---------|----------|----------|
| **Import** | `import psycopg2` | `import psycopg` |
| **Python Support** | Python 2.7, 3.6+ | Python 3.7+ only |
| **Async Support** | External (aiopg) | Native asyncio |
| **Connection Pooling** | External packages | Built-in `psycopg_pool` |
| **Type System** | Static | Flexible adapters |
| **Binary Protocol** | Limited | Full support |
| **Performance** | Fast | 20-30% faster |
| **Pipeline Mode** | No | Yes |
| **Context Managers** | Basic | Enhanced |
| **Server Cursors** | Manual | Simplified |

### Migration Example

**Psycopg2 Code:**
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="mydb",
    user="user",
    password="password"
)
cur = conn.cursor()
cur.execute("SELECT * FROM tickets WHERE status = %s", ('open',))
tickets = cur.fetchall()
cur.close()
conn.close()
```

**Psycopg3 Equivalent:**
```python
import psycopg

with psycopg.connect(
    host="localhost",
    dbname="mydb",  # Note: 'dbname' instead of 'database'
    user="user",
    password="password"
) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM tickets WHERE status = %s", ('open',))
        tickets = cur.fetchall()
# Automatic cleanup, no need for close()
```

### Migration Checklist

- [ ] Update import statements: `psycopg2` → `psycopg`
- [ ] Change parameter: `database` → `dbname`
- [ ] Replace external pooling with `psycopg_pool`
- [ ] Update async code to use native `AsyncConnection`
- [ ] Review transaction handling (improved in v3)
- [ ] Test binary protocol usage
- [ ] Update error handling if using specific exceptions
- [ ] Review type adapter usage if custom types exist

## Performance Characteristics

### Benchmarks

Typical performance for common operations (on modern hardware):

| Operation | Throughput | Notes |
|-----------|-----------|-------|
| Simple SELECT | ~50,000 queries/sec | Using connection pool |
| Parameterized INSERT | ~10,000 inserts/sec | Single connection |
| Batch INSERT (executemany) | ~100,000 rows/sec | 1000 rows per batch |
| COPY FROM | ~500,000 rows/sec | Bulk import |
| COPY TO | ~1,000,000 rows/sec | Bulk export |
| Connection pool checkout | ~0.1ms | From warm pool |
| Async query | ~0.5ms | Simple query overhead |

### Performance Tips

1. **Use connection pooling** for multi-request applications
2. **Use COPY** for bulk operations (10-50x faster than INSERT)
3. **Enable binary protocol** for large result sets
4. **Use prepared statements** for repeated queries
5. **Batch operations** with executemany() when possible
6. **Use async** for I/O-bound concurrent operations
7. **Set appropriate fetch sizes** for iteration
8. **Monitor pool statistics** to optimize sizing

## Troubleshooting

### Common Issues and Solutions

#### Issue: Connection Refused

```
psycopg.OperationalError: connection to server at "localhost" failed: Connection refused
```

**Solutions:**
1. Check PostgreSQL is running: `pg_isready`
2. Verify host and port: `psql -h localhost -p 5432`
3. Check firewall rules
4. Verify `postgresql.conf` has correct `listen_addresses`

#### Issue: Authentication Failed

```
psycopg.OperationalError: FATAL: password authentication failed for user "myuser"
```

**Solutions:**
1. Verify credentials in `.env` file
2. Check `pg_hba.conf` for authentication method
3. Ensure user exists: `SELECT * FROM pg_user WHERE usename = 'myuser'`
4. Try connection string: `postgresql://user:password@host/dbname`

#### Issue: Too Many Connections

```
psycopg.OperationalError: FATAL: sorry, too many clients already
```

**Solutions:**
1. Reduce pool `max_size`
2. Increase PostgreSQL `max_connections` setting
3. Use PgBouncer for connection pooling
4. Check for connection leaks (not using context managers)

#### Issue: Connection Pool Timeout

```
psycopg_pool.PoolTimeout: timeout waiting for connection
```

**Solutions:**
1. Increase pool `timeout` parameter
2. Increase pool `max_size`
3. Check for slow queries blocking connections
4. Monitor pool stats: `pool.get_stats()`

#### Issue: Query Timeout

```
psycopg.errors.QueryCanceled: canceling statement due to statement timeout
```

**Solutions:**
1. Optimize query with EXPLAIN ANALYZE
2. Add appropriate indexes
3. Increase `statement_timeout` setting
4. Consider using async queries for long operations

#### Issue: Out of Memory (Large Result Set)

```
MemoryError: unable to allocate memory
```

**Solutions:**
1. Use cursor iteration instead of fetchall()
2. Use server-side cursor for large datasets
3. Set `cur.itersize` to control batch size
4. Use COPY TO for exports

### Debugging Tips

#### Enable Query Logging

```python
import logging

# Log all queries
logging.basicConfig(level=logging.DEBUG)
logging.getLogger("psycopg").setLevel(logging.DEBUG)
```

#### Monitor Connection Pool

```python
import time
from psycopg_pool import ConnectionPool

pool = ConnectionPool(..., open=True)

# Enable pool logging
logging.getLogger("psycopg.pool").setLevel(logging.INFO)

# Periodic monitoring
def monitor_pool():
    while True:
        stats = pool.get_stats()
        print(f"Pool size: {stats.get('pool_size')}")
        print(f"Available: {stats.get('pool_available')}")
        print(f"Waiting: {stats.get('requests_waiting')}")
        time.sleep(60)
```

#### Check Connection Health

```python
def check_connection(conn):
    """Verify connection is healthy."""
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            return cur.fetchone()[0] == 1
    except Exception as e:
        print(f"Connection unhealthy: {e}")
        return False
```

### Getting Help

1. **Check Documentation**: https://www.psycopg.org/psycopg3/docs/
2. **Review Examples**: See EXAMPLES.md in this skill
3. **Check PostgreSQL Logs**: Look for server-side errors
4. **Enable Debug Logging**: See debugging tips above
5. **Community Support**: https://github.com/psycopg/psycopg/discussions
6. **Stack Overflow**: Tag questions with `psycopg3` and `postgresql`

## Security Best Practices

### 1. Always Use Parameterized Queries

```python
# WRONG - SQL Injection risk!
customer_id = request.args.get('id')
cur.execute(f"SELECT * FROM customers WHERE id = {customer_id}")

# CORRECT - Safe from SQL injection
cur.execute("SELECT * FROM customers WHERE customer_id = %s", (customer_id,))
```

### 2. Use Read-Only Connections for Support

```python
# Grant read-only access to support team
SUPPORT_DB_CONFIG = {
    'host': 'prod-db-replica.company.com',  # Read replica
    'user': 'support_readonly',              # Read-only user
    'password': os.getenv('SUPPORT_DB_PASSWORD'),
    'dbname': 'production',
}

# Verify read-only
with psycopg.connect(**SUPPORT_DB_CONFIG) as conn:
    with conn.cursor() as cur:
        cur.execute("SHOW default_transaction_read_only")
        readonly = cur.fetchone()[0]
        assert readonly == 'on', "Connection is not read-only!"
```

### 3. Store Credentials Securely

```python
# Use environment variables
import os
password = os.getenv('DB_PASSWORD')

# Or use secret management services
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://myvault.vault.azure.net/", credential=credential)
password = client.get_secret("db-password").value
```

### 4. Encrypt Connections

```python
# Require SSL/TLS
conn = psycopg.connect(
    **DB_CONFIG,
    sslmode='require'  # or 'verify-full' for certificate validation
)
```

### 5. Limit Connection Privileges

```sql
-- Create restricted user for support team
CREATE ROLE support_readonly WITH LOGIN PASSWORD 'secure_password';

-- Grant SELECT only
GRANT CONNECT ON DATABASE support_db TO support_readonly;
GRANT USAGE ON SCHEMA public TO support_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO support_readonly;

-- Prevent data modification
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM support_readonly;
```

## Best Practices Summary

### Connection Management
- ✅ Always use context managers (`with` statements)
- ✅ Use connection pooling for production apps
- ✅ Implement retry logic for resilience
- ✅ Monitor pool health and statistics
- ❌ Don't create connections for every query
- ❌ Don't forget to close connections

### Query Execution
- ✅ Use parameterized queries for all user input
- ✅ Use prepared statements for repeated queries
- ✅ Batch operations with executemany()
- ✅ Use COPY for bulk data transfer
- ❌ Don't use string formatting for queries
- ❌ Don't fetch entire large result sets

### Error Handling
- ✅ Handle specific exception types
- ✅ Implement retry logic for transient failures
- ✅ Log errors with context
- ✅ Monitor connection health
- ❌ Don't ignore exceptions
- ❌ Don't expose error details to users

### Performance
- ✅ Use binary protocol for large data
- ✅ Iterate over large result sets
- ✅ Use async for concurrent operations
- ✅ Monitor and optimize slow queries
- ❌ Don't load entire tables into memory
- ❌ Don't create indexes without analysis

## Additional Resources

### Official Documentation
- **Psycopg3 Docs**: https://www.psycopg.org/psycopg3/docs/
- **API Reference**: https://www.psycopg.org/psycopg3/docs/api/
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

### Community Resources
- **GitHub**: https://github.com/psycopg/psycopg
- **Discussions**: https://github.com/psycopg/psycopg/discussions
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/psycopg3

### Related Skills
- SQLAlchemy: ORM built on psycopg
- FastAPI: Async web framework integration
- pytest: Testing database code
- PostgreSQL: Database administration

### Example Projects
- FastAPI + Psycopg3: See EXAMPLES.md
- Connection pooling patterns: See SKILL.md
- Data migration scripts: See EXAMPLES.md

## Contributing

This skill is maintained by the Customer Support Tech Enablement Team. For updates or corrections:

1. Report issues to the tech team
2. Suggest improvements based on real-world usage
3. Share your own examples and patterns
4. Update documentation for new PostgreSQL features

## Version History

- **1.0.0** (2025-10-18): Initial release
  - Complete psycopg3 coverage
  - Customer support use cases
  - FastAPI integration
  - Testing patterns
  - Migration guide from psycopg2

---

**Maintained By**: Customer Support Tech Enablement Team
**Last Updated**: 2025-10-18
**License**: Internal Use Only
