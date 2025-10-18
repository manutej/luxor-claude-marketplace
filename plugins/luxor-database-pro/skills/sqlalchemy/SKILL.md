---
name: SQLAlchemy ORM Expert
version: 1.0.0
description: Comprehensive SQLAlchemy skill for customer support tech enablement, covering ORM patterns, session management, query optimization, async operations, and PostgreSQL integration
author: Customer Support Tech Enablement Team
tags:
  - python
  - sqlalchemy
  - orm
  - postgresql
  - database
  - customer-support
  - backend
  - fastapi
  - async
  - testing
  - data-curation
context:
  - customer_support
  - technical_enablement
  - backend_engineering
  - data_management
dependencies:
  - sqlalchemy>=2.0
  - asyncpg
  - psycopg2-binary
  - alembic
  - pytest
  - pytest-asyncio
supported_frameworks:
  - FastAPI
  - Flask
  - Django
use_cases:
  - Support ticket management
  - User authentication and authorization
  - Data curation and bulk operations
  - Analytics and reporting
  - Audit trails and compliance
---

# SQLAlchemy ORM Expert Skill

## Overview

This skill provides comprehensive guidance for using SQLAlchemy 2.0+ in customer support systems, focusing on ORM patterns, session management, query optimization, async operations with FastAPI, and PostgreSQL integration. It covers everything from basic model definitions to advanced patterns for high-performance support applications.

## Core Competencies

### 1. Customer Support Data Models

When building customer support systems, you need robust data models that represent tickets, users, comments, attachments, and their relationships. SQLAlchemy's declarative mapping with type hints provides a clean, modern approach.

**Base Model Setup:**

```python
from datetime import datetime
from typing import Optional, List
from sqlalchemy import String, Integer, DateTime, Text, ForeignKey, Enum, Boolean
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func
import enum

class Base(DeclarativeBase):
    """Base class for all ORM models"""
    pass

class TicketStatus(enum.Enum):
    """Ticket status enumeration"""
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    WAITING_ON_CUSTOMER = "waiting_on_customer"
    RESOLVED = "resolved"
    CLOSED = "closed"

class TicketPriority(enum.Enum):
    """Ticket priority levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"
```

**User Model:**

```python
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_staff: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    last_login: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    # Relationships
    tickets_created: Mapped[List["Ticket"]] = relationship(
        "Ticket",
        back_populates="creator",
        foreign_keys="Ticket.creator_id",
        cascade="all, delete-orphan"
    )
    tickets_assigned: Mapped[List["Ticket"]] = relationship(
        "Ticket",
        back_populates="assignee",
        foreign_keys="Ticket.assignee_id"
    )
    comments: Mapped[List["Comment"]] = relationship(
        "Comment",
        back_populates="author",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email='{self.email}', name='{self.full_name}')>"
```

**Ticket Model:**

```python
class Ticket(Base):
    __tablename__ = "tickets"

    id: Mapped[int] = mapped_column(primary_key=True)
    ticket_number: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    # Status and priority
    status: Mapped[TicketStatus] = mapped_column(
        Enum(TicketStatus),
        default=TicketStatus.OPEN,
        nullable=False,
        index=True
    )
    priority: Mapped[TicketPriority] = mapped_column(
        Enum(TicketPriority),
        default=TicketPriority.MEDIUM,
        nullable=False,
        index=True
    )

    # Foreign keys
    creator_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    assignee_id: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), index=True)

    # Soft delete
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    # Relationships
    creator: Mapped["User"] = relationship(
        "User",
        back_populates="tickets_created",
        foreign_keys=[creator_id]
    )
    assignee: Mapped[Optional["User"]] = relationship(
        "User",
        back_populates="tickets_assigned",
        foreign_keys=[assignee_id]
    )
    comments: Mapped[List["Comment"]] = relationship(
        "Comment",
        back_populates="ticket",
        cascade="all, delete-orphan",
        order_by="Comment.created_at"
    )
    attachments: Mapped[List["Attachment"]] = relationship(
        "Attachment",
        back_populates="ticket",
        cascade="all, delete-orphan"
    )
    tags: Mapped[List["Tag"]] = relationship(
        "Tag",
        secondary="ticket_tags",
        back_populates="tickets"
    )

    def __repr__(self) -> str:
        return f"<Ticket(id={self.id}, number='{self.ticket_number}', status={self.status.value})>"
```

### 2. Relationship Patterns

**One-to-Many (Comments on Tickets):**

```python
class Comment(Base):
    __tablename__ = "comments"

    id: Mapped[int] = mapped_column(primary_key=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    is_internal: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Foreign keys
    ticket_id: Mapped[int] = mapped_column(ForeignKey("tickets.id"), nullable=False, index=True)
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )

    # Relationships
    ticket: Mapped["Ticket"] = relationship("Ticket", back_populates="comments")
    author: Mapped["User"] = relationship("User", back_populates="comments")

    def __repr__(self) -> str:
        return f"<Comment(id={self.id}, ticket_id={self.ticket_id}, author_id={self.author_id})>"
```

**Many-to-Many (Tags on Tickets):**

```python
from sqlalchemy import Table, Column

# Association table for many-to-many relationship
ticket_tags = Table(
    "ticket_tags",
    Base.metadata,
    Column("ticket_id", ForeignKey("tickets.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
    Column("created_at", DateTime(timezone=True), server_default=func.now())
)

class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    color: Mapped[str] = mapped_column(String(7), nullable=False)  # Hex color
    description: Mapped[Optional[str]] = mapped_column(String(500))

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )

    # Relationships
    tickets: Mapped[List["Ticket"]] = relationship(
        "Ticket",
        secondary=ticket_tags,
        back_populates="tags"
    )

    def __repr__(self) -> str:
        return f"<Tag(id={self.id}, name='{self.name}')>"
```

### 3. Session Management

**Synchronous Session Setup:**

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from contextlib import contextmanager

# Database URL
DATABASE_URL = "postgresql://user:password@localhost:5432/support_db"

# Create engine with connection pooling
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Verify connections before using
    pool_size=10,  # Number of connections to maintain
    max_overflow=20,  # Additional connections when pool is full
    echo=False,  # Set to True for SQL logging
)

# Create session factory
SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False  # Don't expire objects after commit
)

@contextmanager
def get_db_session() -> Session:
    """Context manager for database sessions"""
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
```

**Async Session Setup for FastAPI:**

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

# Async database URL (using asyncpg)
ASYNC_DATABASE_URL = "postgresql+asyncpg://user:password@localhost:5432/support_db"

# Create async engine
async_engine = create_async_engine(
    ASYNC_DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    echo=False,
)

# Create async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False
)

async def get_async_db() -> AsyncSession:
    """Dependency for FastAPI to get async database session"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### 4. Query Optimization and Eager Loading

**Avoiding N+1 Queries with Joined Load:**

```python
from sqlalchemy import select
from sqlalchemy.orm import joinedload, selectinload

async def get_tickets_with_details(
    session: AsyncSession,
    status: Optional[TicketStatus] = None
) -> List[Ticket]:
    """
    Fetch tickets with all related data in optimized queries.
    Uses joinedload for single-row relationships and selectinload for collections.
    """
    stmt = (
        select(Ticket)
        .options(
            joinedload(Ticket.creator),  # One-to-one/many-to-one: use joinedload
            joinedload(Ticket.assignee),
            selectinload(Ticket.comments).joinedload(Comment.author),  # Collections: use selectinload
            selectinload(Ticket.attachments),
            selectinload(Ticket.tags)
        )
        .where(Ticket.deleted_at.is_(None))  # Soft delete filter
    )

    if status:
        stmt = stmt.where(Ticket.status == status)

    stmt = stmt.order_by(Ticket.created_at.desc())

    result = await session.execute(stmt)
    return list(result.unique().scalars().all())
```

**Select In Load for Better Performance:**

```python
async def get_user_with_tickets(session: AsyncSession, user_id: int) -> Optional[User]:
    """
    Fetch user with all tickets using selectinload for better performance
    on large collections.
    """
    stmt = (
        select(User)
        .options(
            selectinload(User.tickets_created).selectinload(Ticket.comments),
            selectinload(User.tickets_assigned)
        )
        .where(User.id == user_id)
    )

    result = await session.execute(stmt)
    return result.unique().scalar_one_or_none()
```

### 5. Complex Queries and Filters

**Advanced Filtering:**

```python
from sqlalchemy import and_, or_, not_, func, case
from datetime import timedelta

async def search_tickets(
    session: AsyncSession,
    search_term: Optional[str] = None,
    status_list: Optional[List[TicketStatus]] = None,
    priority: Optional[TicketPriority] = None,
    assignee_id: Optional[int] = None,
    created_after: Optional[datetime] = None,
    tags: Optional[List[str]] = None,
    limit: int = 50,
    offset: int = 0
) -> tuple[List[Ticket], int]:
    """
    Advanced ticket search with multiple filters.
    Returns tickets and total count.
    """
    # Base query
    stmt = (
        select(Ticket)
        .options(
            joinedload(Ticket.creator),
            joinedload(Ticket.assignee),
            selectinload(Ticket.tags)
        )
        .where(Ticket.deleted_at.is_(None))
    )

    # Apply filters
    if search_term:
        search_filter = or_(
            Ticket.title.ilike(f"%{search_term}%"),
            Ticket.description.ilike(f"%{search_term}%"),
            Ticket.ticket_number.ilike(f"%{search_term}%")
        )
        stmt = stmt.where(search_filter)

    if status_list:
        stmt = stmt.where(Ticket.status.in_(status_list))

    if priority:
        stmt = stmt.where(Ticket.priority == priority)

    if assignee_id:
        stmt = stmt.where(Ticket.assignee_id == assignee_id)

    if created_after:
        stmt = stmt.where(Ticket.created_at >= created_after)

    if tags:
        stmt = stmt.join(Ticket.tags).where(Tag.name.in_(tags))

    # Count query
    count_stmt = select(func.count()).select_from(stmt.subquery())
    count_result = await session.execute(count_stmt)
    total = count_result.scalar_one()

    # Apply ordering and pagination
    stmt = stmt.order_by(Ticket.created_at.desc()).limit(limit).offset(offset)

    result = await session.execute(stmt)
    tickets = list(result.unique().scalars().all())

    return tickets, total
```

### 6. Aggregation Queries for Analytics

**Ticket Statistics:**

```python
from sqlalchemy import func, case, extract, literal_column
from typing import Dict, Any

async def get_ticket_statistics(
    session: AsyncSession,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> Dict[str, Any]:
    """
    Get comprehensive ticket statistics for analytics dashboard.
    """
    # Base filter
    base_filter = Ticket.deleted_at.is_(None)
    if start_date:
        base_filter = and_(base_filter, Ticket.created_at >= start_date)
    if end_date:
        base_filter = and_(base_filter, Ticket.created_at <= end_date)

    # Count by status
    status_stmt = (
        select(
            Ticket.status,
            func.count(Ticket.id).label("count")
        )
        .where(base_filter)
        .group_by(Ticket.status)
    )
    status_result = await session.execute(status_stmt)
    status_counts = {row[0].value: row[1] for row in status_result}

    # Count by priority
    priority_stmt = (
        select(
            Ticket.priority,
            func.count(Ticket.id).label("count")
        )
        .where(base_filter)
        .group_by(Ticket.priority)
    )
    priority_result = await session.execute(priority_stmt)
    priority_counts = {row[0].value: row[1] for row in priority_result}

    # Average resolution time
    resolution_stmt = (
        select(
            func.avg(
                func.extract("epoch", Ticket.resolved_at - Ticket.created_at)
            ).label("avg_seconds")
        )
        .where(
            and_(
                base_filter,
                Ticket.resolved_at.is_not(None)
            )
        )
    )
    resolution_result = await session.execute(resolution_stmt)
    avg_resolution_seconds = resolution_result.scalar_one() or 0

    # Tickets per assignee
    assignee_stmt = (
        select(
            User.full_name,
            func.count(Ticket.id).label("ticket_count"),
            func.avg(
                case(
                    (Ticket.resolved_at.is_not(None),
                     func.extract("epoch", Ticket.resolved_at - Ticket.created_at))
                )
            ).label("avg_resolution_time")
        )
        .join(Ticket.assignee)
        .where(base_filter)
        .group_by(User.id, User.full_name)
        .order_by(func.count(Ticket.id).desc())
    )
    assignee_result = await session.execute(assignee_stmt)
    assignee_stats = [
        {
            "assignee": row[0],
            "ticket_count": row[1],
            "avg_resolution_hours": (row[2] / 3600) if row[2] else None
        }
        for row in assignee_result
    ]

    return {
        "status_counts": status_counts,
        "priority_counts": priority_counts,
        "avg_resolution_hours": avg_resolution_seconds / 3600,
        "assignee_stats": assignee_stats
    }
```

### 7. Bulk Operations for Data Curation

**Bulk Insert:**

```python
async def bulk_create_tickets(
    session: AsyncSession,
    tickets_data: List[Dict[str, Any]]
) -> List[Ticket]:
    """
    Efficiently create multiple tickets in a single transaction.
    """
    tickets = [Ticket(**data) for data in tickets_data]
    session.add_all(tickets)
    await session.flush()  # Flush to get IDs without committing
    return tickets

async def bulk_insert_with_return(
    session: AsyncSession,
    tickets_data: List[Dict[str, Any]]
) -> List[Ticket]:
    """
    Bulk insert with RETURNING clause for PostgreSQL.
    """
    from sqlalchemy.dialects.postgresql import insert

    stmt = insert(Ticket).returning(Ticket)
    result = await session.execute(stmt, tickets_data)
    tickets = list(result.scalars().all())
    return tickets
```

**Bulk Update:**

```python
from sqlalchemy import update

async def bulk_update_ticket_status(
    session: AsyncSession,
    ticket_ids: List[int],
    new_status: TicketStatus
) -> int:
    """
    Update status for multiple tickets efficiently.
    Returns number of updated rows.
    """
    stmt = (
        update(Ticket)
        .where(
            and_(
                Ticket.id.in_(ticket_ids),
                Ticket.deleted_at.is_(None)
            )
        )
        .values(
            status=new_status,
            updated_at=func.now()
        )
    )
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount

async def bulk_assign_tickets(
    session: AsyncSession,
    ticket_ids: List[int],
    assignee_id: int
) -> int:
    """
    Bulk assign tickets to a user.
    """
    stmt = (
        update(Ticket)
        .where(Ticket.id.in_(ticket_ids))
        .values(
            assignee_id=assignee_id,
            status=TicketStatus.IN_PROGRESS,
            updated_at=func.now()
        )
    )
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount
```

### 8. Soft Deletes and Audit Trails

**Soft Delete Implementation:**

```python
async def soft_delete_ticket(session: AsyncSession, ticket_id: int) -> bool:
    """
    Soft delete a ticket by setting deleted_at timestamp.
    """
    stmt = (
        update(Ticket)
        .where(
            and_(
                Ticket.id == ticket_id,
                Ticket.deleted_at.is_(None)
            )
        )
        .values(deleted_at=func.now())
    )
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount > 0

async def restore_ticket(session: AsyncSession, ticket_id: int) -> bool:
    """
    Restore a soft-deleted ticket.
    """
    stmt = (
        update(Ticket)
        .where(Ticket.id == ticket_id)
        .values(deleted_at=None)
    )
    result = await session.execute(stmt)
    await session.commit()
    return result.rowcount > 0
```

**Audit Trail Model:**

```python
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(primary_key=True)
    table_name: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    record_id: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    action: Mapped[str] = mapped_column(String(50), nullable=False)  # CREATE, UPDATE, DELETE
    user_id: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), index=True)
    changes: Mapped[Optional[Dict]] = mapped_column(JSON)  # Store before/after values
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True
    )

    user: Mapped[Optional["User"]] = relationship("User")
```

### 9. Event Listeners for Automation

**Automatic Audit Logging:**

```python
from sqlalchemy import event
from sqlalchemy.orm import Session

@event.listens_for(Ticket, "after_insert")
def log_ticket_created(mapper, connection, target):
    """Automatically log ticket creation"""
    audit_log = AuditLog(
        table_name="tickets",
        record_id=target.id,
        action="CREATE",
        changes={"ticket_number": target.ticket_number, "status": target.status.value}
    )
    session = Session(bind=connection)
    session.add(audit_log)

@event.listens_for(Ticket, "after_update")
def log_ticket_updated(mapper, connection, target):
    """Automatically log ticket updates"""
    changes = {}
    for attr in ["status", "priority", "assignee_id"]:
        hist = getattr(mapper.get_property(attr), "impl").get_history(target, mapper)
        if hist.has_changes():
            changes[attr] = {"old": hist.deleted[0] if hist.deleted else None,
                            "new": hist.added[0] if hist.added else None}

    if changes:
        audit_log = AuditLog(
            table_name="tickets",
            record_id=target.id,
            action="UPDATE",
            changes=changes
        )
        session = Session(bind=connection)
        session.add(audit_log)
```

### 10. Hybrid Properties and Expressions

**Computed Properties:**

```python
from sqlalchemy.ext.hybrid import hybrid_property, hybrid_method

class Ticket(Base):
    # ... existing fields ...

    @hybrid_property
    def is_overdue(self) -> bool:
        """Check if ticket is overdue (open for more than 7 days)"""
        if self.status in [TicketStatus.RESOLVED, TicketStatus.CLOSED]:
            return False
        return (datetime.utcnow() - self.created_at).days > 7

    @is_overdue.expression
    def is_overdue(cls):
        """SQL expression for is_overdue"""
        return and_(
            cls.status.notin_([TicketStatus.RESOLVED, TicketStatus.CLOSED]),
            func.date_part("day", func.now() - cls.created_at) > 7
        )

    @hybrid_property
    def response_time_hours(self) -> Optional[float]:
        """Time to first comment in hours"""
        if not self.comments:
            return None
        first_comment = min(self.comments, key=lambda c: c.created_at)
        delta = first_comment.created_at - self.created_at
        return delta.total_seconds() / 3600

    @hybrid_method
    def is_priority_escalation_needed(self, hours: int = 24) -> bool:
        """Check if priority escalation is needed"""
        if self.status == TicketStatus.OPEN:
            age_hours = (datetime.utcnow() - self.created_at).total_seconds() / 3600
            return age_hours > hours
        return False
```

### 11. Connection Pooling and Performance

**Optimized Engine Configuration:**

```python
from sqlalchemy.pool import QueuePool

# Production-grade engine configuration
production_engine = create_async_engine(
    ASYNC_DATABASE_URL,
    poolclass=QueuePool,
    pool_size=20,  # Maintain 20 connections
    max_overflow=40,  # Allow 40 additional connections
    pool_timeout=30,  # Wait 30 seconds for connection
    pool_recycle=3600,  # Recycle connections after 1 hour
    pool_pre_ping=True,  # Verify connection health
    echo_pool=False,  # Disable pool logging in production
    echo=False,  # Disable SQL logging in production
    connect_args={
        "server_settings": {"jit": "off"},  # Disable JIT for PostgreSQL
        "command_timeout": 60,
        "timeout": 30,
    }
)
```

### 12. Testing with Pytest

**Pytest Fixtures:**

```python
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

@pytest.fixture(scope="session")
def test_database_url():
    """Test database URL"""
    return "postgresql+asyncpg://test_user:test_pass@localhost:5432/test_support_db"

@pytest.fixture(scope="session")
async def async_engine(test_database_url):
    """Create test engine"""
    engine = create_async_engine(test_database_url, echo=True)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()

@pytest.fixture
async def async_session(async_engine):
    """Create test session"""
    async_session_factory = async_sessionmaker(
        bind=async_engine,
        class_=AsyncSession,
        expire_on_commit=False
    )

    async with async_session_factory() as session:
        yield session
        await session.rollback()

@pytest.fixture
async def test_user(async_session):
    """Create test user"""
    user = User(
        email="test@example.com",
        full_name="Test User",
        password_hash="hashed_password",
        is_active=True
    )
    async_session.add(user)
    await async_session.commit()
    await async_session.refresh(user)
    return user
```

### 13. Alembic Migrations

**Migration Setup:**

```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Create support tables"

# Apply migration
alembic upgrade head

# Rollback migration
alembic downgrade -1
```

**Migration Template:**

```python
"""Create support tables

Revision ID: 001
Create Date: 2025-01-15 10:00:00
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = '001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('full_name', sa.String(length=255), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('is_staff', sa.Boolean(), nullable=False),
        sa.Column('password_hash', sa.String(length=255), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('last_login', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'])

def downgrade() -> None:
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
```

## Best Practices

1. **Always use type hints** with Mapped[] for better IDE support and validation
2. **Use indexes** on foreign keys and frequently queried columns
3. **Implement soft deletes** for data recovery and audit compliance
4. **Use selectinload** for collections to avoid N+1 queries
5. **Use joinedload** for single-row relationships (many-to-one)
6. **Enable pool_pre_ping** to handle stale connections
7. **Set expire_on_commit=False** when using async sessions
8. **Use transactions** properly with proper rollback handling
9. **Implement audit logging** for compliance and debugging
10. **Write comprehensive tests** with isolated test databases

## Common Pitfalls

1. **N+1 Query Problem**: Always use eager loading for relationships
2. **Missing Indexes**: Add indexes on foreign keys and filter columns
3. **Not Closing Sessions**: Use context managers or FastAPI dependencies
4. **Lazy Loading in Async**: Will fail - always eager load or use async methods
5. **Mixing Sync and Async**: Never mix sync and async sessions
6. **Not Using Transactions**: Always wrap related operations in transactions
7. **Forgetting pool_pre_ping**: Results in stale connection errors
8. **Not Setting Timezones**: Always use timezone-aware DateTime
9. **Inefficient Bulk Operations**: Use bulk_insert_mappings for large datasets
10. **Not Testing Query Performance**: Always use EXPLAIN ANALYZE

## Performance Tuning

1. **Use EXPLAIN ANALYZE** to understand query execution plans
2. **Add composite indexes** for common filter combinations
3. **Use partial indexes** for filtered queries
4. **Implement query result caching** with Redis
5. **Use read replicas** for analytics queries
6. **Partition large tables** by date ranges
7. **Use connection pooling** appropriately for your workload
8. **Monitor slow queries** with pg_stat_statements
9. **Use materialized views** for complex analytics
10. **Implement query timeout** to prevent long-running queries

## Security Considerations

1. **Never expose raw database errors** to end users
2. **Use parameterized queries** (SQLAlchemy does this automatically)
3. **Validate user input** before database operations
4. **Implement row-level security** in PostgreSQL
5. **Use SSL connections** in production
6. **Rotate database credentials** regularly
7. **Limit database user permissions** to minimum required
8. **Implement rate limiting** on expensive queries
9. **Log all data access** for audit trails
10. **Encrypt sensitive data** at rest and in transit

## Additional Resources

- SQLAlchemy 2.0 Documentation: https://docs.sqlalchemy.org/en/21/
- Alembic Documentation: https://alembic.sqlalchemy.org/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- FastAPI with SQLAlchemy: https://fastapi.tiangolo.com/tutorial/sql-databases/
- AsyncPG Documentation: https://magicstack.github.io/asyncpg/

---

This skill provides comprehensive guidance for building production-ready customer support systems with SQLAlchemy. Follow these patterns for maintainable, performant, and scalable applications.
