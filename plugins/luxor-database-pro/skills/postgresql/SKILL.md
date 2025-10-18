---
name: PostgreSQL Database Administration
version: 1.0.0
description: Comprehensive PostgreSQL database administration skill for customer support tech enablement, covering database design, optimization, performance tuning, backup/recovery, and advanced query techniques
author: Claude
tags:
  - postgresql
  - database
  - sql
  - customer-support
  - performance-tuning
  - backup-recovery
  - indexing
  - optimization
  - analytics
  - data-curation
capabilities:
  - Database schema design for customer support systems
  - Performance optimization and query tuning
  - Index strategy development and maintenance
  - Backup and recovery procedures
  - Connection pooling and resource management
  - Full-text search implementation
  - JSON/JSONB data handling
  - Partitioning for large datasets
  - Monitoring and maintenance operations
  - Analytics query optimization
  - Audit logging and compliance
  - High availability and replication
category: database
difficulty: intermediate-to-advanced
use_cases:
  - Customer support ticketing systems
  - User management and authentication
  - Analytics and reporting dashboards
  - Audit trail and compliance tracking
  - SLA monitoring and alerting
  - Knowledge base systems
  - Chat and communication logs
prerequisites:
  - Basic SQL knowledge
  - Understanding of relational database concepts
  - Familiarity with command-line tools
  - Access to PostgreSQL 12+ installation
related_skills:
  - python-unit-tests
  - backend-support
  - data-curation
---

# PostgreSQL Database Administration for Customer Support

## Overview

This comprehensive skill covers PostgreSQL database administration specifically tailored for customer support tech enablement. PostgreSQL is a powerful, open-source object-relational database system with over 35 years of active development, known for its reliability, feature robustness, and performance. In customer support environments, PostgreSQL excels at handling complex ticket management, user analytics, audit logging, and real-time reporting requirements.

## Core Competencies

### 1. Customer Support Database Design

#### Schema Design Principles

When designing databases for customer support systems, focus on:

- **Normalization**: Balance between 3NF and denormalization for performance
- **Scalability**: Design for growth in ticket volume and user base
- **Auditability**: Track all changes with timestamps and user attribution
- **Flexibility**: Use JSONB for dynamic metadata and custom fields
- **Performance**: Strategic indexing for common query patterns

#### Support Ticket Schema Design

```sql
-- Core tables for customer support system
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('customer', 'agent', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE tickets (
    ticket_id BIGSERIAL PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES users(user_id),
    assigned_agent_id BIGINT REFERENCES users(user_id),
    subject VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'in_progress', 'waiting', 'resolved', 'closed')),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium'
        CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    category VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    first_response_at TIMESTAMP WITH TIME ZONE,
    tags TEXT[] DEFAULT '{}',
    custom_fields JSONB DEFAULT '{}'::jsonb,
    search_vector tsvector
);

CREATE TABLE ticket_comments (
    comment_id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(user_id),
    comment_text TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    attachments JSONB DEFAULT '[]'::jsonb,
    search_vector tsvector
);

CREATE TABLE ticket_history (
    history_id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(user_id),
    field_name VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organizations (
    org_id BIGSERIAL PRIMARY KEY,
    org_name VARCHAR(255) NOT NULL UNIQUE,
    domain VARCHAR(255),
    plan_type VARCHAR(50) NOT NULL DEFAULT 'free',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settings JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE user_organizations (
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    org_id BIGINT NOT NULL REFERENCES organizations(org_id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, org_id)
);
```

#### Audit Logging Schema

```sql
CREATE TABLE audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    user_id BIGINT REFERENCES users(user_id),
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- Create a partition for audit logs by month
CREATE TABLE audit_logs_y2025m01 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 2. Indexing Strategies for Support Queries

#### B-Tree Indexes for Common Queries

```sql
-- Index for finding tickets by status
CREATE INDEX idx_tickets_status ON tickets(status) WHERE status != 'closed';

-- Index for finding tickets by customer
CREATE INDEX idx_tickets_customer ON tickets(customer_id, created_at DESC);

-- Index for finding tickets by assigned agent
CREATE INDEX idx_tickets_agent ON tickets(assigned_agent_id, status)
    WHERE assigned_agent_id IS NOT NULL;

-- Composite index for ticket filtering
CREATE INDEX idx_tickets_status_priority_created
    ON tickets(status, priority, created_at DESC);

-- Index for email lookups
CREATE INDEX idx_users_email ON users(email) WHERE is_active = true;

-- Index for ticket number lookups
CREATE UNIQUE INDEX idx_tickets_ticket_number ON tickets(ticket_number);
```

#### GIN Indexes for Full-Text Search

```sql
-- Full-text search on ticket subject and description
CREATE INDEX idx_tickets_search ON tickets USING GIN(search_vector);

-- Update trigger for maintaining search vector
CREATE OR REPLACE FUNCTION tickets_search_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.subject, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_search_update
    BEFORE INSERT OR UPDATE ON tickets
    FOR EACH ROW EXECUTE FUNCTION tickets_search_trigger();

-- Full-text search on comments
CREATE INDEX idx_comments_search ON ticket_comments USING GIN(search_vector);

CREATE OR REPLACE FUNCTION comments_search_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_vector := to_tsvector('english', COALESCE(NEW.comment_text, ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_search_update
    BEFORE INSERT OR UPDATE ON ticket_comments
    FOR EACH ROW EXECUTE FUNCTION comments_search_trigger();
```

#### GIN Indexes for JSONB and Array Operations

```sql
-- Index for JSONB containment queries
CREATE INDEX idx_tickets_custom_fields ON tickets USING GIN(custom_fields);

-- Index for array tag searches
CREATE INDEX idx_tickets_tags ON tickets USING GIN(tags);

-- Index for specific JSONB keys
CREATE INDEX idx_tickets_custom_source
    ON tickets USING GIN((custom_fields -> 'source'));
```

#### Partial Indexes for Specific Use Cases

```sql
-- Index only open and in-progress tickets
CREATE INDEX idx_tickets_active
    ON tickets(created_at DESC)
    WHERE status IN ('open', 'in_progress', 'waiting');

-- Index unassigned tickets
CREATE INDEX idx_tickets_unassigned
    ON tickets(priority DESC, created_at ASC)
    WHERE assigned_agent_id IS NULL AND status = 'open';

-- Index high-priority unresolved tickets
CREATE INDEX idx_tickets_urgent
    ON tickets(created_at ASC)
    WHERE priority IN ('high', 'critical') AND status != 'closed';
```

### 3. Full-Text Search Implementation

#### Basic Full-Text Search Queries

```sql
-- Search tickets by keyword
SELECT
    ticket_id,
    ticket_number,
    subject,
    ts_rank(search_vector, query) AS rank
FROM
    tickets,
    to_tsquery('english', 'login & problem') AS query
WHERE
    search_vector @@ query
ORDER BY
    rank DESC, created_at DESC
LIMIT 20;

-- Advanced search with phrase matching
SELECT
    ticket_id,
    ticket_number,
    subject,
    ts_headline('english', description, query, 'MaxWords=50, MinWords=25') AS excerpt
FROM
    tickets,
    websearch_to_tsquery('english', '"password reset" OR authentication') AS query
WHERE
    search_vector @@ query
ORDER BY
    ts_rank_cd(search_vector, query) DESC
LIMIT 10;
```

#### Searching Across Multiple Tables

```sql
-- Search tickets and comments together
WITH search_results AS (
    SELECT
        'ticket' AS source,
        ticket_id,
        ticket_id AS ref_id,
        subject AS title,
        description AS content,
        created_at,
        ts_rank(search_vector, query) AS rank
    FROM
        tickets,
        to_tsquery('english', 'billing & invoice') AS query
    WHERE
        search_vector @@ query

    UNION ALL

    SELECT
        'comment' AS source,
        ticket_id,
        comment_id AS ref_id,
        'Comment' AS title,
        comment_text AS content,
        created_at,
        ts_rank(search_vector, query) AS rank
    FROM
        ticket_comments,
        to_tsquery('english', 'billing & invoice') AS query
    WHERE
        search_vector @@ query
)
SELECT * FROM search_results
ORDER BY rank DESC, created_at DESC
LIMIT 50;
```

### 4. Query Optimization for Analytics

#### Window Functions for Ranking and Analytics

```sql
-- Agent performance metrics with ranking
SELECT
    u.user_id,
    u.full_name,
    COUNT(t.ticket_id) AS tickets_resolved,
    AVG(EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600)::numeric(10,2) AS avg_resolution_hours,
    RANK() OVER (ORDER BY COUNT(t.ticket_id) DESC) AS volume_rank,
    RANK() OVER (ORDER BY AVG(EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))) ASC) AS speed_rank
FROM
    users u
    JOIN tickets t ON u.user_id = t.assigned_agent_id
WHERE
    u.role = 'agent'
    AND t.resolved_at >= CURRENT_DATE - INTERVAL '30 days'
    AND t.status = 'resolved'
GROUP BY
    u.user_id, u.full_name
ORDER BY
    tickets_resolved DESC;

-- Daily ticket trends with moving average
SELECT
    date_trunc('day', created_at) AS ticket_date,
    COUNT(*) AS daily_tickets,
    AVG(COUNT(*)) OVER (ORDER BY date_trunc('day', created_at) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM
    tickets
WHERE
    created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY
    date_trunc('day', created_at)
ORDER BY
    ticket_date;
```

#### Materialized Views for Dashboards

```sql
-- Create materialized view for agent performance dashboard
CREATE MATERIALIZED VIEW mv_agent_performance AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT t.ticket_id) AS total_tickets,
    COUNT(DISTINCT CASE WHEN t.status = 'resolved' THEN t.ticket_id END) AS resolved_tickets,
    COUNT(DISTINCT CASE WHEN t.status IN ('open', 'in_progress') THEN t.ticket_id END) AS active_tickets,
    AVG(EXTRACT(EPOCH FROM (COALESCE(t.first_response_at, CURRENT_TIMESTAMP) - t.created_at)) / 3600)::numeric(10,2) AS avg_first_response_hours,
    AVG(CASE
        WHEN t.resolved_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600
    END)::numeric(10,2) AS avg_resolution_hours,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600) AS median_resolution_hours
FROM
    users u
    LEFT JOIN tickets t ON u.user_id = t.assigned_agent_id
WHERE
    u.role = 'agent'
    AND u.is_active = true
    AND (t.created_at >= CURRENT_DATE - INTERVAL '30 days' OR t.ticket_id IS NULL)
GROUP BY
    u.user_id, u.full_name, u.email;

-- Create unique index on materialized view
CREATE UNIQUE INDEX idx_mv_agent_performance_user ON mv_agent_performance(user_id);

-- Refresh strategy (daily scheduled job)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_agent_performance;
```

#### SLA Tracking Queries

```sql
-- SLA compliance by priority
WITH sla_targets AS (
    SELECT
        'low' AS priority,
        48 AS response_hours,
        120 AS resolution_hours
    UNION ALL SELECT 'medium', 24, 72
    UNION ALL SELECT 'high', 8, 48
    UNION ALL SELECT 'critical', 2, 24
),
ticket_metrics AS (
    SELECT
        t.ticket_id,
        t.priority,
        EXTRACT(EPOCH FROM (t.first_response_at - t.created_at)) / 3600 AS response_hours,
        EXTRACT(EPOCH FROM (COALESCE(t.resolved_at, CURRENT_TIMESTAMP) - t.created_at)) / 3600 AS resolution_hours
    FROM
        tickets t
    WHERE
        t.created_at >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT
    tm.priority,
    COUNT(*) AS total_tickets,
    COUNT(CASE WHEN tm.response_hours <= st.response_hours THEN 1 END) AS response_met,
    ROUND(100.0 * COUNT(CASE WHEN tm.response_hours <= st.response_hours THEN 1 END) / COUNT(*), 2) AS response_sla_pct,
    COUNT(CASE WHEN tm.resolution_hours <= st.resolution_hours THEN 1 END) AS resolution_met,
    ROUND(100.0 * COUNT(CASE WHEN tm.resolution_hours <= st.resolution_hours THEN 1 END) / COUNT(*), 2) AS resolution_sla_pct
FROM
    ticket_metrics tm
    JOIN sla_targets st ON tm.priority = st.priority
GROUP BY
    tm.priority, st.response_hours, st.resolution_hours
ORDER BY
    CASE tm.priority
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END;
```

### 5. Partitioning for Large Support Datasets

#### Range Partitioning by Date

```sql
-- Create partitioned tickets table for historical data
CREATE TABLE tickets_partitioned (
    ticket_id BIGSERIAL,
    ticket_number VARCHAR(50) NOT NULL,
    customer_id BIGINT NOT NULL,
    assigned_agent_id BIGINT,
    subject VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    PRIMARY KEY (ticket_id, created_at)
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE tickets_y2024m01 PARTITION OF tickets_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE tickets_y2024m02 PARTITION OF tickets_partitioned
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

CREATE TABLE tickets_y2024m03 PARTITION OF tickets_partitioned
    FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

-- Create index on each partition
CREATE INDEX idx_tickets_y2024m01_status ON tickets_y2024m01(status);
CREATE INDEX idx_tickets_y2024m02_status ON tickets_y2024m02(status);
CREATE INDEX idx_tickets_y2024m03_status ON tickets_y2024m03(status);

-- Function to automatically create new partitions
CREATE OR REPLACE FUNCTION create_ticket_partition()
RETURNS void AS $$
DECLARE
    partition_date DATE;
    partition_name TEXT;
    start_date TEXT;
    end_date TEXT;
BEGIN
    partition_date := date_trunc('month', CURRENT_DATE + INTERVAL '1 month');
    partition_name := 'tickets_y' || to_char(partition_date, 'YYYY') || 'm' || to_char(partition_date, 'MM');
    start_date := partition_date::TEXT;
    end_date := (partition_date + INTERVAL '1 month')::TEXT;

    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF tickets_partitioned FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );

    EXECUTE format('CREATE INDEX idx_%I_status ON %I(status)', partition_name, partition_name);
    EXECUTE format('CREATE INDEX idx_%I_customer ON %I(customer_id)', partition_name, partition_name);
END;
$$ LANGUAGE plpgsql;
```

#### List Partitioning by Status or Category

```sql
-- Create list-partitioned table by status
CREATE TABLE tickets_by_status (
    ticket_id BIGSERIAL,
    ticket_number VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ticket_id, status)
) PARTITION BY LIST (status);

CREATE TABLE tickets_active PARTITION OF tickets_by_status
    FOR VALUES IN ('open', 'in_progress', 'waiting');

CREATE TABLE tickets_resolved PARTITION OF tickets_by_status
    FOR VALUES IN ('resolved');

CREATE TABLE tickets_closed PARTITION OF tickets_by_status
    FOR VALUES IN ('closed');
```

### 6. Backup and Recovery Procedures

#### Physical Backups with pg_basebackup

```bash
# Full physical backup
pg_basebackup -h localhost -p 5432 -U backup_user -D /backup/postgres/base_$(date +%Y%m%d) -Ft -z -P

# Incremental backup using WAL archiving
# Configure postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = 'cp %p /backup/postgres/wal/%f'

# Point-in-time recovery configuration
# Create recovery.conf (PostgreSQL < 12) or recovery.signal (PostgreSQL >= 12)
restore_command = 'cp /backup/postgres/wal/%f %p'
recovery_target_time = '2025-01-15 14:30:00'
```

#### Logical Backups with pg_dump

```bash
# Dump entire database
pg_dump -h localhost -p 5432 -U postgres -d support_db -Fc -f /backup/support_db_$(date +%Y%m%d).dump

# Dump specific tables
pg_dump -h localhost -p 5432 -U postgres -d support_db -t tickets -t ticket_comments -Fc -f /backup/tickets_$(date +%Y%m%d).dump

# Dump only schema
pg_dump -h localhost -p 5432 -U postgres -d support_db -s -f /backup/schema_$(date +%Y%m%d).sql

# Dump only data
pg_dump -h localhost -p 5432 -U postgres -d support_db -a -f /backup/data_$(date +%Y%m%d).sql

# Dump with parallel jobs for faster backup
pg_dump -h localhost -p 5432 -U postgres -d support_db -Fd -j 4 -f /backup/support_db_parallel_$(date +%Y%m%d)

# Restore from dump
pg_restore -h localhost -p 5432 -U postgres -d support_db_restore -j 4 /backup/support_db_20250115.dump
```

#### Continuous Archiving Strategy

```sql
-- Create backup schema tracking table
CREATE TABLE backup_history (
    backup_id SERIAL PRIMARY KEY,
    backup_type VARCHAR(20) NOT NULL,
    backup_path TEXT NOT NULL,
    backup_size BIGINT,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL,
    error_message TEXT
);

-- Monitor backup status
SELECT
    backup_type,
    COUNT(*) AS total_backups,
    MAX(completed_at) AS last_successful_backup,
    SUM(backup_size) / 1024 / 1024 / 1024 AS total_size_gb
FROM
    backup_history
WHERE
    status = 'completed'
GROUP BY
    backup_type;
```

### 7. Connection Pooling and Performance Optimization

#### PgBouncer Configuration

```ini
[databases]
support_db = host=localhost port=5432 dbname=support_db

[pgbouncer]
listen_port = 6432
listen_addr = *
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
reserve_pool_size = 5
reserve_pool_timeout = 3
max_db_connections = 100
max_user_connections = 100
server_lifetime = 3600
server_idle_timeout = 600
log_connections = 1
log_disconnections = 1
log_pooler_errors = 1
stats_period = 60
```

#### Connection Pooling Best Practices

```python
# Python application using connection pooling with psycopg2
from psycopg2 import pool
import psycopg2.extras

# Create connection pool
connection_pool = pool.ThreadedConnectionPool(
    minconn=5,
    maxconn=20,
    host='localhost',
    port=6432,  # PgBouncer port
    database='support_db',
    user='app_user',
    password='secure_password'
)

# Use connection from pool
def execute_query(query, params=None):
    conn = None
    try:
        conn = connection_pool.getconn()
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, params)
            return cursor.fetchall()
    finally:
        if conn:
            connection_pool.putconn(conn)
```

#### Query Performance Optimization

```sql
-- Analyze query execution plan
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    t.ticket_id,
    t.ticket_number,
    t.subject,
    u.full_name AS customer_name,
    a.full_name AS agent_name
FROM
    tickets t
    JOIN users u ON t.customer_id = u.user_id
    LEFT JOIN users a ON t.assigned_agent_id = a.user_id
WHERE
    t.status = 'open'
    AND t.created_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY
    t.priority DESC, t.created_at ASC;

-- Identify slow queries
SELECT
    userid::regrole,
    dbid,
    query,
    calls,
    total_exec_time / 1000 AS total_seconds,
    mean_exec_time / 1000 AS mean_seconds,
    max_exec_time / 1000 AS max_seconds
FROM
    pg_stat_statements
ORDER BY
    total_exec_time DESC
LIMIT 20;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

### 8. Monitoring and Maintenance

#### Database Health Monitoring

```sql
-- Check database size and growth
SELECT
    pg_database.datname AS database_name,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS size,
    pg_size_pretty(pg_total_relation_size('tickets')) AS tickets_size,
    pg_size_pretty(pg_total_relation_size('ticket_comments')) AS comments_size
FROM
    pg_database
WHERE
    pg_database.datname = current_database();

-- Check table bloat
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size,
    n_live_tup,
    n_dead_tup,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_percent
FROM
    pg_stat_user_tables
ORDER BY
    pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;

-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM
    pg_stat_user_indexes
WHERE
    idx_scan = 0
    AND schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    pg_relation_size(indexrelid) DESC;

-- Check replication lag (for replicas)
SELECT
    client_addr,
    application_name,
    state,
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) / 1024 / 1024 AS sent_lag_mb,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) / 1024 / 1024 AS replay_lag_mb,
    write_lag,
    flush_lag,
    replay_lag
FROM
    pg_stat_replication;
```

#### VACUUM and ANALYZE Operations

```sql
-- Manual vacuum operations
VACUUM VERBOSE ANALYZE tickets;
VACUUM FULL tickets;  -- Warning: locks table exclusively

-- Autovacuum configuration in postgresql.conf
-- autovacuum = on
-- autovacuum_max_workers = 3
-- autovacuum_naptime = 1min
-- autovacuum_vacuum_threshold = 50
-- autovacuum_analyze_threshold = 50
-- autovacuum_vacuum_scale_factor = 0.2
-- autovacuum_analyze_scale_factor = 0.1

-- Monitor autovacuum activity
SELECT
    schemaname,
    relname,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM
    pg_stat_user_tables
WHERE
    schemaname = 'public'
ORDER BY
    last_autovacuum NULLS FIRST;
```

#### Maintenance Scripts

```bash
#!/bin/bash
# Daily maintenance script

# Run vacuum analyze on all databases
vacuumdb --all --analyze --verbose

# Update statistics
psql -d support_db -c "ANALYZE;"

# Reindex tables with high bloat
psql -d support_db -c "REINDEX TABLE CONCURRENTLY tickets;"

# Clean up old audit logs (keep 90 days)
psql -d support_db -c "DELETE FROM audit_logs WHERE changed_at < NOW() - INTERVAL '90 days';"

# Check for missing indexes
psql -d support_db -f /scripts/check_missing_indexes.sql

# Generate performance report
psql -d support_db -f /scripts/performance_report.sql > /reports/perf_$(date +%Y%m%d).txt
```

### 9. Security and Role Management

#### Role-Based Access Control

```sql
-- Create roles for different access levels
CREATE ROLE support_readonly;
CREATE ROLE support_agent;
CREATE ROLE support_admin;

-- Grant read-only access
GRANT CONNECT ON DATABASE support_db TO support_readonly;
GRANT USAGE ON SCHEMA public TO support_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO support_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO support_readonly;

-- Grant agent access
GRANT CONNECT ON DATABASE support_db TO support_agent;
GRANT USAGE ON SCHEMA public TO support_agent;
GRANT SELECT, INSERT, UPDATE ON tickets, ticket_comments, ticket_history TO support_agent;
GRANT SELECT ON users, organizations TO support_agent;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO support_agent;

-- Grant admin access
GRANT CONNECT ON DATABASE support_db TO support_admin;
GRANT ALL PRIVILEGES ON DATABASE support_db TO support_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO support_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO support_admin;

-- Create specific users
CREATE USER readonly_user WITH PASSWORD 'secure_password' IN ROLE support_readonly;
CREATE USER agent_user WITH PASSWORD 'secure_password' IN ROLE support_agent;
CREATE USER admin_user WITH PASSWORD 'secure_password' IN ROLE support_admin;

-- Row-level security for multi-tenancy
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY ticket_customer_access ON tickets
    FOR SELECT
    TO support_readonly, support_agent
    USING (customer_id IN (
        SELECT user_id FROM users WHERE email = current_user
    ));

CREATE POLICY ticket_agent_access ON tickets
    FOR ALL
    TO support_agent
    USING (assigned_agent_id IN (
        SELECT user_id FROM users WHERE email = current_user
    ));
```

### 10. Advanced JSON/JSONB Operations

#### Storing and Querying Flexible Metadata

```sql
-- Insert ticket with custom fields
INSERT INTO tickets (
    ticket_number, customer_id, subject, description, status, priority, custom_fields
) VALUES (
    'TKT-12345', 101, 'Billing issue', 'Cannot access invoice', 'open', 'high',
    jsonb_build_object(
        'source', 'email',
        'product', 'enterprise',
        'invoice_number', 'INV-2025-001',
        'amount', 1500.00,
        'tags', jsonb_build_array('billing', 'urgent', 'vip')
    )
);

-- Query by JSONB field
SELECT
    ticket_id,
    ticket_number,
    subject,
    custom_fields->>'source' AS source,
    custom_fields->>'product' AS product
FROM
    tickets
WHERE
    custom_fields @> '{"product": "enterprise"}'
    AND custom_fields->>'source' = 'email';

-- Update JSONB field
UPDATE tickets
SET custom_fields = jsonb_set(
    custom_fields,
    '{invoice_paid}',
    'true',
    true
)
WHERE ticket_id = 12345;

-- Remove JSONB field
UPDATE tickets
SET custom_fields = custom_fields - 'temporary_flag'
WHERE ticket_id = 12345;

-- Aggregate JSONB data
SELECT
    custom_fields->>'source' AS source,
    COUNT(*) AS ticket_count,
    AVG((custom_fields->>'amount')::numeric) AS avg_amount
FROM
    tickets
WHERE
    custom_fields ? 'amount'
    AND created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    custom_fields->>'source';
```

### 11. High Availability and Replication

#### Streaming Replication Setup

```bash
# On primary server (postgresql.conf)
wal_level = replica
max_wal_senders = 10
wal_keep_size = 1GB
synchronous_commit = on
synchronous_standby_names = 'standby1'

# Create replication user on primary
psql -c "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'repl_password';"

# On standby server
pg_basebackup -h primary_host -D /var/lib/postgresql/data -U replicator -P -v -R -X stream -C -S standby1

# Start standby server
pg_ctl start
```

#### Monitoring Replication Status

```sql
-- On primary: check replication slots
SELECT
    slot_name,
    slot_type,
    active,
    restart_lsn,
    confirmed_flush_lsn,
    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 AS lag_mb
FROM
    pg_replication_slots;

-- On standby: check recovery status
SELECT
    pg_is_in_recovery() AS is_standby,
    pg_last_wal_receive_lsn() AS last_received,
    pg_last_wal_replay_lsn() AS last_applied,
    pg_wal_lsn_diff(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()) / 1024 AS replay_lag_kb;
```

## Best Practices

### 1. Performance Optimization
- Use connection pooling (PgBouncer) for high-concurrency applications
- Implement prepared statements to reduce parsing overhead
- Use EXPLAIN ANALYZE to identify slow queries
- Create appropriate indexes based on query patterns
- Regularly update statistics with ANALYZE
- Monitor and tune autovacuum settings
- Use materialized views for complex reporting queries

### 2. Data Integrity
- Always use foreign key constraints
- Implement check constraints for data validation
- Use NOT NULL constraints where appropriate
- Leverage triggers for complex business logic
- Maintain audit trails for compliance
- Use transactions for multi-step operations

### 3. Scalability
- Partition large tables by date or category
- Implement archiving strategy for historical data
- Use read replicas for reporting queries
- Monitor table and index bloat
- Plan for horizontal scaling with sharding if needed

### 4. Security
- Follow principle of least privilege
- Use SSL/TLS for all connections
- Implement row-level security for multi-tenancy
- Regularly update PostgreSQL to latest stable version
- Audit user access and privileges
- Encrypt sensitive data at rest and in transit

### 5. Backup and Recovery
- Implement automated daily backups
- Test restore procedures regularly
- Use point-in-time recovery for critical data
- Store backups in multiple locations
- Monitor backup success/failure
- Document recovery procedures

## Common Pitfalls to Avoid

1. **Over-indexing**: Too many indexes slow down writes
2. **Ignoring VACUUM**: Leads to table bloat and performance degradation
3. **Not using connection pooling**: Exhausts database connections
4. **Premature optimization**: Profile first, optimize later
5. **Ignoring query plans**: EXPLAIN is your friend
6. **Not monitoring replication lag**: Can lead to data inconsistency
7. **Storing large BLOBs in database**: Use object storage instead
8. **Not setting appropriate work_mem**: Can cause disk-based sorts
9. **Ignoring security best practices**: Always validate and sanitize inputs
10. **Not planning for growth**: Design for scale from the beginning

## Troubleshooting Guide

### High CPU Usage
```sql
-- Find active queries consuming CPU
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change,
    query
FROM
    pg_stat_activity
WHERE
    state = 'active'
    AND query NOT LIKE '%pg_stat_activity%'
ORDER BY
    query_start ASC;

-- Terminate problematic query
SELECT pg_terminate_backend(pid);
```

### Slow Queries
```sql
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries
SELECT
    query,
    calls,
    total_exec_time / 1000 AS total_seconds,
    mean_exec_time / 1000 AS mean_seconds,
    max_exec_time / 1000 AS max_seconds,
    stddev_exec_time / 1000 AS stddev_seconds
FROM
    pg_stat_statements
WHERE
    query NOT LIKE '%pg_stat_statements%'
ORDER BY
    mean_exec_time DESC
LIMIT 20;
```

### Lock Contention
```sql
-- Identify locks and blocking queries
SELECT
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS blocking_statement
FROM
    pg_catalog.pg_locks blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE
    NOT blocked_locks.granted;
```

## Resources and Further Learning

- **Official PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **PostgreSQL Wiki**: https://wiki.postgresql.org/
- **PostgreSQL Performance Blog**: https://www.cybertec-postgresql.com/en/blog/
- **PgExercises**: https://pgexercises.com/ (Practice SQL queries)
- **Use The Index, Luke**: https://use-the-index-luke.com/ (Index optimization)
- **PostgreSQL Mailing Lists**: https://www.postgresql.org/list/

## Conclusion

This skill provides a comprehensive foundation for PostgreSQL database administration in customer support environments. Master these concepts through hands-on practice, always test in non-production environments first, and continuously monitor and optimize your database performance. Remember that database administration is an ongoing process of learning, monitoring, and refinement.
