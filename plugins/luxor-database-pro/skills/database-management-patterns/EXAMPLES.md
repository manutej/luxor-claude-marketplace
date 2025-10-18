# Database Management Patterns - Detailed Examples

Comprehensive collection of production-ready examples for PostgreSQL and MongoDB database management.

## Table of Contents

1. [PostgreSQL Schema Design Examples](#postgresql-schema-design-examples)
2. [PostgreSQL Advanced Queries](#postgresql-advanced-queries)
3. [PostgreSQL Performance Optimization](#postgresql-performance-optimization)
4. [MongoDB Schema Design Examples](#mongodb-schema-design-examples)
5. [MongoDB Aggregation Examples](#mongodb-aggregation-examples)
6. [MongoDB Sharding Examples](#mongodb-sharding-examples)
7. [Cross-Database Patterns](#cross-database-patterns)
8. [Real-World Use Cases](#real-world-use-cases)

---

## PostgreSQL Schema Design Examples

### Example 1: E-Commerce Database Schema

**Scenario**: Design a normalized schema for an e-commerce platform with products, orders, customers, and inventory.

```sql
-- Customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Addresses table (one customer, many addresses)
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('billing', 'shipping')),
    street_line1 VARCHAR(255) NOT NULL,
    street_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'US',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table (hierarchical)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES categories(id),
    description TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    cost NUMERIC(10, 2) CHECK (cost >= 0),
    weight_kg NUMERIC(8, 2),
    dimensions JSONB, -- { length, width, height, unit }
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT price_cost CHECK (price >= cost)
);

-- Inventory table
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    warehouse_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    reserved_quantity INTEGER NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    reorder_level INTEGER DEFAULT 10,
    last_restocked TIMESTAMP,
    UNIQUE (product_id, warehouse_id),
    CONSTRAINT available_stock CHECK (quantity >= reserved_quantity)
);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    subtotal NUMERIC(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (shipping_amount >= 0),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id INTEGER REFERENCES addresses(id),
    billing_address_id INTEGER REFERENCES addresses(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT total_calculation CHECK (
        total_amount = subtotal + tax_amount + shipping_amount
    )
);

-- Order items table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(10, 2) NOT NULL CHECK (subtotal >= 0),
    discount_amount NUMERIC(10, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    CONSTRAINT subtotal_calculation CHECK (
        subtotal = (unit_price * quantity) - discount_amount
    )
);

-- Indexes for performance
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_addresses_customer ON addresses(customer_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_active ON products(is_active) WHERE is_active = true;
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_update_timestamp
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER products_update_timestamp
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER orders_update_timestamp
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
```

### Example 2: Multi-Tenant SaaS Application

**Scenario**: Design schema for a multi-tenant application with row-level security.

```sql
-- Tenants table
CREATE TABLE tenants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    plan VARCHAR(50) NOT NULL CHECK (plan IN ('free', 'starter', 'professional', 'enterprise')),
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trial_ends_at TIMESTAMP
);

-- Users table (multi-tenant)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'member', 'viewer')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (tenant_id, email)
);

-- Projects table (multi-tenant)
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    owner_id INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enable row-level security
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see projects from their tenant
CREATE POLICY tenant_isolation_policy ON projects
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant_id')::INTEGER);

-- Policy: Admins can see all projects in their tenant
CREATE POLICY admin_policy ON projects
    FOR ALL
    USING (
        tenant_id = current_setting('app.current_tenant_id')::INTEGER
        AND EXISTS (
            SELECT 1 FROM users
            WHERE id = current_setting('app.current_user_id')::INTEGER
            AND role = 'admin'
            AND tenant_id = projects.tenant_id
        )
    );

-- Application sets tenant context before queries
-- SET app.current_tenant_id = 123;
-- SET app.current_user_id = 456;
```

### Example 3: Audit Logging with Triggers

**Scenario**: Track all changes to critical tables for compliance and debugging.

```sql
-- Generic audit log table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    schema_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id INTEGER NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    user_id INTEGER,
    username VARCHAR(255),
    ip_address INET,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for efficient queries
CREATE INDEX idx_audit_table ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp DESC);
CREATE INDEX idx_audit_user ON audit_log(user_id);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    old_row JSONB;
    new_row JSONB;
    changed_fields TEXT[];
BEGIN
    -- Convert rows to JSON
    IF TG_OP = 'DELETE' THEN
        old_row = row_to_json(OLD)::JSONB;
        new_row = NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_row = NULL;
        new_row = row_to_json(NEW)::JSONB;
    ELSE -- UPDATE
        old_row = row_to_json(OLD)::JSONB;
        new_row = row_to_json(NEW)::JSONB;

        -- Find changed fields
        SELECT ARRAY_AGG(key)
        INTO changed_fields
        FROM jsonb_each(old_row) o
        WHERE o.value IS DISTINCT FROM new_row->o.key;
    END IF;

    -- Insert audit record
    INSERT INTO audit_log (
        schema_name,
        table_name,
        operation,
        record_id,
        old_data,
        new_data,
        changed_fields,
        username
    ) VALUES (
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(NEW.id, OLD.id),
        old_row,
        new_row,
        changed_fields,
        current_user
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Attach audit trigger to tables
CREATE TRIGGER orders_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER products_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Query audit log
SELECT
    table_name,
    operation,
    record_id,
    changed_fields,
    username,
    timestamp
FROM audit_log
WHERE table_name = 'orders'
    AND record_id = 12345
ORDER BY timestamp DESC;
```

### Example 4: Hierarchical Data (Categories/Organization Chart)

**Scenario**: Store and query hierarchical organizational structure efficiently.

```sql
-- Organization table using materialized path pattern
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES organizations(id),
    path VARCHAR(500) NOT NULL, -- e.g., '1.5.12' for nested hierarchy
    level INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to maintain path and level
CREATE OR REPLACE FUNCTION update_org_path()
RETURNS TRIGGER AS $$
DECLARE
    parent_path VARCHAR(500);
    parent_level INTEGER;
BEGIN
    IF NEW.parent_id IS NULL THEN
        -- Root node
        NEW.path = NEW.id::VARCHAR;
        NEW.level = 0;
    ELSE
        -- Get parent's path and level
        SELECT path, level INTO parent_path, parent_level
        FROM organizations
        WHERE id = NEW.parent_id;

        NEW.path = parent_path || '.' || NEW.id;
        NEW.level = parent_level + 1;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER organizations_path_trigger
    BEFORE INSERT OR UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_org_path();

-- Efficient queries

-- Get all descendants of a node
SELECT *
FROM organizations
WHERE path LIKE (
    SELECT path || '.%'
    FROM organizations
    WHERE id = 5
);

-- Get all ancestors of a node
SELECT *
FROM organizations
WHERE id IN (
    SELECT unnest(string_to_array(
        (SELECT path FROM organizations WHERE id = 12),
        '.'
    )::INTEGER[])
);

-- Get immediate children
SELECT *
FROM organizations
WHERE parent_id = 5;

-- Get leaf nodes (no children)
SELECT o.*
FROM organizations o
LEFT JOIN organizations c ON c.parent_id = o.id
WHERE c.id IS NULL;

-- Get depth of tree
SELECT MAX(level) as max_depth
FROM organizations;
```

### Example 5: Time-Series Data with Partitioning

**Scenario**: Store sensor data with automatic partitioning by month.

```sql
-- Parent table (partitioned by range)
CREATE TABLE sensor_readings (
    id BIGSERIAL,
    sensor_id INTEGER NOT NULL,
    reading_time TIMESTAMP NOT NULL,
    temperature NUMERIC(5, 2),
    humidity NUMERIC(5, 2),
    pressure NUMERIC(7, 2),
    metadata JSONB,
    PRIMARY KEY (id, reading_time)
) PARTITION BY RANGE (reading_time);

-- Create partitions for each month
CREATE TABLE sensor_readings_2025_01 PARTITION OF sensor_readings
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE sensor_readings_2025_02 PARTITION OF sensor_readings
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE sensor_readings_2025_03 PARTITION OF sensor_readings
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

-- Indexes on partitions (created automatically on parent)
CREATE INDEX idx_sensor_readings_sensor_time
    ON sensor_readings(sensor_id, reading_time DESC);

CREATE INDEX idx_sensor_readings_metadata
    ON sensor_readings USING GIN(metadata);

-- Function to automatically create next month's partition
CREATE OR REPLACE FUNCTION create_next_partition()
RETURNS void AS $$
DECLARE
    next_month DATE;
    following_month DATE;
    partition_name VARCHAR(100);
BEGIN
    next_month := date_trunc('month', CURRENT_DATE + INTERVAL '1 month');
    following_month := next_month + INTERVAL '1 month';
    partition_name := 'sensor_readings_' || to_char(next_month, 'YYYY_MM');

    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF sensor_readings
         FOR VALUES FROM (%L) TO (%L)',
        partition_name,
        next_month,
        following_month
    );
END;
$$ LANGUAGE plpgsql;

-- Schedule this function to run monthly (via cron or pg_cron extension)

-- Query benefits from partition pruning
SELECT
    sensor_id,
    AVG(temperature) as avg_temp,
    MAX(temperature) as max_temp,
    MIN(temperature) as min_temp
FROM sensor_readings
WHERE reading_time >= '2025-01-15'
    AND reading_time < '2025-01-20'
    AND sensor_id = 42
GROUP BY sensor_id;
-- Only scans sensor_readings_2025_01 partition!
```

---

## PostgreSQL Advanced Queries

### Example 6: Window Functions for Analytics

**Scenario**: Calculate running totals, rankings, and moving averages.

```sql
-- Sample data: daily sales
CREATE TABLE daily_sales (
    sale_date DATE NOT NULL,
    product_id INTEGER NOT NULL,
    category VARCHAR(50),
    revenue NUMERIC(10, 2),
    units_sold INTEGER,
    PRIMARY KEY (sale_date, product_id)
);

-- Running total revenue by date
SELECT
    sale_date,
    revenue,
    SUM(revenue) OVER (ORDER BY sale_date) as running_total,
    AVG(revenue) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as moving_avg_7day
FROM daily_sales
WHERE product_id = 100
ORDER BY sale_date;

-- Rank products by revenue within each category
SELECT
    category,
    product_id,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as rank_in_category,
    PERCENT_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as percentile
FROM daily_sales
WHERE sale_date = '2025-01-15';

-- Year-over-year comparison
SELECT
    DATE_TRUNC('month', sale_date) as month,
    SUM(revenue) as current_revenue,
    LAG(SUM(revenue), 12) OVER (ORDER BY DATE_TRUNC('month', sale_date)) as previous_year_revenue,
    (SUM(revenue) - LAG(SUM(revenue), 12) OVER (ORDER BY DATE_TRUNC('month', sale_date)))
        / LAG(SUM(revenue), 12) OVER (ORDER BY DATE_TRUNC('month', sale_date)) * 100 as yoy_growth_pct
FROM daily_sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month;

-- Cumulative distribution
SELECT
    product_id,
    revenue,
    CUME_DIST() OVER (ORDER BY revenue) as cumulative_distribution,
    NTILE(4) OVER (ORDER BY revenue) as quartile
FROM daily_sales
WHERE sale_date = '2025-01-15';
```

### Example 7: Common Table Expressions (CTEs) and Recursion

**Scenario**: Find all related records recursively and perform complex multi-step analysis.

```sql
-- Recursive CTE: Find all employees in reporting hierarchy
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: start with CEO
    SELECT
        id,
        name,
        manager_id,
        title,
        1 as level,
        name::TEXT as path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: find direct reports
    SELECT
        e.id,
        e.name,
        e.manager_id,
        e.title,
        eh.level + 1,
        eh.path || ' > ' || e.name
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT
    level,
    name,
    title,
    path
FROM employee_hierarchy
ORDER BY level, name;

-- Multi-step analysis with CTEs
WITH
-- Step 1: Aggregate sales by customer
customer_totals AS (
    SELECT
        customer_id,
        COUNT(*) as order_count,
        SUM(total_amount) as total_spent,
        MAX(created_at) as last_order_date
    FROM orders
    WHERE created_at >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY customer_id
),
-- Step 2: Classify customers
customer_segments AS (
    SELECT
        customer_id,
        order_count,
        total_spent,
        last_order_date,
        CASE
            WHEN total_spent >= 10000 THEN 'VIP'
            WHEN total_spent >= 5000 THEN 'Premium'
            WHEN total_spent >= 1000 THEN 'Regular'
            ELSE 'Occasional'
        END as segment,
        CASE
            WHEN last_order_date >= CURRENT_DATE - INTERVAL '30 days' THEN 'Active'
            WHEN last_order_date >= CURRENT_DATE - INTERVAL '90 days' THEN 'At Risk'
            ELSE 'Churned'
        END as status
    FROM customer_totals
),
-- Step 3: Calculate segment statistics
segment_stats AS (
    SELECT
        segment,
        status,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_spent,
        SUM(total_spent) as segment_revenue
    FROM customer_segments
    GROUP BY segment, status
)
-- Final output
SELECT
    segment,
    status,
    customer_count,
    ROUND(avg_spent, 2) as avg_spent,
    segment_revenue,
    ROUND(segment_revenue * 100.0 / SUM(segment_revenue) OVER (), 2) as pct_of_total_revenue
FROM segment_stats
ORDER BY segment_revenue DESC;
```

### Example 8: Full-Text Search with Ranking

**Scenario**: Implement full-text search with relevance ranking.

```sql
-- Add tsvector column for full-text search
ALTER TABLE articles
    ADD COLUMN search_vector tsvector;

-- Populate search vector from title and content
UPDATE articles
SET search_vector =
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(content, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(tags::text, '')), 'C');

-- Create GIN index for fast full-text search
CREATE INDEX idx_articles_search ON articles USING GIN(search_vector);

-- Trigger to keep search_vector updated
CREATE OR REPLACE FUNCTION articles_search_trigger()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.tags::text, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER articles_search_update
    BEFORE INSERT OR UPDATE ON articles
    FOR EACH ROW EXECUTE FUNCTION articles_search_trigger();

-- Search with ranking
SELECT
    id,
    title,
    ts_rank(search_vector, query) as rank,
    ts_headline('english', content, query, 'MaxWords=50, MinWords=25') as snippet
FROM
    articles,
    to_tsquery('english', 'database & (design | pattern)') query
WHERE
    search_vector @@ query
ORDER BY rank DESC
LIMIT 20;

-- Advanced search with phrase matching
SELECT
    title,
    ts_rank_cd(search_vector, query) as rank
FROM
    articles,
    phraseto_tsquery('english', 'database design patterns') query
WHERE
    search_vector @@ query
ORDER BY rank DESC;
```

---

## PostgreSQL Performance Optimization

### Example 9: Index Optimization Strategies

```sql
-- Analyze table for query planner
ANALYZE products;

-- Check index usage statistics
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Find unused indexes (candidates for removal)
SELECT
    schemaname || '.' || tablename AS table,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size,
    idx_scan,
    idx_tup_read
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND indexrelname NOT LIKE 'pg_toast%'
    AND schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Create partial index for active records only
CREATE INDEX idx_active_products
ON products(category_id, name)
WHERE is_active = true AND stock_quantity > 0;

-- Expression index for case-insensitive search
CREATE INDEX idx_products_name_lower
ON products(LOWER(name));

-- Query that uses expression index
SELECT * FROM products
WHERE LOWER(name) = LOWER('Widget Pro');

-- Covering index (index-only scan)
CREATE INDEX idx_orders_covering
ON orders(customer_id, status)
INCLUDE (total_amount, created_at);

-- This query can be served entirely from index
SELECT customer_id, status, total_amount, created_at
FROM orders
WHERE customer_id = 123 AND status = 'completed';
```

### Example 10: Query Optimization Patterns

```sql
-- BEFORE: Inefficient subquery in SELECT
SELECT
    p.name,
    (SELECT COUNT(*) FROM order_items oi WHERE oi.product_id = p.id) as times_ordered
FROM products p;

-- AFTER: Use LEFT JOIN with GROUP BY
SELECT
    p.name,
    COALESCE(COUNT(oi.id), 0) as times_ordered
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name;

-- BEFORE: IN clause with large subquery
SELECT * FROM orders
WHERE customer_id IN (
    SELECT id FROM customers WHERE country = 'US'
);

-- AFTER: Use EXISTS or JOIN
SELECT o.* FROM orders o
WHERE EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = o.customer_id AND c.country = 'US'
);

-- Or using JOIN (often faster)
SELECT o.* FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE c.country = 'US';

-- BEFORE: Function in WHERE clause prevents index usage
SELECT * FROM orders
WHERE EXTRACT(YEAR FROM created_at) = 2025;

-- AFTER: Use range query
SELECT * FROM orders
WHERE created_at >= '2025-01-01'
    AND created_at < '2026-01-01';

-- BEFORE: OR conditions that prevent index usage
SELECT * FROM products
WHERE category_id = 10 OR category_id = 20;

-- AFTER: Use IN clause or UNION
SELECT * FROM products
WHERE category_id IN (10, 20);

-- Materialized CTE for reuse (PostgreSQL 12+)
WITH product_stats AS MATERIALIZED (
    SELECT
        product_id,
        COUNT(*) as order_count,
        SUM(quantity) as total_quantity
    FROM order_items
    GROUP BY product_id
)
SELECT
    p.name,
    ps.order_count,
    ps.total_quantity,
    ps.total_quantity / ps.order_count as avg_quantity_per_order
FROM products p
INNER JOIN product_stats ps ON p.id = ps.product_id
WHERE ps.order_count > 100
ORDER BY ps.total_quantity DESC;
```

---

## MongoDB Schema Design Examples

### Example 11: E-Commerce Product Catalog (Polymorphic Pattern)

**Scenario**: Store different product types with varying attributes in single collection.

```javascript
// Book product
{
    _id: ObjectId("507f1f77bcf86cd799439011"),
    type: "book",
    name: "Database Design Patterns",
    slug: "database-design-patterns",
    price: 49.99,
    currency: "USD",
    in_stock: true,

    // Book-specific fields
    isbn: "978-0-123456-78-9",
    author: "John Smith",
    publisher: "Tech Books Inc",
    pages: 456,
    publication_date: ISODate("2024-06-15"),
    language: "English",
    format: "Hardcover",

    // Common fields
    description: "Comprehensive guide to database design...",
    images: [
        { url: "https://cdn.example.com/book-cover.jpg", alt: "Book cover", order: 0 },
        { url: "https://cdn.example.com/book-back.jpg", alt: "Back cover", order: 1 }
    ],
    categories: ["Technology", "Databases", "Software Development"],
    tags: ["database", "design", "sql", "nosql"],
    reviews: {
        average: 4.7,
        count: 243
    },
    created_at: ISODate("2024-05-01"),
    updated_at: ISODate("2025-01-10")
}

// Electronics product
{
    _id: ObjectId("507f1f77bcf86cd799439012"),
    type: "electronics",
    name: "Wireless Noise-Cancelling Headphones",
    slug: "wireless-noise-cancelling-headphones",
    price: 299.99,
    currency: "USD",
    in_stock: true,

    // Electronics-specific fields
    brand: "AudioTech",
    model: "AT-5000",
    sku: "AUDIO-HP-5000",
    warranty_months: 24,
    specifications: {
        battery_life: "30 hours",
        bluetooth_version: "5.2",
        driver_size: "40mm",
        frequency_response: "20Hz - 20kHz",
        weight: "250g",
        colors: ["Black", "Silver", "Blue"]
    },
    features: [
        "Active Noise Cancellation",
        "Bluetooth 5.2",
        "30-hour battery life",
        "Quick charge (5 min = 2 hours)",
        "Multipoint connection"
    ],

    // Common fields
    description: "Premium wireless headphones with...",
    images: [
        { url: "https://cdn.example.com/hp-main.jpg", alt: "Main view", order: 0 },
        { url: "https://cdn.example.com/hp-side.jpg", alt: "Side view", order: 1 },
        { url: "https://cdn.example.com/hp-case.jpg", alt: "With case", order: 2 }
    ],
    categories: ["Electronics", "Audio", "Headphones"],
    tags: ["wireless", "bluetooth", "noise-cancelling", "headphones"],
    reviews: {
        average: 4.5,
        count: 892
    },
    created_at: ISODate("2024-03-20"),
    updated_at: ISODate("2025-01-12")
}

// Indexes for polymorphic collection
db.products.createIndex({ type: 1, slug: 1 }, { unique: true })
db.products.createIndex({ categories: 1, price: 1 })
db.products.createIndex({ tags: 1 })
db.products.createIndex({ "reviews.average": -1 })

// Type-specific indexes
db.products.createIndex({ isbn: 1 }, {
    unique: true,
    partialFilterExpression: { type: "book" }
})
db.products.createIndex({ sku: 1 }, {
    unique: true,
    partialFilterExpression: { type: "electronics" }
})

// Query books by author
db.products.find({
    type: "book",
    author: "John Smith"
})

// Query electronics by brand and price range
db.products.find({
    type: "electronics",
    brand: "AudioTech",
    price: { $gte: 200, $lte: 400 }
}).sort({ "reviews.average": -1 })
```

### Example 12: Social Media Application (Embedded vs Referenced)

**Scenario**: Design schema for posts, comments, likes with appropriate embedding strategy.

```javascript
// Users collection (separate - frequently updated, referenced by many)
{
    _id: ObjectId("user1"),
    username: "john_doe",
    email: "john@example.com",
    profile: {
        full_name: "John Doe",
        avatar_url: "https://cdn.example.com/avatars/john.jpg",
        bio: "Software engineer and database enthusiast",
        location: "San Francisco, CA",
        website: "https://johndoe.dev"
    },
    stats: {
        followers: 1523,
        following: 342,
        posts: 89
    },
    created_at: ISODate("2023-01-15"),
    last_seen: ISODate("2025-01-18T10:30:00Z")
}

// Posts collection (embed comments, reference user)
{
    _id: ObjectId("post1"),

    // Author reference with selective denormalization
    author: {
        id: ObjectId("user1"),
        username: "john_doe",
        avatar_url: "https://cdn.example.com/avatars/john.jpg"
        // Denormalize frequently accessed, rarely changing fields
    },

    content: {
        text: "Just published a comprehensive guide to database design patterns!",
        media: [
            {
                type: "image",
                url: "https://cdn.example.com/posts/db-guide.jpg",
                width: 1200,
                height: 630,
                alt: "Database design book cover"
            }
        ],
        links: [
            {
                url: "https://example.com/db-guide",
                title: "Database Design Patterns",
                description: "Learn advanced patterns...",
                image: "https://example.com/preview.jpg"
            }
        ]
    },

    // Embed comments (one-to-many, bounded, accessed together)
    comments: [
        {
            _id: ObjectId("comment1"),
            author: {
                id: ObjectId("user2"),
                username: "jane_smith",
                avatar_url: "https://cdn.example.com/avatars/jane.jpg"
            },
            text: "This looks great! Can't wait to read it.",
            created_at: ISODate("2025-01-15T11:00:00Z"),
            likes: 12,

            // Nested replies (limited depth)
            replies: [
                {
                    _id: ObjectId("reply1"),
                    author: {
                        id: ObjectId("user1"),
                        username: "john_doe",
                        avatar_url: "https://cdn.example.com/avatars/john.jpg"
                    },
                    text: "Thanks! Hope you find it useful.",
                    created_at: ISODate("2025-01-15T11:30:00Z"),
                    likes: 3
                }
            ]
        },
        {
            _id: ObjectId("comment2"),
            author: {
                id: ObjectId("user3"),
                username: "bob_wilson",
                avatar_url: "https://cdn.example.com/avatars/bob.jpg"
            },
            text: "Excellent timing! We're redesigning our database.",
            created_at: ISODate("2025-01-15T14:20:00Z"),
            likes: 8,
            replies: []
        }
    ],

    // Stats embedded (frequently updated together)
    stats: {
        views: 3542,
        likes: 234,
        shares: 45,
        comments: 2
    },

    // Tags for categorization
    tags: ["database", "software", "tutorial"],

    // Metadata
    created_at: ISODate("2025-01-15T10:00:00Z"),
    updated_at: ISODate("2025-01-15T14:20:00Z"),
    visibility: "public", // public, followers, private
    is_pinned: false
}

// Likes collection (separate - unbounded, may be millions)
{
    _id: ObjectId("like1"),
    post_id: ObjectId("post1"),
    user_id: ObjectId("user2"),
    created_at: ISODate("2025-01-15T11:00:00Z")
}

// Indexes
db.posts.createIndex({ "author.id": 1, created_at: -1 })
db.posts.createIndex({ created_at: -1 })
db.posts.createIndex({ tags: 1 })
db.posts.createIndex({ "stats.likes": -1 })

db.likes.createIndex({ post_id: 1, user_id: 1 }, { unique: true })
db.likes.createIndex({ user_id: 1, created_at: -1 })

// Query: Get user's feed (posts from people they follow)
db.posts.find({
    "author.id": { $in: followingUserIds },
    visibility: { $in: ["public", "followers"] }
}).sort({ created_at: -1 }).limit(20)

// Query: Check if user liked a post
db.likes.findOne({
    post_id: ObjectId("post1"),
    user_id: ObjectId("user2")
})

// Update: Increment like count (atomic operation)
db.posts.updateOne(
    { _id: ObjectId("post1") },
    {
        $inc: { "stats.likes": 1 },
        $set: { updated_at: new Date() }
    }
)
```

### Example 13: Time-Series Data (Bucketing Pattern)

**Scenario**: Store IoT sensor data efficiently using the bucket pattern.

```javascript
// BAD: One document per reading (millions of tiny documents)
{
    _id: ObjectId("..."),
    sensor_id: "temp_sensor_001",
    timestamp: ISODate("2025-01-15T10:00:00Z"),
    temperature: 72.5,
    humidity: 45.2
}

// GOOD: Bucket pattern - group readings by hour
{
    _id: ObjectId("..."),
    sensor_id: "temp_sensor_001",
    date: ISODate("2025-01-15"),
    hour: 10,

    // Array of measurements (up to 60 for 1-minute intervals)
    measurements: [
        {
            minute: 0,
            timestamp: ISODate("2025-01-15T10:00:00Z"),
            temperature: 72.5,
            humidity: 45.2,
            pressure: 1013.25
        },
        {
            minute: 1,
            timestamp: ISODate("2025-01-15T10:01:00Z"),
            temperature: 72.6,
            humidity: 45.1,
            pressure: 1013.30
        },
        // ... up to 60 measurements
    ],

    // Pre-computed summary statistics
    summary: {
        count: 60,
        temperature: {
            min: 71.8,
            max: 73.2,
            avg: 72.5,
            sum: 4350.0
        },
        humidity: {
            min: 44.5,
            max: 46.1,
            avg: 45.2,
            sum: 2712.0
        },
        pressure: {
            min: 1012.80,
            max: 1013.90,
            avg: 1013.25
        }
    },

    metadata: {
        sensor_location: "Building A - Room 101",
        sensor_type: "DHT22",
        firmware_version: "2.1.3"
    }
}

// Indexes for efficient queries
db.sensor_data.createIndex({ sensor_id: 1, date: 1, hour: 1 }, { unique: true })
db.sensor_data.createIndex({ date: 1, hour: 1 })
db.sensor_data.createIndex({ "metadata.sensor_location": 1, date: 1 })

// Query: Get all readings for a sensor on a specific day
db.sensor_data.find({
    sensor_id: "temp_sensor_001",
    date: ISODate("2025-01-15")
}).sort({ hour: 1 })

// Query: Get hourly averages for a date range
db.sensor_data.aggregate([
    {
        $match: {
            sensor_id: "temp_sensor_001",
            date: {
                $gte: ISODate("2025-01-01"),
                $lte: ISODate("2025-01-31")
            }
        }
    },
    {
        $project: {
            date: 1,
            hour: 1,
            avg_temperature: "$summary.temperature.avg",
            avg_humidity: "$summary.humidity.avg"
        }
    },
    {
        $sort: { date: 1, hour: 1 }
    }
])

// Insert new measurement (update bucket)
db.sensor_data.updateOne(
    {
        sensor_id: "temp_sensor_001",
        date: ISODate("2025-01-15"),
        hour: 10
    },
    {
        $push: {
            measurements: {
                minute: 30,
                timestamp: ISODate("2025-01-15T10:30:00Z"),
                temperature: 72.8,
                humidity: 45.5,
                pressure: 1013.40
            }
        },
        $inc: {
            "summary.count": 1,
            "summary.temperature.sum": 72.8
        },
        $min: {
            "summary.temperature.min": 72.8
        },
        $max: {
            "summary.temperature.max": 72.8
        }
    },
    { upsert: true }
)

// Benefits:
// - 60x fewer documents
// - Better index efficiency
// - Pre-computed statistics
// - Easier time-range queries
// - Reduced disk I/O
```

---

## MongoDB Aggregation Examples

### Example 14: Complex Multi-Stage Aggregation Pipeline

**Scenario**: Analyze e-commerce sales data with multiple transformations.

```javascript
db.orders.aggregate([
    // Stage 1: Filter to completed orders in date range
    {
        $match: {
            status: "completed",
            created_at: {
                $gte: ISODate("2025-01-01"),
                $lt: ISODate("2025-02-01")
            }
        }
    },

    // Stage 2: Unwind order items array
    {
        $unwind: "$items"
    },

    // Stage 3: Lookup product details
    {
        $lookup: {
            from: "products",
            localField: "items.product_id",
            foreignField: "_id",
            as: "product_info"
        }
    },

    // Stage 4: Unwind product info (should be single doc)
    {
        $unwind: "$product_info"
    },

    // Stage 5: Group by product and calculate metrics
    {
        $group: {
            _id: {
                product_id: "$items.product_id",
                product_name: "$product_info.name",
                category: "$product_info.category"
            },
            total_quantity: { $sum: "$items.quantity" },
            total_revenue: { $sum: "$items.subtotal" },
            order_count: { $sum: 1 },
            avg_quantity_per_order: { $avg: "$items.quantity" },
            avg_price: { $avg: "$items.unit_price" },
            customers: { $addToSet: "$customer_id" }
        }
    },

    // Stage 6: Calculate unique customer count
    {
        $addFields: {
            unique_customers: { $size: "$customers" }
        }
    },

    // Stage 7: Group by category for summary
    {
        $group: {
            _id: "$_id.category",
            products: {
                $push: {
                    product_id: "$_id.product_id",
                    product_name: "$_id.product_name",
                    total_quantity: "$total_quantity",
                    total_revenue: "$total_revenue",
                    unique_customers: "$unique_customers"
                }
            },
            category_revenue: { $sum: "$total_revenue" },
            category_units: { $sum: "$total_quantity" }
        }
    },

    // Stage 8: Sort products within each category
    {
        $addFields: {
            products: {
                $slice: [
                    {
                        $sortArray: {
                            input: "$products",
                            sortBy: { total_revenue: -1 }
                        }
                    },
                    5  // Top 5 products per category
                ]
            }
        }
    },

    // Stage 9: Sort categories by revenue
    {
        $sort: { category_revenue: -1 }
    },

    // Stage 10: Format output
    {
        $project: {
            category: "$_id",
            total_revenue: {
                $round: ["$category_revenue", 2]
            },
            total_units: "$category_units",
            top_products: "$products",
            _id: 0
        }
    }
])

// Example output:
[
    {
        "category": "Electronics",
        "total_revenue": 125430.50,
        "total_units": 1823,
        "top_products": [
            {
                "product_id": ObjectId("..."),
                "product_name": "Wireless Headphones",
                "total_quantity": 234,
                "total_revenue": 69882.00,
                "unique_customers": 198
            },
            // ... 4 more products
        ]
    },
    // ... more categories
]
```

### Example 15: Aggregation with Facets (Multiple Pipelines)

**Scenario**: Execute multiple aggregation pipelines in parallel for a dashboard.

```javascript
db.orders.aggregate([
    // Common filter stage
    {
        $match: {
            created_at: {
                $gte: ISODate("2025-01-01"),
                $lt: ISODate("2025-02-01")
            }
        }
    },

    // Facet: Multiple parallel aggregations
    {
        $facet: {
            // Facet 1: Revenue by day
            daily_revenue: [
                {
                    $group: {
                        _id: {
                            $dateToString: {
                                format: "%Y-%m-%d",
                                date: "$created_at"
                            }
                        },
                        revenue: { $sum: "$total_amount" },
                        orders: { $sum: 1 }
                    }
                },
                {
                    $sort: { _id: 1 }
                },
                {
                    $project: {
                        date: "$_id",
                        revenue: { $round: ["$revenue", 2] },
                        orders: 1,
                        _id: 0
                    }
                }
            ],

            // Facet 2: Top customers
            top_customers: [
                {
                    $group: {
                        _id: "$customer_id",
                        total_spent: { $sum: "$total_amount" },
                        order_count: { $sum: 1 }
                    }
                },
                {
                    $sort: { total_spent: -1 }
                },
                {
                    $limit: 10
                },
                {
                    $lookup: {
                        from: "customers",
                        localField: "_id",
                        foreignField: "_id",
                        as: "customer"
                    }
                },
                {
                    $unwind: "$customer"
                },
                {
                    $project: {
                        customer_id: "$_id",
                        customer_name: "$customer.name",
                        email: "$customer.email",
                        total_spent: { $round: ["$total_spent", 2] },
                        order_count: 1,
                        _id: 0
                    }
                }
            ],

            // Facet 3: Status distribution
            status_distribution: [
                {
                    $group: {
                        _id: "$status",
                        count: { $sum: 1 },
                        total_value: { $sum: "$total_amount" }
                    }
                },
                {
                    $project: {
                        status: "$_id",
                        count: 1,
                        total_value: { $round: ["$total_value", 2] },
                        _id: 0
                    }
                }
            ],

            // Facet 4: Overall statistics
            summary: [
                {
                    $group: {
                        _id: null,
                        total_orders: { $sum: 1 },
                        total_revenue: { $sum: "$total_amount" },
                        avg_order_value: { $avg: "$total_amount" },
                        unique_customers: { $addToSet: "$customer_id" }
                    }
                },
                {
                    $project: {
                        total_orders: 1,
                        total_revenue: { $round: ["$total_revenue", 2] },
                        avg_order_value: { $round: ["$avg_order_value", 2] },
                        unique_customers: { $size: "$unique_customers" },
                        _id: 0
                    }
                }
            ]
        }
    }
])
```

---

## MongoDB Sharding Examples

### Example 16: Sharding Setup and Configuration

**Scenario**: Set up a sharded cluster with zone-aware sharding for geographic distribution.

```javascript
// Step 1: Enable sharding on database
sh.enableSharding("ecommerce")

// Step 2: Choose appropriate shard key
// Option A: Hashed shard key for even distribution
sh.shardCollection("ecommerce.orders", { _id: "hashed" })

// Option B: Range-based compound key for query isolation
sh.shardCollection("ecommerce.users", {
    region: 1,
    user_id: 1
})

// Option C: Hashed compound key
sh.shardCollection("ecommerce.events", {
    user_id: "hashed",
    timestamp: 1
})

// Step 3: Create zones for geographic sharding
sh.addShardToZone("shard-us-east", "US-EAST")
sh.addShardToZone("shard-us-west", "US-WEST")
sh.addShardToZone("shard-eu", "EU")
sh.addShardToZone("shard-apac", "APAC")

// Step 4: Define zone ranges
sh.updateZoneKeyRange(
    "ecommerce.users",
    { region: "US", user_id: MinKey },
    { region: "US", user_id: MaxKey },
    "US-EAST"
)

sh.updateZoneKeyRange(
    "ecommerce.users",
    { region: "EU", user_id: MinKey },
    { region: "EU", user_id: MaxKey },
    "EU"
)

sh.updateZoneKeyRange(
    "ecommerce.users",
    { region: "APAC", user_id: MinKey },
    { region: "APAC", user_id: MaxKey },
    "APAC"
)

// Step 5: Monitor sharding status
sh.status()

// Step 6: Check chunk distribution
db.getSiblingDB("config").chunks.aggregate([
    {
        $group: {
            _id: { ns: "$ns", shard: "$shard" },
            count: { $sum: 1 }
        }
    },
    {
        $sort: { "_id.ns": 1, "_id.shard": 1 }
    }
])

// Step 7: Enable balancer (if disabled)
sh.startBalancer()
sh.getBalancerState()

// Step 8: Check for jumbo chunks
db.getSiblingDB("config").chunks.find({ jumbo: true })

// Example: Targeted query (routes to single shard)
db.users.find({
    region: "US",
    email: "user@example.com"
})
// Routes only to US-EAST shard

// Example: Scatter-gather query (routes to all shards)
db.users.find({
    email: "user@example.com"
})
// Routes to all shards (no shard key in query)
```

---

## Cross-Database Patterns

### Example 17: Polyglot Persistence Pattern

**Scenario**: Use PostgreSQL for transactional data and MongoDB for product catalog.

```javascript
// Application Architecture:
// - PostgreSQL: Orders, payments, inventory (ACID transactions)
// - MongoDB: Product catalog, user sessions, logs (flexible schema)
// - Sync critical data between systems

// PostgreSQL: Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id VARCHAR(50) NOT NULL, -- References MongoDB product_id
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL
);

// MongoDB: Product catalog
{
    _id: "PROD-12345",
    name: "Wireless Mouse",
    description: "Ergonomic wireless mouse...",
    price: 29.99,
    categories: ["Electronics", "Computer Accessories"],
    specifications: {
        battery_life: "12 months",
        connectivity: "2.4GHz wireless",
        dpi: "1600",
        buttons: 5
    },
    images: [...],
    inventory: {
        available: 150,
        reserved: 23
    },
    seo: {
        meta_title: "...",
        meta_description: "...",
        keywords: [...]
    }
}

// Synchronization pattern:
// 1. Application creates order in PostgreSQL (transactional)
// 2. Application reserves inventory in MongoDB
// 3. If either fails, rollback both (saga pattern)

// Application code (pseudo-code):
async function createOrder(orderData) {
    const pgClient = await pgPool.connect()
    const mongoSession = mongoClient.startSession()

    try {
        // Start PostgreSQL transaction
        await pgClient.query('BEGIN')

        // Start MongoDB transaction
        mongoSession.startTransaction()

        // 1. Create order in PostgreSQL
        const orderResult = await pgClient.query(
            'INSERT INTO orders (customer_id, total_amount) VALUES ($1, $2) RETURNING id',
            [orderData.customer_id, orderData.total]
        )
        const orderId = orderResult.rows[0].id

        // 2. Insert order items
        for (const item of orderData.items) {
            await pgClient.query(
                'INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES ($1, $2, $3, $4, $5)',
                [orderId, item.product_id, item.quantity, item.price, item.subtotal]
            )
        }

        // 3. Reserve inventory in MongoDB
        for (const item of orderData.items) {
            const result = await db.products.updateOne(
                {
                    _id: item.product_id,
                    "inventory.available": { $gte: item.quantity }
                },
                {
                    $inc: {
                        "inventory.available": -item.quantity,
                        "inventory.reserved": item.quantity
                    }
                },
                { session: mongoSession }
            )

            if (result.modifiedCount === 0) {
                throw new Error(`Insufficient inventory for product ${item.product_id}`)
            }
        }

        // Commit both transactions
        await pgClient.query('COMMIT')
        await mongoSession.commitTransaction()

        return { success: true, orderId }

    } catch (error) {
        // Rollback both transactions
        await pgClient.query('ROLLBACK')
        await mongoSession.abortTransaction()

        throw error

    } finally {
        pgClient.release()
        mongoSession.endSession()
    }
}
```

---

## Real-World Use Cases

### Example 18: Multi-Tenant SaaS Application

**Scenario**: Design database for a multi-tenant project management SaaS.

**PostgreSQL Approach (Row-Level Security):**

```sql
-- Single database, row-level isolation
CREATE TABLE tenants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    plan VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    project_id INTEGER NOT NULL REFERENCES projects(id),
    title VARCHAR(255) NOT NULL,
    status VARCHAR(50),
    assignee_id INTEGER,
    due_date DATE
);

-- Enable row-level security
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their tenant's data
CREATE POLICY tenant_isolation ON projects
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant')::INTEGER);

CREATE POLICY tenant_isolation ON tasks
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant')::INTEGER);

-- Application sets tenant context
SET app.current_tenant = 42;
SELECT * FROM projects; -- Only sees tenant 42's projects
```

**MongoDB Approach (Database-per-Tenant):**

```javascript
// Separate database for each tenant
// tenant_42 database
{
    _id: ObjectId("..."),
    name: "Website Redesign",
    description: "Redesign company website",
    owner_id: ObjectId("..."),
    members: [
        {
            user_id: ObjectId("..."),
            role: "admin",
            joined_at: ISODate("2025-01-01")
        },
        {
            user_id: ObjectId("..."),
            role: "member",
            joined_at: ISODate("2025-01-05")
        }
    ],
    tasks: [
        {
            _id: ObjectId("..."),
            title: "Create wireframes",
            status: "completed",
            assignee_id: ObjectId("..."),
            due_date: ISODate("2025-01-15"),
            completed_at: ISODate("2025-01-14")
        },
        {
            _id: ObjectId("..."),
            title: "Design homepage mockup",
            status: "in_progress",
            assignee_id: ObjectId("..."),
            due_date: ISODate("2025-01-20")
        }
    ],
    created_at: ISODate("2024-12-01"),
    updated_at: ISODate("2025-01-18")
}

// Application routing
function getTenantDatabase(tenantId) {
    return mongoClient.db(`tenant_${tenantId}`)
}

const tenantDb = getTenantDatabase(42)
const projects = await tenantDb.collection('projects').find().toArray()
```

### Example 19: Real-Time Analytics Dashboard

**Scenario**: Build real-time analytics for e-commerce platform.

```javascript
// MongoDB: Pre-aggregated metrics collection
{
    _id: ObjectId("..."),
    metric_type: "daily_sales",
    date: ISODate("2025-01-15"),

    // Pre-computed hourly breakdown
    hourly_data: [
        { hour: 0, orders: 23, revenue: 1245.50, customers: 18 },
        { hour: 1, orders: 18, revenue: 987.25, customers: 15 },
        // ... 24 hours
    ],

    // Overall daily totals
    totals: {
        orders: 542,
        revenue: 28456.75,
        unique_customers: 387,
        avg_order_value: 52.48,
        items_sold: 1234
    },

    // Top products
    top_products: [
        {
            product_id: "PROD-123",
            name: "Wireless Mouse",
            quantity: 89,
            revenue: 2581.11
        },
        // ... top 10
    ],

    // Category breakdown
    by_category: [
        {
            category: "Electronics",
            orders: 234,
            revenue: 15678.50
        },
        // ... all categories
    ],

    computed_at: ISODate("2025-01-16T00:05:00Z")
}

// Aggregation pipeline to compute metrics (run hourly/daily)
db.orders.aggregate([
    {
        $match: {
            created_at: {
                $gte: ISODate("2025-01-15T00:00:00Z"),
                $lt: ISODate("2025-01-16T00:00:00Z")
            },
            status: "completed"
        }
    },
    {
        $facet: {
            // Hourly breakdown
            hourly: [
                {
                    $group: {
                        _id: { $hour: "$created_at" },
                        orders: { $sum: 1 },
                        revenue: { $sum: "$total_amount" },
                        customers: { $addToSet: "$customer_id" }
                    }
                },
                {
                    $project: {
                        hour: "$_id",
                        orders: 1,
                        revenue: 1,
                        customers: { $size: "$customers" },
                        _id: 0
                    }
                },
                {
                    $sort: { hour: 1 }
                }
            ],

            // Overall totals
            totals: [
                {
                    $group: {
                        _id: null,
                        orders: { $sum: 1 },
                        revenue: { $sum: "$total_amount" },
                        customers: { $addToSet: "$customer_id" }
                    }
                },
                {
                    $project: {
                        orders: 1,
                        revenue: 1,
                        unique_customers: { $size: "$customers" },
                        avg_order_value: { $divide: ["$revenue", "$orders"] },
                        _id: 0
                    }
                }
            ],

            // Top products
            top_products: [
                { $unwind: "$items" },
                {
                    $group: {
                        _id: "$items.product_id",
                        quantity: { $sum: "$items.quantity" },
                        revenue: { $sum: "$items.subtotal" }
                    }
                },
                {
                    $lookup: {
                        from: "products",
                        localField: "_id",
                        foreignField: "_id",
                        as: "product"
                    }
                },
                { $unwind: "$product" },
                {
                    $project: {
                        product_id: "$_id",
                        name: "$product.name",
                        quantity: 1,
                        revenue: 1,
                        _id: 0
                    }
                },
                { $sort: { revenue: -1 } },
                { $limit: 10 }
            ]
        }
    },
    // Merge facets and store
    {
        $project: {
            metric_type: { $literal: "daily_sales" },
            date: { $literal: ISODate("2025-01-15") },
            hourly_data: "$hourly",
            totals: { $arrayElemAt: ["$totals", 0] },
            top_products: "$top_products",
            computed_at: { $literal: new Date() }
        }
    },
    // Output to metrics collection
    {
        $merge: {
            into: "daily_metrics",
            whenMatched: "replace",
            whenNotMatched: "insert"
        }
    }
])

// Dashboard query (fast - pre-computed)
db.daily_metrics.find({
    metric_type: "daily_sales",
    date: {
        $gte: ISODate("2025-01-01"),
        $lte: ISODate("2025-01-31")
    }
}).sort({ date: 1 })
```

### Example 20: Event Sourcing Pattern

**Scenario**: Implement event sourcing for order management.

**PostgreSQL Event Store:**

```sql
-- Events table (append-only)
CREATE TABLE order_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL,
    UNIQUE (aggregate_id, version)
);

CREATE INDEX idx_events_aggregate ON order_events(aggregate_id, version);
CREATE INDEX idx_events_type ON order_events(event_type, created_at);

-- Snapshots table (for performance)
CREATE TABLE order_snapshots (
    aggregate_id UUID PRIMARY KEY,
    state JSONB NOT NULL,
    version INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example: Order lifecycle events
INSERT INTO order_events (aggregate_id, aggregate_type, event_type, event_data, version)
VALUES
    -- Event 1: Order created
    (
        '550e8400-e29b-41d4-a716-446655440000',
        'Order',
        'OrderCreated',
        '{"customer_id": 123, "items": [...], "total": 99.99}'::jsonb,
        1
    ),
    -- Event 2: Payment received
    (
        '550e8400-e29b-41d4-a716-446655440000',
        'Order',
        'PaymentReceived',
        '{"payment_method": "credit_card", "amount": 99.99, "transaction_id": "TXN-123"}'::jsonb,
        2
    ),
    -- Event 3: Order shipped
    (
        '550e8400-e29b-41d4-a716-446655440000',
        'Order',
        'OrderShipped',
        '{"tracking_number": "TRK-456", "carrier": "UPS", "shipped_at": "2025-01-16T10:00:00Z"}'::jsonb,
        3
    );

-- Rebuild order state from events
WITH order_events_sorted AS (
    SELECT event_type, event_data, created_at
    FROM order_events
    WHERE aggregate_id = '550e8400-e29b-41d4-a716-446655440000'
    ORDER BY version
)
SELECT
    jsonb_agg(
        jsonb_build_object(
            'event', event_type,
            'data', event_data,
            'timestamp', created_at
        )
        ORDER BY created_at
    ) as event_history
FROM order_events_sorted;

-- Create snapshot for performance
INSERT INTO order_snapshots (aggregate_id, state, version)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    '{
        "customer_id": 123,
        "status": "shipped",
        "total": 99.99,
        "payment_status": "paid",
        "tracking_number": "TRK-456"
    }'::jsonb,
    3
)
ON CONFLICT (aggregate_id)
DO UPDATE SET
    state = EXCLUDED.state,
    version = EXCLUDED.version,
    created_at = CURRENT_TIMESTAMP;
```

---

**Total Examples**: 20+ comprehensive, production-ready examples covering:
- PostgreSQL schema design, advanced queries, performance tuning
- MongoDB document modeling, aggregation, sharding
- Cross-database patterns and real-world use cases
- Event sourcing, multi-tenancy, analytics, time-series data

These examples integrate concepts from the Context7 documentation and demonstrate practical application of database management patterns.
