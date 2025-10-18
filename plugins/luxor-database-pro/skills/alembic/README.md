# Alembic Database Migrations for Customer Support Systems

## Overview

This skill provides comprehensive guidance for managing database schema evolution using Alembic in customer support environments. Whether you're building a ticketing system, managing customer data, or maintaining complex support infrastructure, Alembic helps you safely evolve your database schema while preserving data integrity.

## What is Alembic?

Alembic is a lightweight database migration tool for SQLAlchemy that provides:

- **Version Control for Database Schemas**: Track every change to your database structure
- **Automated Migration Generation**: Detect schema differences automatically
- **Safe Rollback Capabilities**: Revert changes when issues arise
- **Team Collaboration**: Merge schema changes from multiple developers
- **Production-Ready Workflows**: Deploy schema changes with confidence

For customer support teams, this means you can:
- Add new features without database downtime
- Safely modify ticket tracking schemas
- Migrate data as business requirements evolve
- Maintain consistency across dev, staging, and production environments

## Quick Start

### Installation

```bash
# Install Alembic with PostgreSQL support
pip install alembic sqlalchemy psycopg2-binary

# Or add to your requirements.txt
echo "alembic>=1.13.0" >> requirements.txt
echo "sqlalchemy>=2.0.0" >> requirements.txt
echo "psycopg2-binary>=2.9.0" >> requirements.txt
pip install -r requirements.txt
```

### Initialize Your Project

```bash
# Initialize Alembic in your project
alembic init alembic

# This creates:
# - alembic/                 Directory for migrations
# - alembic/versions/        Individual migration files
# - alembic/env.py          Environment configuration
# - alembic.ini             Main configuration file
```

### Configure Database Connection

Edit `alembic.ini` to set your database URL:

```ini
# For development
sqlalchemy.url = postgresql://user:password@localhost/support_db

# For production, use environment variables (see below)
```

Better practice - use environment variables in `alembic/env.py`:

```python
import os
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

# Import your SQLAlchemy models
from myapp.models import Base

config = context.config

# Override database URL from environment
database_url = os.getenv(
    'DATABASE_URL',
    'postgresql://localhost/support_dev'
)
config.set_main_option('sqlalchemy.url', database_url)

# Set target metadata for autogenerate
target_metadata = Base.metadata
```

### Create Your First Migration

**Option 1: Manual Migration**

```bash
# Create empty migration file
alembic revision -m "create initial support tables"
```

This generates a file like `alembic/versions/abc123_create_initial_support_tables.py`:

```python
"""create initial support tables

Revision ID: abc123
Revises:
Create Date: 2025-01-15 10:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = 'abc123'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Create tickets table
    op.create_table(
        'tickets',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('title', sa.String(200), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('status', sa.String(50), nullable=False, server_default='open'),
        sa.Column('priority', sa.String(20), nullable=False, server_default='normal'),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
    )

    # Create indexes for common queries
    op.create_index('ix_tickets_status', 'tickets', ['status'])
    op.create_index('ix_tickets_created_at', 'tickets', ['created_at'])

def downgrade() -> None:
    op.drop_index('ix_tickets_created_at', 'tickets')
    op.drop_index('ix_tickets_status', 'tickets')
    op.drop_table('tickets')
```

**Option 2: Autogenerate Migration**

First, define your models using SQLAlchemy:

```python
# myapp/models.py
from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class Ticket(Base):
    __tablename__ = 'tickets'

    id = Column(Integer, primary_key=True)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    status = Column(String(50), nullable=False, default='open')
    priority = Column(String(20), nullable=False, default='normal')
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
```

Then autogenerate the migration:

```bash
# Alembic compares your models to the database and generates migration
alembic revision --autogenerate -m "create initial support tables"
```

**Important**: Always review autogenerated migrations before running them!

### Apply Migrations

```bash
# Apply all pending migrations to database
alembic upgrade head

# You should see output like:
# INFO  [alembic.runtime.migration] Running upgrade  -> abc123, create initial support tables
```

### Check Migration Status

```bash
# Show current database revision
alembic current

# Show migration history
alembic history

# Show detailed current status
alembic current --verbose
```

## Key Features for Support Teams

### 1. Safe Schema Evolution

Modify your support system database without downtime or data loss:

```bash
# Add a new column to track customer satisfaction
alembic revision -m "add satisfaction rating to tickets"
```

```python
def upgrade() -> None:
    op.add_column('tickets',
        sa.Column('satisfaction_rating', sa.Integer(), nullable=True)
    )

def downgrade() -> None:
    op.drop_column('tickets', 'satisfaction_rating')
```

### 2. Data Migrations

Transform existing data during schema changes:

```python
"""convert ticket priorities to new system

Revision ID: def456
Revises: abc123
"""

from alembic import op
from sqlalchemy.sql import table, column

def upgrade() -> None:
    # Map old priority values to new ones
    tickets = table('tickets', column('priority', sa.String))

    connection = op.get_bind()
    connection.execute(
        tickets.update().where(
            tickets.c.priority == 'high'
        ).values(priority='urgent')
    )

def downgrade() -> None:
    # Reverse the mapping
    tickets = table('tickets', column('priority', sa.String))

    connection = op.get_bind()
    connection.execute(
        tickets.update().where(
            tickets.c.priority == 'urgent'
        ).values(priority='high')
    )
```

### 3. Rollback Capabilities

If something goes wrong, easily revert:

```bash
# Rollback last migration
alembic downgrade -1

# Rollback to specific revision
alembic downgrade abc123

# Rollback to empty database
alembic downgrade base
```

### 4. Branch Management

Handle parallel development from multiple teams:

```bash
# Create feature branch for reporting module
alembic revision -m "reporting branch" \
    --branch-label=reporting \
    --head=base

# Create migration on specific branch
alembic revision -m "add report tables" \
    --head=reporting@head

# Merge branches when ready
alembic merge -m "merge reporting into main" \
    main@head reporting@head
```

### 5. Testing Migrations

Ensure migrations work before production:

```python
# tests/test_migrations.py
import pytest
from alembic import command
from alembic.config import Config

def test_migration_upgrade_downgrade():
    config = Config("alembic.ini")
    config.set_main_option("sqlalchemy.url", "postgresql://localhost/test_db")

    # Test upgrade
    command.upgrade(config, "head")

    # Test downgrade
    command.downgrade(config, "base")

    # Test upgrade again
    command.upgrade(config, "head")
```

## Common Customer Support Use Cases

### Use Case 1: Adding User Assignment to Tickets

```bash
alembic revision -m "add user assignment to tickets"
```

```python
def upgrade() -> None:
    # Add user_id column
    op.add_column('tickets',
        sa.Column('assigned_user_id', sa.Integer(), nullable=True)
    )

    # Create foreign key to users table
    op.create_foreign_key(
        'fk_tickets_assigned_user',
        'tickets', 'users',
        ['assigned_user_id'], ['id'],
        ondelete='SET NULL'
    )

    # Add index for performance
    op.create_index(
        'ix_tickets_assigned_user_id',
        'tickets',
        ['assigned_user_id']
    )

def downgrade() -> None:
    op.drop_index('ix_tickets_assigned_user_id', 'tickets')
    op.drop_constraint('fk_tickets_assigned_user', 'tickets', type_='foreignkey')
    op.drop_column('tickets', 'assigned_user_id')
```

### Use Case 2: Tracking Ticket Resolution Time

```bash
alembic revision --autogenerate -m "add resolution tracking"
```

```python
def upgrade() -> None:
    # Add resolved_at timestamp
    op.add_column('tickets',
        sa.Column('resolved_at', sa.DateTime(), nullable=True)
    )

    # Add computed resolution time in seconds
    op.add_column('tickets',
        sa.Column('resolution_time_seconds', sa.Integer(), nullable=True)
    )

def downgrade() -> None:
    op.drop_column('tickets', 'resolution_time_seconds')
    op.drop_column('tickets', 'resolved_at')
```

### Use Case 3: Customer Satisfaction Survey

```bash
alembic revision -m "create satisfaction survey table"
```

```python
def upgrade() -> None:
    op.create_table(
        'satisfaction_surveys',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('ticket_id', sa.Integer(), nullable=False),
        sa.Column('rating', sa.Integer(), nullable=False),
        sa.Column('feedback', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(
            ['ticket_id'], ['tickets.id'],
            ondelete='CASCADE'
        )
    )

    op.create_index('ix_surveys_ticket_id', 'satisfaction_surveys', ['ticket_id'])
    op.create_index('ix_surveys_rating', 'satisfaction_surveys', ['rating'])

def downgrade() -> None:
    op.drop_index('ix_surveys_rating', 'satisfaction_surveys')
    op.drop_index('ix_surveys_ticket_id', 'satisfaction_surveys')
    op.drop_table('satisfaction_surveys')
```

## Migration Workflow Best Practices

### Development Workflow

1. **Make model changes** in your SQLAlchemy models
2. **Generate migration**: `alembic revision --autogenerate -m "description"`
3. **Review migration file** - autogenerate isn't perfect!
4. **Test locally**: `alembic upgrade head`
5. **Test downgrade**: `alembic downgrade -1`
6. **Commit migration file** to version control

### Staging Workflow

1. **Deploy code** to staging environment
2. **Backup staging database**
3. **Run migrations**: `alembic upgrade head`
4. **Test application** thoroughly
5. **Test rollback** if time permits: `alembic downgrade -1` then `alembic upgrade head`

### Production Workflow

1. **Schedule maintenance window** (if needed)
2. **Create production backup**
3. **Deploy code** to production
4. **Run migrations**: `alembic upgrade head`
5. **Monitor application** for issues
6. **Keep rollback plan ready**

### Emergency Rollback

```bash
# If migration causes issues in production
alembic downgrade -1

# Or downgrade to specific known-good revision
alembic downgrade abc123

# Then deploy previous code version
```

## Troubleshooting

### Problem: "Multiple heads exist"

**Cause**: You have divergent migration branches that need merging.

**Solution**:
```bash
# Show all heads
alembic heads

# Merge them
alembic merge heads -m "merge migration branches"

# Apply the merge
alembic upgrade head
```

### Problem: "Can't locate revision identified by 'xyz'"

**Cause**: Migration file missing or database revision table corrupted.

**Solution**:
```bash
# Check current database state
alembic current

# Check migration history
alembic history

# If needed, manually stamp database to correct revision
alembic stamp head  # or specific revision
```

### Problem: Migration fails partway through

**Cause**: SQL error, constraint violation, or data issue.

**Solution**:
```bash
# 1. Check current state
alembic current

# 2. Fix the underlying issue (database constraint, data problem, etc.)

# 3. Try migration again
alembic upgrade head

# 4. If migration script needs fixing:
#    - Edit the migration file
#    - Stamp to previous revision
#    - Run migration again
alembic stamp previous_revision
alembic upgrade head
```

### Problem: Autogenerate creates too many/wrong changes

**Cause**: Difference in type comparison or server defaults.

**Solution**: Configure `env.py` to filter or customize autogenerate:

```python
def run_migrations_online():
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
        compare_server_default=True,
        include_object=include_object,
        include_name=include_name
    )

def include_object(object, name, type_, reflected, compare_to):
    """Filter out test tables and temp tables"""
    if type_ == "table" and (name.startswith("test_") or name.startswith("temp_")):
        return False
    return True

def include_name(name, type_, parent_names):
    """Filter schemas"""
    if type_ == "schema" and name in ("information_schema", "pg_catalog"):
        return False
    return True
```

## File Size and Structure Reference

This skill package includes:

1. **SKILL.md** (20KB+): Comprehensive skill definition with all migration scenarios
2. **README.md** (This file, 10KB+): Quick start and overview
3. **EXAMPLES.md** (15KB+): 15+ practical, runnable examples

## Additional Resources

- **Official Documentation**: https://alembic.sqlalchemy.org/
- **SQLAlchemy Documentation**: https://docs.sqlalchemy.org/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/

## Getting Help

Common questions:

**Q: Should I use manual or autogenerate for migrations?**
A: Use autogenerate for simple schema changes, but always review the generated code. Use manual migrations for complex data transformations or when you need precise control.

**Q: How do I handle large data migrations?**
A: Process data in batches to avoid memory issues and reduce database lock time. See the data migration examples in EXAMPLES.md.

**Q: Can I run migrations in production without downtime?**
A: Yes, using multi-phase migrations. Add new columns as nullable, populate data in background, then make required. See zero-downtime migrations in SKILL.md.

**Q: How do I test migrations?**
A: Write tests that apply migrations to a test database, verify schema changes, and test upgrade/downgrade cycles. See testing section in SKILL.md.

**Q: What if multiple developers create migrations at the same time?**
A: Alembic will create multiple heads. Merge them using `alembic merge heads`. Consider using branch labels for team-specific work.

## Next Steps

1. Review **SKILL.md** for comprehensive documentation
2. Check **EXAMPLES.md** for practical, copy-paste examples
3. Set up your first migration following the Quick Start above
4. Practice upgrade/downgrade cycles in development
5. Implement CI/CD checks for migrations
6. Establish team migration guidelines

## Support

For customer support specific questions about this skill package, consult your team lead or check your internal documentation.

For Alembic-specific issues:
- Check the official documentation
- Search GitHub issues: https://github.com/sqlalchemy/alembic/issues
- Ask on Stack Overflow with the `alembic` tag
