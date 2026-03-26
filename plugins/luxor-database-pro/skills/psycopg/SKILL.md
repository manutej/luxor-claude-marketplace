---
name: "psycopg-database-adapter"
description: "Psycopg3 patterns for PostgreSQL database operations including async connections, connection pooling, parameterized queries, COPY for bulk transfers, and cursor management. Use when building Python database layers with psycopg, performing bulk data imports, setting up async connection pools, or migrating from psycopg2."
---

# Psycopg3 Database Operations

Production patterns for psycopg3 PostgreSQL adapter covering connections, pooling, async operations, bulk transfers, and query optimization.

## Connection Management

```python
import psycopg

# Basic connection with context manager (auto-closes)
with psycopg.connect("postgresql://user:pass@localhost/support_db") as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM tickets WHERE status = %s", ("open",))
        tickets = cur.fetchall()

# Connection with explicit parameters
conn = psycopg.connect(
    host="localhost", port=5432, dbname="support_db",
    user="app_user", password="secret",
    autocommit=False,
    options="-c search_path=public,support"
)
```

## Async Connections

```python
import psycopg

async def get_open_tickets():
    async with await psycopg.AsyncConnection.connect(
        "postgresql://user:pass@localhost/support_db"
    ) as conn:
        async with conn.cursor() as cur:
            await cur.execute(
                "SELECT id, title, priority FROM tickets WHERE status = %s ORDER BY created_at DESC",
                ("open",)
            )
            return await cur.fetchall()
```

## Connection Pooling

```python
from psycopg_pool import ConnectionPool, AsyncConnectionPool

# Synchronous pool
pool = ConnectionPool(
    conninfo="postgresql://user:pass@localhost/support_db",
    min_size=5, max_size=20,
    max_idle=300,  # seconds before idle connections are closed
)

with pool.connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT count(*) FROM tickets WHERE status = 'open'")
        count = cur.fetchone()[0]

# Async pool
async_pool = AsyncConnectionPool(
    conninfo="postgresql://user:pass@localhost/support_db",
    min_size=5, max_size=20,
)

async with async_pool.connection() as conn:
    async with conn.cursor() as cur:
        await cur.execute("SELECT * FROM tickets WHERE assigned_to = %s", (agent_id,))
        return await cur.fetchall()
```

## Parameterized Queries (SQL Injection Prevention)

```python
# Always use parameterized queries — never f-strings or string concatenation
with conn.cursor() as cur:
    # Positional parameters
    cur.execute("SELECT * FROM tickets WHERE priority = %s AND status = %s", ("urgent", "open"))

    # Named parameters
    cur.execute(
        "INSERT INTO tickets (title, description, customer_email) VALUES (%(title)s, %(desc)s, %(email)s)",
        {"title": "Login issue", "desc": "Cannot access portal", "email": "user@example.com"}
    )

    # Dynamic column names with sql.Identifier (safe)
    from psycopg import sql
    cur.execute(
        sql.SQL("SELECT {} FROM tickets ORDER BY {} DESC LIMIT %s").format(
            sql.Identifier("title"), sql.Identifier("created_at")
        ),
        (10,)
    )
```

## Row Factories for Typed Results

```python
from psycopg.rows import dict_row, namedtuple_row, class_row
from dataclasses import dataclass

# Dict rows
with conn.cursor(row_factory=dict_row) as cur:
    cur.execute("SELECT id, title, status FROM tickets LIMIT 5")
    for row in cur:
        print(row["title"])  # Access by column name

# Dataclass rows
@dataclass
class Ticket:
    id: int
    title: str
    status: str
    priority: str

with conn.cursor(row_factory=class_row(Ticket)) as cur:
    cur.execute("SELECT id, title, status, priority FROM tickets WHERE id = %s", (42,))
    ticket = cur.fetchone()  # Returns Ticket instance
```

## COPY for Bulk Data Transfer

```python
# Bulk insert from Python data (fastest method for large datasets)
records = [
    ("Ticket 1", "Description 1", "user1@example.com"),
    ("Ticket 2", "Description 2", "user2@example.com"),
]

with conn.cursor() as cur:
    with cur.copy("COPY tickets (title, description, customer_email) FROM STDIN") as copy:
        for record in records:
            copy.write_row(record)

# Bulk export to Python
with conn.cursor() as cur:
    with cur.copy("COPY (SELECT * FROM tickets WHERE status = 'closed') TO STDOUT") as copy:
        for row in copy.rows():
            process_row(row)
```

## Transaction Management

```python
# Explicit transaction control
with conn.transaction() as tx:
    conn.execute("UPDATE tickets SET status = 'in_progress' WHERE id = %s", (ticket_id,))
    conn.execute("INSERT INTO ticket_history (ticket_id, action) VALUES (%s, 'assigned')", (ticket_id,))
    # Commits on exit; rolls back on exception

# Savepoints for partial rollback
with conn.transaction() as tx:
    conn.execute("UPDATE tickets SET status = 'resolved' WHERE id = %s", (ticket_id,))
    try:
        with conn.transaction() as sp:  # savepoint
            conn.execute("INSERT INTO notifications (...) VALUES (...)")
    except Exception:
        pass  # Notification failure doesn't roll back ticket update
```

## Server-Side Cursors for Large Result Sets

```python
# Stream large result sets without loading all into memory
with conn.cursor(name="ticket_export") as cur:
    cur.execute("SELECT * FROM tickets WHERE created_at > %s", (start_date,))
    while batch := cur.fetchmany(1000):
        for row in batch:
            process_row(row)
```

## Pipeline Mode for Batch Operations

```python
# Send multiple queries in a single network round-trip
with conn.pipeline() as pipe:
    results = []
    for ticket_id in ticket_ids:
        cur = conn.execute(
            "UPDATE tickets SET status = %s WHERE id = %s RETURNING id",
            ("closed", ticket_id)
        )
        results.append(cur)
    pipe.sync()
    updated = [r.fetchone()[0] for r in results]
```

See [EXAMPLES.md](EXAMPLES.md) for complete application examples including data migration scripts, connection pool monitoring, and integration with FastAPI and SQLAlchemy.
