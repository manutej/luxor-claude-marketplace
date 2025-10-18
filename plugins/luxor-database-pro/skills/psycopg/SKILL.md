---
skill: psycopg
description: PostgreSQL adapter for Python - customer support tech enablement for database operations, query optimization, and data management
version: 1.0.0
author: Customer Support Tech Team
category: database
tags:
  - postgresql
  - database
  - psycopg3
  - async
  - connection-pooling
  - data-migration
  - customer-support
  - backend
  - python
related_skills:
  - sqlalchemy
  - fastapi
  - pytest
  - postgresql
context: customer-support-tech-enablement
use_cases:
  - high-performance database queries
  - bulk data operations
  - customer data migration
  - support ticket analysis
  - real-time analytics
  - async API backends
---

# Psycopg Skill - Customer Support Tech Enablement

## Overview

This skill provides comprehensive guidance on using **psycopg3** (and psycopg2 where applicable) for PostgreSQL database operations in customer support contexts. It covers everything from basic connections to advanced features like connection pooling, async operations, bulk data transfers, and performance optimization.

## Target Audience

- Customer Support Engineers working with backend systems
- Technical Support teams handling data migrations
- Support teams analyzing customer data and usage patterns
- Backend developers building support tools and dashboards
- QA engineers writing integration tests for PostgreSQL-backed applications

## Core Competencies

When using this skill, you will be able to:

1. **Establish robust database connections** with proper error handling and retry logic
2. **Implement connection pooling** for high-performance multi-threaded applications
3. **Execute async database operations** for non-blocking I/O in modern Python applications
4. **Perform bulk data operations** efficiently using COPY and batch insert techniques
5. **Write secure parameterized queries** to prevent SQL injection
6. **Handle transactions** with proper commit/rollback semantics
7. **Optimize query performance** using prepared statements and binary protocols
8. **Work with JSON/JSONB data** for flexible customer data storage
9. **Implement retry patterns** for resilient database connections
10. **Test database code** effectively using pytest and fixtures

## Installation and Setup

### Installing Psycopg3

For new projects, always use psycopg3:

```bash
# Basic installation (pure Python implementation)
pip install psycopg

# With binary package for better performance
pip install "psycopg[binary]"

# With connection pool support
pip install "psycopg[pool]"

# Complete installation with all extras
pip install "psycopg[binary,pool]"

# For C implementation (fastest, requires build tools)
pip install "psycopg[c]"
```

### Installing Psycopg2 (Legacy Projects)

If you're maintaining legacy code:

```bash
# Binary package (recommended for most cases)
pip install psycopg2-binary

# Source package (requires PostgreSQL dev libraries)
pip install psycopg2
```

### Environment Setup for Customer Support

Create a `.env` file for database credentials:

```bash
# Production support database (read-only)
SUPPORT_DB_HOST=support-db.company.com
SUPPORT_DB_PORT=5432
SUPPORT_DB_NAME=support_analytics
SUPPORT_DB_USER=support_readonly
SUPPORT_DB_PASSWORD=secure_password_here

# Development/testing database
DEV_DB_HOST=localhost
DEV_DB_PORT=5432
DEV_DB_NAME=support_dev
DEV_DB_USER=dev_user
DEV_DB_PASSWORD=dev_password
```

Load with python-dotenv:

```python
from dotenv import load_dotenv
import os

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('SUPPORT_DB_HOST'),
    'port': os.getenv('SUPPORT_DB_PORT'),
    'dbname': os.getenv('SUPPORT_DB_NAME'),
    'user': os.getenv('SUPPORT_DB_USER'),
    'password': os.getenv('SUPPORT_DB_PASSWORD'),
}
```

## Connection Management

### Basic Connection (Psycopg3)

```python
import psycopg

# Using connection string
conn = psycopg.connect(
    "postgresql://user:password@localhost:5432/support_db"
)

# Using parameters (recommended for flexibility)
conn = psycopg.connect(
    host="localhost",
    port=5432,
    dbname="support_db",
    user="support_user",
    password="secure_password",
    autocommit=False,  # Explicit transaction management
    connect_timeout=10  # Timeout in seconds
)

# Always use context manager for automatic cleanup
with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version()")
        print(cur.fetchone()[0])
# Connection automatically closed
```

### Connection with Retry Logic

For resilient customer support applications:

```python
import psycopg
import time
import logging
from typing import Optional

logger = logging.getLogger(__name__)

def connect_with_retry(
    max_attempts: int = 5,
    retry_delay: float = 2.0,
    backoff_factor: float = 2.0,
    **conn_params
) -> Optional[psycopg.Connection]:
    """
    Establish database connection with exponential backoff retry.

    Args:
        max_attempts: Maximum number of connection attempts
        retry_delay: Initial delay between retries (seconds)
        backoff_factor: Multiplier for exponential backoff
        **conn_params: Connection parameters for psycopg.connect()

    Returns:
        Connection object or None if all attempts fail
    """
    attempt = 0
    current_delay = retry_delay

    while attempt < max_attempts:
        try:
            conn = psycopg.connect(**conn_params)
            logger.info(f"Database connection established on attempt {attempt + 1}")
            return conn
        except psycopg.OperationalError as e:
            attempt += 1
            if attempt >= max_attempts:
                logger.error(f"Failed to connect after {max_attempts} attempts: {e}")
                raise

            logger.warning(
                f"Connection attempt {attempt} failed: {e}. "
                f"Retrying in {current_delay:.1f}s..."
            )
            time.sleep(current_delay)
            current_delay *= backoff_factor

    return None

# Usage in customer support tools
try:
    conn = connect_with_retry(
        host="support-db.company.com",
        dbname="support_analytics",
        user="support_user",
        password=os.getenv("DB_PASSWORD"),
        max_attempts=5
    )
    with conn:
        # Perform operations
        pass
except psycopg.OperationalError:
    logger.critical("Database unavailable - alerting on-call team")
    # Send alert to monitoring system
```

## Connection Pooling

### Synchronous Connection Pool

Essential for high-performance support tools handling multiple requests:

```python
from psycopg_pool import ConnectionPool
import logging

logging.basicConfig(level=logging.INFO)
logging.getLogger("psycopg.pool").setLevel(logging.INFO)

# Create a global connection pool
pool = ConnectionPool(
    conninfo="postgresql://user:password@localhost/support_db",
    min_size=2,          # Minimum connections to maintain
    max_size=10,         # Maximum connections allowed
    max_idle=300,        # Close idle connections after 5 minutes
    max_lifetime=3600,   # Recycle connections after 1 hour
    timeout=30,          # Wait up to 30s for a connection
    check=ConnectionPool.check_connection,  # Validate connections
    open=True            # Open pool immediately
)

# Wait for minimum connections to be established
pool.wait()

# Use in application code
def get_customer_tickets(customer_id: int):
    """Fetch all tickets for a customer."""
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT ticket_id, subject, status, created_at "
                "FROM tickets WHERE customer_id = %s "
                "ORDER BY created_at DESC",
                (customer_id,)
            )
            return cur.fetchall()

# Monitor pool health
def check_pool_health():
    """Get pool statistics for monitoring."""
    stats = pool.get_stats()
    return {
        'pool_size': stats.get('pool_size', 0),
        'available': stats.get('pool_available', 0),
        'waiting': stats.get('requests_waiting', 0),
        'requests_total': stats.get('requests_num', 0),
        'requests_queued': stats.get('requests_queued', 0),
        'connection_errors': stats.get('connections_errors', 0)
    }

# Cleanup on application shutdown
import atexit
atexit.register(pool.close)
```

### Asynchronous Connection Pool

For async FastAPI/Starlette support applications:

```python
from psycopg_pool import AsyncConnectionPool
from contextlib import asynccontextmanager
from fastapi import FastAPI
import logging

logger = logging.getLogger(__name__)

# Create async pool
async_pool = AsyncConnectionPool(
    conninfo="postgresql://user:password@localhost/support_db",
    min_size=5,
    max_size=20,
    open=False  # Open during application startup
)

# FastAPI integration with lifespan
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage async pool lifecycle with FastAPI."""
    await async_pool.open()
    logger.info("Async connection pool opened")
    yield
    await async_pool.close()
    logger.info("Async connection pool closed")

app = FastAPI(lifespan=lifespan)

# Async endpoint using the pool
@app.get("/api/customers/{customer_id}/tickets")
async def get_customer_tickets(customer_id: int):
    """Fetch customer tickets asynchronously."""
    async with async_pool.connection() as conn:
        async with conn.cursor() as cur:
            await cur.execute(
                "SELECT ticket_id, subject, status, priority, created_at "
                "FROM tickets "
                "WHERE customer_id = %s "
                "ORDER BY created_at DESC "
                "LIMIT 100",
                (customer_id,)
            )
            tickets = await cur.fetchall()

            return [
                {
                    'ticket_id': t[0],
                    'subject': t[1],
                    'status': t[2],
                    'priority': t[3],
                    'created_at': t[4].isoformat()
                }
                for t in tickets
            ]

# Health check endpoint
@app.get("/health/database")
async def database_health():
    """Check database and pool health."""
    try:
        async with async_pool.connection() as conn:
            async with conn.cursor() as cur:
                await cur.execute("SELECT 1")
                result = await cur.fetchone()

        stats = async_pool.get_stats()
        return {
            'status': 'healthy',
            'database_responsive': result[0] == 1,
            'pool_stats': {
                'size': stats.get('pool_size'),
                'available': stats.get('pool_available'),
                'waiting': stats.get('requests_waiting')
            }
        }
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return {'status': 'unhealthy', 'error': str(e)}
```

## Async Operations

### Basic Async Pattern

```python
import asyncio
import psycopg

async def fetch_support_metrics():
    """Fetch support metrics asynchronously."""
    async with await psycopg.AsyncConnection.connect(
        "postgresql://user:password@localhost/support_db"
    ) as conn:
        async with conn.cursor() as cur:
            # Execute query asynchronously
            await cur.execute(
                """
                SELECT
                    status,
                    COUNT(*) as count,
                    AVG(response_time_minutes) as avg_response
                FROM tickets
                WHERE created_at > CURRENT_DATE - INTERVAL '7 days'
                GROUP BY status
                """
            )

            # Fetch results
            results = await cur.fetchall()

            # Process asynchronously
            metrics = {}
            async for row in cur:
                metrics[row[0]] = {
                    'count': row[1],
                    'avg_response': float(row[2]) if row[2] else 0
                }

            return metrics

# Run async function
if __name__ == "__main__":
    metrics = asyncio.run(fetch_support_metrics())
    print(metrics)
```

### Concurrent Async Queries

Execute multiple queries concurrently for better performance:

```python
import asyncio
import psycopg
from typing import List, Tuple

async def fetch_customer_data(customer_id: int, conn: psycopg.AsyncConnection):
    """Fetch all data for a customer."""
    async with conn.cursor() as cur:
        await cur.execute(
            "SELECT * FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        return await cur.fetchone()

async def fetch_customer_tickets(customer_id: int, conn: psycopg.AsyncConnection):
    """Fetch tickets for a customer."""
    async with conn.cursor() as cur:
        await cur.execute(
            "SELECT * FROM tickets WHERE customer_id = %s",
            (customer_id,)
        )
        return await cur.fetchall()

async def fetch_customer_interactions(customer_id: int, conn: psycopg.AsyncConnection):
    """Fetch all interactions for a customer."""
    async with conn.cursor() as cur:
        await cur.execute(
            "SELECT * FROM interactions WHERE customer_id = %s "
            "ORDER BY interaction_date DESC",
            (customer_id,)
        )
        return await cur.fetchall()

async def get_complete_customer_view(customer_id: int) -> dict:
    """Get complete customer view with concurrent queries."""
    async with await psycopg.AsyncConnection.connect(
        "postgresql://user:password@localhost/support_db"
    ) as conn:
        # Execute all queries concurrently
        customer, tickets, interactions = await asyncio.gather(
            fetch_customer_data(customer_id, conn),
            fetch_customer_tickets(customer_id, conn),
            fetch_customer_interactions(customer_id, conn)
        )

        return {
            'customer': customer,
            'tickets': tickets,
            'interactions': interactions
        }
```

## Transaction Management

### Explicit Transactions

```python
import psycopg
from psycopg import Rollback

def create_ticket_with_audit(customer_id: int, subject: str, description: str):
    """Create ticket and audit log in a single transaction."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.transaction():
            with conn.cursor() as cur:
                # Insert ticket
                cur.execute(
                    """
                    INSERT INTO tickets (customer_id, subject, description, status)
                    VALUES (%s, %s, %s, 'open')
                    RETURNING ticket_id, created_at
                    """,
                    (customer_id, subject, description)
                )
                ticket_id, created_at = cur.fetchone()

                # Insert audit log
                cur.execute(
                    """
                    INSERT INTO audit_log (entity_type, entity_id, action, created_by)
                    VALUES ('ticket', %s, 'created', 'system')
                    """,
                    (ticket_id,)
                )

                # Transaction automatically commits on successful exit
                # or rolls back on exception
                return ticket_id, created_at
```

### Nested Transactions with Savepoints

```python
import psycopg
import logging

logger = logging.getLogger(__name__)

def bulk_import_customer_data(records: list) -> dict:
    """
    Import customer data with nested transactions.
    Successful records are committed; failed records are logged.
    """
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.transaction() as outer_tx:
            stats = {'success': 0, 'failed': 0, 'errors': []}

            for record in records:
                try:
                    # Create savepoint for each record
                    with conn.transaction() as inner_tx:
                        with conn.cursor() as cur:
                            cur.execute(
                                """
                                INSERT INTO customers (email, name, company)
                                VALUES (%(email)s, %(name)s, %(company)s)
                                """,
                                record
                            )
                            stats['success'] += 1
                except Exception as e:
                    # Inner transaction rolls back to savepoint
                    logger.error(f"Failed to import record {record}: {e}")
                    stats['failed'] += 1
                    stats['errors'].append({
                        'record': record,
                        'error': str(e)
                    })

            # Log summary
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO import_log (success_count, failed_count, imported_at)
                    VALUES (%s, %s, NOW())
                    """,
                    (stats['success'], stats['failed'])
                )

            # Outer transaction commits all successful imports
            return stats
```

### Autocommit Mode

For operations that can't run in a transaction block:

```python
import psycopg

# Create database (must be in autocommit mode)
with psycopg.connect(**DB_CONFIG, autocommit=True) as conn:
    with conn.cursor() as cur:
        cur.execute("CREATE DATABASE new_support_db")

# Vacuum operation (must be in autocommit mode)
with psycopg.connect(**DB_CONFIG, autocommit=True) as conn:
    with conn.cursor() as cur:
        cur.execute("VACUUM ANALYZE tickets")

# Mixed mode: autocommit connection with explicit transactions
with psycopg.connect(**DB_CONFIG, autocommit=True) as conn:
    # This query commits immediately
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM tickets")
        count = cur.fetchone()[0]

    # Use explicit transaction when needed
    with conn.transaction():
        with conn.cursor() as cur:
            cur.execute("INSERT INTO tickets (...) VALUES (...)")
            cur.execute("INSERT INTO audit_log (...) VALUES (...)")
        # Both operations commit together
```

## Parameterized Queries and Security

### Always Use Parameterized Queries

**NEVER** use string formatting for query values:

```python
# WRONG - Vulnerable to SQL injection!
customer_id = request.args.get('id')
cur.execute(f"SELECT * FROM customers WHERE id = {customer_id}")  # DANGEROUS!

# WRONG - Still vulnerable!
cur.execute("SELECT * FROM customers WHERE id = %s" % customer_id)  # DANGEROUS!

# CORRECT - Use parameterized queries
cur.execute(
    "SELECT * FROM customers WHERE customer_id = %s",
    (customer_id,)  # Parameters as tuple
)

# CORRECT - Named parameters with dict
cur.execute(
    "SELECT * FROM customers WHERE customer_id = %(id)s AND status = %(status)s",
    {'id': customer_id, 'status': 'active'}
)
```

### Dynamic Table/Column Names

Use `psycopg.sql` module for identifiers:

```python
from psycopg import sql

def get_records_from_table(table_name: str, column: str, value: any):
    """
    Safely query with dynamic table/column names.
    """
    # Validate table name against whitelist
    ALLOWED_TABLES = ['tickets', 'customers', 'interactions']
    if table_name not in ALLOWED_TABLES:
        raise ValueError(f"Invalid table name: {table_name}")

    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            query = sql.SQL("SELECT * FROM {} WHERE {} = %s").format(
                sql.Identifier(table_name),
                sql.Identifier(column)
            )
            cur.execute(query, (value,))
            return cur.fetchall()

# Build complex dynamic queries
def build_search_query(search_filters: dict):
    """Build search query from filter dictionary."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # Base query
            query = sql.SQL("SELECT * FROM tickets WHERE ")

            # Build WHERE clause dynamically
            conditions = []
            params = []

            for field, value in search_filters.items():
                conditions.append(
                    sql.SQL("{} = %s").format(sql.Identifier(field))
                )
                params.append(value)

            # Combine with AND
            query = query + sql.SQL(" AND ").join(conditions)

            cur.execute(query, params)
            return cur.fetchall()
```

## Bulk Operations and COPY

### Batch Inserts with executemany

```python
import psycopg

def batch_insert_tickets(tickets: list[dict]):
    """
    Efficiently insert multiple tickets using executemany.
    """
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # Prepare data as list of tuples
            data = [
                (
                    ticket['customer_id'],
                    ticket['subject'],
                    ticket['description'],
                    ticket['priority']
                )
                for ticket in tickets
            ]

            # Execute batch insert
            cur.executemany(
                """
                INSERT INTO tickets (customer_id, subject, description, priority)
                VALUES (%s, %s, %s, %s)
                """,
                data
            )

            print(f"Inserted {cur.rowcount} tickets")

# With RETURNING clause to get generated IDs
def batch_insert_with_ids(tickets: list[dict]) -> list[int]:
    """Insert tickets and return generated IDs."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            data = [(t['customer_id'], t['subject']) for t in tickets]

            # Use returning=True to fetch results
            cur.executemany(
                """
                INSERT INTO tickets (customer_id, subject)
                VALUES (%s, %s)
                RETURNING ticket_id
                """,
                data,
                returning=True
            )

            # Collect all returned IDs
            ids = []
            for result in cur.results():
                ids.append(result.fetchone()[0])

            return ids
```

### COPY for Maximum Performance

COPY is the fastest way to bulk import/export data:

```python
import psycopg
from io import StringIO
import csv

def bulk_import_from_csv(csv_file_path: str):
    """
    Import data from CSV using COPY.
    Fastest method for large datasets.
    """
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # COPY FROM file
            with open(csv_file_path, 'r') as f:
                with cur.copy(
                    "COPY tickets (customer_id, subject, description, priority) "
                    "FROM STDIN WITH (FORMAT CSV, HEADER)"
                ) as copy:
                    while data := f.read(8192):  # Read in chunks
                        copy.write(data)

            print(f"Imported {cur.rowcount} records")

def bulk_export_to_csv(output_file: str):
    """Export data to CSV using COPY."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            with open(output_file, 'w') as f:
                with cur.copy(
                    "COPY (SELECT * FROM tickets WHERE status = 'open') "
                    "TO STDOUT WITH (FORMAT CSV, HEADER)"
                ) as copy:
                    for data in copy:
                        f.write(data)

def copy_from_memory(records: list[dict]):
    """COPY from in-memory data."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # Prepare CSV data in memory
            buffer = StringIO()
            writer = csv.writer(buffer)

            for record in records:
                writer.writerow([
                    record['customer_id'],
                    record['subject'],
                    record['description']
                ])

            buffer.seek(0)

            # COPY from StringIO
            with cur.copy(
                "COPY tickets (customer_id, subject, description) FROM STDIN"
            ) as copy:
                copy.write(buffer.getvalue())
```

### Async COPY Operations

```python
import asyncio
import psycopg

async def async_bulk_export(query: str, output_file: str):
    """Async COPY operation for large exports."""
    async with await psycopg.AsyncConnection.connect(**DB_CONFIG) as conn:
        async with conn.cursor() as cur:
            with open(output_file, 'wb') as f:
                async with cur.copy(
                    f"COPY ({query}) TO STDOUT WITH (FORMAT CSV, HEADER)"
                ) as copy:
                    async for data in copy:
                        f.write(data)

# Usage
query = """
    SELECT t.ticket_id, t.subject, c.email, t.created_at
    FROM tickets t
    JOIN customers c ON t.customer_id = c.customer_id
    WHERE t.created_at > CURRENT_DATE - INTERVAL '30 days'
"""

asyncio.run(async_bulk_export(query, 'recent_tickets.csv'))
```

## Working with JSON/JSONB Data

PostgreSQL's JSONB is perfect for flexible customer data:

```python
import psycopg
import json
from typing import Any

def store_customer_metadata(customer_id: int, metadata: dict):
    """Store flexible customer metadata as JSONB."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE customers
                SET metadata = %s
                WHERE customer_id = %s
                """,
                (json.dumps(metadata), customer_id)
            )

def query_json_field(industry: str):
    """Query customers by JSON field."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT customer_id, name, metadata
                FROM customers
                WHERE metadata->>'industry' = %s
                """,
                (industry,)
            )
            return cur.fetchall()

def update_nested_json(customer_id: int, key_path: str, value: Any):
    """Update nested JSONB field."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE customers
                SET metadata = jsonb_set(
                    metadata,
                    %s,
                    %s
                )
                WHERE customer_id = %s
                """,
                (
                    '{' + key_path + '}',  # Path as text
                    json.dumps(value),      # New value
                    customer_id
                )
            )

def search_json_array(tag: str):
    """Search for customers with specific tag in JSONB array."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT customer_id, name, metadata->'tags' as tags
                FROM customers
                WHERE metadata->'tags' ? %s
                """,
                (tag,)
            )
            return cur.fetchall()
```

## Performance Optimization

### Prepared Statements

Psycopg3 automatically prepares frequently used statements:

```python
import psycopg

# Configure prepare threshold (default is 5)
conn = psycopg.connect(**DB_CONFIG, prepare_threshold=5)

# After executing the same query 5 times, it's automatically prepared
with conn.cursor() as cur:
    for customer_id in range(1, 100):
        cur.execute(
            "SELECT * FROM tickets WHERE customer_id = %s",
            (customer_id,)
        )
        # After 5th execution, this becomes a prepared statement

# Force preparation for a specific query
with conn.cursor() as cur:
    cur.execute(
        "SELECT * FROM tickets WHERE status = %s",
        ('open',),
        prepare=True  # Force preparation on first execution
    )
```

### Binary Protocol for Large Data

```python
import psycopg

def fetch_large_binary_data(attachment_id: int) -> bytes:
    """Fetch large binary data efficiently."""
    with psycopg.connect(**DB_CONFIG) as conn:
        # Use binary cursor for binary data
        with conn.cursor(binary=True) as cur:
            cur.execute(
                "SELECT file_data FROM attachments WHERE attachment_id = %s",
                (attachment_id,),
                binary=True  # Request binary format
            )
            return cur.fetchone()[0]

def store_binary_attachment(ticket_id: int, filename: str, data: bytes):
    """Store binary attachment efficiently."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO attachments (ticket_id, filename, file_data)
                VALUES (%s, %s, %s)
                """,
                (ticket_id, filename, data)
            )
```

### Cursor Iteration for Large Result Sets

```python
import psycopg

def process_large_result_set():
    """
    Process large result sets without loading all into memory.
    """
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # Set fetch size for iteration
            cur.itersize = 1000

            cur.execute(
                "SELECT ticket_id, subject, description FROM tickets"
            )

            # Iterate efficiently in batches
            processed = 0
            for row in cur:
                # Process each row
                ticket_id, subject, description = row
                # ... do something with the data
                processed += 1

                if processed % 10000 == 0:
                    print(f"Processed {processed} records...")

# Server-side cursor for very large datasets
def process_with_server_cursor():
    """Use server-side cursor for memory-efficient processing."""
    with psycopg.connect(**DB_CONFIG) as conn:
        # Named cursor creates server-side cursor
        with conn.cursor(name='large_fetch') as cur:
            cur.execute(
                "SELECT * FROM tickets WHERE created_at > %s",
                ('2024-01-01',)
            )

            # Fetch in chunks
            while rows := cur.fetchmany(size=1000):
                for row in rows:
                    # Process each row
                    pass
```

## Error Handling and Monitoring

### Comprehensive Error Handling

```python
import psycopg
from psycopg import errors
import logging

logger = logging.getLogger(__name__)

def safe_database_operation(customer_id: int):
    """
    Database operation with comprehensive error handling.
    """
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT * FROM customers WHERE customer_id = %s",
                    (customer_id,)
                )
                return cur.fetchone()

    except errors.OperationalError as e:
        # Connection issues, server down, etc.
        logger.error(f"Database connection error: {e}")
        # Trigger alert, use fallback, etc.
        raise

    except errors.IntegrityError as e:
        # Constraint violations (unique, foreign key, etc.)
        logger.warning(f"Integrity constraint violated: {e}")
        # Return user-friendly error message
        return None

    except errors.DataError as e:
        # Data type mismatches, invalid input
        logger.error(f"Invalid data provided: {e}")
        raise ValueError("Invalid customer data")

    except errors.ProgrammingError as e:
        # SQL syntax errors, table doesn't exist, etc.
        logger.error(f"Programming error in query: {e}")
        raise

    except errors.QueryCanceled as e:
        # Query timeout or cancellation
        logger.warning(f"Query was canceled: {e}")
        return None

    except Exception as e:
        # Catch-all for unexpected errors
        logger.exception(f"Unexpected database error: {e}")
        raise

# Handle specific constraint violations
def handle_duplicate_email(email: str, name: str):
    """Handle unique constraint on email."""
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO customers (email, name) VALUES (%s, %s)",
                    (email, name)
                )
    except errors.UniqueViolation:
        logger.info(f"Customer with email {email} already exists")
        # Update instead of insert
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "UPDATE customers SET name = %s WHERE email = %s",
                    (name, email)
                )
```

### Connection Health Monitoring

```python
import psycopg
import selectors
import logging

logger = logging.getLogger(__name__)

def monitor_connection_health(conn: psycopg.Connection, timeout: float = 60.0):
    """
    Monitor database connection health using selectors.
    """
    sel = selectors.DefaultSelector()
    sel.register(conn.fileno(), selectors.EVENT_READ)

    while True:
        # Wait for activity on connection file descriptor
        if not sel.select(timeout=timeout):
            logger.debug("No activity in the last minute")
            continue

        # Activity detected - verify connection is still healthy
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                result = cur.fetchone()
                if result and result[0] == 1:
                    logger.debug("Connection health check passed")
        except psycopg.OperationalError as e:
            logger.error(f"Connection lost: {e}")
            # Alert monitoring system
            break
```

## Testing with Pytest

### Pytest Fixtures for Database Testing

```python
# conftest.py
import pytest
import psycopg
from psycopg_pool import ConnectionPool

@pytest.fixture(scope="session")
def db_config():
    """Database configuration for tests."""
    return {
        'host': 'localhost',
        'port': 5432,
        'dbname': 'support_test',
        'user': 'test_user',
        'password': 'test_password'
    }

@pytest.fixture(scope="session")
def db_pool(db_config):
    """Create connection pool for tests."""
    pool = ConnectionPool(
        **db_config,
        min_size=2,
        max_size=5
    )
    yield pool
    pool.close()

@pytest.fixture(scope="function")
def db_conn(db_config):
    """Provide a fresh connection for each test."""
    conn = psycopg.connect(**db_config)
    yield conn
    conn.close()

@pytest.fixture(scope="function")
def db_transaction(db_conn):
    """
    Provide transactional isolation for tests.
    Rollback after each test.
    """
    with db_conn.transaction() as tx:
        yield db_conn
        # Transaction is rolled back automatically

@pytest.fixture(autouse=True)
def setup_test_data(db_conn):
    """Set up test data before each test."""
    with db_conn.cursor() as cur:
        # Create test schema
        cur.execute("""
            CREATE TABLE IF NOT EXISTS test_customers (
                customer_id SERIAL PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                name VARCHAR(255)
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS test_tickets (
                ticket_id SERIAL PRIMARY KEY,
                customer_id INTEGER REFERENCES test_customers(customer_id),
                subject VARCHAR(255),
                status VARCHAR(50)
            )
        """)
    db_conn.commit()

    yield

    # Cleanup after test
    with db_conn.cursor() as cur:
        cur.execute("TRUNCATE test_tickets, test_customers CASCADE")
    db_conn.commit()

# test_database.py
def test_insert_customer(db_transaction):
    """Test customer insertion."""
    with db_transaction.cursor() as cur:
        cur.execute(
            "INSERT INTO test_customers (email, name) VALUES (%s, %s) RETURNING customer_id",
            ('test@example.com', 'Test User')
        )
        customer_id = cur.fetchone()[0]
        assert customer_id is not None

def test_query_with_pool(db_pool):
    """Test querying with connection pool."""
    with db_pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            assert cur.fetchone()[0] == 1
```

## Integration with FastAPI

Complete example of psycopg3 with FastAPI:

```python
from fastapi import FastAPI, HTTPException, Depends
from contextlib import asynccontextmanager
from psycopg_pool import AsyncConnectionPool
from pydantic import BaseModel
from typing import List, Optional
import os

# Pydantic models
class Ticket(BaseModel):
    ticket_id: Optional[int] = None
    customer_id: int
    subject: str
    description: str
    status: str = 'open'
    priority: str = 'medium'

class TicketResponse(BaseModel):
    ticket_id: int
    customer_id: int
    subject: str
    status: str
    priority: str

# Global connection pool
pool: Optional[AsyncConnectionPool] = None

# Lifecycle management
@asynccontextmanager
async def lifespan(app: FastAPI):
    global pool
    # Startup
    pool = AsyncConnectionPool(
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', 5432)),
        dbname=os.getenv('DB_NAME', 'support_db'),
        user=os.getenv('DB_USER', 'support_user'),
        password=os.getenv('DB_PASSWORD'),
        min_size=5,
        max_size=20
    )
    await pool.open()
    yield
    # Shutdown
    await pool.close()

app = FastAPI(lifespan=lifespan)

# Dependency for getting pool connection
async def get_db():
    async with pool.connection() as conn:
        yield conn

# API endpoints
@app.post("/tickets", response_model=TicketResponse)
async def create_ticket(
    ticket: Ticket,
    conn = Depends(get_db)
):
    """Create a new support ticket."""
    async with conn.cursor() as cur:
        await cur.execute(
            """
            INSERT INTO tickets (customer_id, subject, description, status, priority)
            VALUES (%(customer_id)s, %(subject)s, %(description)s, %(status)s, %(priority)s)
            RETURNING ticket_id, customer_id, subject, status, priority
            """,
            ticket.dict()
        )
        result = await cur.fetchone()

        if not result:
            raise HTTPException(status_code=500, detail="Failed to create ticket")

        return TicketResponse(
            ticket_id=result[0],
            customer_id=result[1],
            subject=result[2],
            status=result[3],
            priority=result[4]
        )

@app.get("/tickets/{ticket_id}", response_model=TicketResponse)
async def get_ticket(
    ticket_id: int,
    conn = Depends(get_db)
):
    """Retrieve a specific ticket."""
    async with conn.cursor() as cur:
        await cur.execute(
            """
            SELECT ticket_id, customer_id, subject, status, priority
            FROM tickets
            WHERE ticket_id = %s
            """,
            (ticket_id,)
        )
        result = await cur.fetchone()

        if not result:
            raise HTTPException(status_code=404, detail="Ticket not found")

        return TicketResponse(
            ticket_id=result[0],
            customer_id=result[1],
            subject=result[2],
            status=result[3],
            priority=result[4]
        )

@app.get("/tickets", response_model=List[TicketResponse])
async def list_tickets(
    status: Optional[str] = None,
    limit: int = 100,
    conn = Depends(get_db)
):
    """List tickets with optional filtering."""
    async with conn.cursor() as cur:
        if status:
            await cur.execute(
                """
                SELECT ticket_id, customer_id, subject, status, priority
                FROM tickets
                WHERE status = %s
                ORDER BY ticket_id DESC
                LIMIT %s
                """,
                (status, limit)
            )
        else:
            await cur.execute(
                """
                SELECT ticket_id, customer_id, subject, status, priority
                FROM tickets
                ORDER BY ticket_id DESC
                LIMIT %s
                """,
                (limit,)
            )

        results = await cur.fetchall()

        return [
            TicketResponse(
                ticket_id=row[0],
                customer_id=row[1],
                subject=row[2],
                status=row[3],
                priority=row[4]
            )
            for row in results
        ]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## Best Practices for Customer Support

1. **Always use connection pooling** for production applications
2. **Implement retry logic** for resilient connections
3. **Use parameterized queries** to prevent SQL injection
4. **Leverage COPY** for bulk data operations
5. **Monitor pool statistics** for performance insights
6. **Use transactions** for data integrity
7. **Implement proper error handling** with specific exception types
8. **Test with isolated transactions** to avoid test pollution
9. **Use async operations** for high-concurrency applications
10. **Log database operations** for debugging and audit trails

## Common Pitfalls to Avoid

1. **Don't forget to close connections** - always use context managers
2. **Don't use string formatting** for query values - use parameters
3. **Don't ignore connection pool limits** - monitor and adjust as needed
4. **Don't fetch entire large result sets** - use iteration or server cursors
5. **Don't mix transaction modes** - be explicit about autocommit
6. **Don't ignore exceptions** - handle database errors appropriately
7. **Don't use blocking operations** in async code
8. **Don't create a new connection** for every query - use pooling

## Psycopg2 vs Psycopg3 Migration

Key differences when migrating from psycopg2:

| Feature | Psycopg2 | Psycopg3 |
|---------|----------|----------|
| Import | `import psycopg2` | `import psycopg` |
| Connection | `psycopg2.connect()` | `psycopg.connect()` |
| Async | Limited (via gevent) | Native asyncio support |
| Pooling | External packages | Built-in `psycopg_pool` |
| Performance | Good | Better (optimized) |
| Type system | Static | Flexible adapters |
| Binary protocol | Limited | Full support |
| Pipeline mode | No | Yes |
| Python versions | 2.7+ and 3.6+ | 3.7+ only |

Migration example:

```python
# Psycopg2
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    database="mydb",
    user="user",
    password="password"
)
cur = conn.cursor()
cur.execute("SELECT * FROM table")
rows = cur.fetchall()
cur.close()
conn.close()

# Psycopg3 (improved)
import psycopg
with psycopg.connect(
    host="localhost",
    dbname="mydb",  # Note: 'dbname' instead of 'database'
    user="user",
    password="password"
) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM table")
        rows = cur.fetchall()
# Automatic cleanup
```

## Additional Resources

- **Official Documentation**: https://www.psycopg.org/psycopg3/docs/
- **GitHub Repository**: https://github.com/psycopg/psycopg
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **FastAPI Integration**: https://fastapi.tiangolo.com/advanced/async-sql-databases/
- **Testing Guide**: https://docs.pytest.org/en/stable/

## Support and Troubleshooting

For customer support team questions:
- Check the EXAMPLES.md file for practical code samples
- Review the README.md for setup and configuration help
- Consult the troubleshooting section in README.md for common issues
- Reach out to the backend engineering team for complex database issues

---

**Version**: 1.0.0
**Last Updated**: 2025-10-18
**Maintained By**: Customer Support Tech Enablement Team
