# SQLAlchemy for Customer Support Systems

## Overview

SQLAlchemy is the premier SQL toolkit and Object Relational Mapper (ORM) for Python, providing a comprehensive suite of tools for working with databases. This guide focuses on using SQLAlchemy 2.0+ in customer support systems, covering everything from basic setup to advanced production patterns.

## Why SQLAlchemy for Customer Support?

Customer support systems have unique requirements that SQLAlchemy addresses exceptionally well:

- **Complex Relationships**: Tickets, users, comments, attachments, and tags all interconnect in intricate ways
- **High Query Volume**: Support teams need fast, efficient queries to retrieve ticket information
- **Data Integrity**: Transactional support ensures data consistency during concurrent operations
- **Audit Requirements**: Event system enables comprehensive audit trails
- **Scalability**: Connection pooling and query optimization support growing user bases
- **Async Support**: Modern async capabilities work seamlessly with FastAPI and other async frameworks
- **Type Safety**: Python type hints with Mapped[] provide excellent IDE support and catch errors early
- **Migration Management**: Alembic integration makes schema evolution straightforward

## Installation

### Basic Installation

```bash
# Core SQLAlchemy
pip install sqlalchemy>=2.0

# PostgreSQL driver (async)
pip install asyncpg

# PostgreSQL driver (sync)
pip install psycopg2-binary

# Migration tool
pip install alembic

# Testing
pip install pytest pytest-asyncio
```

### With FastAPI

```bash
pip install fastapi[all] sqlalchemy[asyncio] asyncpg alembic
```

### With Flask

```bash
pip install flask flask-sqlalchemy sqlalchemy psycopg2-binary alembic
```

## Quick Start Guide

### 1. Define Your Models

Create a base class and define your customer support models:

```python
from datetime import datetime
from typing import Optional, List
from sqlalchemy import String, Integer, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func

class Base(DeclarativeBase):
    """Base class for all models"""
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    full_name: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    # Relationships
    tickets: Mapped[List["Ticket"]] = relationship(
        "Ticket",
        back_populates="creator",
        cascade="all, delete-orphan"
    )

class Ticket(Base):
    __tablename__ = "tickets"

    id: Mapped[int] = mapped_column(primary_key=True)
    ticket_number: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(500))
    description: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(50), default="open", index=True)
    creator_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    # Relationships
    creator: Mapped["User"] = relationship("User", back_populates="tickets")
```

### 2. Set Up the Database Connection

For async applications (recommended with FastAPI):

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

# Database URL
DATABASE_URL = "postgresql+asyncpg://user:password@localhost:5432/support_db"

# Create async engine
async_engine = create_async_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    echo=True  # Set to False in production
)

# Create session factory
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Dependency for FastAPI
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### 3. Create Tables

```python
async def init_db():
    """Initialize database tables"""
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# Run initialization
import asyncio
asyncio.run(init_db())
```

### 4. Perform CRUD Operations

**Create:**

```python
from sqlalchemy import select

async def create_ticket(
    session: AsyncSession,
    ticket_number: str,
    title: str,
    description: str,
    creator_id: int
) -> Ticket:
    """Create a new support ticket"""
    ticket = Ticket(
        ticket_number=ticket_number,
        title=title,
        description=description,
        creator_id=creator_id
    )
    session.add(ticket)
    await session.commit()
    await session.refresh(ticket)
    return ticket
```

**Read:**

```python
async def get_ticket_by_number(
    session: AsyncSession,
    ticket_number: str
) -> Optional[Ticket]:
    """Retrieve ticket by number"""
    stmt = (
        select(Ticket)
        .where(Ticket.ticket_number == ticket_number)
        .options(
            joinedload(Ticket.creator)  # Eager load the creator
        )
    )
    result = await session.execute(stmt)
    return result.scalar_one_or_none()
```

**Update:**

```python
from sqlalchemy import update

async def update_ticket_status(
    session: AsyncSession,
    ticket_id: int,
    new_status: str
) -> bool:
    """Update ticket status"""
    stmt = (
        update(Ticket)
        .where(Ticket.id == ticket_id)
        .values(status=new_status)
    )
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount > 0
```

**Delete:**

```python
from sqlalchemy import delete

async def delete_ticket(
    session: AsyncSession,
    ticket_id: int
) -> bool:
    """Delete a ticket"""
    stmt = delete(Ticket).where(Ticket.id == ticket_id)
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount > 0
```

## Core vs ORM Approaches

SQLAlchemy provides two main ways to work with databases:

### Core API (SQL Expression Language)

Direct SQL construction with Python objects - more explicit, closer to raw SQL:

```python
from sqlalchemy import select, insert, update, delete

# Explicit SQL construction
stmt = (
    select(Ticket.id, Ticket.title, User.full_name)
    .join(User, Ticket.creator_id == User.id)
    .where(Ticket.status == "open")
    .order_by(Ticket.created_at.desc())
)
result = await session.execute(stmt)
rows = result.all()
```

**Use when:**
- You need fine-grained control over SQL
- Building complex analytical queries
- Performance is critical
- Working with legacy schemas

### ORM API (Object-Relational Mapping)

Work with Python objects that map to database tables:

```python
from sqlalchemy import select
from sqlalchemy.orm import joinedload

# Object-oriented approach
stmt = (
    select(Ticket)
    .options(joinedload(Ticket.creator))
    .where(Ticket.status == "open")
    .order_by(Ticket.created_at.desc())
)
result = await session.execute(stmt)
tickets = result.scalars().all()

# Access as objects
for ticket in tickets:
    print(f"{ticket.title} by {ticket.creator.full_name}")
```

**Use when:**
- Building business logic with domain models
- Need automatic relationship handling
- Want type safety and IDE support
- Rapid development is important

**Best Practice**: Use ORM for business logic and Core for complex analytics queries.

## Key Features for Support Teams

### 1. Relationship Management

Automatically handle relationships between tickets, users, comments, and attachments:

```python
# Access related objects seamlessly
ticket = await get_ticket(session, ticket_id)
print(f"Creator: {ticket.creator.full_name}")
print(f"Comments: {len(ticket.comments)}")
for comment in ticket.comments:
    print(f"  - {comment.author.full_name}: {comment.content}")
```

### 2. Eager Loading (Avoid N+1 Queries)

Load related data efficiently in a single query:

```python
from sqlalchemy.orm import joinedload, selectinload

# Load ticket with all related data
stmt = (
    select(Ticket)
    .options(
        joinedload(Ticket.creator),  # One-to-one/many-to-one
        selectinload(Ticket.comments).joinedload(Comment.author),  # Collections
        selectinload(Ticket.attachments)
    )
    .where(Ticket.id == ticket_id)
)
result = await session.execute(stmt)
ticket = result.unique().scalar_one()
```

### 3. Advanced Filtering

Build complex queries with multiple conditions:

```python
from sqlalchemy import and_, or_, func

stmt = (
    select(Ticket)
    .where(
        and_(
            Ticket.status.in_(["open", "in_progress"]),
            or_(
                Ticket.priority == "urgent",
                func.date_part("day", func.now() - Ticket.created_at) > 7
            ),
            Ticket.title.ilike("%payment%")
        )
    )
)
```

### 4. Aggregation and Analytics

Generate reports and statistics:

```python
from sqlalchemy import func, case

# Count tickets by status
stmt = (
    select(
        Ticket.status,
        func.count(Ticket.id).label("count")
    )
    .group_by(Ticket.status)
)
result = await session.execute(stmt)
status_counts = {row[0]: row[1] for row in result}
```

### 5. Transaction Management

Ensure data consistency with proper transaction handling:

```python
async def transfer_ticket_ownership(
    session: AsyncSession,
    ticket_id: int,
    new_owner_id: int
):
    """Transfer ticket with automatic rollback on error"""
    async with session.begin():  # Automatic commit/rollback
        ticket = await session.get(Ticket, ticket_id)
        if not ticket:
            raise ValueError("Ticket not found")

        old_owner_id = ticket.creator_id
        ticket.creator_id = new_owner_id

        # Create audit log
        audit = AuditLog(
            action="transfer_ownership",
            ticket_id=ticket_id,
            old_value=old_owner_id,
            new_value=new_owner_id
        )
        session.add(audit)
        # Commits automatically if no exception
```

### 6. Connection Pooling

Handle concurrent requests efficiently:

```python
async_engine = create_async_engine(
    DATABASE_URL,
    pool_size=10,        # Maintain 10 connections
    max_overflow=20,     # Allow 20 additional connections
    pool_timeout=30,     # Wait 30 seconds for connection
    pool_recycle=3600,   # Recycle connections after 1 hour
    pool_pre_ping=True   # Verify connection health
)
```

## Best Practices

### 1. Always Use Type Hints

```python
# Good
class User(Base):
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255))
    tickets: Mapped[List["Ticket"]] = relationship()

# Avoid (old style)
class User(Base):
    id = Column(Integer, primary_key=True)
    email = Column(String(255))
```

### 2. Use Eager Loading

```python
# Good - Single query
tickets = await session.execute(
    select(Ticket).options(joinedload(Ticket.creator))
)

# Avoid - N+1 queries
tickets = await session.execute(select(Ticket))
for ticket in tickets.scalars():
    print(ticket.creator.name)  # Separate query for each ticket!
```

### 3. Handle Sessions Properly

```python
# Good - Using FastAPI dependency
@app.get("/tickets/{ticket_id}")
async def get_ticket(
    ticket_id: int,
    session: AsyncSession = Depends(get_db)
):
    ticket = await session.get(Ticket, ticket_id)
    return ticket

# Avoid - Manual session management in routes
@app.get("/tickets/{ticket_id}")
async def get_ticket(ticket_id: int):
    session = AsyncSessionLocal()
    ticket = await session.get(Ticket, ticket_id)
    # Forgot to close session!
    return ticket
```

### 4. Use Indexes

```python
class Ticket(Base):
    __tablename__ = "tickets"

    # Index frequently queried columns
    ticket_number: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    status: Mapped[str] = mapped_column(String(50), index=True)
    creator_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
```

### 5. Implement Soft Deletes

```python
class Ticket(Base):
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    @hybrid_property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None

# Filter out soft-deleted records
stmt = select(Ticket).where(Ticket.deleted_at.is_(None))
```

## Common Pitfalls

### 1. N+1 Query Problem

**Problem:**
```python
# This creates N+1 queries (1 for tickets + N for each creator)
tickets = await session.execute(select(Ticket))
for ticket in tickets.scalars():
    print(ticket.creator.full_name)  # Lazy load triggers new query!
```

**Solution:**
```python
# Single query with eager loading
tickets = await session.execute(
    select(Ticket).options(joinedload(Ticket.creator))
)
for ticket in tickets.unique().scalars():
    print(ticket.creator.full_name)  # Already loaded!
```

### 2. Forgetting to Close Sessions

**Problem:**
```python
async def get_tickets():
    session = AsyncSessionLocal()
    tickets = await session.execute(select(Ticket))
    return tickets.scalars().all()
    # Session never closed - connection leak!
```

**Solution:**
```python
async def get_tickets():
    async with AsyncSessionLocal() as session:
        tickets = await session.execute(select(Ticket))
        return tickets.scalars().all()
    # Session automatically closed
```

### 3. Missing pool_pre_ping

**Problem:**
```python
engine = create_async_engine(DATABASE_URL)
# Stale connections will cause errors!
```

**Solution:**
```python
engine = create_async_engine(
    DATABASE_URL,
    pool_pre_ping=True  # Verify connections are alive
)
```

### 4. Mixing Sync and Async

**Problem:**
```python
# NEVER mix sync and async code!
async def bad_example():
    session = Session(engine)  # Sync session in async function!
    # This will cause problems
```

**Solution:**
```python
# Use async throughout
async def good_example():
    async with AsyncSessionLocal() as session:
        # All async operations
        result = await session.execute(select(Ticket))
```

### 5. Not Using Transactions

**Problem:**
```python
# Multiple operations without transaction
ticket = await session.get(Ticket, ticket_id)
ticket.status = "resolved"
await session.commit()  # Partial commit

audit = AuditLog(ticket_id=ticket_id, action="resolved")
session.add(audit)
await session.commit()  # If this fails, ticket is still resolved!
```

**Solution:**
```python
# Atomic transaction
async with session.begin():
    ticket = await session.get(Ticket, ticket_id)
    ticket.status = "resolved"

    audit = AuditLog(ticket_id=ticket_id, action="resolved")
    session.add(audit)
    # Both committed together or both rolled back
```

## Troubleshooting Guide

### Connection Issues

**Error:** `connection pool exceeded`

**Solution:**
```python
# Increase pool size or check for connection leaks
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,      # Increase from default 5
    max_overflow=40    # Increase from default 10
)
```

### Stale Connection Errors

**Error:** `server closed the connection unexpectedly`

**Solution:**
```python
# Enable pool_pre_ping
engine = create_async_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600  # Recycle connections every hour
)
```

### Lazy Loading in Async

**Error:** `greenlet_spawn has not been called`

**Solution:**
```python
# Always eager load relationships in async code
stmt = select(Ticket).options(
    joinedload(Ticket.creator),
    selectinload(Ticket.comments)
)
```

### Detached Instance Errors

**Error:** `Instance is not bound to a Session`

**Solution:**
```python
# Use expire_on_commit=False or refresh objects
SessionLocal = async_sessionmaker(
    bind=engine,
    expire_on_commit=False  # Keep objects usable after commit
)

# Or refresh explicitly
await session.refresh(ticket)
```

### Migration Conflicts

**Error:** `Alembic can't detect changes`

**Solution:**
```bash
# Ensure alembic.ini is configured correctly
# Check env.py imports all models
# Force autogenerate
alembic revision --autogenerate -m "migration" --head head
```

## Performance Tips

1. **Use EXPLAIN ANALYZE**: Understand query execution
   ```python
   from sqlalchemy import text
   result = await session.execute(text("EXPLAIN ANALYZE SELECT * FROM tickets"))
   ```

2. **Add Indexes**: Index foreign keys and filter columns
3. **Use Bulk Operations**: For large datasets
4. **Implement Caching**: Cache frequently accessed data
5. **Use Read Replicas**: Separate read and write operations
6. **Monitor Queries**: Log slow queries in production
7. **Optimize Joins**: Use appropriate join strategies
8. **Partition Large Tables**: By date or other criteria
9. **Use Materialized Views**: For complex analytics
10. **Enable Query Logging**: During development only

## Next Steps

1. Read the complete SKILL.md for advanced patterns
2. Explore EXAMPLES.md for 15+ practical examples
3. Set up Alembic for database migrations
4. Implement comprehensive tests with pytest
5. Monitor performance in production
6. Join the SQLAlchemy community for support

## Additional Resources

- Official Documentation: https://docs.sqlalchemy.org/
- Alembic (Migrations): https://alembic.sqlalchemy.org/
- FastAPI Integration: https://fastapi.tiangolo.com/tutorial/sql-databases/
- PostgreSQL Guide: https://www.postgresql.org/docs/
- Community Discord: https://discord.gg/sqlalchemy

---

Built with expertise for customer support tech enablement teams.
