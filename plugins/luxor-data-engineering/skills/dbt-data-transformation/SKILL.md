---
name: dbt-data-transformation
description: Complete guide for dbt data transformation including models, tests, documentation, incremental builds, macros, packages, and production workflows
tags: [dbt, data-transformation, analytics, sql, jinja, testing, documentation, incremental]
tier: tier-1
---

# dbt Data Transformation

A comprehensive skill for mastering dbt (data build tool) for analytics engineering. This skill covers model development, testing strategies, documentation practices, incremental builds, Jinja templating, macro development, package management, and production deployment workflows.

## When to Use This Skill

Use this skill when:

- Building data transformation pipelines for analytics and business intelligence
- Creating a data warehouse with modular, testable SQL transformations
- Implementing ELT (Extract, Load, Transform) workflows
- Developing dimensional models (facts, dimensions) for analytics
- Managing complex SQL dependencies and data lineage
- Creating reusable data transformation logic across projects
- Testing data quality and implementing data contracts
- Documenting data models and business logic
- Building incremental models for large datasets
- Orchestrating dbt with tools like Airflow, Dagster, or dbt Cloud
- Migrating legacy ETL processes to modern ELT architecture
- Implementing DataOps practices for analytics teams

## Core Concepts

### What is dbt?

dbt (data build tool) enables analytics engineers to transform data in their warehouse more effectively. It's a development framework that brings software engineering best practices to data transformation:

- **Version Control**: SQL transformations as code in Git
- **Testing**: Built-in data quality testing framework
- **Documentation**: Auto-generated, searchable data dictionary
- **Modularity**: Reusable SQL through refs and macros
- **Lineage**: Automatic dependency resolution and visualization
- **Deployment**: CI/CD for data transformations

### The dbt Workflow

```
1. Develop: Write SQL SELECT statements as models
2. Test: Define data quality tests
3. Document: Add descriptions and metadata
4. Build: dbt run compiles and executes models
5. Test: dbt test validates data quality
6. Deploy: CI/CD pipelines deploy to production
```

### Key dbt Entities

1. **Models**: SQL SELECT statements that define data transformations
2. **Sources**: Raw data tables in your warehouse
3. **Seeds**: CSV files loaded into your warehouse
4. **Tests**: Data quality assertions
5. **Macros**: Reusable Jinja-SQL functions
6. **Snapshots**: Type 2 slowly changing dimension captures
7. **Exposures**: Downstream uses of dbt models (dashboards, ML models)
8. **Metrics**: Business metric definitions

## Model Development

### Basic Model Structure

A dbt model is a SELECT statement saved as a `.sql` file:

```sql
-- models/staging/stg_orders.sql

with source as (
    select * from {{ source('jaffle_shop', 'orders') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status,
        _etl_loaded_at
    from source
)

select * from renamed
```

**Key Points:**
- Models are SELECT statements only (no DDL)
- Use CTEs (Common Table Expressions) for readability
- Reference sources with `{{ source() }}`
- dbt handles CREATE/INSERT logic based on materialization

### The ref() Function

Reference other models using `{{ ref() }}`:

```sql
-- models/marts/fct_orders.sql

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

joined as (
    select
        orders.order_id,
        orders.order_date,
        customers.customer_name,
        orders.status
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
)

select * from joined
```

**Benefits of ref():**
- Builds dependency graph automatically
- Resolves to correct schema/database
- Enables testing in dev without affecting prod
- Powers lineage visualization

### The source() Function

Define and reference raw data sources:

```yaml
# models/staging/sources.yml

version: 2

sources:
  - name: jaffle_shop
    description: Raw data from the Jaffle Shop application
    database: raw
    schema: jaffle_shop
    tables:
      - name: orders
        description: One record per order
        columns:
          - name: id
            description: Primary key for orders
            tests:
              - unique
              - not_null
          - name: user_id
            description: Foreign key to customers
          - name: order_date
            description: Date order was placed
          - name: status
            description: Order status (completed, pending, cancelled)
```

```sql
-- Reference the source
select * from {{ source('jaffle_shop', 'orders') }}
```

**Source Features:**
- Document raw data tables
- Test source data quality
- Track freshness with `freshness` config
- Separate source definitions from transformations

### Model Organization

Recommended project structure:

```
models/
├── staging/           # One-to-one with source tables
│   ├── jaffle_shop/
│   │   ├── _jaffle_shop__sources.yml
│   │   ├── _jaffle_shop__models.yml
│   │   ├── stg_jaffle_shop__orders.sql
│   │   └── stg_jaffle_shop__customers.sql
│   └── stripe/
│       ├── _stripe__sources.yml
│       ├── _stripe__models.yml
│       └── stg_stripe__payments.sql
├── intermediate/      # Purpose-built transformations
│   └── int_orders_joined.sql
└── marts/            # Business-defined entities
    ├── core/
    │   ├── _core__models.yml
    │   ├── dim_customers.sql
    │   └── fct_orders.sql
    └── marketing/
        └── fct_customer_sessions.sql
```

**Naming Conventions:**
- `stg_`: Staging models (one-to-one with sources)
- `int_`: Intermediate models (not exposed to end users)
- `fct_`: Fact tables
- `dim_`: Dimension tables

## Materializations

Materializations determine how dbt builds models in your warehouse:

### 1. View (Default)

```sql
{{ config(materialized='view') }}

select * from {{ ref('base_model') }}
```

**Characteristics:**
- Lightweight, no data stored
- Query runs each time view is accessed
- Best for: Small datasets, models queried infrequently
- Fast to build, slower to query

### 2. Table

```sql
{{ config(materialized='table') }}

select * from {{ ref('base_model') }}
```

**Characteristics:**
- Full table rebuild on each run
- Data physically stored
- Best for: Small to medium datasets, heavily queried models
- Slower to build, faster to query

### 3. Incremental

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='fail'
) }}

select * from {{ source('jaffle_shop', 'orders') }}

{% if is_incremental() %}
    -- Only process new/updated records
    where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

**Characteristics:**
- Only processes new data on subsequent runs
- First run builds full table
- Best for: Large datasets, event/time-series data
- Fast incremental builds, maintains historical data

**Incremental Strategies:**

```sql
-- Append (default): Add new rows only
{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

-- Merge: Upsert based on unique_key
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

-- Delete+Insert: Delete matching records, insert new
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert'
) }}
```

### 4. Ephemeral

```sql
{{ config(materialized='ephemeral') }}

select * from {{ ref('base_model') }}
```

**Characteristics:**
- Not built in warehouse
- Interpolated as CTE in dependent models
- Best for: Lightweight transformations, avoiding view proliferation
- No storage, compiled into downstream models

### Configuration Comparison

| Materialization | Build Speed | Query Speed | Storage | Use Case |
|----------------|-------------|-------------|---------|----------|
| View | Fast | Slow | None | Small datasets, infrequent queries |
| Table | Slow | Fast | High | Medium datasets, frequent queries |
| Incremental | Fast* | Fast | High | Large datasets, time-series data |
| Ephemeral | N/A | Varies | None | Intermediate logic, CTEs |

*After initial full build

## Testing

### Schema Tests

Built-in generic tests defined in YAML:

```yaml
# models/staging/stg_orders.yml

version: 2

models:
  - name: stg_orders
    description: Staged order data
    columns:
      - name: order_id
        description: Primary key
        tests:
          - unique
          - not_null

      - name: customer_id
        description: Foreign key to customers
        tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_id

      - name: status
        description: Order status
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned', 'cancelled']

      - name: order_total
        description: Total order amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

**Built-in Tests:**
- `unique`: No duplicate values
- `not_null`: No null values
- `accepted_values`: Value in specified list
- `relationships`: Foreign key validation

### Custom Data Tests

Create custom tests in `tests/` directory:

```sql
-- tests/assert_positive_order_totals.sql

select
    order_id,
    order_total
from {{ ref('fct_orders') }}
where order_total < 0
```

**How it works:**
- Test fails if query returns any rows
- Query should return failing records
- Can use any SQL logic

### Advanced Testing Patterns

```sql
-- Test for data freshness
-- tests/assert_orders_are_fresh.sql

with latest_order as (
    select max(order_date) as max_date
    from {{ ref('fct_orders') }}
)

select max_date
from latest_order
where max_date < current_date - interval '1 day'
```

```sql
-- Test for referential integrity across time
-- tests/assert_no_orphaned_orders.sql

select
    o.order_id,
    o.customer_id
from {{ ref('fct_orders') }} o
left join {{ ref('dim_customers') }} c
    on o.customer_id = c.customer_id
where c.customer_id is null
```

### Testing with dbt_utils

```yaml
# Requires dbt-utils package

models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          # Test for uniqueness across multiple columns
          - dbt_utils.unique_combination_of_columns:
              combination_of_columns:
                - order_id
                - order_date

          # Test for sequential values
          - dbt_utils.sequential_values:
              interval: 1

          # Test that values match regex
          - dbt_utils.not_null_proportion:
              at_least: 0.95
```

### Test Severity Levels

```yaml
models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - unique:
              severity: error  # Fail build (default)
          - not_null:
              severity: warn   # Warning only
```

## Documentation

### Model Documentation

```yaml
# models/marts/core/_core__models.yml

version: 2

models:
  - name: fct_orders
    description: |
      Order fact table containing one row per order with associated
      customer and payment information. This is the primary table for
      order analytics and reporting.

      **Grain:** One row per order

      **Refresh:** Incremental, updates daily at 2 AM UTC

      **Notes:**
      - Includes cancelled orders (filter with status column)
      - Payment info joined from Stripe data
      - Customer info joined from application database

    columns:
      - name: order_id
        description: Primary key for orders table
        tests:
          - unique
          - not_null

      - name: customer_id
        description: |
          Foreign key to dim_customers. Links to customer who placed the order.
          **Note:** May be null for guest checkout orders.

      - name: order_date
        description: Date order was placed (UTC timezone)

      - name: status
        description: |
          Current order status. Possible values:
          - `placed`: Order received, not yet processed
          - `shipped`: Order shipped to customer
          - `completed`: Order delivered and confirmed
          - `returned`: Order returned by customer
          - `cancelled`: Order cancelled before shipment

      - name: order_total
        description: Total order amount in USD including tax and shipping
```

### Documentation Blocks

Create reusable documentation:

```markdown
<!-- models/docs.md -->

{% docs order_status %}

Order status indicates the current state of an order in our fulfillment pipeline.

| Status | Description | Next Steps |
|--------|-------------|------------|
| placed | Order received | Inventory check |
| shipped | En route to customer | Track shipment |
| completed | Delivered successfully | Request feedback |
| returned | Customer return initiated | Process refund |
| cancelled | Order cancelled | Update inventory |

{% enddocs %}

{% docs customer_id %}

Unique identifier for customers. This ID is:
- Generated by the application on account creation
- Persistent across orders
- Used to track customer lifetime value
- **Note:** NULL for guest checkouts

{% enddocs %}
```

Reference documentation blocks:

```yaml
models:
  - name: fct_orders
    columns:
      - name: status
        description: "{{ doc('order_status') }}"

      - name: customer_id
        description: "{{ doc('customer_id') }}"
```

### Generating Documentation

```bash
# Generate documentation site
dbt docs generate

# Serve documentation locally
dbt docs serve --port 8001

# View in browser at http://localhost:8001
```

**Documentation Features:**
- Interactive lineage graph (DAG visualization)
- Searchable model catalog
- Column-level documentation
- Source freshness tracking
- Test coverage visibility
- Compiled SQL preview

### Documentation Best Practices

1. **Document at all levels**: Project, models, columns, sources
2. **Explain business logic**: Why transformations exist
3. **Define grain explicitly**: One row represents...
4. **Note refresh schedules**: How often data updates
5. **Document assumptions**: Edge cases, known issues
6. **Link to external resources**: Confluence, wiki, dashboards

## Incremental Models

### Basic Incremental Pattern

```sql
{{ config(
    materialized='incremental',
    unique_key='event_id'
) }}

with source as (
    select
        event_id,
        user_id,
        event_timestamp,
        event_type,
        event_properties
    from {{ source('analytics', 'events') }}

    {% if is_incremental() %}
        -- Only process events newer than existing data
        where event_timestamp > (select max(event_timestamp) from {{ this }})
    {% endif %}
)

select * from source
```

**Key Components:**
- `is_incremental()`: True after first run
- `{{ this }}`: References current model's table
- `unique_key`: Column(s) for deduplication

### Incremental with Merge Strategy

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    merge_update_columns=['status', 'updated_at'],
    merge_exclude_columns=['created_at']
) }}

with orders as (
    select
        order_id,
        customer_id,
        order_date,
        status,
        order_total,
        current_timestamp() as updated_at,
        case
            when status = 'placed' then current_timestamp()
            else null
        end as created_at
    from {{ source('ecommerce', 'orders') }}

    {% if is_incremental() %}
        -- Look back 3 days to catch late-arriving updates
        where order_date >= (select max(order_date) - interval '3 days' from {{ this }})
    {% endif %}
)

select * from orders
```

**Merge Strategy Features:**
- Updates existing records based on `unique_key`
- Inserts new records
- Optional: Specify which columns to update/exclude
- Best for: Slowly changing data, updates to historical records

### Incremental with Delete+Insert

```sql
{{ config(
    materialized='incremental',
    unique_key=['date', 'customer_id'],
    incremental_strategy='delete+insert'
) }}

with daily_metrics as (
    select
        date_trunc('day', order_timestamp) as date,
        customer_id,
        count(*) as order_count,
        sum(order_total) as total_revenue
    from {{ ref('fct_orders') }}

    {% if is_incremental() %}
        where date_trunc('day', order_timestamp) >= (
            select max(date) - interval '7 days' from {{ this }}
        )
    {% endif %}

    group by 1, 2
)

select * from daily_metrics
```

**Delete+Insert Strategy:**
- Deletes all rows matching `unique_key`
- Inserts new rows
- Best for: Aggregated data, full partition replacement
- More efficient than merge for bulk updates

### Handling Late-Arriving Data

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id'
) }}

select
    order_id,
    customer_id,
    order_date,
    status,
    _loaded_at
from {{ source('ecommerce', 'orders') }}

{% if is_incremental() %}
    -- Use _loaded_at instead of order_date to catch updates
    where _loaded_at > (select max(_loaded_at) from {{ this }})

    -- OR use a lookback window
    -- where order_date > (select max(order_date) - interval '3 days' from {{ this }})
{% endif %}
```

### Incremental with Partitioning

```sql
{{ config(
    materialized='incremental',
    unique_key='event_id',
    partition_by={
        'field': 'event_date',
        'data_type': 'date',
        'granularity': 'day'
    },
    cluster_by=['user_id', 'event_type']
) }}

select
    event_id,
    user_id,
    event_type,
    event_timestamp,
    date(event_timestamp) as event_date
from {{ source('analytics', 'raw_events') }}

{% if is_incremental() %}
    where date(event_timestamp) > (select max(event_date) from {{ this }})
{% endif %}
```

**Partition Benefits:**
- Improved query performance
- Cost optimization (scan less data)
- Efficient incremental processing
- Better for time-series data

### Full Refresh Capability

```bash
# Force full rebuild of incremental models
dbt run --full-refresh

# Full refresh specific model
dbt run --select my_incremental_model --full-refresh
```

## Macros & Jinja

### Basic Macro Structure

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

### Reusable Data Quality Macros

```sql
-- macros/test_not_negative.sql

{% macro test_not_negative(model, column_name) %}

select
    {{ column_name }}
from {{ model }}
where {{ column_name }} < 0

{% endmacro %}
```

### Date Spine Macro

```sql
-- macros/date_spine.sql

{% macro date_spine(start_date, end_date) %}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ start_date ~ "' as date)",
        end_date="cast('" ~ end_date ~ "' as date)"
    ) }}
)

select
    date_day
from date_spine

{% endmacro %}
```

### Dynamic SQL Generation

```sql
-- macros/pivot_metric.sql

{% macro pivot_metric(metric_column, group_by_column, values) %}

select
    {{ group_by_column }},
    {% for value in values %}
        sum(case when status = '{{ value }}' then {{ metric_column }} else 0 end)
            as {{ value }}_{{ metric_column }}
        {% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('fct_orders') }}
group by 1

{% endmacro %}
```

Usage:

```sql
{{ pivot_metric(
    metric_column='order_total',
    group_by_column='customer_id',
    values=['completed', 'pending', 'cancelled']
) }}
```

### Grant Permissions Macro

```sql
-- macros/grant_select.sql

{% macro grant_select(schema, role) %}

{% set sql %}
    grant select on all tables in schema {{ schema }} to {{ role }};
{% endset %}

{% do run_query(sql) %}
{% do log("Granted select on " ~ schema ~ " to " ~ role, info=True) %}

{% endmacro %}
```

Usage in hooks:

```yaml
# dbt_project.yml

on-run-end:
  - "{{ grant_select(target.schema, 'analyst_role') }}"
```

### Environment-Specific Logic

```sql
-- macros/generate_schema_name.sql

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if target.name == 'prod' -%}
        {%- if custom_schema_name is not none -%}
            {{ custom_schema_name | trim }}
        {%- else -%}
            {{ default_schema }}
        {%- endif -%}

    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
```

### Audit Column Macro

```sql
-- macros/add_audit_columns.sql

{% macro add_audit_columns() %}

    current_timestamp() as dbt_updated_at,
    current_timestamp() as dbt_created_at,
    '{{ var("dbt_user") }}' as dbt_updated_by

{% endmacro %}
```

Usage:

```sql
select
    order_id,
    customer_id,
    order_total,
    {{ add_audit_columns() }}
from {{ ref('stg_orders') }}
```

### Jinja Control Structures

```sql
-- Conditionals
{% if target.name == 'prod' %}
    from {{ source('production', 'orders') }}
{% else %}
    from {{ source('development', 'orders') }}
{% endif %}

-- Loops
{% for status in ['placed', 'shipped', 'completed'] %}
    sum(case when status = '{{ status }}' then 1 else 0 end) as {{ status }}_count
    {% if not loop.last %},{% endif %}
{% endfor %}

-- Set variables
{% set payment_methods = ['credit_card', 'paypal', 'bank_transfer'] %}

{% for method in payment_methods %}
    count(distinct case when payment_method = '{{ method }}'
        then customer_id end) as {{ method }}_customers
    {% if not loop.last %},{% endif %}
{% endfor %}
```

## Package Management

### Installing Packages

```yaml
# packages.yml

packages:
  # dbt-utils: Essential utility macros
  - package: dbt-labs/dbt_utils
    version: 1.1.1

  # Audit helper: Compare datasets
  - package: dbt-labs/audit_helper
    version: 0.9.0

  # Codegen: Code generation utilities
  - package: dbt-labs/codegen
    version: 0.11.0

  # Custom package from Git
  - git: "https://github.com/your-org/dbt-custom-package.git"
    revision: main

  # Local package
  - local: ../dbt-shared-macros
```

Install packages:

```bash
dbt deps
```

### Using dbt_utils

```sql
-- Surrogate key generation
select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'line_item_id']) }} as order_line_id,
    order_id,
    line_item_id
from {{ ref('stg_order_lines') }}

-- Union multiple tables
{{ dbt_utils.union_relations(
    relations=[
        ref('orders_2022'),
        ref('orders_2023'),
        ref('orders_2024')
    ]
) }}

-- Get column values as list
{% set statuses = dbt_utils.get_column_values(
    table=ref('stg_orders'),
    column='status'
) %}

-- Pivot table
{{ dbt_utils.pivot(
    column='metric_name',
    values=dbt_utils.get_column_values(table=ref('metrics'), column='metric_name'),
    agg='sum',
    then_value='metric_value',
    else_value=0,
    prefix='',
    suffix='_total'
) }}
```

### Creating Custom Packages

Project structure for a package:

```
dbt-custom-package/
├── dbt_project.yml
├── macros/
│   ├── custom_test.sql
│   └── custom_macro.sql
├── models/
│   └── example_model.sql
└── README.md
```

```yaml
# dbt_project.yml for custom package

name: 'custom_package'
version: '1.0.0'
config-version: 2

require-dbt-version: [">=1.0.0", "<2.0.0"]
```

### Package Versioning

```yaml
# Semantic versioning
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.0.0", "<2.0.0"]  # Any 1.x version

  # Exact version
  - package: dbt-labs/dbt_utils
    version: 1.1.1

  # Git branch/tag
  - git: "https://github.com/org/package.git"
    revision: v1.2.3

  # Latest from branch
  - git: "https://github.com/org/package.git"
    revision: main
```

## Production Workflows

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/dbt_ci.yml

name: dbt CI

on:
  pull_request:
    branches: [main]

jobs:
  dbt_run:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dbt
        run: |
          pip install dbt-core dbt-snowflake

      - name: Install dbt packages
        run: dbt deps

      - name: Run dbt debug
        run: dbt debug
        env:
          DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
          DBT_SNOWFLAKE_USER: ${{ secrets.DBT_SNOWFLAKE_USER }}
          DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_SNOWFLAKE_PASSWORD }}

      - name: Run dbt models (modified only)
        run: dbt run --select state:modified+ --state ./prod_manifest
        env:
          DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
          DBT_SNOWFLAKE_USER: ${{ secrets.DBT_SNOWFLAKE_USER }}
          DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_SNOWFLAKE_PASSWORD }}

      - name: Run dbt tests
        run: dbt test --select state:modified+
        env:
          DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
          DBT_SNOWFLAKE_USER: ${{ secrets.DBT_SNOWFLAKE_USER }}
          DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_SNOWFLAKE_PASSWORD }}
```

### Slim CI (Test Changed Models Only)

```bash
# Store production manifest
dbt compile --target prod
cp target/manifest.json ./prod_manifest/

# In CI: Test only changed models and downstream dependencies
dbt test --select state:modified+ --state ./prod_manifest
```

### Production Deployment

```yaml
# .github/workflows/dbt_prod.yml

name: dbt Production Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dbt
        run: pip install dbt-core dbt-snowflake

      - name: Install packages
        run: dbt deps

      - name: Run dbt seed
        run: dbt seed --target prod

      - name: Run dbt run
        run: dbt run --target prod

      - name: Run dbt test
        run: dbt test --target prod

      - name: Generate docs
        run: dbt docs generate --target prod

      - name: Upload docs to S3
        run: |
          aws s3 sync target/ s3://dbt-docs-bucket/
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Orchestration with Airflow

```python
# dags/dbt_dag.py

from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'analytics',
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'dbt_production',
    default_args=default_args,
    description='Run dbt models in production',
    schedule_interval='0 2 * * *',  # 2 AM daily
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['dbt', 'analytics'],
) as dag:

    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command='cd /opt/dbt && dbt deps',
    )

    dbt_seed = BashOperator(
        task_id='dbt_seed',
        bash_command='cd /opt/dbt && dbt seed --target prod',
    )

    dbt_run_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command='cd /opt/dbt && dbt run --select staging.* --target prod',
    )

    dbt_run_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command='cd /opt/dbt && dbt run --select marts.* --target prod',
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/dbt && dbt test --target prod',
    )

    dbt_docs = BashOperator(
        task_id='dbt_docs',
        bash_command='cd /opt/dbt && dbt docs generate --target prod',
    )

    # Define task dependencies
    dbt_deps >> dbt_seed >> dbt_run_staging >> dbt_run_marts >> dbt_test >> dbt_docs
```

### dbt Cloud Integration

```yaml
# dbt_cloud.yml

# Environment configuration
environments:
  - name: Production
    dbt_version: 1.7.latest
    type: deployment

  - name: Development
    dbt_version: 1.7.latest
    type: development

# Job configuration
jobs:
  - name: Production Run
    environment: Production
    triggers:
      schedule:
        cron: "0 2 * * *"  # 2 AM daily
    commands:
      - dbt deps
      - dbt seed
      - dbt run
      - dbt test

  - name: CI Check
    environment: Development
    triggers:
      github_webhook: true
    commands:
      - dbt deps
      - dbt run --select state:modified+
      - dbt test --select state:modified+
```

### Monitoring & Alerting

```sql
-- macros/post_hook_monitoring.sql

{% macro monitor_row_count(threshold=0) %}

{% if execute %}
    {% set row_count_query %}
        select count(*) as row_count from {{ this }}
    {% endset %}

    {% set results = run_query(row_count_query) %}
    {% set row_count = results.columns[0].values()[0] %}

    {% if row_count < threshold %}
        {{ exceptions.raise_compiler_error("Row count " ~ row_count ~ " below threshold " ~ threshold) }}
    {% endif %}

    {{ log("Model " ~ this ~ " has " ~ row_count ~ " rows", info=True) }}
{% endif %}

{% endmacro %}
```

Usage:

```sql
{{ config(
    post_hook="{{ monitor_row_count(threshold=1000) }}"
) }}

select * from {{ ref('stg_orders') }}
```

## Best Practices

### Naming Conventions

**Models:**
```
stg_[source]__[entity].sql        # Staging: stg_stripe__payments.sql
int_[entity]_[verb].sql            # Intermediate: int_orders_joined.sql
fct_[entity].sql                   # Fact: fct_orders.sql
dim_[entity].sql                   # Dimension: dim_customers.sql
```

**Tests:**
```
assert_[description].sql           # assert_positive_order_totals.sql
```

**Macros:**
```
[verb]_[noun].sql                  # generate_surrogate_key.sql
```

### SQL Style Guide

```sql
-- ✓ Good: Clear CTEs, proper formatting
with orders as (
    select
        order_id,
        customer_id,
        order_date,
        status
    from {{ ref('stg_orders') }}
    where status != 'cancelled'
),

customers as (
    select
        customer_id,
        customer_name,
        customer_email
    from {{ ref('dim_customers') }}
),

final as (
    select
        orders.order_id,
        orders.order_date,
        customers.customer_name,
        orders.status
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
)

select * from final

-- ✗ Bad: Nested subqueries, poor formatting
select o.order_id, o.order_date, c.customer_name, o.status from (
select order_id, customer_id, order_date, status from {{ ref('stg_orders') }}
where status != 'cancelled') o left join (select customer_id, customer_name from
{{ ref('dim_customers') }}) c on o.customer_id = c.customer_id
```

### Performance Optimization

**1. Use Incremental Models for Large Tables**

```sql
-- Process only new data
{{ config(materialized='incremental') }}

select * from {{ source('events', 'page_views') }}
{% if is_incremental() %}
    where event_timestamp > (select max(event_timestamp) from {{ this }})
{% endif %}
```

**2. Leverage Clustering and Partitioning**

```sql
{{ config(
    materialized='table',
    partition_by={'field': 'order_date', 'data_type': 'date'},
    cluster_by=['customer_id', 'status']
) }}
```

**3. Reduce Data Scanned**

```sql
-- ✓ Good: Filter early
with source as (
    select *
    from {{ source('app', 'events') }}
    where event_date >= '2024-01-01'  -- Filter in source CTE
)

-- ✗ Bad: Filter late
with source as (
    select * from {{ source('app', 'events') }}
)

select * from source
where event_date >= '2024-01-01'  -- Filtering after full scan
```

**4. Use Ephemeral for Simple Transformations**

```sql
-- Avoid creating unnecessary views
{{ config(materialized='ephemeral') }}

select
    order_id,
    lower(trim(status)) as status_clean
from {{ ref('stg_orders') }}
```

### Project Structure Best Practices

**1. Layer Your Transformations**

```
Staging → Intermediate → Marts
  ↓           ↓            ↓
 1:1      Purpose-built  Business
Sources    Logic        Entities
```

**2. Modularize Complex Logic**

```sql
-- Instead of one massive model, break it down:

-- intermediate/int_order_items_aggregated.sql
-- intermediate/int_customer_lifetime_value.sql
-- intermediate/int_payment_summaries.sql

-- marts/fct_orders.sql (combines intermediate models)
```

**3. Use Consistent File Organization**

```
models/
├── staging/
│   └── [source]/
│       ├── _[source]__sources.yml
│       ├── _[source]__models.yml
│       └── stg_[source]__[table].sql
├── intermediate/
│   └── int_[purpose].sql
└── marts/
    └── [business_area]/
        ├── _[area]__models.yml
        └── [model_type]_[entity].sql
```

### Testing Strategy

**1. Test at Multiple Levels**

```yaml
# Source tests: Data quality at ingestion
sources:
  - name: raw_data
    tables:
      - name: orders
        columns:
          - name: id
            tests: [unique, not_null]

# Model tests: Transformation logic
models:
  - name: fct_orders
    tests:
      - dbt_utils.expression_is_true:
          expression: "order_total >= 0"
    columns:
      - name: order_id
        tests: [unique, not_null]

# Custom tests: Business logic
# tests/assert_revenue_reconciliation.sql
```

**2. Use Appropriate Test Severity**

```yaml
# Critical tests: error (fail build)
# Nice-to-have tests: warn (log but don't fail)

tests:
  - unique:
      severity: error
  - dbt_utils.not_null_proportion:
      at_least: 0.95
      severity: warn
```

**3. Test Coverage Goals**

- 100% of primary keys: unique + not_null
- 100% of foreign keys: relationships tests
- All business logic: custom data tests
- Critical calculations: expression tests

### Documentation Standards

**1. Document Every Model**

```yaml
models:
  - name: fct_orders
    description: |
      **Purpose:** [Why this model exists]
      **Grain:** [One row represents...]
      **Refresh:** [When and how often]
      **Consumers:** [Who uses this]
```

**2. Document Complex Logic**

```sql
-- Use comments for complex business rules
select
    order_id,
    -- Revenue recognition: Only count completed orders
    -- cancelled within 30 days (per finance policy 2024-03)
    case
        when status = 'completed'
            and datediff('day', order_date, current_date) > 30
        then order_total
        else 0
    end as recognized_revenue
from {{ ref('stg_orders') }}
```

**3. Keep Docs Updated**

- Update docs when logic changes
- Review docs during code reviews
- Generate docs regularly: `dbt docs generate`

## 20 Detailed Examples

### Example 1: Basic Staging Model

```sql
-- models/staging/jaffle_shop/stg_jaffle_shop__customers.sql

with source as (
    select * from {{ source('jaffle_shop', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as customer_name,
        email,
        _loaded_at
    from source
)

select * from renamed
```

### Example 2: Fact Table with Multiple Joins

```sql
-- models/marts/core/fct_orders.sql

{{ config(
    materialized='table',
    tags=['core', 'daily']
) }}

with orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

payments as (
    select
        order_id,
        sum(amount) as total_payment_amount
    from {{ ref('stg_stripe__payments') }}
    where status = 'success'
    group by 1
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        customers.customer_name,
        orders.order_date,
        orders.status,
        coalesce(payments.total_payment_amount, 0) as order_total,
        {{ add_audit_columns() }}
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
    left join payments
        on orders.order_id = payments.order_id
)

select * from final
```

### Example 3: Incremental Event Table

```sql
-- models/marts/analytics/fct_page_views.sql

{{ config(
    materialized='incremental',
    unique_key='page_view_id',
    partition_by={
        'field': 'event_date',
        'data_type': 'date',
        'granularity': 'day'
    },
    cluster_by=['user_id', 'page_path']
) }}

with events as (
    select
        event_id as page_view_id,
        user_id,
        session_id,
        event_timestamp,
        date(event_timestamp) as event_date,
        event_properties:page_path::string as page_path,
        event_properties:referrer::string as referrer,
        _loaded_at
    from {{ source('analytics', 'raw_events') }}
    where event_type = 'page_view'

    {% if is_incremental() %}
        -- Use _loaded_at to catch late-arriving data
        and _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}
),

enriched as (
    select
        page_view_id,
        user_id,
        session_id,
        event_timestamp,
        event_date,
        page_path,
        referrer,
        -- Parse URL components
        split_part(page_path, '?', 1) as page_path_clean,
        case
            when referrer like '%google%' then 'Google'
            when referrer like '%facebook%' then 'Facebook'
            when referrer is null then 'Direct'
            else 'Other'
        end as referrer_source,
        _loaded_at
    from events
)

select * from enriched
```

### Example 4: Customer Dimension with SCD Type 2

```sql
-- models/marts/core/dim_customers.sql

{{ config(
    materialized='table',
    unique_key='customer_key'
) }}

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as total_orders
    from {{ ref('fct_orders') }}
    group by 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customers.customer_id', 'customers._loaded_at']) }}
            as customer_key,
        customers.customer_id,
        customers.customer_name,
        customers.email,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        customer_orders.total_orders,
        case
            when customer_orders.total_orders >= 10 then 'VIP'
            when customer_orders.total_orders >= 5 then 'Regular'
            when customer_orders.total_orders >= 1 then 'New'
            else 'Prospect'
        end as customer_segment,
        customers._loaded_at as effective_from,
        null as effective_to,
        true as is_current
    from customers
    left join customer_orders
        on customers.customer_id = customer_orders.customer_id
)

select * from final
```

### Example 5: Aggregated Metrics Table

```sql
-- models/marts/analytics/daily_order_metrics.sql

{{ config(
    materialized='incremental',
    unique_key=['metric_date', 'status'],
    incremental_strategy='delete+insert'
) }}

with orders as (
    select * from {{ ref('fct_orders') }}

    {% if is_incremental() %}
        where order_date >= (select max(metric_date) - interval '7 days' from {{ this }})
    {% endif %}
),

daily_metrics as (
    select
        date_trunc('day', order_date) as metric_date,
        status,
        count(distinct order_id) as order_count,
        count(distinct customer_id) as unique_customers,
        sum(order_total) as total_revenue,
        avg(order_total) as avg_order_value,
        min(order_total) as min_order_value,
        max(order_total) as max_order_value,
        percentile_cont(0.5) within group (order by order_total) as median_order_value
    from orders
    group by 1, 2
)

select * from daily_metrics
```

### Example 6: Pivoted Metrics Using Macro

```sql
-- models/marts/analytics/customer_order_status_summary.sql

with orders as (
    select
        customer_id,
        status,
        order_total
    from {{ ref('fct_orders') }}
)

select
    customer_id,
    {% for status in ['placed', 'shipped', 'completed', 'returned', 'cancelled'] %}
        sum(case when status = '{{ status }}' then 1 else 0 end)
            as {{ status }}_count,
        sum(case when status = '{{ status }}' then order_total else 0 end)
            as {{ status }}_revenue
        {% if not loop.last %},{% endif %}
    {% endfor %}
from orders
group by 1
```

### Example 7: Snapshot for SCD Type 2

```sql
-- snapshots/customers_snapshot.sql

{% snapshot customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        target_database='analytics',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=True
    )
}}

select
    customer_id,
    customer_name,
    email,
    customer_segment,
    updated_at
from {{ source('jaffle_shop', 'customers') }}

{% endsnapshot %}
```

### Example 8: Funnel Analysis Model

```sql
-- models/marts/analytics/conversion_funnel.sql

with page_views as (
    select
        user_id,
        session_id,
        min(event_timestamp) as session_start
    from {{ ref('fct_page_views') }}
    where event_date >= current_date - interval '30 days'
    group by 1, 2
),

product_views as (
    select distinct
        user_id,
        session_id
    from {{ ref('fct_page_views') }}
    where page_path like '/product/%'
        and event_date >= current_date - interval '30 days'
),

add_to_cart as (
    select distinct
        user_id,
        session_id
    from {{ ref('fct_events') }}
    where event_type = 'add_to_cart'
        and event_date >= current_date - interval '30 days'
),

checkout_started as (
    select distinct
        user_id,
        session_id
    from {{ ref('fct_events') }}
    where event_type = 'checkout_started'
        and event_date >= current_date - interval '30 days'
),

orders as (
    select distinct
        customer_id as user_id,
        session_id
    from {{ ref('fct_orders') }}
    where order_date >= current_date - interval '30 days'
        and status = 'completed'
),

funnel as (
    select
        count(distinct page_views.session_id) as sessions,
        count(distinct product_views.session_id) as product_views,
        count(distinct add_to_cart.session_id) as add_to_cart,
        count(distinct checkout_started.session_id) as checkout_started,
        count(distinct orders.session_id) as completed_orders
    from page_views
    left join product_views using (session_id)
    left join add_to_cart using (session_id)
    left join checkout_started using (session_id)
    left join orders using (session_id)
),

funnel_metrics as (
    select
        sessions,
        product_views,
        round(100.0 * product_views / nullif(sessions, 0), 2) as pct_product_views,
        add_to_cart,
        round(100.0 * add_to_cart / nullif(product_views, 0), 2) as pct_add_to_cart,
        checkout_started,
        round(100.0 * checkout_started / nullif(add_to_cart, 0), 2) as pct_checkout_started,
        completed_orders,
        round(100.0 * completed_orders / nullif(checkout_started, 0), 2) as pct_completed_orders,
        round(100.0 * completed_orders / nullif(sessions, 0), 2) as overall_conversion_rate
    from funnel
)

select * from funnel_metrics
```

### Example 9: Cohort Retention Analysis

```sql
-- models/marts/analytics/cohort_retention.sql

with customer_orders as (
    select
        customer_id,
        date_trunc('month', order_date) as order_month
    from {{ ref('fct_orders') }}
    where status = 'completed'
),

first_order as (
    select
        customer_id,
        min(order_month) as cohort_month
    from customer_orders
    group by 1
),

cohort_data as (
    select
        f.cohort_month,
        c.order_month,
        datediff('month', f.cohort_month, c.order_month) as months_since_first_order,
        count(distinct c.customer_id) as customer_count
    from first_order f
    join customer_orders c
        on f.customer_id = c.customer_id
    group by 1, 2, 3
),

cohort_size as (
    select
        cohort_month,
        customer_count as cohort_size
    from cohort_data
    where months_since_first_order = 0
),

retention as (
    select
        cohort_data.cohort_month,
        cohort_data.months_since_first_order,
        cohort_data.customer_count,
        cohort_size.cohort_size,
        round(100.0 * cohort_data.customer_count / cohort_size.cohort_size, 2) as retention_pct
    from cohort_data
    join cohort_size
        on cohort_data.cohort_month = cohort_size.cohort_month
)

select * from retention
order by cohort_month, months_since_first_order
```

### Example 10: Revenue Attribution Model

```sql
-- models/marts/analytics/revenue_attribution.sql

with touchpoints as (
    select
        user_id,
        session_id,
        event_timestamp,
        case
            when referrer like '%google%' then 'Google'
            when referrer like '%facebook%' then 'Facebook'
            when referrer like '%email%' then 'Email'
            when referrer is null then 'Direct'
            else 'Other'
        end as channel
    from {{ ref('fct_page_views') }}
),

customer_journeys as (
    select
        t.user_id,
        o.order_id,
        o.order_total,
        t.channel,
        t.event_timestamp,
        o.order_date,
        row_number() over (
            partition by o.order_id
            order by t.event_timestamp
        ) as touchpoint_number,
        count(*) over (partition by o.order_id) as total_touchpoints
    from touchpoints t
    join {{ ref('fct_orders') }} o
        on t.user_id = o.customer_id
        and t.event_timestamp <= o.order_date
        and t.event_timestamp >= dateadd('day', -30, o.order_date)
),

attributed_revenue as (
    select
        order_id,
        channel,
        order_total,
        -- First touch attribution
        case when touchpoint_number = 1
            then order_total else 0 end as first_touch_revenue,
        -- Last touch attribution
        case when touchpoint_number = total_touchpoints
            then order_total else 0 end as last_touch_revenue,
        -- Linear attribution
        order_total / total_touchpoints as linear_revenue,
        -- Time decay (more recent touchpoints get more credit)
        order_total * (power(2, touchpoint_number - 1) /
            (power(2, total_touchpoints) - 1)) as time_decay_revenue
    from customer_journeys
)

select
    channel,
    count(distinct order_id) as orders,
    sum(first_touch_revenue) as first_touch_revenue,
    sum(last_touch_revenue) as last_touch_revenue,
    sum(linear_revenue) as linear_revenue,
    sum(time_decay_revenue) as time_decay_revenue
from attributed_revenue
group by 1
```

### Example 11: Data Quality Test Suite

```sql
-- tests/assert_fct_orders_quality.sql

-- Test multiple data quality rules in one test

with order_quality_checks as (
    select
        order_id,
        customer_id,
        order_date,
        order_total,
        status,

        -- Check 1: Order total should be positive
        case when order_total < 0
            then 'Negative order total' end as check_1,

        -- Check 2: Order date should not be in future
        case when order_date > current_date
            then 'Future order date' end as check_2,

        -- Check 3: Customer ID should exist
        case when customer_id is null
            then 'Missing customer ID' end as check_3,

        -- Check 4: Status should be valid
        case when status not in ('placed', 'shipped', 'completed', 'returned', 'cancelled')
            then 'Invalid status' end as check_4

    from {{ ref('fct_orders') }}
),

failed_checks as (
    select
        order_id,
        check_1,
        check_2,
        check_3,
        check_4
    from order_quality_checks
    where check_1 is not null
        or check_2 is not null
        or check_3 is not null
        or check_4 is not null
)

select * from failed_checks
```

### Example 12: Slowly Changing Dimension Merge

```sql
-- models/marts/core/dim_products_scd.sql

{{ config(
    materialized='incremental',
    unique_key='product_key',
    merge_update_columns=['product_name', 'category', 'price', 'effective_to', 'is_current']
) }}

with source_data as (
    select
        product_id,
        product_name,
        category,
        price,
        updated_at
    from {{ source('ecommerce', 'products') }}

    {% if is_incremental() %}
        where updated_at > (select max(updated_at) from {{ this }} where is_current = true)
    {% endif %}
),

{% if is_incremental() %}
existing_records as (
    select *
    from {{ this }}
    where is_current = true
),

changed_records as (
    select
        s.product_id,
        s.product_name,
        s.category,
        s.price,
        s.updated_at
    from source_data s
    join existing_records e
        on s.product_id = e.product_id
        and (
            s.product_name != e.product_name
            or s.category != e.category
            or s.price != e.price
        )
),

expire_old_records as (
    select
        e.product_key,
        e.product_id,
        e.product_name,
        e.category,
        e.price,
        e.effective_from,
        c.updated_at as effective_to,
        false as is_current,
        e.updated_at
    from existing_records e
    join changed_records c
        on e.product_id = c.product_id
),

new_versions as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.product_id', 'c.updated_at']) }} as product_key,
        c.product_id,
        c.product_name,
        c.category,
        c.price,
        c.updated_at as effective_from,
        null::timestamp as effective_to,
        true as is_current,
        c.updated_at
    from changed_records c
),

combined as (
    select * from expire_old_records
    union all
    select * from new_versions
)

select * from combined

{% else %}

-- First load: all records are current
select
    {{ dbt_utils.generate_surrogate_key(['product_id', 'updated_at']) }} as product_key,
    product_id,
    product_name,
    category,
    price,
    updated_at as effective_from,
    null::timestamp as effective_to,
    true as is_current,
    updated_at
from source_data

{% endif %}
```

### Example 13: Window Functions for Rankings

```sql
-- models/marts/analytics/customer_rfm_score.sql

with customer_metrics as (
    select
        customer_id,
        max(order_date) as last_order_date,
        count(order_id) as total_orders,
        sum(order_total) as total_revenue
    from {{ ref('fct_orders') }}
    where status = 'completed'
    group by 1
),

rfm_calculations as (
    select
        customer_id,
        -- Recency: Days since last order
        datediff('day', last_order_date, current_date) as recency_days,
        -- Frequency: Total orders
        total_orders as frequency,
        -- Monetary: Total revenue
        total_revenue as monetary,

        -- Recency score (1-5, lower days = higher score)
        ntile(5) over (order by datediff('day', last_order_date, current_date) desc) as recency_score,
        -- Frequency score (1-5, more orders = higher score)
        ntile(5) over (order by total_orders) as frequency_score,
        -- Monetary score (1-5, more revenue = higher score)
        ntile(5) over (order by total_revenue) as monetary_score
    from customer_metrics
),

rfm_segments as (
    select
        customer_id,
        recency_days,
        frequency,
        monetary,
        recency_score,
        frequency_score,
        monetary_score,
        recency_score * 100 + frequency_score * 10 + monetary_score as rfm_score,
        case
            when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4
                then 'Champions'
            when recency_score >= 3 and frequency_score >= 3 and monetary_score >= 3
                then 'Loyal Customers'
            when recency_score >= 4 and frequency_score <= 2 and monetary_score <= 2
                then 'Promising'
            when recency_score >= 3 and frequency_score <= 2 and monetary_score <= 2
                then 'Potential Loyalists'
            when recency_score <= 2 and frequency_score >= 3 and monetary_score >= 3
                then 'At Risk'
            when recency_score <= 2 and frequency_score <= 2 and monetary_score <= 2
                then 'Hibernating'
            when recency_score <= 1
                then 'Lost'
            else 'Need Attention'
        end as customer_segment
    from rfm_calculations
)

select * from rfm_segments
```

### Example 14: Union Multiple Sources

```sql
-- models/staging/stg_all_events.sql

{{ config(
    materialized='view'
) }}

-- Union events from multiple sources using dbt_utils

{{
    dbt_utils.union_relations(
        relations=[
            ref('stg_web_events'),
            ref('stg_mobile_events'),
            ref('stg_api_events')
        ],
        exclude=['_loaded_at'],  -- Exclude source-specific columns
        source_column_name='event_source'  -- Add column to track source
    )
}}
```

### Example 15: Surrogate Key Generation

```sql
-- models/marts/core/fct_order_lines.sql

with order_lines as (
    select
        order_id,
        line_number,
        product_id,
        quantity,
        unit_price,
        quantity * unit_price as line_total
    from {{ source('ecommerce', 'order_lines') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'line_number']) }} as order_line_key,
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} as order_key,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    order_id,
    line_number,
    product_id,
    quantity,
    unit_price,
    line_total
from order_lines
```

### Example 16: Date Spine for Time Series

```sql
-- models/marts/analytics/daily_revenue_complete.sql

-- Generate complete date spine to ensure no missing dates

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast(current_date as date)"
    ) }}
),

daily_revenue as (
    select
        date_trunc('day', order_date) as order_date,
        sum(order_total) as revenue
    from {{ ref('fct_orders') }}
    where status = 'completed'
    group by 1
),

complete_series as (
    select
        date_spine.date_day,
        coalesce(daily_revenue.revenue, 0) as revenue,
        -- 7-day moving average
        avg(coalesce(daily_revenue.revenue, 0)) over (
            order by date_spine.date_day
            rows between 6 preceding and current row
        ) as revenue_7d_ma,
        -- Month-to-date revenue
        sum(coalesce(daily_revenue.revenue, 0)) over (
            partition by date_trunc('month', date_spine.date_day)
            order by date_spine.date_day
        ) as revenue_mtd
    from date_spine
    left join daily_revenue
        on date_spine.date_day = daily_revenue.order_date
)

select * from complete_series
```

### Example 17: Custom Schema Macro Override

```sql
-- macros/generate_schema_name.sql

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if target.name == 'prod' -%}
        -- Production: Use custom schema names directly
        {%- if custom_schema_name is not none -%}
            {{ custom_schema_name | trim }}
        {%- else -%}
            {{ default_schema }}
        {%- endif -%}

    {%- elif target.name == 'dev' -%}
        -- Development: Prefix with dev_username
        {%- if custom_schema_name is not none -%}
            dev_{{ env_var('DBT_USER', 'unknown') }}_{{ custom_schema_name | trim }}
        {%- else -%}
            dev_{{ env_var('DBT_USER', 'unknown') }}
        {%- endif -%}

    {%- else -%}
        -- Default: Concatenate target schema with custom schema
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
```

### Example 18: Cross-Database Query Macro

```sql
-- macros/cross_db_concat.sql

-- Handle database-specific concat syntax

{% macro concat(fields) -%}
    {{ return(adapter.dispatch('concat', 'dbt_utils')(fields)) }}
{%- endmacro %}

{% macro default__concat(fields) -%}
    concat({{ fields|join(', ') }})
{%- endmacro %}

{% macro snowflake__concat(fields) -%}
    {{ fields|join(' || ') }}
{%- endmacro %}

{% macro bigquery__concat(fields) -%}
    concat({{ fields|join(', ') }})
{%- endmacro %}

{% macro redshift__concat(fields) -%}
    {{ fields|join(' || ') }}
{%- endmacro %}
```

Usage:

```sql
select
    {{ concat(['first_name', "' '", 'last_name']) }} as full_name
from {{ ref('stg_customers') }}
```

### Example 19: Pre-Hook and Post-Hook Configuration

```sql
-- models/marts/core/fct_orders.sql

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        pre_hook=[
            "delete from {{ this }} where order_date < dateadd('year', -3, current_date)",
            "{{ log('Starting incremental load for fct_orders', info=True) }}"
        ],
        post_hook=[
            "create index if not exists idx_fct_orders_customer_id on {{ this }}(customer_id)",
            "create index if not exists idx_fct_orders_order_date on {{ this }}(order_date)",
            "{{ grant_select(this, 'analyst_role') }}",
            "{{ log('Completed incremental load for fct_orders', info=True) }}"
        ],
        tags=['core', 'incremental']
    )
}}

select * from {{ ref('stg_orders') }}

{% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

### Example 20: Exposure Definition

```yaml
# models/exposures.yml

version: 2

exposures:
  - name: customer_dashboard
    description: |
      Executive dashboard showing customer metrics including:
      - Customer acquisition trends
      - Customer lifetime value
      - Retention rates
      - RFM segmentation
    type: dashboard
    maturity: high
    url: https://looker.company.com/dashboards/customer-metrics

    owner:
      name: Analytics Team
      email: analytics@company.com

    depends_on:
      - ref('fct_orders')
      - ref('dim_customers')
      - ref('customer_rfm_score')
      - ref('cohort_retention')

    tags: ['executive', 'customer-analytics']

  - name: revenue_forecast_model
    description: |
      Machine learning model for revenue forecasting.
      Uses historical order data to predict future revenue.
    type: ml
    maturity: medium
    url: https://mlflow.company.com/models/revenue-forecast

    owner:
      name: Data Science Team
      email: datascience@company.com

    depends_on:
      - ref('fct_orders')
      - ref('daily_revenue_complete')

    tags: ['ml', 'forecasting']
```

## Quick Reference Commands

### Essential dbt Commands

```bash
# Install dependencies
dbt deps

# Compile project (check for errors)
dbt compile

# Run all models
dbt run

# Run specific model
dbt run --select fct_orders

# Run model and downstream dependencies
dbt run --select fct_orders+

# Run model and upstream dependencies
dbt run --select +fct_orders

# Run model and all dependencies
dbt run --select +fct_orders+

# Run all models in a directory
dbt run --select staging.*

# Run models with specific tag
dbt run --select tag:daily

# Run models, exclude specific ones
dbt run --exclude staging.*

# Run with full refresh (incremental models)
dbt run --full-refresh

# Test all models
dbt test

# Test specific model
dbt test --select fct_orders

# Generate documentation
dbt docs generate

# Serve documentation
dbt docs serve

# Debug connection
dbt debug

# Clean compiled files
dbt clean

# Seed CSV files
dbt seed

# Snapshot models
dbt snapshot

# List resources
dbt ls --select staging.*

# Show compiled SQL
dbt show --select fct_orders

# Parse project
dbt parse
```

### Model Selection Syntax

```bash
# By name
--select model_name

# By path
--select staging.jaffle_shop.*

# By tag
--select tag:daily

# By resource type
--select resource_type:model

# By package
--select package:dbt_utils

# By status (modified, new)
--select state:modified+ --state ./prod_manifest

# Combinations (union)
--select model_a model_b

# Intersections
--select tag:daily,staging.*

# Graph operators
--select +model_name    # Upstream dependencies
--select model_name+    # Downstream dependencies
--select +model_name+   # All dependencies
--select @model_name    # Model + children/parents to nth degree
```

## Resources

- **Official dbt Documentation**: https://docs.getdbt.com/
- **dbt Discourse Community**: https://discourse.getdbt.com/
- **dbt GitHub Repository**: https://github.com/dbt-labs/dbt-core
- **dbt Package Hub**: https://hub.getdbt.com/
- **dbt Learn**: https://courses.getdbt.com/
- **dbt Style Guide**: https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md
- **Analytics Engineering Guide**: https://www.getdbt.com/analytics-engineering/
- **dbt Slack Community**: https://www.getdbt.com/community/join-the-community/

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Data Engineering, Analytics Engineering, Data Transformation
**Compatible With**: dbt Core 1.0+, dbt Cloud, Snowflake, BigQuery, Redshift, Postgres, Databricks
