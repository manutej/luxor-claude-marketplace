# Alembic Migration Examples for Customer Support Systems

This document provides 15+ practical, runnable examples for common database migration scenarios in customer support environments. Each example includes complete code that you can adapt for your own use cases.

## Table of Contents

1. [Initial Database Setup](#example-1-initial-database-setup)
2. [Adding Columns to Existing Table](#example-2-adding-columns-to-existing-table)
3. [Creating Performance Indexes](#example-3-creating-performance-indexes)
4. [Adding Tables with Foreign Keys](#example-4-adding-tables-with-foreign-keys)
5. [Modifying Column Types Safely](#example-5-modifying-column-types-safely)
6. [Data Migration for Status Values](#example-6-data-migration-for-status-values)
7. [Autogenerate from SQLAlchemy Models](#example-7-autogenerate-from-sqlalchemy-models)
8. [Complex Manual Migration](#example-8-complex-manual-migration)
9. [Downgrade Procedures](#example-9-downgrade-procedures)
10. [Creating Migration Branches](#example-10-creating-migration-branches)
11. [Merging Migration Branches](#example-11-merging-migration-branches)
12. [Online Migration with Minimal Downtime](#example-12-online-migration-with-minimal-downtime)
13. [Testing Migrations with Pytest](#example-13-testing-migrations-with-pytest)
14. [Rolling Back Failed Migrations](#example-14-rolling-back-failed-migrations)
15. [Production Deployment Workflow](#example-15-production-deployment-workflow)
16. [Batch Data Migration](#example-16-batch-data-migration)
17. [Adding Enums and Constraints](#example-17-adding-enums-and-constraints)
18. [Multi-Table Data Migration](#example-18-multi-table-data-migration)

---

## Example 1: Initial Database Setup

**Scenario**: Setting up the initial schema for a customer support ticketing system.

**Command**:
```bash
alembic revision -m "create initial support schema"
```

**Migration File** (`versions/001_create_initial_support_schema.py`):

```python
"""create initial support schema

Revision ID: 001_initial
Revises:
Create Date: 2025-01-15 10:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '001_initial'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, unique=True),
        sa.Column('full_name', sa.String(200), nullable=False),
        sa.Column('role', sa.String(50), nullable=False, server_default='agent'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()'))
    )

    # Create customers table
    op.create_table(
        'customers',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, unique=True),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('company', sa.String(200), nullable=True),
        sa.Column('phone', sa.String(50), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()'))
    )

    # Create tickets table
    op.create_table(
        'tickets',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('assigned_user_id', sa.Integer(), nullable=True),
        sa.Column('subject', sa.String(500), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('status', sa.String(50), nullable=False, server_default='open'),
        sa.Column('priority', sa.String(20), nullable=False, server_default='normal'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('resolved_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['assigned_user_id'], ['users.id'], ondelete='SET NULL')
    )

    # Create ticket comments table
    op.create_table(
        'ticket_comments',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('ticket_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('customer_id', sa.Integer(), nullable=True),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('is_internal', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['ticket_id'], ['tickets.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ondelete='SET NULL')
    )

    # Create basic indexes
    op.create_index('ix_users_email', 'users', ['email'])
    op.create_index('ix_users_role', 'users', ['role'])
    op.create_index('ix_customers_email', 'customers', ['email'])
    op.create_index('ix_tickets_status', 'tickets', ['status'])
    op.create_index('ix_tickets_priority', 'tickets', ['priority'])
    op.create_index('ix_tickets_customer_id', 'tickets', ['customer_id'])
    op.create_index('ix_tickets_assigned_user_id', 'tickets', ['assigned_user_id'])
    op.create_index('ix_tickets_created_at', 'tickets', ['created_at'])
    op.create_index('ix_comments_ticket_id', 'ticket_comments', ['ticket_id'])


def downgrade() -> None:
    # Drop indexes
    op.drop_index('ix_comments_ticket_id', 'ticket_comments')
    op.drop_index('ix_tickets_created_at', 'tickets')
    op.drop_index('ix_tickets_assigned_user_id', 'tickets')
    op.drop_index('ix_tickets_customer_id', 'tickets')
    op.drop_index('ix_tickets_priority', 'tickets')
    op.drop_index('ix_tickets_status', 'tickets')
    op.drop_index('ix_customers_email', 'customers')
    op.drop_index('ix_users_role', 'users')
    op.drop_index('ix_users_email', 'users')

    # Drop tables in reverse order
    op.drop_table('ticket_comments')
    op.drop_table('tickets')
    op.drop_table('customers')
    op.drop_table('users')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 2: Adding Columns to Existing Table

**Scenario**: Adding SLA tracking fields to the tickets table.

**Command**:
```bash
alembic revision -m "add sla fields to tickets"
```

**Migration File** (`versions/002_add_sla_fields_to_tickets.py`):

```python
"""add sla fields to tickets

Revision ID: 002_sla_fields
Revises: 001_initial
Create Date: 2025-01-15 11:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '002_sla_fields'
down_revision = '001_initial'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add SLA deadline column
    op.add_column(
        'tickets',
        sa.Column('sla_deadline', sa.DateTime(), nullable=True)
    )

    # Add SLA violated flag
    op.add_column(
        'tickets',
        sa.Column('sla_violated', sa.Boolean(), nullable=False, server_default='false')
    )

    # Add first response time in seconds
    op.add_column(
        'tickets',
        sa.Column('first_response_time_seconds', sa.Integer(), nullable=True)
    )

    # Add resolution time in seconds
    op.add_column(
        'tickets',
        sa.Column('resolution_time_seconds', sa.Integer(), nullable=True)
    )

    # Create index for SLA queries
    op.create_index('ix_tickets_sla_deadline', 'tickets', ['sla_deadline'])
    op.create_index('ix_tickets_sla_violated', 'tickets', ['sla_violated'])


def downgrade() -> None:
    # Drop indexes
    op.drop_index('ix_tickets_sla_violated', 'tickets')
    op.drop_index('ix_tickets_sla_deadline', 'tickets')

    # Drop columns
    op.drop_column('tickets', 'resolution_time_seconds')
    op.drop_column('tickets', 'first_response_time_seconds')
    op.drop_column('tickets', 'sla_violated')
    op.drop_column('tickets', 'sla_deadline')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 3: Creating Performance Indexes

**Scenario**: Adding composite indexes for common queries in the support dashboard.

**Command**:
```bash
alembic revision -m "add performance indexes for dashboard"
```

**Migration File** (`versions/003_add_performance_indexes.py`):

```python
"""add performance indexes for dashboard

Revision ID: 003_perf_indexes
Revises: 002_sla_fields
Create Date: 2025-01-15 12:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '003_perf_indexes'
down_revision = '002_sla_fields'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Composite index for agent dashboard (status + assigned user)
    op.create_index(
        'ix_tickets_status_assigned_user',
        'tickets',
        ['status', 'assigned_user_id']
    )

    # Composite index for priority + status queries
    op.create_index(
        'ix_tickets_priority_status',
        'tickets',
        ['priority', 'status']
    )

    # Composite index for customer ticket history
    op.create_index(
        'ix_tickets_customer_created',
        'tickets',
        ['customer_id', 'created_at'],
        postgresql_using='btree'
    )

    # Partial index for open tickets only (faster queries)
    op.create_index(
        'ix_tickets_open_created',
        'tickets',
        ['created_at'],
        postgresql_where=sa.text("status IN ('open', 'in_progress')")
    )

    # Partial index for unassigned tickets
    op.create_index(
        'ix_tickets_unassigned',
        'tickets',
        ['created_at'],
        postgresql_where=sa.text("assigned_user_id IS NULL")
    )

    # Text search index for ticket subjects (PostgreSQL)
    op.execute("""
        CREATE INDEX ix_tickets_subject_fulltext
        ON tickets
        USING gin(to_tsvector('english', subject))
    """)


def downgrade() -> None:
    # Drop indexes
    op.execute("DROP INDEX IF EXISTS ix_tickets_subject_fulltext")
    op.drop_index('ix_tickets_unassigned', 'tickets')
    op.drop_index('ix_tickets_open_created', 'tickets')
    op.drop_index('ix_tickets_customer_created', 'tickets')
    op.drop_index('ix_tickets_priority_status', 'tickets')
    op.drop_index('ix_tickets_status_assigned_user', 'tickets')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 4: Adding Tables with Foreign Keys

**Scenario**: Adding a table to track customer satisfaction surveys.

**Command**:
```bash
alembic revision -m "create customer satisfaction table"
```

**Migration File** (`versions/004_create_satisfaction_table.py`):

```python
"""create customer satisfaction table

Revision ID: 004_satisfaction
Revises: 003_perf_indexes
Create Date: 2025-01-15 13:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '004_satisfaction'
down_revision = '003_perf_indexes'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create satisfaction surveys table
    op.create_table(
        'satisfaction_surveys',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('ticket_id', sa.Integer(), nullable=False),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('rating', sa.Integer(), nullable=False),
        sa.Column('feedback', sa.Text(), nullable=True),
        sa.Column('survey_sent_at', sa.DateTime(), nullable=False),
        sa.Column('survey_completed_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),

        # Foreign key constraints
        sa.ForeignKeyConstraint(
            ['ticket_id'],
            ['tickets.id'],
            ondelete='CASCADE',
            name='fk_surveys_ticket'
        ),
        sa.ForeignKeyConstraint(
            ['customer_id'],
            ['customers.id'],
            ondelete='CASCADE',
            name='fk_surveys_customer'
        ),

        # Check constraint for valid ratings
        sa.CheckConstraint(
            'rating >= 1 AND rating <= 5',
            name='ck_surveys_rating_range'
        )
    )

    # Create indexes
    op.create_index('ix_surveys_ticket_id', 'satisfaction_surveys', ['ticket_id'])
    op.create_index('ix_surveys_customer_id', 'satisfaction_surveys', ['customer_id'])
    op.create_index('ix_surveys_rating', 'satisfaction_surveys', ['rating'])
    op.create_index('ix_surveys_completed_at', 'satisfaction_surveys', ['survey_completed_at'])

    # Add unique constraint (one survey per ticket)
    op.create_unique_constraint(
        'uq_surveys_ticket',
        'satisfaction_surveys',
        ['ticket_id']
    )


def downgrade() -> None:
    # Drop table (foreign keys and constraints drop automatically)
    op.drop_table('satisfaction_surveys')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 5: Modifying Column Types Safely

**Scenario**: Converting ticket priority from string to enum and increasing subject length.

**Command**:
```bash
alembic revision -m "modify ticket column types"
```

**Migration File** (`versions/005_modify_ticket_column_types.py`):

```python
"""modify ticket column types

Revision ID: 005_modify_types
Revises: 004_satisfaction
Create Date: 2025-01-15 14:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '005_modify_types'
down_revision = '004_satisfaction'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Step 1: Create enum type for priority
    priority_enum = postgresql.ENUM(
        'low', 'normal', 'high', 'urgent',
        name='ticket_priority_enum',
        create_type=True
    )
    priority_enum.create(op.get_bind(), checkfirst=True)

    # Step 2: Add new column with enum type
    op.add_column(
        'tickets',
        sa.Column('priority_new', priority_enum, nullable=True)
    )

    # Step 3: Migrate data from old column to new
    op.execute("""
        UPDATE tickets
        SET priority_new = CAST(priority AS ticket_priority_enum)
        WHERE priority IN ('low', 'normal', 'high', 'urgent')
    """)

    # Step 4: Handle any invalid values (set to 'normal')
    op.execute("""
        UPDATE tickets
        SET priority_new = 'normal'::ticket_priority_enum
        WHERE priority_new IS NULL
    """)

    # Step 5: Make new column non-nullable
    op.alter_column('tickets', 'priority_new', nullable=False)

    # Step 6: Drop old column and rename new one
    op.drop_index('ix_tickets_priority', 'tickets')
    op.drop_column('tickets', 'priority')
    op.alter_column('tickets', 'priority_new', new_column_name='priority')

    # Step 7: Recreate index
    op.create_index('ix_tickets_priority', 'tickets', ['priority'])

    # Step 8: Increase subject length from 500 to 1000
    op.alter_column(
        'tickets',
        'subject',
        type_=sa.String(1000),
        existing_type=sa.String(500),
        existing_nullable=False
    )


def downgrade() -> None:
    # Reverse subject length change
    op.alter_column(
        'tickets',
        'subject',
        type_=sa.String(500),
        existing_type=sa.String(1000),
        existing_nullable=False
    )

    # Convert enum back to string
    op.drop_index('ix_tickets_priority', 'tickets')

    op.add_column(
        'tickets',
        sa.Column('priority_old', sa.String(20), nullable=True)
    )

    op.execute("""
        UPDATE tickets
        SET priority_old = CAST(priority AS VARCHAR)
    """)

    op.alter_column('tickets', 'priority_old', nullable=False)
    op.drop_column('tickets', 'priority')
    op.alter_column('tickets', 'priority_old', new_column_name='priority')

    op.create_index('ix_tickets_priority', 'tickets', ['priority'])

    # Drop enum type
    priority_enum = postgresql.ENUM(
        'low', 'normal', 'high', 'urgent',
        name='ticket_priority_enum'
    )
    priority_enum.drop(op.get_bind(), checkfirst=True)
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 6: Data Migration for Status Values

**Scenario**: Migrating ticket statuses to a new standardized format.

**Command**:
```bash
alembic revision -m "standardize ticket status values"
```

**Migration File** (`versions/006_standardize_status_values.py`):

```python
"""standardize ticket status values

Revision ID: 006_status_migration
Revises: 005_modify_types
Create Date: 2025-01-15 15:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import table, column

revision = '006_status_migration'
down_revision = '005_modify_types'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Define table structure for data migration
    tickets = table(
        'tickets',
        column('id', sa.Integer),
        column('status', sa.String)
    )

    # Mapping of old status values to new standardized values
    status_mapping = {
        'open': 'OPEN',
        'new': 'OPEN',
        'in_progress': 'IN_PROGRESS',
        'working': 'IN_PROGRESS',
        'pending': 'WAITING_ON_CUSTOMER',
        'waiting': 'WAITING_ON_CUSTOMER',
        'customer_reply': 'WAITING_ON_CUSTOMER',
        'resolved': 'RESOLVED',
        'fixed': 'RESOLVED',
        'closed': 'CLOSED',
        'done': 'CLOSED'
    }

    connection = op.get_bind()

    # Update each old status to new status
    for old_status, new_status in status_mapping.items():
        connection.execute(
            tickets.update()
            .where(tickets.c.status == old_status)
            .values(status=new_status)
        )

    # Handle any remaining unmapped statuses (set to OPEN)
    valid_statuses = set(status_mapping.values())
    connection.execute(
        tickets.update()
        .where(~tickets.c.status.in_(valid_statuses))
        .values(status='OPEN')
    )

    # Add check constraint to ensure only valid statuses
    op.create_check_constraint(
        'ck_tickets_status_valid',
        'tickets',
        sa.text("status IN ('OPEN', 'IN_PROGRESS', 'WAITING_ON_CUSTOMER', 'RESOLVED', 'CLOSED')")
    )


def downgrade() -> None:
    # Remove check constraint
    op.drop_constraint('ck_tickets_status_valid', 'tickets', type_='check')

    # Reverse mapping (new to old - using most common old value)
    tickets = table(
        'tickets',
        column('status', sa.String)
    )

    reverse_mapping = {
        'OPEN': 'open',
        'IN_PROGRESS': 'in_progress',
        'WAITING_ON_CUSTOMER': 'pending',
        'RESOLVED': 'resolved',
        'CLOSED': 'closed'
    }

    connection = op.get_bind()

    for new_status, old_status in reverse_mapping.items():
        connection.execute(
            tickets.update()
            .where(tickets.c.status == new_status)
            .values(status=old_status)
        )
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 7: Autogenerate from SQLAlchemy Models

**Scenario**: Using autogenerate to create migration from model changes.

**SQLAlchemy Model** (`myapp/models.py`):

```python
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()


class Tag(Base):
    """New model for ticket tags"""
    __tablename__ = 'tags'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False, unique=True)
    color = Column(String(7), nullable=False, default='#808080')  # Hex color
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)


class TicketTag(Base):
    """Association table for tickets and tags"""
    __tablename__ = 'ticket_tags'

    id = Column(Integer, primary_key=True)
    ticket_id = Column(Integer, ForeignKey('tickets.id', ondelete='CASCADE'), nullable=False)
    tag_id = Column(Integer, ForeignKey('tags.id', ondelete='CASCADE'), nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
```

**Command**:
```bash
alembic revision --autogenerate -m "add tags for tickets"
```

**Generated Migration File** (`versions/007_add_tags_for_tickets.py`):

```python
"""add tags for tickets

Revision ID: 007_tags
Revises: 006_status_migration
Create Date: 2025-01-15 16:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '007_tags'
down_revision = '006_status_migration'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Auto-generated - please review!

    # Create tags table
    op.create_table(
        'tags',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('color', sa.String(length=7), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name')
    )

    # Create ticket_tags association table
    op.create_table(
        'ticket_tags',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('ticket_id', sa.Integer(), nullable=False),
        sa.Column('tag_id', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['tag_id'], ['tags.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['ticket_id'], ['tickets.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # Manual additions (not auto-generated)
    op.create_index('ix_tags_name', 'tags', ['name'])
    op.create_index('ix_ticket_tags_ticket_id', 'ticket_tags', ['ticket_id'])
    op.create_index('ix_ticket_tags_tag_id', 'ticket_tags', ['tag_id'])

    # Unique constraint to prevent duplicate tags on same ticket
    op.create_unique_constraint(
        'uq_ticket_tags_ticket_tag',
        'ticket_tags',
        ['ticket_id', 'tag_id']
    )


def downgrade() -> None:
    op.drop_table('ticket_tags')
    op.drop_table('tags')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 8: Complex Manual Migration

**Scenario**: Creating a ticket audit log with triggers (manual migration for complex logic).

**Command**:
```bash
alembic revision -m "create ticket audit log with triggers"
```

**Migration File** (`versions/008_create_audit_log.py`):

```python
"""create ticket audit log with triggers

Revision ID: 008_audit_log
Revises: 007_tags
Create Date: 2025-01-15 17:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '008_audit_log'
down_revision = '007_tags'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create audit log table
    op.create_table(
        'ticket_audit_log',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('ticket_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('action', sa.String(50), nullable=False),
        sa.Column('field_name', sa.String(100), nullable=True),
        sa.Column('old_value', sa.Text(), nullable=True),
        sa.Column('new_value', sa.Text(), nullable=True),
        sa.Column('changed_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('metadata', postgresql.JSONB(), nullable=True),
        sa.ForeignKeyConstraint(['ticket_id'], ['tickets.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL')
    )

    # Create indexes
    op.create_index('ix_audit_ticket_id', 'ticket_audit_log', ['ticket_id'])
    op.create_index('ix_audit_changed_at', 'ticket_audit_log', ['changed_at'])
    op.create_index('ix_audit_action', 'ticket_audit_log', ['action'])

    # Create GIN index for JSONB metadata column
    op.execute("""
        CREATE INDEX ix_audit_metadata
        ON ticket_audit_log
        USING gin(metadata)
    """)

    # Create trigger function to automatically log ticket changes
    op.execute("""
        CREATE OR REPLACE FUNCTION log_ticket_changes()
        RETURNS TRIGGER AS $$
        BEGIN
            IF (TG_OP = 'UPDATE') THEN
                -- Log status changes
                IF NEW.status IS DISTINCT FROM OLD.status THEN
                    INSERT INTO ticket_audit_log (ticket_id, action, field_name, old_value, new_value)
                    VALUES (NEW.id, 'status_changed', 'status', OLD.status, NEW.status);
                END IF;

                -- Log priority changes
                IF NEW.priority IS DISTINCT FROM OLD.priority THEN
                    INSERT INTO ticket_audit_log (ticket_id, action, field_name, old_value, new_value)
                    VALUES (NEW.id, 'priority_changed', 'priority', CAST(OLD.priority AS TEXT), CAST(NEW.priority AS TEXT));
                END IF;

                -- Log assignment changes
                IF NEW.assigned_user_id IS DISTINCT FROM OLD.assigned_user_id THEN
                    INSERT INTO ticket_audit_log (ticket_id, action, field_name, old_value, new_value, user_id)
                    VALUES (NEW.id, 'assigned', 'assigned_user_id',
                            CAST(OLD.assigned_user_id AS TEXT),
                            CAST(NEW.assigned_user_id AS TEXT),
                            NEW.assigned_user_id);
                END IF;

            ELSIF (TG_OP = 'INSERT') THEN
                INSERT INTO ticket_audit_log (ticket_id, action, user_id)
                VALUES (NEW.id, 'created', NEW.assigned_user_id);

            ELSIF (TG_OP = 'DELETE') THEN
                INSERT INTO ticket_audit_log (ticket_id, action)
                VALUES (OLD.id, 'deleted');
            END IF;

            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
    """)

    # Attach trigger to tickets table
    op.execute("""
        CREATE TRIGGER ticket_changes_trigger
        AFTER INSERT OR UPDATE OR DELETE ON tickets
        FOR EACH ROW
        EXECUTE FUNCTION log_ticket_changes();
    """)


def downgrade() -> None:
    # Drop trigger
    op.execute("DROP TRIGGER IF EXISTS ticket_changes_trigger ON tickets")

    # Drop trigger function
    op.execute("DROP FUNCTION IF EXISTS log_ticket_changes()")

    # Drop table
    op.drop_table('ticket_audit_log')
```

**Run the migration**:
```bash
alembic upgrade head
```

---

## Example 9: Downgrade Procedures

**Scenario**: Demonstrating safe downgrade from audit log migration.

**Commands**:

```bash
# Show current revision
alembic current

# Output:
# 008_audit_log (head)

# Show what downgrade -1 will do
alembic downgrade -1 --sql

# Actually downgrade one step
alembic downgrade -1

# Output:
# INFO  [alembic.runtime.migration] Running downgrade 008_audit_log -> 007_tags

# Verify new head
alembic current

# Output:
# 007_tags (head)

# Upgrade back to latest
alembic upgrade head

# Output:
# INFO  [alembic.runtime.migration] Running upgrade 007_tags -> 008_audit_log

# Downgrade to specific revision
alembic downgrade 005_modify_types

# Downgrade all the way to base (empty database)
alembic downgrade base

# Upgrade all the way back
alembic upgrade head
```

---

## Example 10: Creating Migration Branches

**Scenario**: Creating separate branches for reporting and analytics features.

**Commands and Files**:

```bash
# Create reporting branch from base
alembic revision \
    -m "create reporting branch" \
    --head=base \
    --branch-label=reporting \
    --version-path=alembic/versions/reporting
```

**Generated File** (`versions/reporting/009_create_reporting_branch.py`):

```python
"""create reporting branch

Revision ID: 009_reporting_base
Revises:
Create Date: 2025-01-15 18:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '009_reporting_base'
down_revision = None
branch_labels = ('reporting',)
depends_on = None


def upgrade() -> None:
    # Create reports table
    op.create_table(
        'reports',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('report_type', sa.String(50), nullable=False),
        sa.Column('parameters', sa.JSON(), nullable=True),
        sa.Column('created_by', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['created_by'], ['users.id'], ondelete='CASCADE')
    )


def downgrade() -> None:
    op.drop_table('reports')
```

```bash
# Add another migration to reporting branch
alembic revision \
    -m "add scheduled reports" \
    --head=reporting@head
```

**Generated File** (`versions/reporting/010_add_scheduled_reports.py`):

```python
"""add scheduled reports

Revision ID: 010_scheduled_reports
Revises: 009_reporting_base
Create Date: 2025-01-15 18:30:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '010_scheduled_reports'
down_revision = '009_reporting_base'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create scheduled reports table
    op.create_table(
        'scheduled_reports',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('report_id', sa.Integer(), nullable=False),
        sa.Column('schedule_cron', sa.String(100), nullable=False),
        sa.Column('recipients', sa.JSON(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('last_run_at', sa.DateTime(), nullable=True),
        sa.Column('next_run_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['report_id'], ['reports.id'], ondelete='CASCADE')
    )


def downgrade() -> None:
    op.drop_table('scheduled_reports')
```

**Working with branches**:

```bash
# Show all branches
alembic branches

# Show all heads
alembic heads

# Upgrade specific branch
alembic upgrade reporting@head

# Upgrade all branches
alembic upgrade heads
```

---

## Example 11: Merging Migration Branches

**Scenario**: Merging reporting branch back into main branch.

**Command**:
```bash
# Merge main and reporting branches
alembic merge \
    -m "merge reporting branch into main" \
    008_audit_log 010_scheduled_reports
```

**Generated File** (`versions/011_merge_reporting_into_main.py`):

```python
"""merge reporting branch into main

Revision ID: 011_merge
Revises: 008_audit_log, 010_scheduled_reports
Create Date: 2025-01-15 19:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '011_merge'
down_revision = ('008_audit_log', '010_scheduled_reports')
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Usually empty for simple merges
    # Add code here if you need to reconcile conflicts

    # Example: Add a cross-branch constraint
    op.create_foreign_key(
        'fk_reports_created_by',
        'reports',
        'users',
        ['created_by'],
        ['id'],
        ondelete='CASCADE'
    )


def downgrade() -> None:
    # Reverse any changes made in upgrade
    op.drop_constraint('fk_reports_created_by', 'reports', type_='foreignkey')
```

**Apply the merge**:
```bash
alembic upgrade head
```

---

## Example 12: Online Migration with Minimal Downtime

**Scenario**: Adding a required column to tickets table without downtime.

**Phase 1 - Add Column as Nullable**:

```bash
alembic revision -m "add resolution notes phase 1 - add column"
```

```python
"""add resolution notes phase 1 - add column

Revision ID: 012_phase1
Revises: 011_merge
Create Date: 2025-01-16 10:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '012_phase1'
down_revision = '011_merge'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add column as nullable (safe for existing rows)
    op.add_column(
        'tickets',
        sa.Column('resolution_notes', sa.Text(), nullable=True)
    )


def downgrade() -> None:
    op.drop_column('tickets', 'resolution_notes')
```

**Phase 2 - Backfill Data**:

```bash
alembic revision -m "add resolution notes phase 2 - backfill"
```

```python
"""add resolution notes phase 2 - backfill

Revision ID: 013_phase2
Revises: 012_phase1
Create Date: 2025-01-16 10:30:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import table, column

revision = '013_phase2'
down_revision = '012_phase1'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Backfill resolution_notes for resolved tickets
    # Do this in batches during low-traffic periods

    connection = op.get_bind()
    tickets = table(
        'tickets',
        column('id', sa.Integer),
        column('status', sa.String),
        column('resolution_notes', sa.Text)
    )

    # Set default value for resolved tickets without notes
    connection.execute(
        tickets.update()
        .where(sa.and_(
            tickets.c.status.in_(['RESOLVED', 'CLOSED']),
            tickets.c.resolution_notes.is_(None)
        ))
        .values(resolution_notes='Resolved - details not recorded')
    )


def downgrade() -> None:
    # Clear backfilled data
    connection = op.get_bind()
    tickets = table(
        'tickets',
        column('resolution_notes', sa.Text)
    )

    connection.execute(
        tickets.update()
        .where(tickets.c.resolution_notes == 'Resolved - details not recorded')
        .values(resolution_notes=None)
    )
```

**Phase 3 - Make Column Required**:

```bash
alembic revision -m "add resolution notes phase 3 - make required"
```

```python
"""add resolution notes phase 3 - make required

Revision ID: 014_phase3
Revises: 013_phase2
Create Date: 2025-01-16 11:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '014_phase3'
down_revision = '013_phase2'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Now that all rows have values, make it non-nullable
    op.alter_column(
        'tickets',
        'resolution_notes',
        nullable=False,
        existing_type=sa.Text(),
        server_default='Pending resolution'
    )


def downgrade() -> None:
    op.alter_column(
        'tickets',
        'resolution_notes',
        nullable=True,
        existing_type=sa.Text(),
        server_default=None
    )
```

**Deployment**:
```bash
# Deploy phase 1
alembic upgrade 012_phase1

# Wait and monitor

# Deploy phase 2 (can run during low traffic)
alembic upgrade 013_phase2

# Wait and monitor

# Deploy phase 3
alembic upgrade 014_phase3
```

---

## Example 13: Testing Migrations with Pytest

**Test File** (`tests/test_alembic_migrations.py`):

```python
"""Tests for Alembic migrations"""

import pytest
from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import sessionmaker


@pytest.fixture(scope='session')
def alembic_config():
    """Alembic configuration for testing"""
    config = Config("alembic.ini")
    config.set_main_option(
        "sqlalchemy.url",
        "postgresql://localhost/support_test"
    )
    return config


@pytest.fixture
def test_engine(alembic_config):
    """Create test database engine"""
    url = alembic_config.get_main_option("sqlalchemy.url")
    engine = create_engine(url)

    # Create all tables
    command.upgrade(alembic_config, "head")

    yield engine

    # Cleanup
    command.downgrade(alembic_config, "base")
    engine.dispose()


def test_migration_creates_all_tables(test_engine):
    """Test that migrations create all expected tables"""
    inspector = inspect(test_engine)
    tables = inspector.get_table_names()

    expected_tables = [
        'users',
        'customers',
        'tickets',
        'ticket_comments',
        'satisfaction_surveys',
        'tags',
        'ticket_tags',
        'ticket_audit_log',
        'reports',
        'scheduled_reports',
        'alembic_version'
    ]

    for table in expected_tables:
        assert table in tables, f"Table {table} not found in database"


def test_tickets_table_structure(test_engine):
    """Test tickets table has correct columns and types"""
    inspector = inspect(test_engine)
    columns = {col['name']: col for col in inspector.get_columns('tickets')}

    # Check required columns exist
    required_columns = [
        'id', 'customer_id', 'assigned_user_id', 'subject', 'description',
        'status', 'priority', 'created_at', 'updated_at', 'resolved_at',
        'sla_deadline', 'sla_violated', 'first_response_time_seconds',
        'resolution_time_seconds', 'resolution_notes'
    ]

    for col_name in required_columns:
        assert col_name in columns, f"Column {col_name} not found"

    # Check column types
    assert 'integer' in str(columns['id']['type']).lower()
    assert 'varchar' in str(columns['subject']['type']).lower()
    assert 'text' in str(columns['description']['type']).lower()


def test_foreign_keys_exist(test_engine):
    """Test that foreign key constraints are created"""
    inspector = inspect(test_engine)
    fks = inspector.get_foreign_keys('tickets')

    # Should have foreign keys to customers and users
    fk_tables = [fk['referred_table'] for fk in fks]
    assert 'customers' in fk_tables
    assert 'users' in fk_tables


def test_indexes_created(test_engine):
    """Test that performance indexes exist"""
    inspector = inspect(test_engine)
    indexes = inspector.get_indexes('tickets')

    index_names = [idx['name'] for idx in indexes]

    expected_indexes = [
        'ix_tickets_status',
        'ix_tickets_priority',
        'ix_tickets_customer_id',
        'ix_tickets_assigned_user_id',
        'ix_tickets_created_at'
    ]

    for idx_name in expected_indexes:
        assert idx_name in index_names, f"Index {idx_name} not found"


def test_upgrade_downgrade_cycle(alembic_config):
    """Test complete upgrade/downgrade cycle"""
    # Start from base
    command.downgrade(alembic_config, "base")

    # Upgrade to head
    command.upgrade(alembic_config, "head")

    # Downgrade one step
    command.downgrade(alembic_config, "-1")

    # Upgrade back to head
    command.upgrade(alembic_config, "head")


def test_data_persists_after_migration(test_engine, alembic_config):
    """Test that data is preserved during migrations"""
    Session = sessionmaker(bind=test_engine)
    session = Session()

    # Insert test data
    session.execute(text("""
        INSERT INTO customers (email, name, company)
        VALUES ('test@example.com', 'Test Customer', 'Test Corp')
    """))

    session.execute(text("""
        INSERT INTO tickets (customer_id, subject, description, status, priority)
        VALUES (1, 'Test Ticket', 'Test Description', 'OPEN', 'normal')
    """))

    session.commit()

    # Get ticket ID
    result = session.execute(text("SELECT id FROM tickets WHERE subject = 'Test Ticket'"))
    ticket_id = result.scalar()

    session.close()

    # Run a migration (example: downgrade and upgrade)
    command.downgrade(alembic_config, "-1")
    command.upgrade(alembic_config, "head")

    # Verify data still exists
    session = Session()
    result = session.execute(text(f"SELECT subject FROM tickets WHERE id = {ticket_id}"))
    subject = result.scalar()

    assert subject == 'Test Ticket', "Data was lost during migration"
    session.close()


def test_check_constraint_on_satisfaction_rating(test_engine):
    """Test that check constraint prevents invalid ratings"""
    Session = sessionmaker(bind=test_engine)
    session = Session()

    # Insert valid customer and ticket
    session.execute(text("""
        INSERT INTO customers (id, email, name) VALUES (100, 'check@test.com', 'Check Test')
    """))

    session.execute(text("""
        INSERT INTO tickets (id, customer_id, subject, description, status, priority)
        VALUES (100, 100, 'Check Test', 'Test', 'OPEN', 'normal')
    """))

    session.commit()

    # Try to insert invalid rating (should fail)
    with pytest.raises(Exception):
        session.execute(text("""
            INSERT INTO satisfaction_surveys (ticket_id, customer_id, rating, survey_sent_at)
            VALUES (100, 100, 10, NOW())
        """))
        session.commit()

    session.rollback()

    # Insert valid rating (should succeed)
    session.execute(text("""
        INSERT INTO satisfaction_surveys (ticket_id, customer_id, rating, survey_sent_at)
        VALUES (100, 100, 5, NOW())
    """))
    session.commit()
    session.close()


@pytest.mark.slow
def test_migration_performance(alembic_config):
    """Test that full migration completes within time limit"""
    import time

    command.downgrade(alembic_config, "base")

    start = time.time()
    command.upgrade(alembic_config, "head")
    duration = time.time() - start

    # Should complete within 30 seconds
    assert duration < 30, f"Migration took {duration}s, exceeds 30s limit"
```

**Run tests**:
```bash
# Run all migration tests
pytest tests/test_alembic_migrations.py -v

# Run specific test
pytest tests/test_alembic_migrations.py::test_migration_creates_all_tables -v

# Run with coverage
pytest tests/test_alembic_migrations.py --cov=alembic --cov-report=html
```

---

## Example 14: Rolling Back Failed Migrations

**Scenario**: A migration fails partway through and needs cleanup.

**Simulation**:

```python
"""intentionally failing migration

Revision ID: 015_fail_test
Revises: 014_phase3
Create Date: 2025-01-16 12:00:00.000000
"""

from alembic import op
import sqlalchemy as sa

revision = '015_fail_test'
down_revision = '014_phase3'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # This will succeed
    op.create_table(
        'temp_table',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('data', sa.String(100))
    )

    # This will fail (table doesn't exist)
    op.add_column('nonexistent_table', sa.Column('bad_column', sa.Integer()))


def downgrade() -> None:
    op.drop_table('temp_table')
```

**Recovery Process**:

```bash
# Attempt migration (will fail)
alembic upgrade head

# Output:
# INFO  [alembic.runtime.migration] Running upgrade 014_phase3 -> 015_fail_test
# ERROR [alembic.runtime.migration] Error running upgrade: Table 'nonexistent_table' does not exist
# FAILED: Target database is not up to date.

# Check current status
alembic current

# Output may show partial application or still at previous revision

# Option 1: Fix the migration and retry
# Edit the migration file to fix the error

# Stamp database to current state (if needed)
alembic stamp 014_phase3

# Try again with fixed migration
alembic upgrade head

# Option 2: Manually clean up and skip the migration
# Connect to database and drop temp_table if it was created
psql $DATABASE_URL -c "DROP TABLE IF EXISTS temp_table"

# Stamp to the failed revision to mark it as applied
alembic stamp 015_fail_test

# Then downgrade it
alembic downgrade -1

# Option 3: Use transaction per migration (recommended)
# Configure in env.py:
context.configure(
    connection=connection,
    target_metadata=target_metadata,
    transaction_per_migration=True  # Each migration in its own transaction
)

# Now failed migrations automatically rollback
```

---

## Example 15: Production Deployment Workflow

**Deployment Script** (`scripts/deploy_migrations.sh`):

```bash
#!/bin/bash

# Production migration deployment script
# Usage: ./scripts/deploy_migrations.sh

set -e  # Exit on any error
set -u  # Exit on undefined variable

echo "======================================"
echo "Production Migration Deployment"
echo "======================================"

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/pre_migration_${TIMESTAMP}.sql"
LOG_FILE="./logs/migration_${TIMESTAMP}.log"

# Ensure directories exist
mkdir -p "$BACKUP_DIR"
mkdir -p "./logs"

# Functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# Validate environment
log "Validating environment..."
if [ -z "${DATABASE_URL:-}" ]; then
    error_exit "DATABASE_URL environment variable not set"
fi

if [ -z "${DB_PASSWORD:-}" ]; then
    error_exit "DB_PASSWORD environment variable not set"
fi

# Check Alembic is installed
if ! command -v alembic &> /dev/null; then
    error_exit "Alembic not found. Please install: pip install alembic"
fi

# Step 1: Backup database
log "Creating database backup..."
pg_dump "$DATABASE_URL" > "$BACKUP_FILE" || error_exit "Backup failed"
log "Backup created: $BACKUP_FILE"

# Step 2: Show current status
log "Current migration status:"
alembic current 2>&1 | tee -a "$LOG_FILE"

# Step 3: Show pending migrations
log "Checking for pending migrations..."
CURRENT_REV=$(alembic current | grep -oP 'Rev: \K\w+' || echo "base")
HEAD_REV=$(alembic heads | awk '{print $1}')

if [ "$CURRENT_REV" == "$HEAD_REV" ]; then
    log "Database is already up to date. No migrations needed."
    exit 0
fi

log "Pending migrations will be applied from $CURRENT_REV to $HEAD_REV"

# Step 4: Confirm with user
read -p "Proceed with migration? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log "Migration cancelled by user"
    exit 0
fi

# Step 5: Run migrations with timeout
log "Running migrations..."
timeout 300 alembic upgrade head 2>&1 | tee -a "$LOG_FILE" || {
    log "Migration failed or timed out!"
    log "Attempting to restore from backup..."

    # Restore from backup
    psql "$DATABASE_URL" < "$BACKUP_FILE" || error_exit "Restore failed!"

    log "Database restored from backup"
    error_exit "Migration failed. Database restored to previous state."
}

# Step 6: Verify migration success
log "Verifying migration status..."
NEW_REV=$(alembic current | grep -oP 'Rev: \K\w+' || echo "none")

if [ "$NEW_REV" != "$HEAD_REV" ]; then
    log "WARNING: Migration incomplete. Current: $NEW_REV, Expected: $HEAD_REV"
    log "Restoring from backup..."

    psql "$DATABASE_URL" < "$BACKUP_FILE" || error_exit "Restore failed!"

    error_exit "Migration verification failed. Database restored."
fi

# Step 7: Run post-migration checks
log "Running post-migration checks..."

# Check database connectivity
psql "$DATABASE_URL" -c "SELECT 1" > /dev/null || error_exit "Database connectivity check failed"

# Check critical tables exist
CRITICAL_TABLES=("users" "customers" "tickets")
for table in "${CRITICAL_TABLES[@]}"; do
    COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='$table'")
    if [ "$COUNT" -eq 0 ]; then
        error_exit "Critical table $table not found!"
    fi
done

log "Post-migration checks passed"

# Step 8: Cleanup old backups (keep last 10)
log "Cleaning up old backups..."
ls -t "$BACKUP_DIR"/*.sql 2>/dev/null | tail -n +11 | xargs -r rm
log "Old backups cleaned up (kept last 10)"

# Step 9: Final summary
log "======================================"
log "Migration completed successfully!"
log "Previous revision: $CURRENT_REV"
log "Current revision: $NEW_REV"
log "Backup location: $BACKUP_FILE"
log "Log location: $LOG_FILE"
log "======================================"

exit 0
```

**Usage**:

```bash
# Set environment variables
export DATABASE_URL="postgresql://user:pass@localhost/support_prod"
export DB_PASSWORD="secure_password"

# Make script executable
chmod +x scripts/deploy_migrations.sh

# Run deployment
./scripts/deploy_migrations.sh

# Output:
# ======================================
# Production Migration Deployment
# ======================================
# [2025-01-16 12:00:00] Validating environment...
# [2025-01-16 12:00:01] Creating database backup...
# [2025-01-16 12:00:15] Backup created: ./backups/pre_migration_20250116_120000.sql
# [2025-01-16 12:00:15] Current migration status:
# Rev: 014_phase3 (head)
# [2025-01-16 12:00:16] Checking for pending migrations...
# Proceed with migration? (yes/no): yes
# [2025-01-16 12:00:20] Running migrations...
# INFO  [alembic.runtime.migration] Running upgrade 014_phase3 -> 015_new_feature
# [2025-01-16 12:00:25] Verifying migration status...
# [2025-01-16 12:00:26] Running post-migration checks...
# [2025-01-16 12:00:27] Post-migration checks passed
# [2025-01-16 12:00:27] Cleaning up old backups...
# ======================================
# Migration completed successfully!
# Previous revision: 014_phase3
# Current revision: 015_new_feature
# Backup location: ./backups/pre_migration_20250116_120000.sql
# Log location: ./logs/migration_20250116_120000.log
# ======================================
```

---

## Example 16: Batch Data Migration

**Scenario**: Computing and backfilling metrics for large ticket table.

**Command**:
```bash
alembic revision -m "compute and backfill ticket metrics"
```

**Migration File** (`versions/016_compute_ticket_metrics.py`):

```python
"""compute and backfill ticket metrics

Revision ID: 016_metrics
Revises: 015_new_feature
Create Date: 2025-01-16 13:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import table, column, select
import time

revision = '016_metrics'
down_revision = '015_new_feature'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add metrics columns
    op.add_column('tickets',
        sa.Column('total_comments', sa.Integer(), nullable=True, server_default='0'))

    op.add_column('tickets',
        sa.Column('customer_responses', sa.Integer(), nullable=True, server_default='0'))

    op.add_column('tickets',
        sa.Column('agent_responses', sa.Integer(), nullable=True, server_default='0'))

    # Compute metrics in batches
    connection = op.get_bind()

    # Get total number of tickets
    result = connection.execute(sa.text("SELECT COUNT(*) FROM tickets"))
    total_tickets = result.scalar()

    print(f"Processing {total_tickets} tickets in batches...")

    batch_size = 1000
    processed = 0

    while processed < total_tickets:
        # Get batch of ticket IDs
        batch_ids = connection.execute(
            sa.text(f"""
                SELECT id FROM tickets
                ORDER BY id
                LIMIT {batch_size} OFFSET {processed}
            """)
        ).fetchall()

        if not batch_ids:
            break

        ticket_ids = [row[0] for row in batch_ids]

        # Compute metrics for this batch
        for ticket_id in ticket_ids:
            # Count total comments
            total = connection.execute(
                sa.text(f"""
                    SELECT COUNT(*) FROM ticket_comments
                    WHERE ticket_id = {ticket_id}
                """)
            ).scalar()

            # Count customer responses
            customer_count = connection.execute(
                sa.text(f"""
                    SELECT COUNT(*) FROM ticket_comments
                    WHERE ticket_id = {ticket_id}
                    AND customer_id IS NOT NULL
                """)
            ).scalar()

            # Count agent responses
            agent_count = connection.execute(
                sa.text(f"""
                    SELECT COUNT(*) FROM ticket_comments
                    WHERE ticket_id = {ticket_id}
                    AND user_id IS NOT NULL
                """)
            ).scalar()

            # Update ticket metrics
            connection.execute(
                sa.text(f"""
                    UPDATE tickets
                    SET total_comments = {total},
                        customer_responses = {customer_count},
                        agent_responses = {agent_count}
                    WHERE id = {ticket_id}
                """)
            )

        processed += len(ticket_ids)
        progress = (processed / total_tickets) * 100
        print(f"Processed {processed}/{total_tickets} tickets ({progress:.1f}%)")

        # Small delay to reduce database load
        time.sleep(0.1)

    # Make columns non-nullable
    op.alter_column('tickets', 'total_comments', nullable=False)
    op.alter_column('tickets', 'customer_responses', nullable=False)
    op.alter_column('tickets', 'agent_responses', nullable=False)

    # Create indexes for metrics
    op.create_index('ix_tickets_total_comments', 'tickets', ['total_comments'])


def downgrade() -> None:
    op.drop_index('ix_tickets_total_comments', 'tickets')
    op.drop_column('tickets', 'agent_responses')
    op.drop_column('tickets', 'customer_responses')
    op.drop_column('tickets', 'total_comments')
```

---

## Example 17: Adding Enums and Constraints

**Scenario**: Adding ticket category enum and related constraints.

**Command**:
```bash
alembic revision -m "add ticket categories with constraints"
```

**Migration File** (`versions/017_add_ticket_categories.py`):

```python
"""add ticket categories with constraints

Revision ID: 017_categories
Revises: 016_metrics
Create Date: 2025-01-16 14:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '017_categories'
down_revision = '016_metrics'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create category enum type
    category_enum = postgresql.ENUM(
        'billing',
        'technical',
        'feature_request',
        'bug_report',
        'general_inquiry',
        'account_management',
        name='ticket_category_enum',
        create_type=True
    )
    category_enum.create(op.get_bind())

    # Add category column
    op.add_column('tickets',
        sa.Column('category', category_enum, nullable=True))

    # Set default category based on existing data
    op.execute("""
        UPDATE tickets
        SET category = 'general_inquiry'::ticket_category_enum
        WHERE category IS NULL
    """)

    # Make category required
    op.alter_column('tickets', 'category', nullable=False)

    # Create subcategory table
    op.create_table(
        'ticket_categories',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('category', category_enum, nullable=False),
        sa.Column('subcategory', sa.String(100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('sla_hours', sa.Integer(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.UniqueConstraint('category', 'subcategory', name='uq_category_subcategory')
    )

    # Add subcategory to tickets
    op.add_column('tickets',
        sa.Column('subcategory_id', sa.Integer(), nullable=True))

    op.create_foreign_key(
        'fk_tickets_subcategory',
        'tickets',
        'ticket_categories',
        ['subcategory_id'],
        ['id'],
        ondelete='SET NULL'
    )

    # Insert default subcategories
    op.execute("""
        INSERT INTO ticket_categories (category, subcategory, sla_hours) VALUES
        ('billing', 'Invoice Question', 24),
        ('billing', 'Payment Issue', 12),
        ('billing', 'Refund Request', 48),
        ('technical', 'Login Problem', 4),
        ('technical', 'Performance Issue', 8),
        ('technical', 'Integration Problem', 24),
        ('feature_request', 'New Feature', 168),
        ('feature_request', 'Enhancement', 168),
        ('bug_report', 'Critical Bug', 4),
        ('bug_report', 'Minor Bug', 48),
        ('general_inquiry', 'How To', 24),
        ('general_inquiry', 'Information Request', 24),
        ('account_management', 'Update Details', 24),
        ('account_management', 'Close Account', 48)
    """)

    # Create indexes
    op.create_index('ix_tickets_category', 'tickets', ['category'])
    op.create_index('ix_tickets_subcategory_id', 'tickets', ['subcategory_id'])


def downgrade() -> None:
    # Drop indexes
    op.drop_index('ix_tickets_subcategory_id', 'tickets')
    op.drop_index('ix_tickets_category', 'tickets')

    # Drop foreign key and column
    op.drop_constraint('fk_tickets_subcategory', 'tickets', type_='foreignkey')
    op.drop_column('tickets', 'subcategory_id')

    # Drop subcategory table
    op.drop_table('ticket_categories')

    # Drop category column
    op.drop_column('tickets', 'category')

    # Drop enum type
    category_enum = postgresql.ENUM(name='ticket_category_enum')
    category_enum.drop(op.get_bind())
```

---

## Example 18: Multi-Table Data Migration

**Scenario**: Restructuring customer contact information into separate table.

**Command**:
```bash
alembic revision -m "extract customer contacts to separate table"
```

**Migration File** (`versions/018_extract_customer_contacts.py`):

```python
"""extract customer contacts to separate table

Revision ID: 018_contacts
Revises: 017_categories
Create Date: 2025-01-16 15:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import table, column

revision = '018_contacts'
down_revision = '017_categories'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create new customer_contacts table
    op.create_table(
        'customer_contacts',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('contact_type', sa.String(50), nullable=False),
        sa.Column('contact_value', sa.String(255), nullable=False),
        sa.Column('is_primary', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('is_verified', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ondelete='CASCADE'),
        sa.CheckConstraint(
            "contact_type IN ('email', 'phone', 'mobile')",
            name='ck_contacts_type'
        )
    )

    op.create_index('ix_contacts_customer_id', 'customer_contacts', ['customer_id'])
    op.create_index('ix_contacts_type', 'customer_contacts', ['contact_type'])
    op.create_index('ix_contacts_primary', 'customer_contacts', ['customer_id', 'is_primary'])

    # Migrate existing data from customers table
    connection = op.get_bind()

    # Migrate email addresses
    connection.execute(sa.text("""
        INSERT INTO customer_contacts (customer_id, contact_type, contact_value, is_primary, is_verified)
        SELECT id, 'email', email, true, true
        FROM customers
        WHERE email IS NOT NULL AND email != ''
    """))

    # Migrate phone numbers
    connection.execute(sa.text("""
        INSERT INTO customer_contacts (customer_id, contact_type, contact_value, is_primary)
        SELECT id, 'phone', phone, false
        FROM customers
        WHERE phone IS NOT NULL AND phone != ''
    """))

    # Add primary_contact_id to customers table
    op.add_column('customers',
        sa.Column('primary_contact_id', sa.Integer(), nullable=True))

    # Set primary_contact_id to the email contact for each customer
    connection.execute(sa.text("""
        UPDATE customers c
        SET primary_contact_id = cc.id
        FROM customer_contacts cc
        WHERE cc.customer_id = c.id
        AND cc.contact_type = 'email'
        AND cc.is_primary = true
    """))

    # Create foreign key
    op.create_foreign_key(
        'fk_customers_primary_contact',
        'customers',
        'customer_contacts',
        ['primary_contact_id'],
        ['id'],
        ondelete='SET NULL'
    )

    # Now we can drop the old columns (optional - keep for backwards compatibility)
    # op.drop_column('customers', 'phone')
    # We keep email column for now as it's heavily used


def downgrade() -> None:
    # Drop foreign key
    op.drop_constraint('fk_customers_primary_contact', 'customers', type_='foreignkey')

    # Drop primary_contact_id column
    op.drop_column('customers', 'primary_contact_id')

    # Restore phone data from contacts table (if we dropped it)
    # connection = op.get_bind()
    # connection.execute(sa.text("""
    #     UPDATE customers c
    #     SET phone = cc.contact_value
    #     FROM customer_contacts cc
    #     WHERE cc.customer_id = c.id
    #     AND cc.contact_type = 'phone'
    #     AND cc.is_primary = true
    # """))

    # Drop contacts table
    op.drop_table('customer_contacts')
```

---

## Summary

These 18 examples demonstrate:

1. **Initial Setup**: Creating foundational schema
2. **Schema Evolution**: Adding columns, tables, and indexes
3. **Data Migrations**: Transforming and migrating existing data
4. **Autogenerate**: Using SQLAlchemy models to generate migrations
5. **Complex Migrations**: Manual migrations with triggers and functions
6. **Branching**: Managing parallel development streams
7. **Zero-Downtime**: Multi-phase migrations for production
8. **Testing**: Comprehensive test coverage for migrations
9. **Production Deployment**: Safe deployment workflows with backups
10. **Performance**: Batch processing for large datasets

Each example is production-ready and can be adapted for your specific customer support system needs. Always review and test migrations thoroughly before applying them to production databases.
