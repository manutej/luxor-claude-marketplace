# Database Management Patterns

Comprehensive skill for mastering database design, optimization, and management across PostgreSQL (SQL) and MongoDB (NoSQL) systems.

## Overview

This skill provides production-ready patterns and best practices for:

- **Schema Design**: Normalization vs denormalization, relational vs document models
- **Indexing**: B-tree, hash, compound, partial, text, and geospatial indexes
- **Transactions**: ACID guarantees, isolation levels, multi-document operations
- **Replication**: Primary-standby, replica sets, failover strategies
- **Sharding**: Horizontal scaling, shard key selection, zone sharding
- **Performance**: Query optimization, explain plans, connection pooling
- **Operations**: Monitoring, troubleshooting, maintenance

## Quick Reference

### Database Selection Guide

| Requirement | PostgreSQL | MongoDB |
|-------------|-----------|---------|
| **Strong ACID transactions** | ✓ Excellent | ⚠️ Limited (single replica set) |
| **Complex JOINs** | ✓ Excellent | ⚠️ $lookup (expensive) |
| **Flexible schema** | ⚠️ Requires migrations | ✓ Native support |
| **Horizontal scaling** | ⚠️ Manual sharding | ✓ Built-in sharding |
| **JSON/Document storage** | ✓ JSONB type | ✓ Native BSON |
| **Nested hierarchies** | ⚠️ Requires CTEs/recursion | ✓ Natural fit |
| **Aggregation pipelines** | ✓ Window functions, CTEs | ✓ Aggregation framework |
| **Full-text search** | ✓ tsvector/GIN | ✓ Text indexes |
| **Geospatial queries** | ✓ PostGIS extension | ✓ Native 2dsphere |
| **Maturity & tooling** | ✓ Very mature | ✓ Mature |

### When to Use PostgreSQL

✅ **Ideal for:**
- Financial applications requiring strict consistency
- Complex data relationships with frequent JOINs
- Well-defined schemas that change infrequently
- Applications requiring advanced SQL features
- Strong data integrity guarantees (foreign keys, constraints)
- Multi-step transactions across multiple tables
- Regulatory compliance requiring audit trails

**Example use cases:**
- E-commerce order processing
- Banking and financial systems
- Inventory management
- Enterprise resource planning (ERP)
- Customer relationship management (CRM)

### When to Use MongoDB

✅ **Ideal for:**
- Applications with evolving/flexible schemas
- Rapid prototyping and agile development
- Content management systems with varied document types
- Real-time analytics and event logging
- Mobile and web apps with JSON APIs
- Hierarchical or deeply nested data
- Applications requiring horizontal scalability

**Example use cases:**
- Content management systems (CMS)
- Mobile app backends
- Real-time analytics dashboards
- Product catalogs with varied attributes
- Session storage and caching
- Internet of Things (IoT) event data

## Schema Design Decision Framework

### PostgreSQL Schema Design

```
Start: What is your data structure?
│
├─ Well-defined, stable relationships?
│  └─ Use normalized tables with foreign keys
│
├─ Need for data integrity constraints?
│  └─ Use CHECK constraints, triggers, foreign keys
│
├─ Hierarchical data (categories, org charts)?
│  ├─ Shallow hierarchy → Adjacency list (parent_id)
│  └─ Deep hierarchy → Materialized path or closure table
│
├─ Temporal data (historical tracking)?
│  └─ Use temporal tables or audit log pattern
│
└─ JSON data within relational structure?
   └─ Use JSONB columns for flexible attributes
```

### MongoDB Schema Design

```
Start: What are your access patterns?
│
├─ Data always accessed together?
│  └─ Embed documents (denormalize)
│
├─ Data accessed independently?
│  └─ Reference documents (normalize)
│
├─ One-to-few relationship (< 100 items)?
│  └─ Embed array in parent document
│
├─ One-to-many relationship (100-10,000 items)?
│  └─ Store parent reference in child documents
│
├─ One-to-squillions (unbounded)?
│  └─ Store child reference array in parent (paginate)
│
└─ Many-to-many relationship?
   └─ Use intermediate collection with references
```

## Core Indexing Strategies

### PostgreSQL Index Types

| Index Type | Use Case | Example |
|-----------|----------|---------|
| **B-tree** (default) | Equality, range, sorting | `CREATE INDEX idx_email ON users(email)` |
| **Hash** | Equality only | `CREATE INDEX USING HASH ON sessions(token)` |
| **GIN** | Full-text, JSONB, arrays | `CREATE INDEX USING GIN ON docs(content_tsv)` |
| **GiST** | Geometric, full-text | `CREATE INDEX USING GIST ON locations(geom)` |
| **BRIN** | Very large tables, sorted | `CREATE INDEX USING BRIN ON logs(timestamp)` |
| **Partial** | Subset of rows | `CREATE INDEX ON users(email) WHERE active=true` |
| **Expression** | Computed values | `CREATE INDEX ON users(LOWER(email))` |

### MongoDB Index Types

| Index Type | Use Case | Example |
|-----------|----------|---------|
| **Single field** | Simple queries | `db.users.createIndex({ email: 1 })` |
| **Compound** | Multiple field queries | `db.posts.createIndex({ author: 1, date: -1 })` |
| **Multikey** | Array fields | `db.posts.createIndex({ tags: 1 })` |
| **Text** | Full-text search | `db.articles.createIndex({ content: "text" })` |
| **Geospatial** | Location queries | `db.places.createIndex({ loc: "2dsphere" })` |
| **Hashed** | Even distribution (sharding) | `db.users.createIndex({ _id: "hashed" })` |
| **Wildcard** | Flexible schema fields | `db.products.createIndex({ "$**": 1 })` |

### ESR Rule for Compound Indexes (MongoDB)

Optimal compound index column order:

1. **Equality** filters first (exact matches)
2. **Sort** fields second
3. **Range** filters last

**Example:**
```javascript
// Query pattern
db.orders.find({
    status: "completed",      // Equality
    total: { $gte: 100 }      // Range
}).sort({ created_at: -1 })   // Sort

// Optimal index order
db.orders.createIndex({
    status: 1,        // 1. Equality
    created_at: -1,   // 2. Sort
    total: 1          // 3. Range
})
```

## Transaction Patterns

### PostgreSQL Isolation Levels

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Performance |
|-------|-----------|---------------------|--------------|-------------|
| **Read Uncommitted** | Possible | Possible | Possible | Fastest |
| **Read Committed** (default) | Prevented | Possible | Possible | Fast |
| **Repeatable Read** | Prevented | Prevented | Possible | Slower |
| **Serializable** | Prevented | Prevented | Prevented | Slowest |

**Common scenarios:**
- **Read Committed**: Most web applications (default, good balance)
- **Repeatable Read**: Reports requiring consistent snapshots
- **Serializable**: Financial transactions requiring strict ordering

### MongoDB Read/Write Concerns

**Write Concern Levels:**
- `w: 1` - Acknowledge after writing to primary (fast, less durable)
- `w: "majority"` - Acknowledge after majority of replica set (slower, durable)
- `j: true` - Wait for journal write (durability guarantee)

**Read Concern Levels:**
- `local` - Return latest data from node (fastest, may read rolled-back data)
- `majority` - Return data acknowledged by majority (slower, consistent)
- `linearizable` - Strongest consistency (slowest, serializable)

**Recommendation:**
- **Critical data** (payments, orders): `{ w: "majority", j: true }`
- **Regular data**: `{ w: 1 }`
- **Analytics/reporting**: Read from secondaries with `readPreference: "secondary"`

## Performance Optimization Checklist

### PostgreSQL Performance

- [ ] Enable and configure `pg_stat_statements` extension
- [ ] Set appropriate `shared_buffers` (25% of RAM)
- [ ] Configure `effective_cache_size` (50-75% of RAM)
- [ ] Enable autovacuum with appropriate thresholds
- [ ] Create indexes on foreign keys
- [ ] Use `EXPLAIN ANALYZE` for slow queries
- [ ] Implement connection pooling (PgBouncer)
- [ ] Monitor long-running queries
- [ ] Partition large tables (>10M rows)
- [ ] Use prepared statements in application code

### MongoDB Performance

- [ ] Create indexes matching query patterns
- [ ] Use covered queries when possible
- [ ] Enable profiling for slow queries
- [ ] Monitor index usage with `$indexStats`
- [ ] Choose appropriate shard key (high cardinality, even distribution)
- [ ] Configure replica set with appropriate read preferences
- [ ] Use projection to limit returned fields
- [ ] Batch operations when possible
- [ ] Monitor replication lag
- [ ] Set appropriate connection pool size

## Replication & High Availability

### PostgreSQL Replication Setup

**Streaming Replication (Primary-Standby):**
```
Primary Server
     │
     ├─→ Standby 1 (synchronous)
     ├─→ Standby 2 (asynchronous)
     └─→ Standby 3 (asynchronous)
```

**Benefits:**
- Read scaling (read queries from standbys)
- High availability (automatic failover)
- Zero data loss (synchronous replication)
- Point-in-time recovery

**Configuration:**
- Synchronous replication: Zero data loss, slower writes
- Asynchronous replication: Faster writes, possible data loss on failure

### MongoDB Replica Set

**Typical 3-Node Replica Set:**
```
Primary (writes)
     │
     ├─→ Secondary 1 (reads, failover)
     └─→ Secondary 2 (reads, failover)
```

**Benefits:**
- Automatic failover (election in ~12 seconds)
- Read scaling (read from secondaries)
- Data redundancy
- Rolling upgrades without downtime

**Topology Options:**
- 3 data-bearing members (standard)
- 2 data + 1 arbiter (voting only, saves storage)
- 5+ members for critical systems
- Hidden members for analytics
- Delayed members for disaster recovery

## Sharding Strategies

### MongoDB Sharding Architectures

**Range-Based Sharding:**
```
Shard Key: timestamp
─────────────────────────────
Shard 1: 2020-01-01 to 2022-12-31
Shard 2: 2023-01-01 to 2024-12-31
Shard 3: 2025-01-01 to current
```
- **Pros**: Range queries target specific shards
- **Cons**: Uneven distribution (recent data gets all writes)

**Hashed Sharding:**
```
Shard Key: _id (hashed)
─────────────────────────────
Shard 1: hash values 0-3333...
Shard 2: hash values 3333...-6666...
Shard 3: hash values 6666...-9999...
```
- **Pros**: Even distribution
- **Cons**: Range queries scatter to all shards

**Zone/Tag-Aware Sharding:**
```
Geographic distribution:
─────────────────────────────
US Shard: { region: "US" }
EU Shard: { region: "EU" }
APAC Shard: { region: "APAC" }
```
- **Pros**: Data locality, compliance (GDPR)
- **Cons**: Requires careful capacity planning

### PostgreSQL Partitioning

**Horizontal Partitioning (Sharding):**
- Use Citus extension for distributed PostgreSQL
- Application-level sharding with multiple databases
- Foreign Data Wrappers (FDW) for federated queries

**Vertical Partitioning:**
- Split large tables into frequently/rarely accessed columns
- Store BLOBs in separate table

## Monitoring and Observability

### Key PostgreSQL Metrics

| Metric | Target | Command |
|--------|--------|---------|
| **Cache hit ratio** | > 99% | `SELECT * FROM pg_stat_database` |
| **Active connections** | < max_connections | `SELECT count(*) FROM pg_stat_activity` |
| **Deadlocks** | Minimal | `SELECT deadlocks FROM pg_stat_database` |
| **Replication lag** | < 1 second | `SELECT pg_wal_lsn_diff(...)` |
| **Bloat** | < 20% | `pgstattuple` extension |
| **Slow queries** | None > 1s | `pg_stat_statements` |

### Key MongoDB Metrics

| Metric | Target | Command |
|--------|--------|---------|
| **Replication lag** | < 1 second | `rs.printSecondaryReplicationInfo()` |
| **Index efficiency** | 1:1 ratio | docs examined / docs returned |
| **Connection count** | < pool max | `db.serverStatus().connections` |
| **Queue depth** | < 10 | `db.serverStatus().globalLock.currentQueue` |
| **Memory usage** | < 80% | `db.serverStatus().mem` |
| **Chunk distribution** | Even | `sh.status()` |

## Common Design Patterns

### PostgreSQL Patterns

1. **Audit Trail**: Triggers + audit table for change history
2. **Soft Delete**: `deleted_at` column instead of DELETE
3. **Optimistic Locking**: Version column to detect concurrent updates
4. **Event Sourcing**: Immutable event log, rebuild state
5. **Materialized View**: Pre-computed aggregations for fast reads
6. **Temporal Tables**: System-versioned tables for time travel
7. **Queue Pattern**: `FOR UPDATE SKIP LOCKED` for job queues

### MongoDB Patterns

1. **Embedded**: Store related data in single document
2. **Bucketing**: Group time-series into periodic buckets
3. **Computed**: Store pre-aggregated values
4. **Subset**: Store frequently accessed fields, reference full data
5. **Extended Reference**: Embed key fields, reference for full data
6. **Approximation**: Store statistical approximations for large sets
7. **Outlier**: Separate handling for edge cases (e.g., popular items)

## Migration Strategies

### SQL to NoSQL Migration

**When to migrate:**
- Schema changes too frequent/expensive
- Need horizontal scalability beyond single server
- Document-oriented data is natural fit
- Application primarily JSON/REST API

**Approach:**
1. **Analyze access patterns**: Understand how data is queried
2. **Design document model**: Embed vs reference decisions
3. **Dual-write period**: Write to both databases
4. **Gradual read migration**: Move reads collection by collection
5. **Deprecate old system**: After validation period

### NoSQL to SQL Migration

**When to migrate:**
- Need for complex JOINs and relational queries
- Strong consistency requirements
- Schema has stabilized
- Advanced SQL features needed (window functions, CTEs)

**Approach:**
1. **Normalize schema**: Break documents into related tables
2. **Create foreign keys**: Establish relationships
3. **Migrate data**: Write ETL scripts
4. **Validate integrity**: Check constraints and references
5. **Update application**: Modify queries and ORM models

## Security Best Practices

### PostgreSQL Security

- ✅ Use SSL/TLS for all connections
- ✅ Implement row-level security (RLS) for multi-tenant apps
- ✅ Grant minimum necessary privileges (principle of least privilege)
- ✅ Use parameterized queries (prevent SQL injection)
- ✅ Enable audit logging for sensitive tables
- ✅ Rotate passwords regularly
- ✅ Encrypt sensitive columns (pgcrypto extension)
- ✅ Backup encryption for WAL archives

### MongoDB Security

- ✅ Enable authentication and authorization
- ✅ Use TLS/SSL for client and replica set connections
- ✅ Implement role-based access control (RBAC)
- ✅ Enable audit logging (Enterprise feature)
- ✅ Encrypt data at rest
- ✅ Network isolation (private networks, VPNs)
- ✅ Regular backups with encryption
- ✅ Disable JavaScript execution if not needed

## Troubleshooting Quick Reference

### PostgreSQL Issues

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Slow queries | Missing index | Run `EXPLAIN ANALYZE`, add index |
| High CPU | Expensive queries | Check `pg_stat_statements`, optimize |
| Connection errors | Max connections | Increase `max_connections`, use pooling |
| Deadlocks | Lock ordering | Review transaction logic |
| Bloat | No vacuuming | Enable autovacuum, run manual VACUUM |
| Replication lag | Network/load | Check bandwidth, reduce write load |

### MongoDB Issues

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Slow queries | Missing index | Run `.explain()`, create index |
| High memory | Working set > RAM | Add RAM, optimize queries, scale out |
| Write conflicts | Hotspot shard key | Choose better shard key |
| Replication lag | Oplog too small | Increase oplog size |
| Uneven sharding | Poor shard key | Re-shard with better key |
| Jumbo chunks | Indivisible data | Refine shard key, manual split |

## Resources & Tools

### PostgreSQL Tools
- **pgAdmin**: GUI administration
- **psql**: Command-line client
- **pg_stat_statements**: Query performance analysis
- **PgBouncer**: Connection pooling
- **Patroni**: High availability and failover
- **Barman**: Backup and recovery
- **PostGIS**: Geospatial extension

### MongoDB Tools
- **MongoDB Compass**: GUI explorer
- **mongosh**: Modern shell
- **MongoDB Atlas**: Managed cloud service
- **mongo-express**: Web-based admin
- **Percona Monitoring**: Performance monitoring
- **mongodump/mongorestore**: Backup utilities

---

**Quick Links:**
- [Full SKILL.md Documentation](./SKILL.md)
- [Detailed Examples](./EXAMPLES.md)
- PostgreSQL Docs: https://www.postgresql.org/docs/
- MongoDB Docs: https://docs.mongodb.com/
