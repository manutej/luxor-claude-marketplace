---
name: "postgresql-database-administration"
description: "PostgreSQL administration patterns for schema design, query optimization, indexing strategies, backup/recovery, partitioning, and monitoring. Use when designing support ticket databases, tuning slow queries, setting up replication, implementing full-text search, or managing PostgreSQL in production."
---

# PostgreSQL Database Administration

Production patterns for PostgreSQL schema design, performance tuning, indexing, backup/recovery, and monitoring in customer support systems.

## Schema Design for Support Systems

```sql
-- Core ticket schema with proper indexing
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','waiting','resolved','closed')),
    priority VARCHAR(10) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low','medium','high','urgent')),
    customer_email VARCHAR(100) NOT NULL,
    assigned_to INTEGER REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_assigned ON tickets(assigned_to) WHERE assigned_to IS NOT NULL;
CREATE INDEX idx_tickets_created ON tickets(created_at DESC);
CREATE INDEX idx_tickets_customer ON tickets(customer_email);
```

## Query Optimization

```sql
-- Use EXPLAIN ANALYZE to identify slow queries
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT t.*, u.full_name as agent_name
FROM tickets t
LEFT JOIN users u ON t.assigned_to = u.id
WHERE t.status = 'open' AND t.priority = 'urgent'
ORDER BY t.created_at ASC;

-- Composite index for common filter combinations
CREATE INDEX idx_tickets_status_priority ON tickets(status, priority, created_at DESC);

-- Partial index for active tickets only
CREATE INDEX idx_active_tickets ON tickets(assigned_to, priority)
WHERE status NOT IN ('resolved', 'closed');
```

## Connection Pooling with PgBouncer

```ini
; pgbouncer.ini
[databases]
support_db = host=localhost port=5432 dbname=support_db

[pgbouncer]
pool_mode = transaction
max_client_conn = 200
default_pool_size = 25
min_pool_size = 5
reserve_pool_size = 5
```

## Full-Text Search

```sql
-- Add tsvector column for fast text search
ALTER TABLE tickets ADD COLUMN search_vector tsvector;

CREATE INDEX idx_tickets_search ON tickets USING GIN(search_vector);

-- Update trigger to maintain search vector
CREATE OR REPLACE FUNCTION tickets_search_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector := setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A')
        || setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_search_trigger BEFORE INSERT OR UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION tickets_search_update();

-- Search query with ranking
SELECT id, title, ts_rank(search_vector, query) AS rank
FROM tickets, plainto_tsquery('english', 'password reset') query
WHERE search_vector @@ query
ORDER BY rank DESC LIMIT 20;
```

## JSONB for Flexible Metadata

```sql
ALTER TABLE tickets ADD COLUMN metadata JSONB DEFAULT '{}';
CREATE INDEX idx_tickets_metadata ON tickets USING GIN(metadata);

-- Query JSONB fields
SELECT * FROM tickets WHERE metadata->>'source' = 'email';
SELECT * FROM tickets WHERE metadata @> '{"tags": ["billing"]}';

-- Update nested JSONB
UPDATE tickets SET metadata = jsonb_set(metadata, '{resolution_notes}', '"Fixed by reset"')
WHERE id = 123;
```

## Table Partitioning

```sql
-- Range partition by creation date for large ticket tables
CREATE TABLE tickets_partitioned (
    LIKE tickets INCLUDING ALL
) PARTITION BY RANGE (created_at);

CREATE TABLE tickets_2024_q1 PARTITION OF tickets_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE tickets_2024_q2 PARTITION OF tickets_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
```

## Backup & Recovery

```bash
# Full backup with compression
pg_dump -Fc -Z 9 support_db > backup_$(date +%Y%m%d).dump

# Parallel backup for large databases
pg_dump -Fc -j 4 support_db > backup_parallel.dump

# Point-in-time recovery setup (postgresql.conf)
# wal_level = replica
# archive_mode = on
# archive_command = 'cp %p /archive/%f'

# Restore from backup
pg_restore -d support_db -j 4 --clean backup.dump
```

## Monitoring & Maintenance

```sql
-- Check slow queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state != 'idle' AND now() - pg_stat_activity.query_start > interval '5 seconds'
ORDER BY duration DESC;

-- Table bloat check
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage statistics
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes ORDER BY idx_scan ASC;

-- Routine maintenance
VACUUM ANALYZE tickets;
REINDEX INDEX CONCURRENTLY idx_tickets_status;
```

## Replication & High Availability

```bash
# Primary: enable replication in postgresql.conf
# wal_level = replica
# max_wal_senders = 5
# synchronous_standby_names = 'replica1'

# Replica: set up streaming replication
pg_basebackup -h primary-host -D /var/lib/postgresql/data -P -R
```

```sql
-- Verify replication status on primary
SELECT client_addr, state, sent_lsn, write_lsn, replay_lsn
FROM pg_stat_replication;
```

See [README.md](README.md) for additional context on database design patterns for customer support systems.
