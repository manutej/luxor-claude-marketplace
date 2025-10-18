# dbt Data Transformation Examples

Practical, production-ready examples for building data transformation pipelines with dbt. Each example includes complete code, explanations, and best practices.

## Table of Contents

1. [Staging Models](#1-staging-models)
2. [Fact Tables](#2-fact-tables)
3. [Dimension Tables](#3-dimension-tables)
4. [Incremental Models](#4-incremental-models)
5. [Testing Patterns](#5-testing-patterns)
6. [Documentation](#6-documentation)
7. [Macros](#7-macros)
8. [Snapshots](#8-snapshots)
9. [Advanced Analytics](#9-advanced-analytics)
10. [Production Workflows](#10-production-workflows)

---

## 1. Staging Models

### Example 1.1: Basic Staging Model

Clean and rename raw data from sources:

```sql
-- models/staging/jaffle_shop/stg_jaffle_shop__customers.sql

{{
    config(
        materialized='view',
        tags=['staging', 'daily']
    )
}}

with source as (
    -- Use source() to reference raw tables
    select * from {{ source('jaffle_shop', 'customers') }}
),

renamed as (
    select
        -- Rename for clarity and consistency
        id as customer_id,
        first_name,
        last_name,

        -- Create computed columns
        first_name || ' ' || last_name as customer_name,
        lower(trim(email)) as email,

        -- Preserve audit columns
        created_at,
        updated_at,
        _loaded_at

    from source
)

select * from renamed
```

**Configuration:**

```yaml
# models/staging/jaffle_shop/_jaffle_shop__sources.yml

version: 2

sources:
  - name: jaffle_shop
    description: Raw data from Jaffle Shop application database
    database: raw
    schema: jaffle_shop

    tables:
      - name: customers
        description: Customer records from the application
        loaded_at_field: _loaded_at
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}

        columns:
          - name: id
            description: Primary key
            tests:
              - unique
              - not_null
          - name: email
            description: Customer email address
            tests:
              - not_null
```

### Example 1.2: Staging with Type Casting

Handle data type conversions and parsing:

```sql
-- models/staging/stripe/stg_stripe__payments.sql

with source as (
    select * from {{ source('stripe', 'payments') }}
),

cleaned as (
    select
        id as payment_id,
        order_id,
        payment_method,

        -- Type casting
        cast(amount as decimal(10,2)) as amount,
        cast(created_at as timestamp) as payment_timestamp,

        -- Parse JSON columns
        parse_json(metadata):customer_ip::string as customer_ip,
        parse_json(metadata):user_agent::string as user_agent,

        -- Standardize status values
        case lower(trim(status))
            when 'success' then 'succeeded'
            when 'fail' then 'failed'
            else lower(trim(status))
        end as payment_status,

        -- Handle null/empty strings
        nullif(trim(failure_message), '') as failure_message,

        _loaded_at

    from source
),

validated as (
    select *
    from cleaned

    -- Filter out invalid records
    where payment_id is not null
        and order_id is not null
        and amount >= 0
)

select * from validated
```

### Example 1.3: Staging with Deduplication

Handle duplicate records in source data:

```sql
-- models/staging/events/stg_events__page_views.sql

{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('events', 'page_views') }}
),

deduplicated as (
    select
        event_id,
        user_id,
        session_id,
        event_timestamp,
        page_path,
        referrer,

        -- Use row_number to identify duplicates
        row_number() over (
            partition by event_id
            order by _loaded_at desc
        ) as row_num

    from source
),

final as (
    select
        event_id,
        user_id,
        session_id,
        event_timestamp,
        page_path,
        referrer
    from deduplicated
    where row_num = 1  -- Keep most recent version
)

select * from final
```

---

## 2. Fact Tables

### Example 2.1: Order Fact Table

Build a comprehensive fact table with measures and foreign keys:

```sql
-- models/marts/core/fct_orders.sql

{{
    config(
        materialized='table',
        partition_by={
            'field': 'order_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['customer_id', 'status'],
        tags=['core', 'daily']
    )
}}

with orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

payments as (
    select
        order_id,
        sum(case when payment_status = 'succeeded' then amount else 0 end) as total_paid,
        sum(amount) as total_attempted,
        count(*) as payment_count,
        max(payment_timestamp) as last_payment_timestamp
    from {{ ref('stg_stripe__payments') }}
    group by 1
),

order_items as (
    select
        order_id,
        count(*) as item_count,
        sum(quantity) as total_quantity
    from {{ ref('stg_jaffle_shop__order_items') }}
    group by 1
),

final as (
    select
        -- Primary key
        orders.order_id,

        -- Foreign keys
        orders.customer_id,
        customers.customer_segment,

        -- Dates
        orders.order_date,
        date_trunc('month', orders.order_date) as order_month,
        date_trunc('year', orders.order_date) as order_year,

        -- Order attributes
        orders.status,

        -- Measures (additive facts)
        coalesce(payments.total_paid, 0) as order_total,
        coalesce(payments.total_attempted, 0) as amount_attempted,
        coalesce(order_items.item_count, 0) as line_item_count,
        coalesce(order_items.total_quantity, 0) as total_quantity,

        -- Semi-additive facts
        case when payments.payment_count > 1 then 1 else 0 end as has_multiple_payments,

        -- Flags and indicators
        case when orders.status = 'completed' then 1 else 0 end as is_completed,
        case when orders.status = 'returned' then 1 else 0 end as is_returned,

        -- Timestamps
        orders.created_at as order_created_at,
        payments.last_payment_timestamp,

        -- Audit columns
        current_timestamp() as dbt_updated_at

    from orders
    left join customers
        on orders.customer_id = customers.customer_id
    left join payments
        on orders.order_id = payments.order_id
    left join order_items
        on orders.order_id = order_items.order_id
)

select * from final
```

### Example 2.2: Event Fact Table (Many-to-Many)

Handle events with multiple dimensions:

```sql
-- models/marts/analytics/fct_user_events.sql

{{
    config(
        materialized='incremental',
        unique_key='event_id',
        partition_by={
            'field': 'event_date',
            'data_type': 'date'
        },
        cluster_by=['user_id', 'event_type']
    )
}}

with events as (
    select * from {{ ref('stg_events__raw_events') }}

    {% if is_incremental() %}
        where event_timestamp > (select max(event_timestamp) from {{ this }})
    {% endif %}
),

users as (
    select * from {{ ref('dim_users') }}
),

sessions as (
    select * from {{ ref('dim_sessions') }}
),

final as (
    select
        -- Primary key
        events.event_id,

        -- Foreign keys (multiple dimensions)
        events.user_id,
        events.session_id,
        events.device_id,
        events.page_id,

        -- Degenerate dimensions (stored in fact)
        events.event_type,
        events.event_category,

        -- Date/time dimensions
        events.event_timestamp,
        date(events.event_timestamp) as event_date,
        date_trunc('hour', events.event_timestamp) as event_hour,

        -- Measures
        coalesce(events.event_value, 0) as event_value,
        events.duration_seconds,

        -- User attributes (from dimension)
        users.user_segment,
        users.acquisition_channel,

        -- Session attributes
        sessions.is_first_session,
        sessions.device_type,

        -- Flags
        case when events.event_type = 'purchase' then 1 else 0 end as is_conversion_event,

        -- Audit
        current_timestamp() as dbt_updated_at

    from events
    left join users
        on events.user_id = users.user_id
    left join sessions
        on events.session_id = sessions.session_id
)

select * from final
```

---

## 3. Dimension Tables

### Example 3.1: Customer Dimension with Enrichment

Create a slowly changing dimension with derived attributes:

```sql
-- models/marts/core/dim_customers.sql

{{
    config(
        materialized='table',
        tags=['core', 'dimension']
    )
}}

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(distinct order_id) as total_orders,
        count(distinct case when status = 'completed' then order_id end) as completed_orders,
        sum(case when status = 'completed' then order_total else 0 end) as lifetime_value,
        avg(case when status = 'completed' then order_total end) as avg_order_value
    from {{ ref('fct_orders') }}
    group by 1
),

customer_segments as (
    select
        customer_id,
        case
            when lifetime_value >= 1000 then 'VIP'
            when lifetime_value >= 500 then 'High Value'
            when total_orders >= 5 then 'Regular'
            when total_orders >= 1 then 'New'
            else 'Prospect'
        end as customer_segment,

        case
            when most_recent_order_date >= current_date - interval '30 days' then 'Active'
            when most_recent_order_date >= current_date - interval '90 days' then 'At Risk'
            when most_recent_order_date < current_date - interval '90 days' then 'Churned'
            else 'Prospect'
        end as customer_status
    from customer_orders
),

final as (
    select
        -- Surrogate key (optional, for SCD Type 2)
        {{ dbt_utils.generate_surrogate_key(['customers.customer_id']) }} as customer_key,

        -- Natural key
        customers.customer_id,

        -- Attributes
        customers.customer_name,
        customers.first_name,
        customers.last_name,
        customers.email,

        -- Derived attributes
        coalesce(customer_orders.first_order_date, null) as first_order_date,
        coalesce(customer_orders.most_recent_order_date, null) as most_recent_order_date,
        coalesce(customer_orders.total_orders, 0) as total_orders,
        coalesce(customer_orders.completed_orders, 0) as completed_orders,
        coalesce(customer_orders.lifetime_value, 0) as lifetime_value,
        coalesce(customer_orders.avg_order_value, 0) as avg_order_value,

        -- Calculated metrics
        datediff('day', customer_orders.first_order_date, customer_orders.most_recent_order_date) as customer_tenure_days,
        case
            when customer_orders.total_orders > 0
            then customer_orders.lifetime_value / customer_orders.total_orders
            else 0
        end as avg_order_size,

        -- Segments
        coalesce(customer_segments.customer_segment, 'Prospect') as customer_segment,
        coalesce(customer_segments.customer_status, 'Prospect') as customer_status,

        -- Flags
        case when customer_orders.total_orders > 0 then true else false end as has_ordered,
        case when customer_orders.completed_orders > 0 then true else false end as has_completed_order,

        -- Timestamps
        customers.created_at as customer_created_at,
        customers.updated_at as customer_updated_at,

        -- Audit
        current_timestamp() as dbt_updated_at

    from customers
    left join customer_orders
        on customers.customer_id = customer_orders.customer_id
    left join customer_segments
        on customers.customer_id = customer_segments.customer_id
)

select * from final
```

### Example 3.2: Date Dimension

Generate a comprehensive date dimension table:

```sql
-- models/marts/core/dim_date.sql

{{
    config(
        materialized='table',
        tags=['dimension', 'reference']
    )
}}

with date_spine as (
    -- Generate dates for the next 10 years
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast(dateadd('year', 10, current_date) as date)"
    ) }}
),

date_attributes as (
    select
        date_day,

        -- Date parts
        extract(year from date_day) as year_number,
        extract(quarter from date_day) as quarter_number,
        extract(month from date_day) as month_number,
        extract(week from date_day) as week_number,
        extract(dayofyear from date_day) as day_of_year,
        extract(dayofweek from date_day) as day_of_week,
        extract(dayofmonth from date_day) as day_of_month,

        -- Date names
        to_char(date_day, 'YYYY') as year_name,
        to_char(date_day, 'YYYY-Q') as quarter_name,
        to_char(date_day, 'YYYY-MM') as month_name,
        to_char(date_day, 'Mon') as month_short_name,
        to_char(date_day, 'Month') as month_long_name,
        to_char(date_day, 'Dy') as day_short_name,
        to_char(date_day, 'Day') as day_long_name,

        -- Fiscal periods (assuming fiscal year starts July 1)
        case
            when extract(month from date_day) >= 7
            then extract(year from date_day) + 1
            else extract(year from date_day)
        end as fiscal_year,
        case
            when extract(month from date_day) between 7 and 9 then 1
            when extract(month from date_day) between 10 and 12 then 2
            when extract(month from date_day) between 1 and 3 then 3
            when extract(month from date_day) between 4 and 6 then 4
        end as fiscal_quarter,

        -- Flags
        case when extract(dayofweek from date_day) in (0, 6) then true else false end as is_weekend,
        case when extract(dayofweek from date_day) between 1 and 5 then true else false end as is_weekday,

        -- Relative dates
        case when date_day = current_date then true else false end as is_today,
        case when date_day = current_date - interval '1 day' then true else false end as is_yesterday,
        case when date_trunc('week', date_day) = date_trunc('week', current_date) then true else false end as is_current_week,
        case when date_trunc('month', date_day) = date_trunc('month', current_date) then true else false end as is_current_month,
        case when date_trunc('quarter', date_day) = date_trunc('quarter', current_date) then true else false end as is_current_quarter,
        case when date_trunc('year', date_day) = date_trunc('year', current_date) then true else false end as is_current_year,

        -- Period start/end
        date_trunc('week', date_day) as week_start_date,
        date_trunc('month', date_day) as month_start_date,
        date_trunc('quarter', date_day) as quarter_start_date,
        date_trunc('year', date_day) as year_start_date

    from date_spine
)

select * from date_attributes
```

---

## 4. Incremental Models

### Example 4.1: Append-Only Incremental

For immutable event data:

```sql
-- models/marts/analytics/fct_page_views_incremental.sql

{{
    config(
        materialized='incremental',
        unique_key='page_view_id',
        incremental_strategy='append',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['user_id', 'session_id']
    )
}}

with page_views as (
    select
        event_id as page_view_id,
        user_id,
        session_id,
        event_timestamp,
        date(event_timestamp) as event_date,
        page_path,
        referrer,
        device_type,
        _loaded_at

    from {{ ref('stg_events__page_views') }}

    {% if is_incremental() %}
        -- Use _loaded_at to catch late-arriving data
        where _loaded_at > (
            select coalesce(max(_loaded_at), '1900-01-01'::timestamp)
            from {{ this }}
        )
    {% endif %}
)

select * from page_views
```

### Example 4.2: Merge Incremental with Updates

For data that can change:

```sql
-- models/marts/core/fct_orders_incremental.sql

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        merge_update_columns=['status', 'order_total', 'updated_at'],
        on_schema_change='fail'
    )
}}

with orders as (
    select
        order_id,
        customer_id,
        order_date,
        status,
        order_total,
        created_at,
        updated_at

    from {{ ref('stg_jaffle_shop__orders') }}

    {% if is_incremental() %}
        -- Look back 3 days to catch status updates
        where updated_at > (
            select dateadd('day', -3, max(updated_at))
            from {{ this }}
        )
    {% endif %}
)

select * from orders
```

### Example 4.3: Delete+Insert Incremental

For daily aggregations:

```sql
-- models/marts/analytics/daily_metrics.sql

{{
    config(
        materialized='incremental',
        unique_key=['metric_date', 'customer_segment'],
        incremental_strategy='delete+insert',
        partition_by={
            'field': 'metric_date',
            'data_type': 'date'
        }
    )
}}

with orders as (
    select
        date_trunc('day', order_date) as order_date,
        customer_id,
        status,
        order_total
    from {{ ref('fct_orders') }}

    {% if is_incremental() %}
        -- Reprocess last 7 days to handle late updates
        where date_trunc('day', order_date) >= (
            select max(metric_date) - interval '7 days'
            from {{ this }}
        )
    {% endif %}
),

customers as (
    select
        customer_id,
        customer_segment
    from {{ ref('dim_customers') }}
),

daily_metrics as (
    select
        orders.order_date as metric_date,
        customers.customer_segment,
        count(distinct orders.order_id) as order_count,
        count(distinct orders.customer_id) as unique_customers,
        sum(case when orders.status = 'completed' then orders.order_total else 0 end) as revenue,
        avg(case when orders.status = 'completed' then orders.order_total end) as avg_order_value

    from orders
    left join customers
        on orders.customer_id = customers.customer_id
    group by 1, 2
)

select * from daily_metrics
```

---

## 5. Testing Patterns

### Example 5.1: Comprehensive Schema Tests

```yaml
# models/marts/core/_core__models.yml

version: 2

models:
  - name: fct_orders
    description: Order fact table

    tests:
      # Table-level tests
      - dbt_utils.expression_is_true:
          expression: "order_total >= 0"
          config:
            severity: error

      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_date
          config:
            severity: warn

    columns:
      - name: order_id
        description: Primary key
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error

      - name: customer_id
        description: Foreign key to dim_customers
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
              config:
                severity: error

      - name: status
        description: Order status
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned', 'cancelled']
              config:
                severity: error

      - name: order_total
        description: Total order amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

      - name: order_date
        description: Date order was placed
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= current_date"
              config:
                error_if: ">100"
                warn_if: ">0"
```

### Example 5.2: Custom Data Quality Tests

```sql
-- tests/assert_revenue_reconciliation.sql

-- Ensure revenue in fct_orders matches payments

with order_revenue as (
    select
        sum(order_total) as total_from_orders
    from {{ ref('fct_orders') }}
    where status = 'completed'
),

payment_revenue as (
    select
        sum(amount) as total_from_payments
    from {{ ref('stg_stripe__payments') }}
    where payment_status = 'succeeded'
),

reconciliation as (
    select
        order_revenue.total_from_orders,
        payment_revenue.total_from_payments,
        abs(order_revenue.total_from_orders - payment_revenue.total_from_payments) as difference,
        order_revenue.total_from_orders * 0.01 as threshold  -- 1% tolerance
    from order_revenue
    cross join payment_revenue
)

-- Test fails if difference exceeds threshold
select *
from reconciliation
where difference > threshold
```

```sql
-- tests/assert_no_future_dates.sql

-- Ensure no records have dates in the future

select
    'fct_orders' as table_name,
    order_id as record_id,
    order_date as problematic_date
from {{ ref('fct_orders') }}
where order_date > current_date

union all

select
    'fct_page_views' as table_name,
    page_view_id as record_id,
    event_timestamp::date as problematic_date
from {{ ref('fct_page_views') }}
where event_timestamp > current_timestamp
```

### Example 5.3: Cross-Model Consistency Tests

```sql
-- tests/assert_customer_order_consistency.sql

-- Ensure customer metrics in dim_customers match fct_orders

with customer_orders_from_dim as (
    select
        customer_id,
        total_orders as order_count_from_dim,
        lifetime_value as ltv_from_dim
    from {{ ref('dim_customers') }}
),

customer_orders_from_fact as (
    select
        customer_id,
        count(distinct order_id) as order_count_from_fact,
        sum(case when status = 'completed' then order_total else 0 end) as ltv_from_fact
    from {{ ref('fct_orders') }}
    group by 1
),

comparison as (
    select
        dim.customer_id,
        dim.order_count_from_dim,
        fact.order_count_from_fact,
        dim.ltv_from_dim,
        fact.ltv_from_fact
    from customer_orders_from_dim dim
    full outer join customer_orders_from_fact fact
        on dim.customer_id = fact.customer_id
)

-- Fail if counts or values don't match
select *
from comparison
where order_count_from_dim != order_count_from_fact
    or abs(ltv_from_dim - ltv_from_fact) > 0.01
```

---

## 6. Documentation

### Example 6.1: Comprehensive Model Documentation

```yaml
# models/marts/core/_core__models.yml

version: 2

models:
  - name: fct_orders
    description: |
      # Order Fact Table

      This table contains one row per order with associated customer,
      payment, and product information.

      ## Grain
      One row per order (order_id is unique)

      ## Refresh Schedule
      - **Development**: On-demand via dbt Cloud IDE
      - **Production**: Daily at 2:00 AM UTC
      - **Incremental**: Processes last 3 days of data

      ## Business Logic
      - Only includes orders from the Jaffle Shop application
      - Order totals calculated from successful Stripe payments
      - Status reflects current order state (may change over time)

      ## Data Quality
      - All orders must have a valid customer_id
      - Order totals must be non-negative
      - Order dates cannot be in the future

      ## Usage Examples
      ```sql
      -- Get total revenue by month
      select
          date_trunc('month', order_date) as month,
          sum(order_total) as revenue
      from {{ ref('fct_orders') }}
      where status = 'completed'
      group by 1;
      ```

      ## Known Issues
      - Guest checkouts may have temporary customer_id values
      - Cancelled orders within 24 hours may show as 'completed' briefly

      ## Related Models
      - Upstream: {{ ref('stg_jaffle_shop__orders') }}, {{ ref('stg_stripe__payments') }}
      - Downstream: {{ ref('daily_revenue_metrics') }}, {{ ref('customer_lifetime_value') }}

    meta:
      owner: analytics_team@company.com
      contains_pii: true
      pii_columns: [customer_id]

    columns:
      - name: order_id
        description: |
          **Primary key** for the orders table.

          Uniquely identifies each order. Generated by the application
          at order creation time. Format: alphanumeric, 32 characters.

        tests:
          - unique
          - not_null

      - name: customer_id
        description: |
          **Foreign key** to {{ ref('dim_customers') }}.

          Links each order to the customer who placed it.

          **Note**: May be NULL for guest checkout orders (rare).

        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id

      - name: order_date
        description: Date the order was placed (UTC timezone)
        tests:
          - not_null

      - name: status
        description: "{{ doc('order_status') }}"
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned', 'cancelled']

      - name: order_total
        description: |
          Total order amount in USD, including:
          - Product costs
          - Shipping fees
          - Taxes
          - Discounts (subtracted)

          Calculated from successful Stripe payment records.

        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

### Example 6.2: Documentation Blocks

```markdown
<!-- models/docs.md -->

{% docs order_status %}

### Order Status Values

The current fulfillment status of an order.

| Status | Description | Transition Conditions |
|--------|-------------|----------------------|
| `placed` | Order received, payment pending | Initial state |
| `shipped` | Order dispatched to customer | After payment confirmed |
| `completed` | Order delivered successfully | After delivery confirmation |
| `returned` | Customer returned the order | Within 30-day window |
| `cancelled` | Order cancelled before shipment | Customer or system initiated |

**Lifecycle Flow:**
```
placed → shipped → completed
   ↓         ↓
cancelled  returned
```

**Business Rules:**
- Orders can only be cancelled in 'placed' status
- Returns accepted within 30 days of delivery
- Status changes tracked in order_history table

{% enddocs %}

{% docs customer_segment %}

### Customer Segmentation Logic

Customers are categorized into segments based on lifetime value and order history:

- **VIP**: Lifetime value ≥ $1,000
- **High Value**: Lifetime value ≥ $500 and < $1,000
- **Regular**: 5+ orders regardless of value
- **New**: 1-4 orders
- **Prospect**: No completed orders

Segments recalculated daily as part of {{ ref('dim_customers') }} refresh.

{% enddocs %}

{% docs data_freshness %}

### Data Freshness Expectations

| Source | Refresh Frequency | Acceptable Lag |
|--------|------------------|----------------|
| Application DB | Real-time CDC | < 5 minutes |
| Stripe API | Hourly sync | < 2 hours |
| Google Analytics | Daily batch | < 24 hours |

Source freshness monitored via dbt source freshness tests.

{% enddocs %}
```

---

## 7. Macros

### Example 7.1: Reusable Calculation Macro

```sql
-- macros/cents_to_dollars.sql

{% macro cents_to_dollars(column_name, precision=2) %}
    round(cast({{ column_name }} as numeric) / 100.0, {{ precision }})
{% endmacro %}
```

Usage:

```sql
select
    payment_id,
    {{ cents_to_dollars('amount_cents') }} as amount_dollars,
    {{ cents_to_dollars('amount_cents', 4) }} as amount_dollars_precise
from {{ ref('stg_stripe__payments') }}
```

### Example 7.2: Dynamic Pivot Macro

```sql
-- macros/pivot_metric.sql

{% macro pivot_metric(table, group_by_col, pivot_col, metric_col, agg='sum', prefix='', suffix='') %}

{% set pivot_values_query %}
    select distinct {{ pivot_col }}
    from {{ table }}
    where {{ pivot_col }} is not null
    order by {{ pivot_col }}
{% endset %}

{% set results = run_query(pivot_values_query) %}

{% if execute %}
    {% set pivot_values = results.columns[0].values() %}
{% else %}
    {% set pivot_values = [] %}
{% endif %}

select
    {{ group_by_col }},
    {% for value in pivot_values %}
        {{ agg }}(case when {{ pivot_col }} = '{{ value }}' then {{ metric_col }} else 0 end)
            as {{ prefix }}{{ value | replace(' ', '_') | lower }}{{ suffix }}
        {% if not loop.last %},{% endif %}
    {% endfor %}
from {{ table }}
group by {{ group_by_col }}

{% endmacro %}
```

Usage:

```sql
-- Pivot revenue by order status
{{ pivot_metric(
    table=ref('fct_orders'),
    group_by_col='customer_id',
    pivot_col='status',
    metric_col='order_total',
    agg='sum',
    suffix='_revenue'
) }}
```

### Example 7.3: Grant Permissions Macro

```sql
-- macros/grant_permissions.sql

{% macro grant_select(schema, role) %}

    {% if target.name == 'prod' %}
        {% set sql %}
            grant select on all tables in schema {{ schema }} to role {{ role }};
            grant select on all views in schema {{ schema }} to role {{ role }};
            grant select on future tables in schema {{ schema }} to role {{ role }};
            grant select on future views in schema {{ schema }} to role {{ role }};
        {% endset %}

        {% do run_query(sql) %}
        {% do log("Granted SELECT on " ~ schema ~ " to " ~ role, info=True) %}
    {% else %}
        {% do log("Skipping grants in " ~ target.name ~ " environment", info=True) %}
    {% endif %}

{% endmacro %}
```

Usage in dbt_project.yml:

```yaml
on-run-end:
  - "{{ grant_select(target.schema, 'analyst_role') }}"
```

### Example 7.4: Audit Columns Macro

```sql
-- macros/audit_columns.sql

{% macro audit_columns() %}
    current_timestamp() as dbt_updated_at,
    '{{ invocation_id }}' as dbt_invocation_id,
    '{{ var("dbt_user", "system") }}' as dbt_updated_by
{% endmacro %}
```

Usage:

```sql
select
    order_id,
    customer_id,
    order_total,
    {{ audit_columns() }}
from {{ ref('stg_orders') }}
```

---

## 8. Snapshots

### Example 8.1: Timestamp Strategy Snapshot

```sql
-- snapshots/customers_snapshot.sql

{% snapshot customers_snapshot %}

{{
    config(
        target_database='analytics',
        target_schema='snapshots',
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
    customer_status,
    lifetime_value,
    updated_at
from {{ ref('dim_customers') }}

{% endsnapshot %}
```

Result includes dbt-generated columns:
- `dbt_valid_from`: When record became active
- `dbt_valid_to`: When record was superseded (NULL if current)
- `dbt_updated_at`: Snapshot run timestamp

### Example 8.2: Check Strategy Snapshot

```sql
-- snapshots/product_prices_snapshot.sql

{% snapshot product_prices_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['price', 'discount_pct', 'is_active']
    )
}}

select
    product_id,
    product_name,
    category,
    price,
    discount_pct,
    is_active
from {{ source('ecommerce', 'products') }}

{% endsnapshot %}
```

---

## 9. Advanced Analytics

### Example 9.1: Cohort Retention Analysis

```sql
-- models/marts/analytics/customer_retention_cohorts.sql

with customer_first_order as (
    select
        customer_id,
        date_trunc('month', min(order_date)) as cohort_month
    from {{ ref('fct_orders') }}
    where status = 'completed'
    group by 1
),

customer_orders_by_month as (
    select
        customer_id,
        date_trunc('month', order_date) as order_month
    from {{ ref('fct_orders') }}
    where status = 'completed'
    group by 1, 2
),

cohort_activity as (
    select
        f.cohort_month,
        o.order_month,
        datediff('month', f.cohort_month, o.order_month) as months_since_first_order,
        count(distinct o.customer_id) as active_customers
    from customer_first_order f
    join customer_orders_by_month o
        on f.customer_id = o.customer_id
    group by 1, 2, 3
),

cohort_size as (
    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from customer_first_order
    group by 1
),

retention_rates as (
    select
        a.cohort_month,
        a.months_since_first_order,
        s.cohort_size,
        a.active_customers,
        round(100.0 * a.active_customers / s.cohort_size, 2) as retention_pct
    from cohort_activity a
    join cohort_size s
        on a.cohort_month = s.cohort_month
)

select * from retention_rates
order by cohort_month, months_since_first_order
```

### Example 9.2: RFM Segmentation

```sql
-- models/marts/analytics/customer_rfm_analysis.sql

with customer_metrics as (
    select
        customer_id,
        max(order_date) as last_order_date,
        count(distinct order_id) as frequency,
        sum(order_total) as monetary
    from {{ ref('fct_orders') }}
    where status = 'completed'
    group by 1
),

rfm_scores as (
    select
        customer_id,
        datediff('day', last_order_date, current_date) as recency_days,
        frequency,
        monetary,

        -- Score 1-5 (5 = best)
        ntile(5) over (order by last_order_date desc) as recency_score,
        ntile(5) over (order by frequency) as frequency_score,
        ntile(5) over (order by monetary) as monetary_score
    from customer_metrics
),

rfm_segments as (
    select
        *,
        recency_score * 100 + frequency_score * 10 + monetary_score as rfm_combined_score,
        case
            -- Champions: Bought recently, buy often, spend the most
            when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4
                then 'Champions'

            -- Loyal Customers: Buy regularly, good spenders
            when recency_score >= 3 and frequency_score >= 3 and monetary_score >= 3
                then 'Loyal Customers'

            -- Potential Loyalists: Recent customers, spent good amount, bought more than once
            when recency_score >= 4 and frequency_score >= 2 and monetary_score >= 2
                then 'Potential Loyalists'

            -- Recent Customers: Bought recently, but not often
            when recency_score >= 4 and frequency_score <= 2
                then 'Recent Customers'

            -- Promising: Recent shoppers, but haven't spent much
            when recency_score >= 3 and frequency_score <= 2 and monetary_score <= 2
                then 'Promising'

            -- Need Attention: Above average recency, frequency, and monetary values
            when recency_score >= 3 and frequency_score >= 2 and monetary_score >= 2
                then 'Need Attention'

            -- About to Sleep: Below average recency, frequency, and monetary values
            when recency_score <= 2 and frequency_score >= 2 and monetary_score >= 2
                then 'About To Sleep'

            -- At Risk: Spent big money, purchased often, but long time ago
            when recency_score <= 2 and frequency_score >= 3 and monetary_score >= 3
                then 'At Risk'

            -- Cannot Lose Them: Made big purchases, often, but haven't returned for long time
            when recency_score <= 1 and frequency_score >= 4 and monetary_score >= 4
                then 'Cannot Lose Them'

            -- Hibernating: Last purchase long ago, low spenders, low frequency
            when recency_score <= 2 and frequency_score <= 2 and monetary_score <= 2
                then 'Hibernating'

            -- Lost: Lowest recency, frequency, and monetary scores
            when recency_score <= 1
                then 'Lost'

            else 'Other'
        end as rfm_segment

    from rfm_scores
)

select * from rfm_segments
```

### Example 9.3: Marketing Attribution

```sql
-- models/marts/analytics/marketing_attribution.sql

with touchpoints as (
    select
        user_id,
        session_id,
        event_timestamp,
        case
            when referrer like '%google%' then 'Google'
            when referrer like '%facebook%' then 'Facebook'
            when referrer like '%instagram%' then 'Instagram'
            when referrer like '%email%' then 'Email'
            when referrer is null then 'Direct'
            else 'Other'
        end as channel
    from {{ ref('fct_page_views') }}
    where user_id is not null
),

conversions as (
    select
        customer_id as user_id,
        order_id,
        order_date,
        order_total
    from {{ ref('fct_orders') }}
    where status = 'completed'
),

customer_journey as (
    select
        c.order_id,
        c.order_total,
        t.channel,
        t.event_timestamp as touchpoint_timestamp,
        c.order_date,

        -- Touchpoint sequencing
        row_number() over (
            partition by c.order_id
            order by t.event_timestamp
        ) as touchpoint_number,

        count(*) over (partition by c.order_id) as total_touchpoints,

        -- Time decay weight (more recent = higher weight)
        datediff('hour', t.event_timestamp, c.order_date) as hours_before_conversion

    from conversions c
    join touchpoints t
        on c.user_id = t.user_id
        and t.event_timestamp <= c.order_date
        and t.event_timestamp >= dateadd('day', -30, c.order_date)
),

attributed_revenue as (
    select
        order_id,
        channel,
        order_total,
        touchpoint_number,
        total_touchpoints,
        hours_before_conversion,

        -- First Touch Attribution
        case when touchpoint_number = 1
            then order_total else 0 end as first_touch_revenue,

        -- Last Touch Attribution
        case when touchpoint_number = total_touchpoints
            then order_total else 0 end as last_touch_revenue,

        -- Linear Attribution (equal credit to all touchpoints)
        order_total / total_touchpoints as linear_revenue,

        -- Time Decay Attribution (exponential decay, 7-day half-life)
        order_total * exp(-0.1 * (hours_before_conversion / 24.0))
            / sum(exp(-0.1 * (hours_before_conversion / 24.0))) over (partition by order_id)
            as time_decay_revenue,

        -- Position-Based Attribution (40% first, 40% last, 20% middle)
        case
            when total_touchpoints = 1 then order_total
            when touchpoint_number = 1 then order_total * 0.4
            when touchpoint_number = total_touchpoints then order_total * 0.4
            else order_total * 0.2 / (total_touchpoints - 2)
        end as position_based_revenue

    from customer_journey
)

select
    channel,
    count(distinct order_id) as orders,
    sum(first_touch_revenue) as first_touch_revenue,
    sum(last_touch_revenue) as last_touch_revenue,
    sum(linear_revenue) as linear_revenue,
    sum(time_decay_revenue) as time_decay_revenue,
    sum(position_based_revenue) as position_based_revenue
from attributed_revenue
group by 1
```

---

## 10. Production Workflows

### Example 10.1: CI/CD with GitHub Actions

```yaml
# .github/workflows/dbt_ci.yml

name: dbt CI

on:
  pull_request:
    branches: [main]
    paths:
      - 'models/**'
      - 'macros/**'
      - 'tests/**'
      - 'dbt_project.yml'
      - 'packages.yml'

jobs:
  dbt_ci_check:
    runs-on: ubuntu-latest

    env:
      DBT_PROFILES_DIR: .
      DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
      DBT_SNOWFLAKE_USER: ${{ secrets.DBT_CI_USER }}
      DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_CI_PASSWORD }}
      DBT_SNOWFLAKE_ROLE: TRANSFORMER
      DBT_SNOWFLAKE_DATABASE: ANALYTICS
      DBT_SNOWFLAKE_WAREHOUSE: TRANSFORMING
      DBT_SNOWFLAKE_SCHEMA: dbt_ci_${{ github.event.pull_request.number }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Needed for state comparison

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dbt
        run: |
          pip install dbt-core==1.7.4 dbt-snowflake==1.7.1

      - name: Install dbt packages
        run: dbt deps

      - name: Download production manifest
        run: |
          mkdir -p ./prod_state
          # Download manifest.json from S3 or artifact storage
          # aws s3 cp s3://your-bucket/prod/manifest.json ./prod_state/

      - name: dbt debug
        run: dbt debug --target ci

      - name: dbt compile (all models)
        run: dbt compile --target ci

      - name: dbt run (modified models only)
        run: |
          dbt run \
            --select state:modified+ \
            --state ./prod_state \
            --target ci

      - name: dbt test (modified models only)
        run: |
          dbt test \
            --select state:modified+ \
            --state ./prod_state \
            --target ci

      - name: Generate dbt docs
        run: dbt docs generate --target ci

      - name: Comment PR with results
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '✅ dbt CI checks passed! Models compiled and tests succeeded.'
            })

      - name: Cleanup CI schema
        if: always()
        run: |
          dbt run-operation drop_schema \
            --args '{schema: dbt_ci_${{ github.event.pull_request.number }}}' \
            --target ci
```

### Example 10.2: Production Deployment

```yaml
# .github/workflows/dbt_production.yml

name: dbt Production Deploy

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC

jobs:
  deploy_production:
    runs-on: ubuntu-latest

    env:
      DBT_PROFILES_DIR: .
      DBT_SNOWFLAKE_ACCOUNT: ${{ secrets.DBT_SNOWFLAKE_ACCOUNT }}
      DBT_SNOWFLAKE_USER: ${{ secrets.DBT_PROD_USER }}
      DBT_SNOWFLAKE_PASSWORD: ${{ secrets.DBT_PROD_PASSWORD }}
      DBT_SNOWFLAKE_ROLE: TRANSFORMER
      DBT_SNOWFLAKE_DATABASE: ANALYTICS
      DBT_SNOWFLAKE_WAREHOUSE: TRANSFORMING
      DBT_SNOWFLAKE_SCHEMA: analytics_prod

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dbt
        run: pip install dbt-core==1.7.4 dbt-snowflake==1.7.1

      - name: Install dbt packages
        run: dbt deps

      - name: dbt debug
        run: dbt debug --target prod

      - name: dbt seed
        run: dbt seed --target prod --full-refresh

      - name: dbt run (staging)
        run: dbt run --select staging.* --target prod

      - name: dbt run (marts)
        run: dbt run --select marts.* --target prod

      - name: dbt test
        run: dbt test --target prod

      - name: dbt source freshness
        run: dbt source freshness --target prod

      - name: Generate documentation
        run: dbt docs generate --target prod

      - name: Upload docs to S3
        run: |
          aws s3 sync target/ s3://your-dbt-docs-bucket/latest/ \
            --exclude "*" \
            --include "manifest.json" \
            --include "catalog.json" \
            --include "index.html"
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Save manifest for state comparison
        run: |
          aws s3 cp target/manifest.json s3://your-state-bucket/prod/manifest.json
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚨 dbt Production run failed!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*dbt Production Deploy Failed*\n\nRun: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Additional Resources

- **dbt Documentation**: https://docs.getdbt.com/
- **dbt Discourse**: https://discourse.getdbt.com/
- **dbt Slack Community**: https://www.getdbt.com/community/
- **dbt Learn**: https://courses.getdbt.com/
- **dbt Package Hub**: https://hub.getdbt.com/

---

**Last Updated**: October 2025
**Skill Version**: 1.0.0
