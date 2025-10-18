# PostgreSQL Database Administration for Customer Support

## Overview

This skill package provides comprehensive guidance for PostgreSQL database administration specifically tailored for customer support tech enablement. PostgreSQL is a powerful, open-source object-relational database system renowned for its reliability, feature robustness, and performance. This skill covers everything from initial setup to advanced optimization techniques, all contextualized for customer support operations.

## What You'll Learn

This PostgreSQL skill equips you with the knowledge and practical examples to:

- Design efficient database schemas for customer support ticketing systems
- Implement full-text search for tickets, comments, and knowledge bases
- Optimize query performance through strategic indexing
- Set up and manage backup and recovery procedures
- Configure connection pooling for high-availability applications
- Partition large datasets for improved performance
- Monitor database health and identify bottlenecks
- Implement security best practices and role-based access control
- Work with JSONB for flexible metadata storage
- Create analytics queries and dashboards for support metrics
- Set up replication for high availability

## Why PostgreSQL for Customer Support?

PostgreSQL is an ideal choice for customer support platforms because it offers:

1. **ACID Compliance**: Ensures data integrity for critical support records
2. **Full-Text Search**: Built-in search capabilities for tickets and knowledge bases
3. **JSONB Support**: Flexible schema design for custom fields and metadata
4. **Advanced Indexing**: GIN, GiST, BRIN, and partial indexes for optimization
5. **Mature Ecosystem**: Extensive tooling, extensions, and community support
6. **Scalability**: Handles millions of tickets with proper partitioning
7. **Cost-Effective**: Open-source with no licensing fees
8. **Window Functions**: Powerful analytics for reporting and dashboards
9. **Extensibility**: Custom functions, triggers, and procedural languages
10. **Proven Track Record**: Used by major companies worldwide

## Installation and Setup

### Prerequisites

- Operating System: Linux, macOS, or Windows
- Minimum RAM: 4GB (8GB+ recommended for production)
- Disk Space: 10GB+ for database and backups
- Administrative access to install software

### Installing PostgreSQL

#### On Ubuntu/Debian

```bash
# Add PostgreSQL repository
sudo apt-get install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

# Install PostgreSQL 17 (latest stable version)
sudo apt-get update
sudo apt-get install -y postgresql-17 postgresql-contrib-17

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Check status
sudo systemctl status postgresql
```

#### On macOS (using Homebrew)

```bash
# Install PostgreSQL
brew install postgresql@17

# Start PostgreSQL service
brew services start postgresql@17

# Verify installation
psql --version
```

#### On Windows

1. Download installer from https://www.postgresql.org/download/windows/
2. Run the installer and follow the setup wizard
3. Remember the password you set for the postgres user
4. Add PostgreSQL bin directory to PATH

### Initial Configuration

```bash
# Switch to postgres user (Linux/macOS)
sudo -u postgres psql

# Inside psql prompt:
# Create a database for customer support
CREATE DATABASE support_db;

# Create application user
CREATE USER support_user WITH ENCRYPTED PASSWORD 'secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE support_db TO support_user;

# Exit psql
\q
```

### Configure PostgreSQL for Production

Edit `postgresql.conf` (typically in `/etc/postgresql/17/main/` or `/var/lib/postgresql/data/`):

```conf
# Connection Settings
listen_addresses = '*'
max_connections = 200
shared_buffers = 4GB                # 25% of available RAM
effective_cache_size = 12GB         # 75% of available RAM
work_mem = 32MB
maintenance_work_mem = 1GB

# Write-Ahead Log (WAL)
wal_level = replica
wal_buffers = 16MB
max_wal_size = 2GB
min_wal_size = 1GB

# Query Tuning
random_page_cost = 1.1              # For SSDs
effective_io_concurrency = 200      # For SSDs

# Logging
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = off
log_lock_waits = on
log_statement = 'ddl'
log_temp_files = 0

# Autovacuum
autovacuum = on
autovacuum_max_workers = 4
autovacuum_naptime = 1min
```

Edit `pg_hba.conf` for authentication:

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
host    support_db      support_user    0.0.0.0/0               scram-sha-256
```

Restart PostgreSQL to apply changes:

```bash
sudo systemctl restart postgresql
```

## Quick Start Guide

### Creating Your First Support Schema

```bash
# Connect to database
psql -U support_user -d support_db -h localhost

# Or connect as postgres user first
sudo -u postgres psql support_db
```

```sql
-- Create users table
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('customer', 'agent', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Create tickets table
CREATE TABLE tickets (
    ticket_id BIGSERIAL PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES users(user_id),
    assigned_agent_id BIGINT REFERENCES users(user_id),
    subject VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_tickets_customer ON tickets(customer_id);
CREATE INDEX idx_tickets_agent ON tickets(assigned_agent_id) WHERE assigned_agent_id IS NOT NULL;
CREATE INDEX idx_tickets_status ON tickets(status) WHERE status != 'closed';

-- Insert sample data
INSERT INTO users (email, full_name, role) VALUES
    ('customer@example.com', 'John Customer', 'customer'),
    ('agent@example.com', 'Jane Agent', 'agent'),
    ('admin@example.com', 'Admin User', 'admin');

INSERT INTO tickets (ticket_number, customer_id, subject, description, status, priority)
SELECT
    'TKT-' || LPAD(generate_series::TEXT, 5, '0'),
    1,
    'Sample ticket ' || generate_series,
    'This is a sample ticket description for testing purposes',
    CASE WHEN random() < 0.3 THEN 'open'
         WHEN random() < 0.6 THEN 'in_progress'
         ELSE 'resolved' END,
    CASE WHEN random() < 0.2 THEN 'critical'
         WHEN random() < 0.4 THEN 'high'
         WHEN random() < 0.7 THEN 'medium'
         ELSE 'low' END
FROM generate_series(1, 100);

-- Query tickets
SELECT
    ticket_number,
    subject,
    status,
    priority,
    created_at
FROM tickets
WHERE status = 'open'
ORDER BY priority DESC, created_at ASC
LIMIT 10;
```

### Essential PostgreSQL Commands

```bash
# Connect to database
psql -U username -d database_name -h hostname

# Common psql commands (inside psql prompt)
\l                  # List all databases
\c database_name    # Connect to database
\dt                 # List all tables
\dt+                # List tables with size
\d table_name       # Describe table structure
\d+ table_name      # Detailed table description
\di                 # List indexes
\du                 # List users/roles
\df                 # List functions
\dv                 # List views
\x                  # Toggle expanded display
\timing             # Toggle query timing
\q                  # Quit psql

# Execute SQL file
\i /path/to/file.sql

# Export query results to CSV
\copy (SELECT * FROM tickets) TO '/tmp/tickets.csv' WITH CSV HEADER;
```

## Key Features for Support Teams

### 1. Full-Text Search

Quickly find tickets by keywords across subject and description:

```sql
-- Add full-text search capability
ALTER TABLE tickets ADD COLUMN search_vector tsvector;

CREATE INDEX idx_tickets_search ON tickets USING GIN(search_vector);

-- Update trigger
CREATE OR REPLACE FUNCTION tickets_search_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.subject, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_search_update
    BEFORE INSERT OR UPDATE ON tickets
    FOR EACH ROW EXECUTE FUNCTION tickets_search_trigger();

-- Search tickets
SELECT ticket_number, subject, ts_rank(search_vector, query) AS rank
FROM tickets, to_tsquery('english', 'billing & invoice') AS query
WHERE search_vector @@ query
ORDER BY rank DESC;
```

### 2. Analytics and Reporting

Generate insights from support data:

```sql
-- Agent performance metrics
SELECT
    u.full_name,
    COUNT(t.ticket_id) AS total_tickets,
    COUNT(CASE WHEN t.status = 'resolved' THEN 1 END) AS resolved_tickets,
    ROUND(100.0 * COUNT(CASE WHEN t.status = 'resolved' THEN 1 END) / COUNT(t.ticket_id), 2) AS resolution_rate
FROM users u
LEFT JOIN tickets t ON u.user_id = t.assigned_agent_id
WHERE u.role = 'agent'
GROUP BY u.user_id, u.full_name
ORDER BY resolution_rate DESC;

-- Daily ticket trends
SELECT
    date_trunc('day', created_at) AS date,
    COUNT(*) AS tickets_created,
    COUNT(CASE WHEN status = 'resolved' THEN 1 END) AS tickets_resolved
FROM tickets
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY date_trunc('day', created_at)
ORDER BY date;
```

### 3. Flexible Metadata with JSONB

Store custom fields without schema changes:

```sql
-- Add JSONB column
ALTER TABLE tickets ADD COLUMN custom_fields JSONB DEFAULT '{}'::jsonb;

-- Insert ticket with custom fields
INSERT INTO tickets (ticket_number, customer_id, subject, description, custom_fields)
VALUES (
    'TKT-12345',
    1,
    'Product inquiry',
    'Customer asking about features',
    '{"source": "chat", "product": "enterprise", "tags": ["sales", "product"]}'::jsonb
);

-- Query by JSONB field
SELECT ticket_number, subject, custom_fields->>'source' AS source
FROM tickets
WHERE custom_fields @> '{"source": "chat"}';

-- Create index on JSONB
CREATE INDEX idx_tickets_custom_fields ON tickets USING GIN(custom_fields);
```

### 4. Automated Backups

```bash
#!/bin/bash
# backup_support_db.sh

BACKUP_DIR="/backup/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATABASE="support_db"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
pg_dump -U postgres -d $DATABASE -Fc -f $BACKUP_DIR/support_db_$TIMESTAMP.dump

# Keep only last 7 days of backups
find $BACKUP_DIR -name "support_db_*.dump" -mtime +7 -delete

# Log backup completion
echo "Backup completed: support_db_$TIMESTAMP.dump" >> $BACKUP_DIR/backup.log
```

Schedule with cron:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/backup_support_db.sh
```

## Performance Best Practices

### 1. Index Strategy

- Create indexes on foreign keys
- Index columns used in WHERE, JOIN, and ORDER BY clauses
- Use partial indexes for frequently filtered subsets
- Monitor index usage with pg_stat_user_indexes
- Drop unused indexes

### 2. Query Optimization

- Use EXPLAIN ANALYZE to understand query plans
- Avoid SELECT * when you only need specific columns
- Use JOINs instead of subqueries when possible
- Limit result sets with LIMIT and pagination
- Use prepared statements to reduce parsing overhead

### 3. Connection Management

- Implement connection pooling (PgBouncer or pgpool-II)
- Close connections when not in use
- Set appropriate connection limits
- Monitor active connections with pg_stat_activity

### 4. Regular Maintenance

- Run VACUUM ANALYZE regularly (or rely on autovacuum)
- Monitor table and index bloat
- Reindex tables with high bloat
- Update statistics frequently on high-traffic tables
- Archive old data to keep tables lean

### 5. Monitoring

```sql
-- Check database size
SELECT pg_size_pretty(pg_database_size(current_database()));

-- Check table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check active queries
SELECT pid, usename, state, query, now() - query_start AS duration
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- Check cache hit ratio (should be > 95%)
SELECT
    sum(heap_blks_read) AS heap_read,
    sum(heap_blks_hit) AS heap_hit,
    sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) AS cache_hit_ratio
FROM pg_statio_user_tables;
```

## Troubleshooting Guide

### Connection Issues

**Problem**: Cannot connect to PostgreSQL

**Solutions**:
1. Check if PostgreSQL is running: `sudo systemctl status postgresql`
2. Verify connection parameters (host, port, username, database)
3. Check pg_hba.conf authentication settings
4. Ensure firewall allows port 5432
5. Check PostgreSQL logs: `sudo tail -f /var/log/postgresql/postgresql-17-main.log`

### Slow Queries

**Problem**: Queries taking too long to execute

**Solutions**:
1. Enable pg_stat_statements: `CREATE EXTENSION pg_stat_statements;`
2. Find slow queries: See SKILL.md for query
3. Use EXPLAIN ANALYZE to identify bottlenecks
4. Add appropriate indexes
5. Update statistics: `ANALYZE table_name;`
6. Consider partitioning large tables

### High Disk Usage

**Problem**: Database consuming excessive disk space

**Solutions**:
1. Identify large tables and indexes
2. Check for table bloat
3. Run VACUUM FULL on bloated tables (during maintenance window)
4. Archive or purge old data
5. Consider partitioning with automated archiving

### Lock Contention

**Problem**: Queries waiting for locks

**Solutions**:
1. Identify blocking queries: See SKILL.md for query
2. Optimize long-running transactions
3. Use appropriate isolation levels
4. Consider using SELECT FOR UPDATE SKIP LOCKED for queue processing
5. Terminate problematic queries if necessary: `SELECT pg_terminate_backend(pid);`

### Memory Issues

**Problem**: PostgreSQL using too much memory

**Solutions**:
1. Tune shared_buffers (typically 25% of RAM)
2. Adjust work_mem (per-operation memory)
3. Set max_connections appropriately
4. Monitor with: `SELECT * FROM pg_stat_database;`
5. Use connection pooling to reduce memory overhead

## Essential Extensions

```sql
-- Enable useful extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;  -- Query statistics
CREATE EXTENSION IF NOT EXISTS pg_trgm;             -- Trigram matching for fuzzy search
CREATE EXTENSION IF NOT EXISTS btree_gin;           -- GIN indexes for multiple types
CREATE EXTENSION IF NOT EXISTS pgcrypto;            -- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS uuid-ossp;           -- UUID generation

-- Verify installed extensions
SELECT * FROM pg_available_extensions WHERE installed_version IS NOT NULL;
```

## Tools and Utilities

### Command-Line Tools

- **psql**: Interactive PostgreSQL terminal
- **pg_dump**: Database backup utility
- **pg_restore**: Restore from pg_dump backup
- **vacuumdb**: Vacuum and analyze databases
- **pg_basebackup**: Physical database backup
- **pgbench**: Benchmarking tool

### GUI Tools

- **pgAdmin**: Web-based administration tool
- **DBeaver**: Universal database manager
- **DataGrip**: JetBrains database IDE
- **TablePlus**: Modern database client (macOS/Windows)
- **Postico**: PostgreSQL client for macOS

### Monitoring Tools

- **pgAdmin**: Built-in dashboard and monitoring
- **pg_stat_statements**: Query performance tracking
- **pgBadger**: Log analyzer and report generator
- **pgMonitor**: Prometheus exporter for PostgreSQL
- **pgHero**: Performance dashboard

## Next Steps

1. **Explore SKILL.md**: Comprehensive guide with advanced techniques
2. **Review EXAMPLES.md**: 15+ practical, runnable examples
3. **Practice**: Create a test database and experiment
4. **Learn Advanced Features**: Partitioning, replication, full-text search
5. **Optimize**: Monitor performance and tune configuration
6. **Stay Updated**: Follow PostgreSQL release notes and community

## Resources

- **Official Documentation**: https://www.postgresql.org/docs/
- **PostgreSQL Wiki**: https://wiki.postgresql.org/
- **Community Support**: https://www.postgresql.org/support/
- **Stack Overflow**: Tag [postgresql]
- **Reddit**: r/PostgreSQL
- **Newsletter**: https://postgresweekly.com/

## Getting Help

If you need assistance:

1. Check PostgreSQL logs for error messages
2. Search official documentation
3. Review EXAMPLES.md for similar use cases
4. Consult Stack Overflow with [postgresql] tag
5. Join PostgreSQL community forums
6. Review SKILL.md troubleshooting section

## License

This skill package is provided as educational material for customer support tech enablement. PostgreSQL itself is released under the PostgreSQL License, a liberal Open Source license similar to the BSD or MIT licenses.

---

**Happy PostgreSQL Administration!**

Master these fundamentals, explore the advanced techniques in SKILL.md, and practice with the examples in EXAMPLES.md to become proficient in PostgreSQL database administration for customer support systems.
