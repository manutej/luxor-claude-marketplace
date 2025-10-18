# dbt Data Transformation

A comprehensive Claude Code skill for mastering dbt (data build tool) for analytics engineering and data transformation.

## Overview

This skill provides complete guidance for building modern data transformation pipelines using dbt. Whether you're migrating from legacy ETL, starting a new analytics project, or optimizing existing data workflows, this skill covers everything from basic model development to advanced production deployment strategies.

### What You'll Learn

- **Model Development**: Build SQL transformations using refs, sources, and CTEs
- **Materializations**: Choose the right strategy (view, table, incremental, ephemeral)
- **Testing**: Implement comprehensive data quality testing
- **Documentation**: Create searchable, auto-generated data catalogs
- **Incremental Models**: Efficiently process large datasets
- **Macros & Jinja**: Write reusable, dynamic SQL
- **Package Management**: Leverage and create dbt packages
- **Production Workflows**: Deploy with CI/CD, orchestration, and monitoring

## Why dbt?

dbt transforms the way analytics teams work by bringing software engineering best practices to data transformation:

### Key Benefits

1. **Version Control for SQL**: Track changes, collaborate with teams, and review transformations
2. **Automated Testing**: Ensure data quality with built-in and custom tests
3. **Documentation**: Auto-generated docs with lineage graphs and searchable catalog
4. **Modularity**: Reusable SQL through refs and macros reduces repetition
5. **Dependency Management**: Automatic DAG building ensures correct execution order
6. **Development Workflow**: Separate dev/prod environments, CI/CD integration
7. **Performance**: Incremental models and optimizations for large datasets

### The Modern Data Stack

```
Data Sources → EL Tool → Data Warehouse → dbt → BI Tool
(Apps, APIs)   (Fivetran) (Snowflake)    (T)   (Looker)
```

dbt handles the "T" (Transform) in ELT, running inside your data warehouse for maximum performance.

## When to Use This Skill

Use dbt when you need to:

- Transform raw data into analytics-ready datasets
- Build dimensional models (facts and dimensions)
- Create reusable data transformation logic
- Test data quality automatically
- Document data models and business logic
- Handle large-scale incremental data processing
- Implement DataOps practices
- Migrate from stored procedures or ETL tools
- Enable self-service analytics

## Project Structure

A well-organized dbt project follows this structure:

```
my_dbt_project/
├── dbt_project.yml           # Project configuration
├── packages.yml              # Package dependencies
├── profiles.yml              # Database connections (not in repo)
├── README.md                 # Project documentation
│
├── models/                   # SQL transformation models
│   ├── staging/              # 1:1 with source tables
│   │   ├── jaffle_shop/
│   │   │   ├── _jaffle_shop__sources.yml
│   │   │   ├── _jaffle_shop__models.yml
│   │   │   ├── stg_jaffle_shop__customers.sql
│   │   │   └── stg_jaffle_shop__orders.sql
│   │   └── stripe/
│   │       ├── _stripe__sources.yml
│   │       └── stg_stripe__payments.sql
│   │
│   ├── intermediate/         # Purpose-built transformations
│   │   └── int_orders_joined.sql
│   │
│   └── marts/               # Business-defined entities
│       ├── core/
│       │   ├── _core__models.yml
│       │   ├── dim_customers.sql
│       │   └── fct_orders.sql
│       └── marketing/
│           └── fct_customer_sessions.sql
│
├── tests/                   # Custom data tests
│   └── assert_positive_totals.sql
│
├── macros/                  # Reusable Jinja-SQL
│   ├── cents_to_dollars.sql
│   └── grant_permissions.sql
│
├── seeds/                   # CSV reference data
│   └── country_codes.csv
│
├── snapshots/               # SCD Type 2 captures
│   └── customers_snapshot.sql
│
├── analyses/                # Ad-hoc queries
│   └── revenue_analysis.sql
│
└── target/                  # Compiled artifacts (gitignored)
    ├── compiled/
    ├── run/
    └── manifest.json
```

## Quick Start Guide

### 1. Installation

```bash
# Install dbt Core with your database adapter
pip install dbt-core dbt-snowflake  # or dbt-bigquery, dbt-redshift, etc.

# Verify installation
dbt --version
```

### 2. Initialize Project

```bash
# Create new dbt project
dbt init my_analytics_project

cd my_analytics_project
```

### 3. Configure Connection

Edit `~/.dbt/profiles.yml`:

```yaml
my_analytics_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: abc123.us-east-1
      user: your_username
      password: "{{ env_var('DBT_PASSWORD') }}"
      role: transformer
      database: analytics
      warehouse: transforming
      schema: dbt_dev
      threads: 4

    prod:
      type: snowflake
      account: abc123.us-east-1
      user: prod_user
      password: "{{ env_var('DBT_PROD_PASSWORD') }}"
      role: transformer
      database: analytics
      warehouse: transforming
      schema: analytics_prod
      threads: 8
```

### 4. Test Connection

```bash
dbt debug
```

### 5. Create Your First Model

```sql
-- models/staging/stg_customers.sql

with source as (
    select * from {{ source('jaffle_shop', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as customer_name,
        email
    from source
)

select * from renamed
```

### 6. Define Source

```yaml
# models/staging/sources.yml

version: 2

sources:
  - name: jaffle_shop
    database: raw
    schema: jaffle_shop
    tables:
      - name: customers
        description: Raw customer data
        columns:
          - name: id
            description: Primary key
            tests:
              - unique
              - not_null
```

### 7. Run Your Model

```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_customers

# Run with tests
dbt build
```

### 8. Test Your Data

```bash
dbt test
```

### 9. Generate Documentation

```bash
dbt docs generate
dbt docs serve
```

Visit http://localhost:8080 to view your data documentation.

## Core Concepts

### Models

Models are SELECT statements that define data transformations:

```sql
-- Every model is a SELECT statement
select
    order_id,
    customer_id,
    order_date,
    status
from {{ ref('stg_orders') }}
```

### Materializations

Control how models are built in your warehouse:

- **View** (default): Virtual table, query runs on access
- **Table**: Physical table, full rebuild each run
- **Incremental**: Only processes new data
- **Ephemeral**: CTE interpolated into dependent models

```sql
{{ config(materialized='incremental') }}

select * from {{ source('events', 'page_views') }}

{% if is_incremental() %}
    where event_timestamp > (select max(event_timestamp) from {{ this }})
{% endif %}
```

### Tests

Ensure data quality with tests:

```yaml
# Schema tests in YAML
models:
  - name: fct_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: customer_id
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

```sql
-- Custom data tests in SQL
-- tests/assert_positive_totals.sql
select * from {{ ref('fct_orders') }}
where order_total < 0
```

### Documentation

Document your models for discoverability:

```yaml
models:
  - name: fct_orders
    description: |
      Order fact table containing one row per order.

      **Grain:** One row per order
      **Refresh:** Daily at 2 AM UTC

    columns:
      - name: order_id
        description: Primary key for orders
      - name: order_total
        description: Total order amount in USD
```

### Macros

Reusable Jinja-SQL functions:

```sql
-- macros/cents_to_dollars.sql
{% macro cents_to_dollars(column_name, precision=2) %}
    round({{ column_name }} / 100.0, {{ precision }})
{% endmacro %}
```

Usage:

```sql
select
    order_id,
    {{ cents_to_dollars('amount_cents') }} as amount_dollars
from {{ ref('stg_orders') }}
```

## Common Use Cases

### Use Case 1: E-commerce Analytics

Build a complete analytics pipeline for an e-commerce business:

```
Sources (Raw Data)
├── Application DB: customers, orders, order_items, products
└── Payment Provider: payments, refunds

Staging (Cleaned & Renamed)
├── stg_customers
├── stg_orders
├── stg_order_items
├── stg_products
└── stg_payments

Marts (Business Entities)
├── dim_customers (with lifetime value)
├── dim_products (with inventory)
├── fct_orders (order facts)
└── fct_order_items (line-level facts)

Metrics & Analytics
├── daily_revenue_metrics
├── customer_cohort_analysis
└── product_performance
```

### Use Case 2: SaaS Product Analytics

Track user behavior and subscription metrics:

```
Event Tracking
├── stg_page_views
├── stg_feature_usage
└── stg_api_calls

User & Account Management
├── dim_users
├── dim_accounts
└── fct_subscriptions

Product Metrics
├── feature_adoption_rates
├── user_retention_cohorts
└── account_health_scores
```

### Use Case 3: Marketing Attribution

Attribute revenue to marketing channels:

```
Marketing Data
├── stg_ad_clicks (Google, Facebook)
├── stg_email_opens
└── stg_referrals

Customer Journey
├── int_customer_touchpoints
└── int_attribution_windows

Attribution Models
├── first_touch_attribution
├── last_touch_attribution
└── multi_touch_attribution
```

## Development Workflow

### Daily Development

1. **Pull latest changes**: `git pull origin main`
2. **Install dependencies**: `dbt deps`
3. **Create feature branch**: `git checkout -b feature/new-metric`
4. **Develop models**: Write SQL in models/
5. **Run models**: `dbt run --select +my_new_model`
6. **Test**: `dbt test --select my_new_model`
7. **Document**: Add descriptions in YAML
8. **Commit & push**: Git workflow
9. **Open PR**: Code review process

### CI/CD Integration

- **On PR**: Run modified models and tests
- **On merge to main**: Full production deployment
- **Scheduled**: Daily/hourly production runs
- **Monitoring**: Track test failures, run times

## Best Practices

### Model Organization

1. **Use the staging → intermediate → marts pattern**
2. **Keep staging models 1:1 with source tables**
3. **Name models clearly** (stg_, int_, fct_, dim_)
4. **One model per business concept**

### SQL Style

1. **Use CTEs for readability**
2. **Lowercase SQL keywords**
3. **Consistent indentation (2 or 4 spaces)**
4. **Comment complex business logic**

### Testing

1. **Test all primary keys** (unique + not_null)
2. **Test foreign key relationships**
3. **Add custom tests for business rules**
4. **Use appropriate severity levels**

### Documentation

1. **Document model purpose and grain**
2. **Explain complex transformations**
3. **Keep documentation current**
4. **Link to external resources**

### Performance

1. **Use incremental models for large datasets**
2. **Partition and cluster tables**
3. **Filter early in CTEs**
4. **Monitor query costs**

## Advanced Topics

### Incremental Strategies

- **Append**: Add new rows only
- **Merge**: Upsert based on unique key
- **Delete+Insert**: Full partition replacement

### Snapshots (SCD Type 2)

Track historical changes:

```sql
{% snapshot customers_snapshot %}
    {{
        config(
            target_schema='snapshots',
            unique_key='customer_id',
            strategy='timestamp',
            updated_at='updated_at'
        )
    }}
    select * from {{ source('app', 'customers') }}
{% endsnapshot %}
```

### Exposures

Track downstream dependencies:

```yaml
exposures:
  - name: executive_dashboard
    type: dashboard
    url: https://looker.company.com/dashboards/123
    depends_on:
      - ref('fct_orders')
      - ref('dim_customers')
```

### Cross-Database Macros

Write database-agnostic SQL:

```sql
{% macro datediff(start_date, end_date, datepart) %}
    {{ adapter.dispatch('datediff')(start_date, end_date, datepart) }}
{% endmacro %}
```

## Troubleshooting

### Common Issues

**"Compilation Error: Model not found"**
- Check model name in ref()
- Ensure model file exists
- Run `dbt compile` to check for syntax errors

**"Database Error: Relation does not exist"**
- Check source configuration
- Verify database/schema names
- Run `dbt run` on upstream models first

**"Incremental model running full refresh every time"**
- Check `is_incremental()` logic
- Verify unique_key is set
- Ensure table exists (first run is full)

**"Tests failing unexpectedly"**
- Review test logic
- Check for data changes
- Use `dbt test --select test_name` to debug

## Resources & Learning

### Official Resources

- **Documentation**: https://docs.getdbt.com/
- **Courses**: https://courses.getdbt.com/
- **Community**: https://discourse.getdbt.com/
- **Package Hub**: https://hub.getdbt.com/

### Community Packages

- **dbt-utils**: Essential utility macros
- **dbt-expectations**: Great Expectations-style tests
- **audit-helper**: Compare datasets
- **codegen**: Generate boilerplate code

### Learning Path

1. **Beginner**: Complete dbt Fundamentals course
2. **Intermediate**: Build a complete project (staging → marts)
3. **Advanced**: Implement incremental models, macros, packages
4. **Expert**: CI/CD, custom materializations, performance tuning

## Getting Help

- **Documentation**: https://docs.getdbt.com/
- **Community Forum**: https://discourse.getdbt.com/
- **Slack**: https://www.getdbt.com/community/
- **GitHub Issues**: https://github.com/dbt-labs/dbt-core/issues
- **Stack Overflow**: Tag questions with `dbt`

## Skill Contents

This skill includes:

- **SKILL.md**: Comprehensive 20KB+ guide with 20+ detailed examples
- **README.md**: This overview and quick start guide
- **EXAMPLES.md**: 18+ practical examples with full code
- **Context7 Integration**: Real-world code snippets from dbt-core repository

---

**Version**: 1.0.0
**Author**: Claude Code Skills
**License**: MIT
**Last Updated**: October 2025
