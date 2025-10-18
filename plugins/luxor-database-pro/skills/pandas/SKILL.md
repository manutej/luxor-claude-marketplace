---
name: pandas
description: Expert data analysis and manipulation for customer support operations using pandas
version: 2.2.0
category: data-analysis
tags:
  - python
  - data-analysis
  - customer-support
  - analytics
  - etl
  - postgresql
  - reporting
  - metrics
dependencies:
  - pandas>=2.2.0
  - sqlalchemy>=2.0.0
  - psycopg2-binary>=2.9.0
  - numpy>=1.26.0
  - openpyxl>=3.1.0
  - pytest>=8.0.0
context: customer-support-tech-enablement
specializations:
  - ticket-analytics
  - sla-tracking
  - performance-metrics
  - data-curation
  - postgresql-integration
---

# pandas - Data Analysis and Manipulation for Customer Support

## Overview

You are an expert in pandas, the powerful Python library for data analysis and manipulation, with specialized knowledge in customer support analytics, ticket management, SLA tracking, and performance reporting. Your expertise covers DataFrame operations, data transformation, time series analysis, database integration, and production-ready data pipelines for support operations.

## Core Competencies

### 1. DataFrame Operations and Data Structures

**DataFrame Creation and Initialization**
- Create DataFrames from various sources: dictionaries, lists, CSV files, databases, JSON, Excel
- Understand DataFrame anatomy: index, columns, values, dtypes
- Use appropriate data types for memory optimization (category, int32, datetime64)
- Initialize DataFrames with proper indices for time series data

**Data Selection and Indexing**
- Use `.loc[]` for label-based indexing (rows and columns by name)
- Use `.iloc[]` for position-based indexing (integer positions)
- Boolean indexing for filtering data based on conditions
- Query method for SQL-like filtering: `df.query('priority == "high" and status == "open"')`
- Multi-level indexing for hierarchical data (team > agent > ticket)

**Column Operations**
- Select, rename, and reorder columns efficiently
- Create calculated columns using vectorized operations
- Apply functions to columns: `.apply()`, `.map()`, `.transform()`
- Use `.assign()` for method chaining and creating new columns
- Handle column data type conversions with `.astype()`

### 2. Customer Support Analytics Patterns

**SLA Tracking and Compliance**
```python
# Calculate SLA compliance for support tickets
def analyze_sla_compliance(tickets_df):
    """
    Analyze SLA compliance for customer support tickets.

    Args:
        tickets_df: DataFrame with columns [ticket_id, created_at, first_response_at,
                    resolved_at, priority, sla_target_hours]

    Returns:
        DataFrame with SLA metrics and compliance flags
    """
    # Calculate response and resolution times
    tickets_df['first_response_time'] = (
        tickets_df['first_response_at'] - tickets_df['created_at']
    ).dt.total_seconds() / 3600  # Convert to hours

    tickets_df['resolution_time'] = (
        tickets_df['resolved_at'] - tickets_df['created_at']
    ).dt.total_seconds() / 3600

    # Determine SLA compliance
    tickets_df['response_sla_met'] = (
        tickets_df['first_response_time'] <= tickets_df['sla_target_hours']
    )

    tickets_df['resolution_sla_met'] = (
        tickets_df['resolution_time'] <= tickets_df['sla_target_hours'] * 2
    )

    # Calculate compliance rate by priority
    compliance_by_priority = tickets_df.groupby('priority').agg({
        'response_sla_met': ['sum', 'count', 'mean'],
        'resolution_sla_met': ['sum', 'count', 'mean'],
        'first_response_time': ['mean', 'median', 'std'],
        'resolution_time': ['mean', 'median', 'std']
    })

    return tickets_df, compliance_by_priority
```

**Ticket Volume and Trend Analysis**
```python
# Time series analysis of ticket volume
def analyze_ticket_trends(tickets_df, frequency='D'):
    """
    Analyze ticket volume trends over time.

    Args:
        tickets_df: DataFrame with created_at column
        frequency: Resampling frequency ('D', 'W', 'M', 'Q')

    Returns:
        DataFrame with aggregated metrics by time period
    """
    # Set datetime index
    tickets_ts = tickets_df.set_index('created_at').sort_index()

    # Resample and aggregate
    volume_trends = tickets_ts.resample(frequency).agg({
        'ticket_id': 'count',
        'priority': lambda x: (x == 'high').sum(),
        'channel': lambda x: x.value_counts().to_dict(),
        'customer_id': 'nunique'
    }).rename(columns={
        'ticket_id': 'total_tickets',
        'priority': 'high_priority_count',
        'customer_id': 'unique_customers'
    })

    # Calculate rolling averages
    volume_trends['7day_avg'] = volume_trends['total_tickets'].rolling(7).mean()
    volume_trends['30day_avg'] = volume_trends['total_tickets'].rolling(30).mean()

    # Calculate percentage change
    volume_trends['pct_change'] = volume_trends['total_tickets'].pct_change()

    return volume_trends
```

**Agent Performance Metrics**
```python
# Calculate comprehensive agent performance metrics
def calculate_agent_metrics(tickets_df, agents_df):
    """
    Calculate detailed performance metrics for support agents.

    Args:
        tickets_df: DataFrame with ticket data
        agents_df: DataFrame with agent information

    Returns:
        DataFrame with agent performance metrics
    """
    # Group by agent
    agent_metrics = tickets_df.groupby('agent_id').agg({
        'ticket_id': 'count',
        'first_response_time': ['mean', 'median', 'std'],
        'resolution_time': ['mean', 'median', 'std'],
        'csat_score': ['mean', 'count'],
        'response_sla_met': 'mean',
        'resolution_sla_met': 'mean',
        'reopened': 'sum'
    })

    # Flatten multi-level columns
    agent_metrics.columns = ['_'.join(col).strip() for col in agent_metrics.columns]

    # Calculate additional metrics
    agent_metrics['tickets_per_day'] = (
        agent_metrics['ticket_id_count'] /
        (tickets_df['created_at'].max() - tickets_df['created_at'].min()).days
    )

    agent_metrics['reopen_rate'] = (
        agent_metrics['reopened_sum'] / agent_metrics['ticket_id_count']
    )

    # Merge with agent details
    agent_metrics = agent_metrics.merge(
        agents_df[['agent_id', 'name', 'team', 'hire_date']],
        left_index=True,
        right_on='agent_id'
    )

    return agent_metrics
```

### 3. Data Integration and ETL

**PostgreSQL Integration with SQLAlchemy**
```python
# Load and save data to PostgreSQL
from sqlalchemy import create_engine, text
import pandas as pd

def create_db_connection(host, database, user, password, port=5432):
    """Create SQLAlchemy engine for PostgreSQL."""
    connection_string = f"postgresql://{user}:{password}@{host}:{port}/{database}"
    return create_engine(connection_string)

def load_tickets_from_db(engine, start_date, end_date):
    """
    Load ticket data from PostgreSQL with optimized query.

    Args:
        engine: SQLAlchemy engine
        start_date: Start date for filtering
        end_date: End date for filtering

    Returns:
        DataFrame with ticket data
    """
    query = text("""
        SELECT
            t.ticket_id,
            t.created_at,
            t.updated_at,
            t.resolved_at,
            t.first_response_at,
            t.priority,
            t.status,
            t.channel,
            t.category,
            t.agent_id,
            t.customer_id,
            t.subject,
            c.name as customer_name,
            c.tier as customer_tier,
            a.name as agent_name,
            a.team as agent_team
        FROM tickets t
        LEFT JOIN customers c ON t.customer_id = c.customer_id
        LEFT JOIN agents a ON t.agent_id = a.agent_id
        WHERE t.created_at >= :start_date
          AND t.created_at < :end_date
        ORDER BY t.created_at DESC
    """)

    # Load with proper data types
    df = pd.read_sql(
        query,
        engine,
        params={'start_date': start_date, 'end_date': end_date},
        parse_dates=['created_at', 'updated_at', 'resolved_at', 'first_response_at']
    )

    # Optimize data types
    df['priority'] = df['priority'].astype('category')
    df['status'] = df['status'].astype('category')
    df['channel'] = df['channel'].astype('category')
    df['customer_tier'] = df['customer_tier'].astype('category')

    return df

def save_metrics_to_db(df, table_name, engine, if_exists='replace'):
    """
    Save processed metrics to PostgreSQL.

    Args:
        df: DataFrame to save
        table_name: Target table name
        engine: SQLAlchemy engine
        if_exists: 'replace', 'append', or 'fail'
    """
    df.to_sql(
        table_name,
        engine,
        if_exists=if_exists,
        index=True,
        method='multi',  # Faster multi-row insert
        chunksize=1000
    )
```

**Data Cleaning and Validation**
```python
# Comprehensive data cleaning for support data
def clean_ticket_data(df):
    """
    Clean and validate ticket data.

    Args:
        df: Raw ticket DataFrame

    Returns:
        Cleaned DataFrame with validation report
    """
    validation_report = {}

    # 1. Handle missing values
    validation_report['missing_before'] = df.isnull().sum().to_dict()

    # Fill missing agent_id for unassigned tickets
    df['agent_id'] = df['agent_id'].fillna('UNASSIGNED')

    # Fill missing categories
    df['category'] = df['category'].fillna('UNCATEGORIZED')

    # Drop tickets with missing critical fields
    critical_fields = ['ticket_id', 'created_at', 'customer_id']
    df = df.dropna(subset=critical_fields)

    validation_report['missing_after'] = df.isnull().sum().to_dict()

    # 2. Remove duplicates
    validation_report['duplicates_found'] = df.duplicated(subset=['ticket_id']).sum()
    df = df.drop_duplicates(subset=['ticket_id'], keep='first')

    # 3. Validate data types and ranges
    df['created_at'] = pd.to_datetime(df['created_at'], errors='coerce')
    df['resolved_at'] = pd.to_datetime(df['resolved_at'], errors='coerce')

    # 4. Validate business logic
    # Resolution time should be positive
    invalid_resolution = df[
        (df['resolved_at'].notna()) &
        (df['resolved_at'] < df['created_at'])
    ]
    validation_report['invalid_resolution_times'] = len(invalid_resolution)

    # Fix by setting to None
    df.loc[df['resolved_at'] < df['created_at'], 'resolved_at'] = None

    # 5. Standardize categorical values
    priority_mapping = {
        'CRITICAL': 'critical',
        'HIGH': 'high',
        'MEDIUM': 'medium',
        'LOW': 'low',
        'urgent': 'high',
        'normal': 'medium'
    }
    df['priority'] = df['priority'].replace(priority_mapping)

    # 6. Outlier detection for response times
    if 'first_response_time' in df.columns:
        q1 = df['first_response_time'].quantile(0.25)
        q3 = df['first_response_time'].quantile(0.75)
        iqr = q3 - q1
        outlier_threshold = q3 + (3 * iqr)

        validation_report['response_time_outliers'] = (
            df['first_response_time'] > outlier_threshold
        ).sum()

    validation_report['final_row_count'] = len(df)

    return df, validation_report
```

### 4. GroupBy and Aggregation Operations

**Multi-level Grouping for Team Analytics**
```python
# Complex groupby operations for team performance
def analyze_team_performance(tickets_df):
    """
    Perform multi-level grouping for team and agent analytics.

    Returns:
        Multiple DataFrames with different aggregation levels
    """
    # Level 1: Team-level metrics
    team_metrics = tickets_df.groupby('agent_team').agg({
        'ticket_id': 'count',
        'resolution_time': ['mean', 'median', 'std', 'min', 'max'],
        'csat_score': ['mean', 'count'],
        'resolution_sla_met': 'mean',
        'reopened': 'sum'
    })

    # Level 2: Team + Priority breakdown
    team_priority_metrics = tickets_df.groupby(
        ['agent_team', 'priority']
    )['ticket_id'].count().unstack(fill_value=0)

    # Level 3: Team + Agent detailed metrics
    team_agent_metrics = tickets_df.groupby(
        ['agent_team', 'agent_id', 'agent_name']
    ).agg({
        'ticket_id': 'count',
        'resolution_time': 'mean',
        'csat_score': 'mean',
        'resolution_sla_met': 'mean'
    })

    # Calculate team rankings
    team_metrics['rank_by_volume'] = team_metrics['ticket_id']['count'].rank(
        ascending=False
    )
    team_metrics['rank_by_csat'] = team_metrics['csat_score']['mean'].rank(
        ascending=False
    )

    return team_metrics, team_priority_metrics, team_agent_metrics

# Custom aggregation functions
def calculate_p95(series):
    """Calculate 95th percentile."""
    return series.quantile(0.95)

def calculate_p99(series):
    """Calculate 99th percentile."""
    return series.quantile(0.99)

# Advanced groupby with custom aggregations
def detailed_response_time_analysis(tickets_df):
    """Calculate detailed response time statistics."""
    return tickets_df.groupby('priority').agg({
        'first_response_time': [
            'count',
            'mean',
            'median',
            'std',
            'min',
            'max',
            calculate_p95,
            calculate_p99
        ]
    })
```

### 5. Merging and Joining Data

**Complex Join Operations**
```python
# Merge ticket, customer, and agent data
def create_comprehensive_dataset(tickets_df, customers_df, agents_df, csat_df):
    """
    Merge multiple data sources into comprehensive dataset.

    Args:
        tickets_df: Ticket information
        customers_df: Customer information
        agents_df: Agent information
        csat_df: Customer satisfaction scores

    Returns:
        Merged DataFrame with all relevant information
    """
    # Step 1: Merge tickets with customers (left join - keep all tickets)
    data = tickets_df.merge(
        customers_df[['customer_id', 'name', 'tier', 'industry', 'contract_value']],
        on='customer_id',
        how='left',
        suffixes=('', '_customer')
    )

    # Step 2: Merge with agents (left join)
    data = data.merge(
        agents_df[['agent_id', 'name', 'team', 'hire_date', 'specialization']],
        on='agent_id',
        how='left',
        suffixes=('', '_agent')
    )

    # Step 3: Merge with CSAT scores (left join)
    data = data.merge(
        csat_df[['ticket_id', 'csat_score', 'csat_comment']],
        on='ticket_id',
        how='left'
    )

    # Validate merge results
    print(f"Original tickets: {len(tickets_df)}")
    print(f"After merges: {len(data)}")
    print(f"Customers matched: {data['name_customer'].notna().sum()}")
    print(f"Agents matched: {data['name_agent'].notna().sum()}")
    print(f"CSAT scores available: {data['csat_score'].notna().sum()}")

    return data

# Concat operations for combining time periods
def combine_historical_data(data_sources):
    """
    Combine data from multiple time periods or sources.

    Args:
        data_sources: List of DataFrames to combine

    Returns:
        Combined DataFrame with source tracking
    """
    # Add source identifier to each DataFrame
    for i, df in enumerate(data_sources):
        df['source_batch'] = f'batch_{i+1}'

    # Concatenate vertically
    combined = pd.concat(data_sources, ignore_index=True)

    # Remove duplicates (prefer newer data)
    combined = combined.sort_values('updated_at', ascending=False)
    combined = combined.drop_duplicates(subset=['ticket_id'], keep='first')

    return combined
```

### 6. Time Series Analysis

**Resampling and Rolling Windows**
```python
# Time series operations for support metrics
def calculate_rolling_metrics(tickets_df, window_days=7):
    """
    Calculate rolling window metrics for trend analysis.

    Args:
        tickets_df: Ticket DataFrame with datetime index
        window_days: Window size in days

    Returns:
        DataFrame with rolling metrics
    """
    # Prepare time series
    ts_data = tickets_df.set_index('created_at').sort_index()

    # Daily aggregation
    daily_metrics = ts_data.resample('D').agg({
        'ticket_id': 'count',
        'resolution_time': 'mean',
        'csat_score': 'mean',
        'resolution_sla_met': 'mean'
    }).rename(columns={'ticket_id': 'daily_tickets'})

    # Rolling window calculations
    window = window_days
    daily_metrics['tickets_rolling_avg'] = (
        daily_metrics['daily_tickets'].rolling(window).mean()
    )
    daily_metrics['tickets_rolling_std'] = (
        daily_metrics['daily_tickets'].rolling(window).std()
    )

    # Calculate control limits for anomaly detection
    daily_metrics['upper_control_limit'] = (
        daily_metrics['tickets_rolling_avg'] +
        (2 * daily_metrics['tickets_rolling_std'])
    )
    daily_metrics['lower_control_limit'] = (
        daily_metrics['tickets_rolling_avg'] -
        (2 * daily_metrics['tickets_rolling_std'])
    ).clip(lower=0)

    # Flag anomalies
    daily_metrics['is_anomaly'] = (
        (daily_metrics['daily_tickets'] > daily_metrics['upper_control_limit']) |
        (daily_metrics['daily_tickets'] < daily_metrics['lower_control_limit'])
    )

    return daily_metrics

# Business day calculations
def calculate_business_day_metrics(tickets_df):
    """Calculate metrics excluding weekends and holidays."""
    from pandas.tseries.offsets import CustomBusinessDay

    # Define US holidays (customize as needed)
    us_bd = CustomBusinessDay()

    # Filter to business days only
    tickets_df['is_business_day'] = tickets_df['created_at'].dt.dayofweek < 5
    business_tickets = tickets_df[tickets_df['is_business_day']]

    # Calculate business day metrics
    bd_metrics = business_tickets.groupby(
        business_tickets['created_at'].dt.date
    ).agg({
        'ticket_id': 'count',
        'resolution_time': 'mean'
    })

    return bd_metrics
```

### 7. Pivot Tables and Cross-tabulation

**Creating Management Reports**
```python
# Pivot tables for executive reporting
def create_executive_dashboard_data(tickets_df):
    """
    Create pivot tables for executive dashboard.

    Returns:
        Dictionary of pivot tables for different views
    """
    dashboards = {}

    # 1. Tickets by Team and Priority
    dashboards['team_priority'] = pd.pivot_table(
        tickets_df,
        values='ticket_id',
        index='agent_team',
        columns='priority',
        aggfunc='count',
        fill_value=0,
        margins=True,
        margins_name='Total'
    )

    # 2. Average Resolution Time by Team and Channel
    dashboards['resolution_by_team_channel'] = pd.pivot_table(
        tickets_df,
        values='resolution_time',
        index='agent_team',
        columns='channel',
        aggfunc='mean',
        fill_value=0
    )

    # 3. SLA Compliance by Priority and Week
    tickets_df['week'] = tickets_df['created_at'].dt.to_period('W')
    dashboards['sla_compliance_weekly'] = pd.pivot_table(
        tickets_df,
        values='resolution_sla_met',
        index='week',
        columns='priority',
        aggfunc='mean',
        fill_value=0
    )

    # 4. CSAT by Agent and Customer Tier
    dashboards['csat_by_agent_tier'] = pd.pivot_table(
        tickets_df,
        values='csat_score',
        index='agent_name',
        columns='customer_tier',
        aggfunc=['mean', 'count'],
        fill_value=0
    )

    # 5. Ticket Volume Heatmap (Day of Week vs Hour)
    tickets_df['day_of_week'] = tickets_df['created_at'].dt.day_name()
    tickets_df['hour'] = tickets_df['created_at'].dt.hour
    dashboards['volume_heatmap'] = pd.pivot_table(
        tickets_df,
        values='ticket_id',
        index='day_of_week',
        columns='hour',
        aggfunc='count',
        fill_value=0
    )

    return dashboards

# Cross-tabulation for category analysis
def analyze_category_distribution(tickets_df):
    """Create cross-tabs for ticket category analysis."""
    # Category vs Priority
    category_priority = pd.crosstab(
        tickets_df['category'],
        tickets_df['priority'],
        normalize='index',  # Row percentages
        margins=True
    )

    # Category vs Team (with counts)
    category_team = pd.crosstab(
        tickets_df['category'],
        tickets_df['agent_team'],
        margins=True
    )

    return category_priority, category_team
```

### 8. Data Export and Reporting

**Export to Multiple Formats**
```python
# Export data for stakeholder reporting
def export_monthly_report(tickets_df, output_dir, month):
    """
    Export comprehensive monthly report in multiple formats.

    Args:
        tickets_df: Ticket data for the month
        output_dir: Directory to save reports
        month: Month identifier (e.g., '2024-01')
    """
    import os
    from datetime import datetime

    # 1. Export to Excel with multiple sheets
    excel_path = os.path.join(output_dir, f'support_report_{month}.xlsx')

    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        # Summary sheet
        summary = tickets_df.groupby('priority').agg({
            'ticket_id': 'count',
            'resolution_time': ['mean', 'median'],
            'csat_score': 'mean',
            'resolution_sla_met': 'mean'
        })
        summary.to_excel(writer, sheet_name='Summary')

        # Team metrics sheet
        team_metrics = tickets_df.groupby('agent_team').agg({
            'ticket_id': 'count',
            'resolution_time': 'mean',
            'csat_score': 'mean'
        })
        team_metrics.to_excel(writer, sheet_name='Team Metrics')

        # Raw data sheet (limited to first 10000 rows)
        tickets_df.head(10000).to_excel(
            writer,
            sheet_name='Raw Data',
            index=False
        )

    # 2. Export to CSV for data analysis
    csv_path = os.path.join(output_dir, f'tickets_{month}.csv')
    tickets_df.to_csv(csv_path, index=False, encoding='utf-8')

    # 3. Export to JSON for API consumption
    json_path = os.path.join(output_dir, f'metrics_{month}.json')
    metrics = {
        'total_tickets': int(tickets_df['ticket_id'].count()),
        'avg_resolution_time': float(tickets_df['resolution_time'].mean()),
        'sla_compliance': float(tickets_df['resolution_sla_met'].mean()),
        'avg_csat': float(tickets_df['csat_score'].mean()),
        'by_priority': tickets_df.groupby('priority')['ticket_id'].count().to_dict()
    }

    with open(json_path, 'w') as f:
        import json
        json.dump(metrics, f, indent=2, default=str)

    # 4. Export to Parquet for efficient storage
    parquet_path = os.path.join(output_dir, f'tickets_{month}.parquet')
    tickets_df.to_parquet(parquet_path, compression='snappy', index=False)

    print(f"Reports exported to {output_dir}")
    print(f"  - Excel: {excel_path}")
    print(f"  - CSV: {csv_path}")
    print(f"  - JSON: {json_path}")
    print(f"  - Parquet: {parquet_path}")

# Format DataFrames for presentation
def format_for_presentation(df):
    """Format DataFrame for stakeholder presentation."""
    # Round numeric columns
    numeric_cols = df.select_dtypes(include=['float64', 'float32']).columns
    df[numeric_cols] = df[numeric_cols].round(2)

    # Format percentages
    percentage_cols = [col for col in df.columns if 'rate' in col or 'pct' in col]
    for col in percentage_cols:
        df[col] = df[col].apply(lambda x: f"{x*100:.1f}%")

    # Format currency if applicable
    currency_cols = [col for col in df.columns if 'revenue' in col or 'value' in col]
    for col in currency_cols:
        df[col] = df[col].apply(lambda x: f"${x:,.2f}")

    return df
```

### 9. Performance Optimization

**Memory Optimization Techniques**
```python
# Optimize DataFrame memory usage
def optimize_dataframe_memory(df):
    """
    Reduce DataFrame memory footprint.

    Args:
        df: DataFrame to optimize

    Returns:
        Optimized DataFrame with memory usage report
    """
    initial_memory = df.memory_usage(deep=True).sum() / 1024**2

    # Optimize integer columns
    int_cols = df.select_dtypes(include=['int64']).columns
    for col in int_cols:
        col_min = df[col].min()
        col_max = df[col].max()

        if col_min >= 0:
            if col_max < 255:
                df[col] = df[col].astype('uint8')
            elif col_max < 65535:
                df[col] = df[col].astype('uint16')
            elif col_max < 4294967295:
                df[col] = df[col].astype('uint32')
        else:
            if col_min > -128 and col_max < 127:
                df[col] = df[col].astype('int8')
            elif col_min > -32768 and col_max < 32767:
                df[col] = df[col].astype('int16')
            elif col_min > -2147483648 and col_max < 2147483647:
                df[col] = df[col].astype('int32')

    # Optimize float columns
    float_cols = df.select_dtypes(include=['float64']).columns
    df[float_cols] = df[float_cols].astype('float32')

    # Convert object columns to category if cardinality is low
    object_cols = df.select_dtypes(include=['object']).columns
    for col in object_cols:
        num_unique = df[col].nunique()
        num_total = len(df[col])

        if num_unique / num_total < 0.5:  # Less than 50% unique values
            df[col] = df[col].astype('category')

    final_memory = df.memory_usage(deep=True).sum() / 1024**2
    reduction = (1 - final_memory/initial_memory) * 100

    print(f"Memory usage reduced from {initial_memory:.2f} MB to {final_memory:.2f} MB")
    print(f"Reduction: {reduction:.1f}%")

    return df

# Chunked processing for large datasets
def process_large_dataset_in_chunks(file_path, chunk_size=10000):
    """
    Process large CSV files in chunks to avoid memory issues.

    Args:
        file_path: Path to large CSV file
        chunk_size: Number of rows per chunk

    Returns:
        Aggregated results from all chunks
    """
    # Initialize aggregation containers
    total_tickets = 0
    priority_counts = {}

    # Process in chunks
    for chunk in pd.read_csv(file_path, chunksize=chunk_size):
        # Process each chunk
        chunk = clean_ticket_data(chunk)[0]

        # Aggregate metrics
        total_tickets += len(chunk)

        chunk_priority = chunk['priority'].value_counts().to_dict()
        for priority, count in chunk_priority.items():
            priority_counts[priority] = priority_counts.get(priority, 0) + count

    return {
        'total_tickets': total_tickets,
        'priority_distribution': priority_counts
    }
```

### 10. Data Quality and Validation

**Validation Framework**
```python
# Comprehensive data quality checks
class DataQualityValidator:
    """Validate data quality for support ticket datasets."""

    def __init__(self, df):
        self.df = df
        self.issues = []

    def check_required_columns(self, required_cols):
        """Ensure all required columns are present."""
        missing = set(required_cols) - set(self.df.columns)
        if missing:
            self.issues.append(f"Missing required columns: {missing}")
        return len(missing) == 0

    def check_null_percentages(self, max_null_pct=0.1):
        """Check if null percentage exceeds threshold."""
        null_pct = self.df.isnull().sum() / len(self.df)
        excessive_nulls = null_pct[null_pct > max_null_pct]

        if not excessive_nulls.empty:
            self.issues.append(
                f"Columns with >{max_null_pct*100}% nulls: {excessive_nulls.to_dict()}"
            )
        return excessive_nulls.empty

    def check_duplicate_ids(self, id_column='ticket_id'):
        """Check for duplicate ticket IDs."""
        duplicates = self.df[id_column].duplicated().sum()
        if duplicates > 0:
            self.issues.append(f"Found {duplicates} duplicate ticket IDs")
        return duplicates == 0

    def check_date_logic(self):
        """Validate date field logic."""
        issues_found = 0

        # Created date should be before resolved date
        if 'created_at' in self.df.columns and 'resolved_at' in self.df.columns:
            invalid = (
                self.df['resolved_at'].notna() &
                (self.df['resolved_at'] < self.df['created_at'])
            ).sum()

            if invalid > 0:
                self.issues.append(
                    f"Found {invalid} tickets with resolved_at before created_at"
                )
                issues_found += invalid

        # Check for future dates
        now = pd.Timestamp.now()
        for date_col in ['created_at', 'resolved_at', 'first_response_at']:
            if date_col in self.df.columns:
                future_dates = (self.df[date_col] > now).sum()
                if future_dates > 0:
                    self.issues.append(
                        f"Found {future_dates} future dates in {date_col}"
                    )
                    issues_found += future_dates

        return issues_found == 0

    def check_value_ranges(self, range_checks):
        """
        Check if values are within expected ranges.

        Args:
            range_checks: Dict with column: (min, max) pairs
        """
        for col, (min_val, max_val) in range_checks.items():
            if col in self.df.columns:
                out_of_range = (
                    (self.df[col] < min_val) | (self.df[col] > max_val)
                ).sum()

                if out_of_range > 0:
                    self.issues.append(
                        f"{col}: {out_of_range} values outside range [{min_val}, {max_val}]"
                    )

    def generate_report(self):
        """Generate comprehensive validation report."""
        return {
            'total_rows': len(self.df),
            'total_columns': len(self.df.columns),
            'issues_found': len(self.issues),
            'issues': self.issues,
            'memory_usage_mb': self.df.memory_usage(deep=True).sum() / 1024**2,
            'null_summary': self.df.isnull().sum().to_dict()
        }
```

### 11. Testing Pandas Operations

**Unit Testing with pytest**
```python
# pytest fixtures and tests for data operations
import pytest
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

@pytest.fixture
def sample_ticket_data():
    """Create sample ticket data for testing."""
    np.random.seed(42)
    n_tickets = 100

    return pd.DataFrame({
        'ticket_id': range(1, n_tickets + 1),
        'created_at': pd.date_range('2024-01-01', periods=n_tickets, freq='H'),
        'priority': np.random.choice(['low', 'medium', 'high'], n_tickets),
        'status': np.random.choice(['open', 'in_progress', 'resolved'], n_tickets),
        'agent_id': np.random.choice(['A001', 'A002', 'A003'], n_tickets),
        'customer_id': np.random.choice(['C001', 'C002', 'C003'], n_tickets)
    })

def test_ticket_data_shape(sample_ticket_data):
    """Test that sample data has expected shape."""
    assert sample_ticket_data.shape == (100, 6)
    assert 'ticket_id' in sample_ticket_data.columns

def test_sla_calculation():
    """Test SLA calculation logic."""
    df = pd.DataFrame({
        'ticket_id': [1, 2],
        'created_at': pd.to_datetime(['2024-01-01 10:00', '2024-01-01 11:00']),
        'first_response_at': pd.to_datetime(['2024-01-01 11:00', '2024-01-01 14:00']),
        'sla_target_hours': [2, 2]
    })

    df['response_time_hours'] = (
        df['first_response_at'] - df['created_at']
    ).dt.total_seconds() / 3600

    df['sla_met'] = df['response_time_hours'] <= df['sla_target_hours']

    assert df.loc[0, 'sla_met'] == True
    assert df.loc[1, 'sla_met'] == False

def test_data_cleaning_removes_nulls(sample_ticket_data):
    """Test that data cleaning handles null values."""
    # Add some null values
    df = sample_ticket_data.copy()
    df.loc[0, 'agent_id'] = None
    df.loc[1, 'customer_id'] = None

    # Apply cleaning
    cleaned, report = clean_ticket_data(df)

    # Verify nulls were handled
    assert 'UNASSIGNED' in cleaned['agent_id'].values
    assert report['missing_before']['agent_id'] == 1

def test_groupby_aggregation(sample_ticket_data):
    """Test groupby aggregation produces correct results."""
    result = sample_ticket_data.groupby('priority')['ticket_id'].count()

    assert result.sum() == 100
    assert all(priority in result.index for priority in ['low', 'medium', 'high'])
```

## Best Practices

### 1. Always Use Vectorized Operations
Avoid Python loops when working with pandas. Use vectorized operations for better performance:
```python
# Bad - slow loop
for idx, row in df.iterrows():
    df.at[idx, 'new_col'] = row['col1'] * row['col2']

# Good - vectorized operation
df['new_col'] = df['col1'] * df['col2']
```

### 2. Use Method Chaining for Readability
```python
result = (
    df
    .query('status == "resolved"')
    .groupby('agent_id')
    .agg({'resolution_time': 'mean'})
    .sort_values('resolution_time')
    .head(10)
)
```

### 3. Optimize Data Types Early
Convert to appropriate data types immediately after loading to save memory and improve performance.

### 4. Use `.loc[]` and `.iloc[]` Explicitly
Avoid chained indexing which can lead to SettingWithCopyWarning and unexpected behavior.

### 5. Handle Time Zones Properly
Always work with timezone-aware datetime objects for support data across regions.

### 6. Document Data Transformations
Add comments explaining business logic in complex transformations.

### 7. Validate Data at Every Step
Implement validation checks after major transformations to catch issues early.

### 8. Use Appropriate Index Types
Set meaningful indices (datetime for time series, ticket_id for lookups) to improve performance.

## Common Pitfalls to Avoid

1. **SettingWithCopyWarning**: Always use `.loc[]` for setting values
2. **Memory Issues**: Process large datasets in chunks or optimize data types
3. **Lost Index**: Remember that many operations return new DataFrames without preserving the index
4. **Implicit Type Conversion**: Be explicit about data type conversions
5. **Ambiguous Truth Values**: Use `.any()` or `.all()` when evaluating Series in boolean context
6. **Mixing Time Zones**: Ensure consistent timezone handling across datetime columns

## Integration Patterns

### With pytest for Testing
Always write tests for data transformation functions using pytest fixtures and parametrize decorators.

### With SQLAlchemy for Database Operations
Use SQLAlchemy engines for database connections and leverage pandas' `read_sql` and `to_sql` methods.

### With PostgreSQL for Data Persistence
Store processed metrics in PostgreSQL for historical tracking and dashboard consumption.

### With Excel for Stakeholder Reports
Use `pd.ExcelWriter` with the openpyxl engine for creating multi-sheet Excel reports.

## Performance Guidelines

1. **Use categorical data types** for columns with low cardinality (< 50% unique values)
2. **Process in chunks** when dataset exceeds available memory
3. **Use query() method** for complex filtering (compiles to optimized code)
4. **Avoid apply() when possible** - use vectorized operations instead
5. **Use eval() for complex expressions** on large DataFrames
6. **Set appropriate dtypes** when reading CSV files to avoid inference overhead
7. **Use copy() judiciously** - only when you need true copies to avoid memory waste

## Conclusion

You are now equipped to handle comprehensive data analysis and manipulation tasks for customer support operations using pandas. Apply these patterns to analyze ticket data, track SLA compliance, measure agent performance, and generate actionable insights for support teams. Always prioritize data quality, performance optimization, and clear, maintainable code.
