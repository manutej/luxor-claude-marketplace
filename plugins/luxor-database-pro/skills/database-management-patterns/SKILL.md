---
name: database-management-patterns
description: Comprehensive guide for database management patterns covering PostgreSQL and MongoDB including schema design, indexing, transactions, replication, and performance tuning
tags: [database, postgresql, mongodb, sql, nosql, indexing, transactions, replication, sharding, performance, schema-design]
tier: tier-1
---

# Database Management Patterns

A comprehensive skill for mastering database management across SQL (PostgreSQL) and NoSQL (MongoDB) systems. This skill covers schema design, indexing strategies, transaction management, replication, sharding, and performance optimization for production-grade applications.

## When to Use This Skill

Use this skill when:

- **Designing database schemas** for new applications or refactoring existing ones
- **Choosing between SQL and NoSQL** databases for your use case
- **Optimizing query performance** with proper indexing strategies
- **Implementing data consistency** with transactions and ACID guarantees
- **Scaling databases** horizontally with sharding and replication
- **Managing high-traffic applications** requiring distributed databases
- **Ensuring data integrity** with constraints, triggers, and validation
- **Troubleshooting performance issues** using explain plans and query analysis
- **Building fault-tolerant systems** with replication and failover strategies
- **Working with complex data relationships** (relational) or flexible schemas (document)

## Core Concepts

### Database Paradigms Comparison

#### Relational Databases (PostgreSQL)

**Strengths:**
- **ACID Transactions**: Strong consistency guarantees
- **Complex Queries**: JOIN operations, subqueries, CTEs
- **Data Integrity**: Foreign keys, constraints, triggers
- **Normalized Data**: Reduced redundancy, consistent updates
- **Mature Ecosystem**: Rich tooling, extensions, community

**Best For:**
- Financial systems requiring strict consistency
- Complex relationships and data integrity requirements
- Applications with structured, well-defined schemas
- Systems requiring complex analytical queries
- Multi-step transactions across multiple tables

#### Document Databases (MongoDB)

**Strengths:**
- **Flexible Schema**: Easy schema evolution, polymorphic data
- **Horizontal Scalability**: Built-in sharding support
- **JSON-Native**: Natural fit for modern application development
- **Embedded Documents**: Denormalized data for performance
- **Aggregation Framework**: Powerful data processing pipeline

**Best For:**
- Rapidly evolving applications with changing requirements
- Content management systems with varied data structures
- Real-time analytics and event logging
- Mobile and web applications with JSON APIs
- Hierarchical or nested data structures

### ACID Properties

**Atomicity**: All operations in a transaction succeed or fail together
**Consistency**: Transactions bring database from one valid state to another
**Isolation**: Concurrent transactions don't interfere with each other
**Durability**: Committed transactions survive system failures

### CAP Theorem

In distributed systems, choose two of three:
- **Consistency**: All nodes see the same data
- **Availability**: System remains operational
- **Partition Tolerance**: System continues despite network failures

PostgreSQL emphasizes CP (Consistency + Partition Tolerance)
MongoDB can be configured for CP or AP depending on write/read concerns

## PostgreSQL Patterns

### Schema Design Fundamentals

#### Normalization Levels

**First Normal Form (1NF)**
- Atomic values (no arrays or lists in columns)
- Each row is unique (primary key exists)
- No repeating groups

**Second Normal Form (2NF)**
- Meets 1NF requirements
- All non-key attributes depend on the entire primary key

**Third Normal Form (3NF)**
- Meets 2NF requirements
- No transitive dependencies (non-key attributes depend only on primary key)

**When to Denormalize:**
- Read-heavy workloads where joins are expensive
- Frequently accessed aggregate data
- Historical snapshots that shouldn't change
- Performance-critical queries

#### Table Design Patterns

**Primary Keys:**
```sql
-- Serial auto-increment (traditional)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- UUID for distributed systems
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Composite primary key
CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

**Foreign Key Constraints:**
```sql
-- Cascade delete: Remove child records when parent deleted
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Set null: Preserve child records, nullify reference
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER,
    user_id INTEGER,
    content TEXT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Restrict: Prevent deletion if child records exist
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);
```

### Advanced Constraints

**Check Constraints:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    discount_percent INTEGER CHECK (discount_percent BETWEEN 0 AND 100),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Table-level check constraint
CREATE TABLE date_ranges (
    id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date > start_date)
);
```

**Unique Constraints:**
```sql
-- Single column unique
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL
);

-- Composite unique constraint
CREATE TABLE user_permissions (
    user_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, permission_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id)
);

-- Partial unique index (unique where condition met)
CREATE UNIQUE INDEX unique_active_email
ON users (email)
WHERE active = true;
```

### Triggers and Functions

**Audit Trail Pattern:**
```sql
-- Audit table
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(10) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by VARCHAR(255),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', row_to_json(OLD), current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to table
CREATE TRIGGER users_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

**Timestamp Update Pattern:**
```sql
CREATE OR REPLACE FUNCTION update_modified_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER posts_update_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW EXECUTE FUNCTION update_modified_timestamp();
```

### Views and Materialized Views

**Standard Views:**
```sql
-- Virtual table - computed on each query
CREATE VIEW active_users_with_posts AS
SELECT
    u.id,
    u.username,
    u.email,
    COUNT(p.id) as post_count,
    MAX(p.created_at) as last_post_date
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.active = true
GROUP BY u.id, u.username, u.email;

-- Use view like a table
SELECT * FROM active_users_with_posts WHERE post_count > 10;
```

**Materialized Views:**
```sql
-- Physical table - stores computed results
CREATE MATERIALIZED VIEW user_statistics AS
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.id) as total_posts,
    COUNT(DISTINCT c.id) as total_comments,
    AVG(p.views) as avg_post_views,
    MAX(p.created_at) as last_activity
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username;

-- Create index on materialized view
CREATE INDEX idx_user_stats_posts ON user_statistics(total_posts);

-- Refresh materialized view (update data)
REFRESH MATERIALIZED VIEW user_statistics;

-- Concurrent refresh (allows reads during refresh)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_statistics;
```

## MongoDB Patterns

### Document Modeling Strategies

#### Embedding vs Referencing

**Embedding Pattern (Denormalization):**
```javascript
// One-to-few: Embed when relationship is contained
// Example: Blog post with comments
{
    _id: ObjectId("..."),
    title: "Database Design Patterns",
    author: "John Doe",
    content: "...",
    published_at: ISODate("2025-01-15"),
    comments: [
        {
            _id: ObjectId("..."),
            author: "Jane Smith",
            text: "Great article!",
            created_at: ISODate("2025-01-16")
        },
        {
            _id: ObjectId("..."),
            author: "Bob Johnson",
            text: "Very helpful, thanks!",
            created_at: ISODate("2025-01-17")
        }
    ],
    tags: ["database", "design", "patterns"],
    stats: {
        views: 1523,
        likes: 89,
        shares: 23
    }
}

// Benefits:
// - Single query to retrieve post with comments
// - Better read performance
// - Atomic updates to entire document
//
// Drawbacks:
// - Document size limits (16MB in MongoDB)
// - Difficult to query comments independently
// - May duplicate data if comments need to appear elsewhere
```

**Referencing Pattern (Normalization):**
```javascript
// One-to-many or many-to-many: Reference when relationship is unbounded
// Example: User with many posts

// Users collection
{
    _id: ObjectId("507f1f77bcf86cd799439011"),
    username: "john_doe",
    email: "john@example.com",
    profile: {
        bio: "Software engineer",
        avatar_url: "https://...",
        location: "San Francisco"
    },
    created_at: ISODate("2024-01-01")
}

// Posts collection (references user)
{
    _id: ObjectId("507f191e810c19729de860ea"),
    user_id: ObjectId("507f1f77bcf86cd799439011"),
    title: "My First Post",
    content: "...",
    published_at: ISODate("2025-01-15"),
    comment_ids: [
        ObjectId("..."),
        ObjectId("...")
    ]
}

// Benefits:
// - No duplication of user data
// - Flexible: users can have unlimited posts
// - Easy to update user information once
//
// Drawbacks:
// - Requires multiple queries or $lookup
// - Slower read performance for joined data
```

**Hybrid Approach (Selective Denormalization):**
```javascript
// Store frequently accessed fields from referenced document
{
    _id: ObjectId("..."),
    title: "Database Patterns",
    content: "...",
    author: {
        // Embedded: frequently accessed, rarely changes
        id: ObjectId("507f1f77bcf86cd799439011"),
        username: "john_doe",
        avatar_url: "https://..."
    },
    // Reference: full user data available if needed
    author_id: ObjectId("507f1f77bcf86cd799439011"),
    published_at: ISODate("2025-01-15")
}

// Benefits:
// - Fast reads with embedded frequently-used data
// - Can still get full user data when needed
// - Balance between performance and flexibility
//
// Tradeoffs:
// - Need to update embedded data when user changes username/avatar
// - Slightly larger documents
```

### Schema Design Patterns

**Bucket Pattern (Time-Series Data):**
```javascript
// Instead of one document per measurement:
// BAD: Millions of tiny documents
{
    sensor_id: "sensor_001",
    timestamp: ISODate("2025-01-15T10:00:00Z"),
    temperature: 72.5,
    humidity: 45
}

// GOOD: Bucket documents with arrays of measurements
{
    sensor_id: "sensor_001",
    date: ISODate("2025-01-15"),
    hour: 10,
    measurements: [
        { minute: 0, temperature: 72.5, humidity: 45 },
        { minute: 1, temperature: 72.6, humidity: 45 },
        { minute: 2, temperature: 72.4, humidity: 46 },
        // ... up to 60 measurements per hour
    ],
    summary: {
        count: 60,
        avg_temperature: 72.5,
        min_temperature: 71.8,
        max_temperature: 73.2
    }
}

// Benefits:
// - Reduced document count (60x fewer documents)
// - Better index efficiency
// - Pre-computed summaries
// - Easier to query by time ranges
```

**Computed Pattern (Pre-Aggregated Data):**
```javascript
// Store computed values to avoid expensive aggregations
{
    _id: ObjectId("..."),
    product_id: "PROD-123",
    month: "2025-01",
    total_sales: 15420.50,
    units_sold: 234,
    unique_customers: 187,
    avg_order_value: 65.90,
    top_customers: [
        { customer_id: "CUST-456", revenue: 890.50 },
        { customer_id: "CUST-789", revenue: 675.25 }
    ],
    computed_at: ISODate("2025-02-01T00:00:00Z")
}

// Update pattern: Scheduled job or trigger updates computed values
```

**Polymorphic Pattern (Varied Schemas):**
```javascript
// Handle different product types in single collection
{
    _id: ObjectId("..."),
    type: "book",
    name: "Database Design",
    price: 49.99,
    // Book-specific fields
    isbn: "978-0-123456-78-9",
    author: "John Smith",
    pages: 456,
    publisher: "Tech Books Inc"
}

{
    _id: ObjectId("..."),
    type: "electronics",
    name: "Wireless Mouse",
    price: 29.99,
    // Electronics-specific fields
    brand: "TechBrand",
    warranty_months: 24,
    specifications: {
        battery_life: "6 months",
        connectivity: "Bluetooth 5.0"
    }
}

// Query by type
db.products.find({ type: "book", author: "John Smith" })
db.products.find({ type: "electronics", "specifications.connectivity": /Bluetooth/ })
```

### Aggregation Framework

**Basic Aggregation Pipeline:**
```javascript
// Group by author and count posts
db.posts.aggregate([
    {
        $match: { published: true } // Filter stage
    },
    {
        $group: {
            _id: "$author_id",
            total_posts: { $sum: 1 },
            total_views: { $sum: "$views" },
            avg_views: { $avg: "$views" },
            latest_post: { $max: "$published_at" }
        }
    },
    {
        $sort: { total_posts: -1 } // Sort by post count
    },
    {
        $limit: 10 // Top 10 authors
    }
])
```

**Advanced Pipeline with Lookup (Join):**
```javascript
// Join posts with user data
db.posts.aggregate([
    {
        $match: {
            published_at: { $gte: ISODate("2025-01-01") }
        }
    },
    {
        $lookup: {
            from: "users",
            localField: "author_id",
            foreignField: "_id",
            as: "author"
        }
    },
    {
        $unwind: "$author" // Flatten author array
    },
    {
        $project: {
            title: 1,
            content: 1,
            views: 1,
            "author.username": 1,
            "author.email": 1,
            days_since_publish: {
                $divide: [
                    { $subtract: [new Date(), "$published_at"] },
                    1000 * 60 * 60 * 24
                ]
            }
        }
    },
    {
        $sort: { views: -1 }
    }
])
```

**Aggregation with Grouping and Reshaping:**
```javascript
// Complex aggregation: Sales analysis
db.orders.aggregate([
    {
        $match: {
            status: "completed",
            created_at: {
                $gte: ISODate("2025-01-01"),
                $lt: ISODate("2025-02-01")
            }
        }
    },
    {
        $unwind: "$items" // Flatten order items
    },
    {
        $group: {
            _id: {
                product_id: "$items.product_id",
                customer_region: "$customer.region"
            },
            total_quantity: { $sum: "$items.quantity" },
            total_revenue: { $sum: "$items.total_price" },
            order_count: { $sum: 1 },
            avg_order_value: { $avg: "$items.total_price" }
        }
    },
    {
        $group: {
            _id: "$_id.product_id",
            regions: {
                $push: {
                    region: "$_id.customer_region",
                    quantity: "$total_quantity",
                    revenue: "$total_revenue"
                }
            },
            total_quantity: { $sum: "$total_quantity" },
            total_revenue: { $sum: "$total_revenue" }
        }
    },
    {
        $sort: { total_revenue: -1 }
    }
])
```

## Indexing Strategies

### PostgreSQL Indexes

**B-tree Indexes (Default):**
```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (order matters!)
CREATE INDEX idx_posts_author_published
ON posts(author_id, published_at);

-- Query can use index:
-- SELECT * FROM posts WHERE author_id = 123 ORDER BY published_at;
-- SELECT * FROM posts WHERE author_id = 123 AND published_at > '2025-01-01';

-- Query CANNOT fully use index:
-- SELECT * FROM posts WHERE published_at > '2025-01-01'; (only uses first column)
```

**Partial Indexes:**
```sql
-- Index only active users
CREATE INDEX idx_active_users
ON users(username)
WHERE active = true;

-- Index only recent orders
CREATE INDEX idx_recent_orders
ON orders(created_at, status)
WHERE created_at > '2024-01-01';

-- Benefits: Smaller index size, faster queries on filtered data
```

**Expression Indexes:**
```sql
-- Index on lowercase email for case-insensitive search
CREATE INDEX idx_users_email_lower
ON users(LOWER(email));

-- Query that uses this index:
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- Index on JSONB field extraction
CREATE INDEX idx_metadata_tags
ON products((metadata->>'category'));
```

**Full-Text Search Indexes:**
```sql
-- Add tsvector column for full-text search
ALTER TABLE articles
ADD COLUMN tsv_content tsvector;

-- Populate tsvector column
UPDATE articles
SET tsv_content = to_tsvector('english', title || ' ' || content);

-- Create GIN index for full-text search
CREATE INDEX idx_articles_tsv ON articles USING GIN(tsv_content);

-- Full-text search query
SELECT title, ts_rank(tsv_content, query) as rank
FROM articles, to_tsquery('english', 'database & design') query
WHERE tsv_content @@ query
ORDER BY rank DESC;

-- Trigger to auto-update tsvector
CREATE TRIGGER articles_tsv_update
BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(tsv_content, 'pg_catalog.english', title, content);
```

**JSONB Indexes:**
```sql
-- GIN index for JSONB containment queries
CREATE INDEX idx_products_metadata
ON products USING GIN(metadata);

-- Queries that use this index:
SELECT * FROM products WHERE metadata @> '{"color": "blue"}';
SELECT * FROM products WHERE metadata ? 'size';

-- Index on specific JSONB path
CREATE INDEX idx_products_category
ON products((metadata->>'category'));
```

**Index Monitoring:**
```sql
-- Find unused indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index usage
SELECT
    relname as table_name,
    indexrelname as index_name,
    idx_scan as times_used,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

### MongoDB Indexes

**Single Field Indexes:**
```javascript
// Create index on single field
db.users.createIndex({ email: 1 }) // 1 = ascending, -1 = descending

// Unique index
db.users.createIndex({ username: 1 }, { unique: true })

// Sparse index (only index documents with the field)
db.users.createIndex({ phone_number: 1 }, { sparse: true })
```

**Compound Indexes:**
```javascript
// Index on multiple fields (order matters!)
db.posts.createIndex({ author_id: 1, published_at: -1 })

// Efficient queries:
// - { author_id: "123" }
// - { author_id: "123", published_at: { $gte: ... } }
// - { author_id: "123" } with sort by published_at

// Inefficient:
// - { published_at: { $gte: ... } } alone (doesn't use index efficiently)

// ESR Rule: Equality, Sort, Range
// Best compound index order:
// 1. Equality filters first
// 2. Sort fields second
// 3. Range filters last
db.orders.createIndex({
    status: 1,           // Equality
    created_at: -1,      // Sort
    total_amount: 1      // Range
})
```

**Multikey Indexes (Array Fields):**
```javascript
// Index on array field
db.posts.createIndex({ tags: 1 })

// Document with array
{
    _id: ObjectId("..."),
    title: "Database Design",
    tags: ["database", "mongodb", "schema"]
}

// Query that uses multikey index
db.posts.find({ tags: "mongodb" })
db.posts.find({ tags: { $in: ["database", "nosql"] } })

// Compound multikey index (max one array field)
db.posts.createIndex({ tags: 1, published_at: -1 }) // Valid
// db.posts.createIndex({ tags: 1, categories: 1 }) // Invalid if both are arrays
```

**Text Indexes:**
```javascript
// Create text index for full-text search
db.articles.createIndex({
    title: "text",
    content: "text"
})

// Text search query
db.articles.find({
    $text: { $search: "database design patterns" }
})

// Search with relevance score
db.articles.find(
    { $text: { $search: "database design" } },
    { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })

// Weighted text index (prioritize title over content)
db.articles.createIndex(
    { title: "text", content: "text" },
    { weights: { title: 10, content: 5 } }
)
```

**Geospatial Indexes:**
```javascript
// 2dsphere index for geographic queries
db.locations.createIndex({ coordinates: "2dsphere" })

// Document format
{
    name: "Coffee Shop",
    coordinates: {
        type: "Point",
        coordinates: [-122.4194, 37.7749] // [longitude, latitude]
    }
}

// Find locations near a point
db.locations.find({
    coordinates: {
        $near: {
            $geometry: {
                type: "Point",
                coordinates: [-122.4194, 37.7749]
            },
            $maxDistance: 1000 // meters
        }
    }
})
```

**Index Properties:**
```javascript
// TTL Index (auto-delete documents after time)
db.sessions.createIndex(
    { created_at: 1 },
    { expireAfterSeconds: 3600 } // 1 hour
)

// Partial Index (index subset of documents)
db.orders.createIndex(
    { status: 1, created_at: -1 },
    { partialFilterExpression: { status: { $eq: "pending" } } }
)

// Case-insensitive index
db.users.createIndex(
    { email: 1 },
    { collation: { locale: "en", strength: 2 } }
)

// Background index creation (doesn't block operations)
db.large_collection.createIndex(
    { field: 1 },
    { background: true }
)
```

**Index Analysis:**
```javascript
// Explain query execution
db.posts.find({ author_id: "123" }).explain("executionStats")

// Check index usage
db.posts.aggregate([
    { $indexStats: {} }
])

// List all indexes on collection
db.posts.getIndexes()

// Drop unused index
db.posts.dropIndex("index_name")
```

## Transactions

### PostgreSQL Transaction Management

**Basic Transactions:**
```sql
-- Explicit transaction
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
-- or ROLLBACK; to cancel changes
```

**Savepoints (Partial Rollback):**
```sql
BEGIN;

UPDATE inventory SET quantity = quantity - 10 WHERE product_id = 'PROD-123';

SAVEPOINT before_audit;

INSERT INTO audit_log (action, details) VALUES ('inventory_update', '...');
-- Oops, error in audit log

ROLLBACK TO SAVEPOINT before_audit;
-- Inventory update preserved, audit insert rolled back

-- Fix and retry
INSERT INTO audit_log (action, details) VALUES ('inventory_update', 'correct details');

COMMIT;
```

**Isolation Levels:**
```sql
-- Read Uncommitted (not supported in PostgreSQL, defaults to Read Committed)
-- Read Committed (default) - sees only committed data
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable Read - sees snapshot at transaction start
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM accounts WHERE id = 1; -- Returns balance 1000
-- Another transaction updates balance to 1500 and commits
SELECT * FROM accounts WHERE id = 1; -- Still returns 1000 (repeatable read)
COMMIT;

-- Serializable - strictest isolation, prevents all anomalies
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- If concurrent transactions would violate serializability, one aborts
COMMIT;
```

**Advisory Locks (Application-Level Locking):**
```sql
-- Exclusive lock on arbitrary number
SELECT pg_advisory_lock(12345);
-- ... perform critical operation ...
SELECT pg_advisory_unlock(12345);

-- Try lock (non-blocking)
SELECT pg_try_advisory_lock(12345); -- Returns true if acquired, false otherwise

-- Session-level advisory lock (auto-released on disconnect)
SELECT pg_advisory_lock(user_id);
```

**Row-Level Locking:**
```sql
-- SELECT FOR UPDATE - lock rows for update
BEGIN;

SELECT * FROM products
WHERE id = 123
FOR UPDATE; -- Locks this row

UPDATE products SET quantity = quantity - 1 WHERE id = 123;

COMMIT;

-- SELECT FOR SHARE - shared lock (allows other reads, blocks writes)
SELECT * FROM products WHERE id = 123 FOR SHARE;

-- SKIP LOCKED - skip locked rows instead of waiting
SELECT * FROM queue
WHERE processed = false
ORDER BY priority
LIMIT 10
FOR UPDATE SKIP LOCKED;
```

### MongoDB Transactions

**Multi-Document Transactions:**
```javascript
// Transactions require replica set or sharded cluster
const session = db.getMongo().startSession()
session.startTransaction()

try {
    const accountsCol = session.getDatabase("mydb").accounts

    // Debit account
    accountsCol.updateOne(
        { _id: "account1" },
        { $inc: { balance: -100 } },
        { session }
    )

    // Credit account
    accountsCol.updateOne(
        { _id: "account2" },
        { $inc: { balance: 100 } },
        { session }
    )

    // Commit transaction
    session.commitTransaction()
} catch (error) {
    // Abort on error
    session.abortTransaction()
    throw error
} finally {
    session.endSession()
}
```

**Read and Write Concerns:**
```javascript
// Write Concern: Acknowledgment level
db.orders.insertOne(
    { customer_id: "123", items: [...] },
    {
        writeConcern: {
            w: "majority",        // Wait for majority of replica set
            j: true,              // Wait for journal write
            wtimeout: 5000        // Timeout after 5 seconds
        }
    }
)

// Read Concern: Data consistency level
db.orders.find(
    { status: "pending" }
).readConcern("majority") // Only return data acknowledged by majority

// Read Preference: Which replica to read from
db.orders.find({ ... }).readPref("secondary") // Read from secondary replica
```

**Atomic Operations (Single Document):**
```javascript
// Single document updates are atomic by default
db.counters.updateOne(
    { _id: "page_views" },
    {
        $inc: { count: 1 },
        $set: { last_updated: new Date() }
    }
)

// Atomic array operations
db.posts.updateOne(
    { _id: ObjectId("...") },
    {
        $push: {
            comments: {
                $each: [{ author: "John", text: "Great!" }],
                $position: 0 // Insert at beginning
            }
        }
    }
)

// Find and modify (atomic read-modify-write)
db.queue.findOneAndUpdate(
    { status: "pending" },
    { $set: { status: "processing", processor_id: "worker-1" } },
    {
        sort: { priority: -1 },
        returnDocument: "after" // Return updated document
    }
)
```

## Replication

### PostgreSQL Replication

**Streaming Replication (Primary-Standby):**
```sql
-- Primary server configuration (postgresql.conf)
wal_level = replica
max_wal_senders = 10
wal_keep_size = '1GB'
hot_standby = on

-- Create replication user
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'secure_password';

-- pg_hba.conf on primary
host replication replicator standby_ip/32 md5

-- Standby server (recovery.conf or postgresql.auto.conf)
primary_conninfo = 'host=primary_ip port=5432 user=replicator password=...'
restore_command = 'cp /var/lib/postgresql/archive/%f %p'
```

**Logical Replication (Selective Replication):**
```sql
-- On publisher (source)
CREATE PUBLICATION my_publication FOR TABLE users, posts;
-- or FOR ALL TABLES;

-- On subscriber (destination)
CREATE SUBSCRIPTION my_subscription
CONNECTION 'host=publisher_ip dbname=mydb user=replicator password=...'
PUBLICATION my_publication;

-- Monitor replication
SELECT * FROM pg_stat_replication;
SELECT * FROM pg_replication_slots;
```

**Failover and Promotion:**
```sql
-- Promote standby to primary
pg_ctl promote -D /var/lib/postgresql/data

-- Check replication lag
SELECT
    client_addr,
    state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    sync_state,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

### MongoDB Replication

**Replica Set Configuration:**
```javascript
// Initialize replica set
rs.initiate({
    _id: "myReplicaSet",
    members: [
        { _id: 0, host: "mongodb1.example.com:27017", priority: 2 },
        { _id: 1, host: "mongodb2.example.com:27017", priority: 1 },
        { _id: 2, host: "mongodb3.example.com:27017", priority: 1 }
    ]
})

// Add member to existing replica set
rs.add("mongodb4.example.com:27017")

// Remove member
rs.remove("mongodb4.example.com:27017")

// Check replica set status
rs.status()

// Check replication lag
rs.printSecondaryReplicationInfo()
```

**Replica Set Roles:**
```javascript
// Priority 0 member (cannot become primary)
rs.add({
    host: "analytics.example.com:27017",
    priority: 0,
    hidden: true // Hidden from application drivers
})

// Arbiter (voting only, no data)
rs.addArb("arbiter.example.com:27017")

// Delayed member (disaster recovery)
rs.add({
    host: "delayed.example.com:27017",
    priority: 0,
    hidden: true,
    slaveDelay: 3600 // 1 hour behind
})
```

**Read Preference Configuration:**
```javascript
// Application connection with read preference
const client = new MongoClient(uri, {
    readPreference: "secondaryPreferred", // Try secondary, fallback to primary
    readConcernLevel: "majority"
})

// Read Preference Modes:
// - primary (default): Read from primary only
// - primaryPreferred: Primary if available, else secondary
// - secondary: Read from secondary only
// - secondaryPreferred: Secondary if available, else primary
// - nearest: Read from nearest member (lowest latency)
```

## Sharding

### MongoDB Sharding Architecture

**Shard Key Selection:**
```javascript
// Good shard key characteristics:
// 1. High cardinality (many distinct values)
// 2. Even distribution
// 3. Query isolation (queries target specific shards)

// Example: User-based application
sh.shardCollection("mydb.users", { user_id: "hashed" })

// Hashed shard key: Even distribution, random data location
sh.shardCollection("mydb.events", { event_id: "hashed" })

// Range-based shard key: Ordered data, good for range queries
sh.shardCollection("mydb.logs", { timestamp: 1, server_id: 1 })

// Compound shard key
sh.shardCollection("mydb.orders", {
    customer_region: 1,  // Coarse grouping
    order_date: 1        // Fine grouping
})
```

**Sharding Setup:**
```javascript
// 1. Start config servers (replica set)
mongod --configsvr --replSet configRS --port 27019

// 2. Initialize config server replica set
rs.initiate({
    _id: "configRS",
    configsvr: true,
    members: [
        { _id: 0, host: "cfg1.example.com:27019" },
        { _id: 1, host: "cfg2.example.com:27019" },
        { _id: 2, host: "cfg3.example.com:27019" }
    ]
})

// 3. Start shard servers (each is a replica set)
mongod --shardsvr --replSet shard1RS --port 27018

// 4. Start mongos (query router)
mongos --configdb configRS/cfg1.example.com:27019,cfg2.example.com:27019

// 5. Add shards to cluster
sh.addShard("shard1RS/shard1-a.example.com:27018")
sh.addShard("shard2RS/shard2-a.example.com:27018")

// 6. Enable sharding on database
sh.enableSharding("mydb")

// 7. Shard collections
sh.shardCollection("mydb.users", { user_id: "hashed" })
```

**Query Targeting:**
```javascript
// Targeted query (includes shard key)
db.users.find({ user_id: "12345" })
// Routes to single shard

// Scatter-gather query (no shard key)
db.users.find({ email: "user@example.com" })
// Queries all shards, merges results

// Check query targeting
db.users.find({ user_id: "12345" }).explain()
// Look for "SINGLE_SHARD" vs "ALL_SHARDS"
```

**Zone Sharding (Geographic Distribution):**
```javascript
// Define zones for geographic sharding
sh.addShardToZone("shard1", "US")
sh.addShardToZone("shard2", "EU")

// Define zone ranges
sh.updateZoneKeyRange(
    "mydb.users",
    { region: "US", user_id: MinKey },
    { region: "US", user_id: MaxKey },
    "US"
)

sh.updateZoneKeyRange(
    "mydb.users",
    { region: "EU", user_id: MinKey },
    { region: "EU", user_id: MaxKey },
    "EU"
)

// Shard collection with zone-aware key
sh.shardCollection("mydb.users", { region: 1, user_id: 1 })
```

### PostgreSQL Horizontal Partitioning

**Declarative Partitioning:**
```sql
-- Range partitioning
CREATE TABLE logs (
    id BIGSERIAL,
    log_time TIMESTAMP NOT NULL,
    message TEXT,
    level VARCHAR(10)
) PARTITION BY RANGE (log_time);

-- Create partitions
CREATE TABLE logs_2025_01 PARTITION OF logs
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE logs_2025_02 PARTITION OF logs
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- List partitioning
CREATE TABLE customers (
    id SERIAL,
    name VARCHAR(255),
    region VARCHAR(50)
) PARTITION BY LIST (region);

CREATE TABLE customers_us PARTITION OF customers
FOR VALUES IN ('US', 'CA', 'MX');

CREATE TABLE customers_eu PARTITION OF customers
FOR VALUES IN ('UK', 'DE', 'FR', 'IT');

-- Hash partitioning
CREATE TABLE events (
    id BIGSERIAL,
    event_type VARCHAR(50),
    data JSONB
) PARTITION BY HASH (id);

CREATE TABLE events_0 PARTITION OF events
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE events_1 PARTITION OF events
FOR VALUES WITH (MODULUS 4, REMAINDER 1);
-- ... events_2 and events_3
```

**Partition Pruning (Query Optimization):**
```sql
-- Query automatically uses only relevant partition
SELECT * FROM logs
WHERE log_time BETWEEN '2025-01-15' AND '2025-01-20';
-- Only scans logs_2025_01 partition

-- Check query plan
EXPLAIN SELECT * FROM logs WHERE log_time > '2025-01-01';
-- Shows which partitions are scanned
```

## Performance Tuning

### Query Optimization Techniques

**PostgreSQL Query Analysis:**
```sql
-- Basic explain
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- Analyze with actual execution statistics
EXPLAIN ANALYZE
SELECT u.username, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.active = true
GROUP BY u.id, u.username
ORDER BY post_count DESC
LIMIT 10;

-- Identify slow queries
SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Table statistics
ANALYZE users; -- Update query planner statistics

-- Vacuum and analyze
VACUUM ANALYZE posts; -- Reclaim space and update stats
```

**Common Query Patterns:**
```sql
-- Avoid SELECT * (retrieve only needed columns)
-- BAD
SELECT * FROM users WHERE id = 123;

-- GOOD
SELECT id, username, email FROM users WHERE id = 123;

-- Use EXISTS instead of IN for large subqueries
-- BAD
SELECT * FROM posts WHERE author_id IN (
    SELECT id FROM users WHERE active = true
);

-- GOOD
SELECT * FROM posts p WHERE EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = p.author_id AND u.active = true
);

-- Use JOINs instead of multiple queries
-- BAD (N+1 query problem)
-- SELECT * FROM posts;
-- Then for each post: SELECT * FROM users WHERE id = post.author_id;

-- GOOD
SELECT p.*, u.username, u.email
FROM posts p
JOIN users u ON p.author_id = u.id;

-- Window functions instead of self-joins
-- Calculate running total
SELECT
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Rank within groups
SELECT
    category,
    product_name,
    sales,
    RANK() OVER (PARTITION BY category ORDER BY sales DESC) as rank_in_category
FROM products;
```

**MongoDB Query Optimization:**
```javascript
// Use projection to limit returned fields
// BAD
db.users.find({ active: true })

// GOOD
db.users.find(
    { active: true },
    { username: 1, email: 1, _id: 0 }
)

// Use covered queries (index covers all fields)
db.users.createIndex({ username: 1, email: 1 })
db.users.find(
    { username: "john_doe" },
    { username: 1, email: 1, _id: 0 }
) // Entire query served from index

// Avoid negation operators
// BAD (cannot use index efficiently)
db.products.find({ status: { $ne: "discontinued" } })

// GOOD
db.products.find({ status: { $in: ["active", "pending", "sold"] } })

// Use $lookup sparingly (expensive operation)
// Consider embedding data instead if appropriate

// Aggregation optimization: Filter early
// BAD
db.orders.aggregate([
    { $lookup: { ... } },        // Expensive join
    { $match: { status: "completed" } } // Filter after join
])

// GOOD
db.orders.aggregate([
    { $match: { status: "completed" } }, // Filter first
    { $lookup: { ... } }                  // Join fewer documents
])
```

### Connection Pooling

**PostgreSQL Connection Pooling:**
```javascript
// Using node-postgres (pg) with pool
const { Pool } = require('pg')

const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'mydb',
    user: 'dbuser',
    password: 'secret',
    max: 20,              // Maximum pool size
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000
})

// Execute query
const result = await pool.query('SELECT * FROM users WHERE id = $1', [123])

// Use PgBouncer for server-side pooling
// pgbouncer.ini
// [databases]
// mydb = host=localhost port=5432 dbname=mydb
//
// [pgbouncer]
// pool_mode = transaction
// max_client_conn = 1000
// default_pool_size = 25
```

**MongoDB Connection Pooling:**
```javascript
// MongoClient automatically manages connection pool
const { MongoClient } = require('mongodb')

const client = new MongoClient(uri, {
    maxPoolSize: 50,           // Max connections
    minPoolSize: 10,           // Min connections
    maxIdleTimeMS: 30000,      // Close idle connections
    waitQueueTimeoutMS: 5000   // Wait for available connection
})

await client.connect()
const db = client.db('mydb')
// Connection automatically returned to pool after use
```

## Best Practices

### PostgreSQL Best Practices

1. **Schema Design**
   - Normalize for data integrity, denormalize for performance
   - Use appropriate data types (avoid TEXT for short strings)
   - Define NOT NULL constraints where appropriate
   - Use SERIAL or UUID for primary keys consistently

2. **Indexing**
   - Index foreign keys for JOIN performance
   - Create indexes on frequently filtered/sorted columns
   - Use partial indexes for selective queries
   - Monitor and remove unused indexes
   - Keep composite index column count reasonable (typically ≤ 3-4)

3. **Query Performance**
   - Use EXPLAIN ANALYZE to understand query plans
   - Avoid SELECT * in application code
   - Use prepared statements to prevent SQL injection
   - Limit result sets with LIMIT
   - Use connection pooling

4. **Maintenance**
   - Run VACUUM regularly (or enable autovacuum)
   - Update statistics with ANALYZE
   - Monitor slow query log
   - Set appropriate autovacuum thresholds
   - Regular backup with pg_dump or WAL archiving

5. **Security**
   - Use SSL/TLS for connections
   - Implement row-level security for multi-tenant apps
   - Grant minimum necessary privileges
   - Use parameterized queries
   - Regular security updates

### MongoDB Best Practices

1. **Schema Design**
   - Embed related data that is accessed together
   - Reference data that is large or rarely accessed
   - Use polymorphic pattern for varied schemas
   - Limit document size to reasonable bounds (< 1-2 MB typically)
   - Design for your query patterns

2. **Indexing**
   - Index on fields used in queries and sorts
   - Use compound indexes with ESR rule (Equality, Sort, Range)
   - Create text indexes for full-text search
   - Monitor index usage with $indexStats
   - Avoid too many indexes (write performance impact)

3. **Query Performance**
   - Use projection to limit returned fields
   - Create covered queries when possible
   - Filter early in aggregation pipelines
   - Avoid $lookup when embedding is appropriate
   - Use explain() to verify index usage

4. **Scalability**
   - Choose appropriate shard key (high cardinality, even distribution)
   - Use replica sets for high availability
   - Configure appropriate read/write concerns
   - Monitor chunk distribution in sharded clusters
   - Use zones for geographic distribution

5. **Operations**
   - Enable authentication and authorization
   - Use TLS for client connections
   - Regular backups (mongodump or filesystem snapshots)
   - Monitor with MongoDB Atlas, Ops Manager, or custom tools
   - Keep MongoDB version updated

### Data Modeling Decision Framework

**Choose PostgreSQL when:**
- Strong ACID guarantees required (financial transactions)
- Complex relationships with many JOINs
- Data structure is well-defined and stable
- Need for advanced SQL features (window functions, CTEs, stored procedures)
- Compliance requirements demand strict consistency

**Choose MongoDB when:**
- Schema flexibility needed (rapid development, evolving requirements)
- Horizontal scalability is priority (sharding required)
- Document-oriented data (JSON/BSON native format)
- Hierarchical or nested data structures
- High write throughput with eventual consistency acceptable

**Hybrid Approach:**
- Use both databases for different parts of application
- PostgreSQL for transactional data (orders, payments)
- MongoDB for catalog, logs, user sessions
- Synchronize critical data between systems

## Common Patterns and Anti-Patterns

### PostgreSQL Anti-Patterns

❌ **Storing JSON when relational fits better**
```sql
-- BAD: Using JSONB for structured, queryable data
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    data JSONB -- { name, email, address: { street, city, state } }
);

-- GOOD: Proper normalization
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
);
```

❌ **Over-indexing**
```sql
-- BAD: Index on every column "just in case"
CREATE INDEX idx1 ON users(username);
CREATE INDEX idx2 ON users(email);
CREATE INDEX idx3 ON users(created_at);
CREATE INDEX idx4 ON users(updated_at);
CREATE INDEX idx5 ON users(active);
-- Result: Slow writes, large database size

-- GOOD: Index based on actual query patterns
CREATE INDEX idx_users_email ON users(email); -- Login queries
CREATE INDEX idx_active_users_created ON users(created_at) WHERE active = true; -- Partial
```

❌ **N+1 Query Problem**
```sql
-- BAD: Multiple queries in loop
SELECT * FROM posts; -- Returns 100 posts
-- Then for each post:
SELECT * FROM users WHERE id = ?; -- 100 additional queries!

-- GOOD: Single query with JOIN
SELECT p.*, u.username, u.email
FROM posts p
JOIN users u ON p.author_id = u.id;
```

### MongoDB Anti-Patterns

❌ **Massive arrays in documents**
```javascript
// BAD: Unbounded array growth
{
    _id: ObjectId("..."),
    username: "popular_user",
    followers: [
        ObjectId("follower1"),
        ObjectId("follower2"),
        // ... 100,000+ follower IDs
        // Document exceeds 16MB limit!
    ]
}

// GOOD: Separate collection with references
// users collection
{ _id: ObjectId("..."), username: "popular_user" }

// followers collection
{ _id: ObjectId("..."), user_id: ObjectId("..."), follower_id: ObjectId("...") }
db.followers.createIndex({ user_id: 1, follower_id: 1 })
```

❌ **Poor shard key selection**
```javascript
// BAD: Monotonically increasing shard key
sh.shardCollection("mydb.events", { _id: 1 })
// All writes go to same shard (highest _id range)

// BAD: Low cardinality shard key
sh.shardCollection("mydb.users", { country: 1 })
// Most users in few countries = uneven distribution

// GOOD: Hashed _id or compound key
sh.shardCollection("mydb.events", { _id: "hashed" }) // Even distribution
sh.shardCollection("mydb.users", { country: 1, user_id: 1 }) // Compound
```

❌ **Ignoring indexes on embedded documents**
```javascript
// Document structure
{
    username: "john_doe",
    profile: {
        email: "john@example.com",
        age: 30,
        city: "San Francisco"
    }
}

// Query on embedded field
db.users.find({ "profile.email": "john@example.com" })

// MISSING: Index on embedded field
db.users.createIndex({ "profile.email": 1 })
```

## Troubleshooting Guide

### PostgreSQL Issues

**Slow Queries:**
```sql
-- Enable slow query logging (postgresql.conf)
-- log_min_duration_statement = 1000  # Log queries > 1 second

-- Find slow queries
SELECT
    query,
    calls,
    total_exec_time / calls as avg_time_ms,
    rows / calls as avg_rows
FROM pg_stat_statements
WHERE calls > 100
ORDER BY total_exec_time DESC
LIMIT 20;

-- Analyze specific slow query
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT ... FROM ... WHERE ...;
```

**High CPU Usage:**
```sql
-- Check running queries
SELECT
    pid,
    now() - query_start as duration,
    state,
    query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- Terminate long-running query
SELECT pg_terminate_backend(pid);
```

**Lock Contention:**
```sql
-- View locks
SELECT
    locktype,
    relation::regclass,
    mode,
    granted,
    pid
FROM pg_locks
WHERE NOT granted;

-- Find blocking queries
SELECT
    blocked_locks.pid AS blocked_pid,
    blocking_locks.pid AS blocking_pid,
    blocked_activity.query AS blocked_query,
    blocking_activity.query AS blocking_query
FROM pg_locks blocked_locks
JOIN pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
JOIN pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted AND blocking_locks.granted;
```

### MongoDB Issues

**Slow Queries:**
```javascript
// Enable profiling
db.setProfilingLevel(1, { slowms: 100 }) // Log queries > 100ms

// View slow queries
db.system.profile.find().sort({ ts: -1 }).limit(10)

// Analyze query performance
db.collection.find({ ... }).explain("executionStats")
// Check: totalDocsExamined vs nReturned (should be close)
// Check: executionTimeMillis
// Check: indexName (should show index usage)
```

**Replication Lag:**
```javascript
// Check lag on secondary
rs.printSecondaryReplicationInfo()

// Check oplog size
db.getReplicationInfo()

// Increase oplog size if needed
db.adminCommand({ replSetResizeOplog: 1, size: 16384 }) // 16GB
```

**Sharding Issues:**
```javascript
// Check chunk distribution
sh.status()

// Check balancer status
sh.getBalancerState()
sh.isBalancerRunning()

// Balance specific collection
sh.enableBalancing("mydb.mycollection")

// Check for jumbo chunks
db.chunks.find({ jumbo: true })
```

## Resources

### PostgreSQL Resources
- Official Documentation: https://www.postgresql.org/docs/
- PostgreSQL Wiki: https://wiki.postgresql.org/
- Performance Tuning: https://wiki.postgresql.org/wiki/Performance_Optimization
- Explain Visualizer: https://explain.dalibo.com/
- pg_stat_statements Extension: Essential for query analysis

### MongoDB Resources
- Official Documentation: https://docs.mongodb.com/
- MongoDB University: Free courses and certification
- Aggregation Framework: https://docs.mongodb.com/manual/aggregation/
- Sharding Guide: https://docs.mongodb.com/manual/sharding/
- Schema Design Patterns: https://www.mongodb.com/blog/post/building-with-patterns-a-summary

### Books
- PostgreSQL: "PostgreSQL: Up and Running" by Regina Obe & Leo Hsu
- MongoDB: "MongoDB: The Definitive Guide" by Shannon Bradshaw, Eoin Brazil, Kristina Chodorow

---

**Skill Version**: 1.0.0
**Last Updated**: January 2025
**Skill Category**: Database Management, Data Architecture, Performance Optimization
**Technologies**: PostgreSQL 16+, MongoDB 7+
