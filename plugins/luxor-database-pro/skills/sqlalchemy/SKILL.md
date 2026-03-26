---
name: "sqlalchemy-orm-patterns"
description: "SQLAlchemy 2.0+ ORM patterns for model definitions, session management, async operations, relationship loading, query optimization, and Alembic migrations. Use when building Python database layers with SQLAlchemy, integrating with FastAPI async sessions, optimizing N+1 queries, or managing schema migrations."
---

# SQLAlchemy ORM Patterns

Production patterns for SQLAlchemy 2.0+ covering model definitions, async sessions, relationship loading, query optimization, and migrations.

## Model Definitions

```python
from sqlalchemy import String, Integer, Text, DateTime, ForeignKey, Enum, Boolean, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from datetime import datetime
import enum

class Base(DeclarativeBase):
    pass

class TicketStatus(enum.Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(100), unique=True)
    role: Mapped[str] = mapped_column(String(20), default="customer")
    is_active: Mapped[bool] = mapped_column(default=True)

    tickets: Mapped[list["Ticket"]] = relationship(back_populates="assigned_agent")

class Ticket(Base):
    __tablename__ = "tickets"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    description: Mapped[str] = mapped_column(Text)
    status: Mapped[TicketStatus] = mapped_column(Enum(TicketStatus), default=TicketStatus.OPEN, index=True)
    assigned_to: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    assigned_agent: Mapped[User | None] = relationship(back_populates="tickets")
    comments: Mapped[list["Comment"]] = relationship(back_populates="ticket", cascade="all, delete-orphan")
```

## Async Session Management (FastAPI)

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost/support_db",
    pool_size=10, max_overflow=20, pool_pre_ping=True,
)
async_session = async_sessionmaker(engine, expire_on_commit=False)

async def get_db():
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

## Query Patterns

```python
from sqlalchemy import select, func, and_, or_

# Basic select with filtering
stmt = select(Ticket).where(
    and_(Ticket.status == TicketStatus.OPEN, Ticket.assigned_to.is_(None))
).order_by(Ticket.created_at.asc())
result = await session.execute(stmt)
tickets = result.scalars().all()

# Aggregation
stmt = select(Ticket.status, func.count(Ticket.id)).group_by(Ticket.status)
result = await session.execute(stmt)
status_counts = {status: count for status, count in result.all()}

# Pagination
stmt = select(Ticket).where(Ticket.status == TicketStatus.OPEN).offset(skip).limit(limit)

# Exists check
stmt = select(select(Ticket).where(Ticket.id == ticket_id).exists())
```

## Relationship Loading Strategies

```python
from sqlalchemy.orm import selectinload, joinedload, lazyload

# Eager load to prevent N+1 queries
stmt = select(Ticket).options(
    selectinload(Ticket.comments),       # Separate SELECT for comments
    joinedload(Ticket.assigned_agent),   # JOIN in same query
).where(Ticket.id == ticket_id)

# Subquery load for large collections
stmt = select(User).options(
    selectinload(User.tickets).selectinload(Ticket.comments)
)
```

## Bulk Operations

```python
from sqlalchemy import update, delete

# Bulk update
stmt = update(Ticket).where(
    Ticket.status == TicketStatus.OPEN,
    Ticket.created_at < cutoff_date
).values(status=TicketStatus.CLOSED)
await session.execute(stmt)

# Bulk insert
session.add_all([
    Ticket(title=f"Ticket {i}", description="Auto-created", status=TicketStatus.OPEN)
    for i in range(100)
])
await session.flush()

# Bulk delete
stmt = delete(Ticket).where(Ticket.status == TicketStatus.CLOSED, Ticket.created_at < archive_date)
await session.execute(stmt)
```

## Alembic Migrations

```bash
# Initialize Alembic
alembic init alembic

# Generate migration from model changes
alembic revision --autogenerate -m "add tickets table"

# Apply migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1
```

```python
# alembic/env.py — async configuration
from sqlalchemy.ext.asyncio import async_engine_from_config

async def run_async_migrations():
    connectable = async_engine_from_config(config.get_section(config.config_ini_section))
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
```

## Events & Hooks

```python
from sqlalchemy import event

@event.listens_for(Ticket, "before_update")
def ticket_before_update(mapper, connection, target):
    target.updated_at = datetime.utcnow()
    if target.status == TicketStatus.RESOLVED and not target.resolved_at:
        target.resolved_at = datetime.utcnow()
```

## Testing Patterns

```python
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

@pytest.fixture
async def db_session():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
    await engine.dispose()
```

See [EXAMPLES.md](EXAMPLES.md) for complete application examples including hybrid property patterns, custom types, and multi-tenant configurations.
