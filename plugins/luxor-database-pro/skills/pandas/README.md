# pandas Skill - Customer Support Analytics & Data Manipulation

## Overview

The pandas skill provides comprehensive data analysis and manipulation capabilities specifically tailored for customer support operations. This skill enables support teams to analyze ticket data, track SLA compliance, measure agent performance, and generate actionable insights using Python's most powerful data analysis library.

### What is pandas?

pandas is an open-source Python library providing high-performance, easy-to-use data structures and data analysis tools. For customer support operations, pandas excels at:

- **Data Loading**: Import ticket data from PostgreSQL, CSV, Excel, JSON, and other formats
- **Data Cleaning**: Handle missing values, standardize formats, and validate data quality
- **Analysis**: Calculate metrics like response times, SLA compliance, and agent performance
- **Aggregation**: Group data by teams, priorities, channels, and time periods
- **Time Series**: Analyze ticket volume trends and identify patterns
- **Reporting**: Generate executive reports and export data for stakeholders

### Why pandas for Customer Support?

Customer support generates vast amounts of structured data - tickets, responses, customer interactions, satisfaction scores. pandas provides the tools to:

1. **Transform raw ticket data into actionable insights** - Calculate key metrics like average response time, resolution time, and SLA compliance rates
2. **Identify trends and patterns** - Use time series analysis to spot ticket volume spikes, seasonal patterns, and anomalies
3. **Measure team performance** - Aggregate data by team, agent, or channel to understand productivity and quality
4. **Ensure data quality** - Validate data, handle missing values, and standardize formats before analysis
5. **Automate reporting** - Create reproducible analysis pipelines that run on schedule to generate regular reports
6. **Integrate with databases** - Connect directly to PostgreSQL to load fresh data and persist results

## Installation

### Prerequisites

- Python 3.8 or higher
- pip package manager
- PostgreSQL (for database integration)

### Basic Installation

```bash
pip install pandas numpy
```

### Full Installation for Customer Support Analytics

Install pandas with all dependencies needed for customer support operations:

```bash
pip install pandas>=2.2.0 \
            numpy>=1.26.0 \
            sqlalchemy>=2.0.0 \
            psycopg2-binary>=2.9.0 \
            openpyxl>=3.1.0 \
            xlrd>=2.0.0 \
            pytest>=8.0.0 \
            pyarrow>=15.0.0
```

### Verify Installation

```python
import pandas as pd
import numpy as np
import sqlalchemy

print(f"pandas version: {pd.__version__}")
print(f"numpy version: {np.__version__}")
print(f"sqlalchemy version: {sqlalchemy.__version__}")
```

## Quick Start Guide

### 1. Loading Ticket Data from CSV

```python
import pandas as pd

# Load ticket data
tickets = pd.read_csv(
    'tickets.csv',
    parse_dates=['created_at', 'resolved_at', 'first_response_at'],
    dtype={
        'priority': 'category',
        'status': 'category',
        'channel': 'category'
    }
)

# Display basic information
print(f"Total tickets: {len(tickets)}")
print(f"Date range: {tickets['created_at'].min()} to {tickets['created_at'].max()}")
print(f"\nFirst few rows:")
print(tickets.head())
```

### 2. Calculate Basic Metrics

```python
# Calculate response and resolution times
tickets['response_time_hours'] = (
    tickets['first_response_at'] - tickets['created_at']
).dt.total_seconds() / 3600

tickets['resolution_time_hours'] = (
    tickets['resolved_at'] - tickets['created_at']
).dt.total_seconds() / 3600

# Calculate average metrics
avg_response = tickets['response_time_hours'].mean()
avg_resolution = tickets['resolution_time_hours'].mean()

print(f"Average response time: {avg_response:.2f} hours")
print(f"Average resolution time: {avg_resolution:.2f} hours")
```

### 3. Analyze SLA Compliance

```python
# Define SLA targets by priority
sla_targets = {
    'critical': 1,   # 1 hour
    'high': 4,       # 4 hours
    'medium': 8,     # 8 hours
    'low': 24        # 24 hours
}

# Map SLA targets to tickets
tickets['sla_target'] = tickets['priority'].map(sla_targets)

# Check SLA compliance
tickets['sla_met'] = tickets['response_time_hours'] <= tickets['sla_target']

# Calculate compliance rate by priority
compliance = tickets.groupby('priority').agg({
    'sla_met': ['sum', 'count', 'mean']
})

print("SLA Compliance by Priority:")
print(compliance)
```

### 4. Group by Team and Agent

```python
# Calculate team metrics
team_metrics = tickets.groupby('team').agg({
    'ticket_id': 'count',
    'response_time_hours': 'mean',
    'resolution_time_hours': 'mean',
    'sla_met': 'mean',
    'csat_score': 'mean'
}).round(2)

print("\nTeam Performance Metrics:")
print(team_metrics)

# Top performing agents
top_agents = tickets.groupby('agent_name').agg({
    'ticket_id': 'count',
    'csat_score': 'mean'
}).sort_values('csat_score', ascending=False).head(10)

print("\nTop 10 Agents by CSAT:")
print(top_agents)
```

### 5. Time Series Analysis

```python
# Daily ticket volume
daily_volume = tickets.set_index('created_at').resample('D')['ticket_id'].count()

# Calculate 7-day moving average
daily_volume_ma = daily_volume.rolling(7).mean()

print("\nDaily Ticket Volume (Last 7 Days):")
print(daily_volume.tail(7))

print("\n7-Day Moving Average (Last 7 Days):")
print(daily_volume_ma.tail(7))
```

### 6. Export Results

```python
# Export to Excel with multiple sheets
with pd.ExcelWriter('support_report.xlsx', engine='openpyxl') as writer:
    team_metrics.to_excel(writer, sheet_name='Team Metrics')
    top_agents.to_excel(writer, sheet_name='Top Agents')
    compliance.to_excel(writer, sheet_name='SLA Compliance')

print("\nReport exported to support_report.xlsx")
```

## Key Features for Support Teams

### Data Loading and Integration

**From Multiple Sources**
- **PostgreSQL**: Load ticket data directly from your support database using SQLAlchemy
- **CSV Files**: Import historical data exports from support platforms
- **Excel**: Read reports from other systems or manual data entry
- **JSON**: Process API responses from support tools like Zendesk, Intercom, or Freshdesk
- **Parquet**: Efficiently store and load large historical datasets

**Optimized Loading**
- Automatic data type inference with manual override options
- Parse dates during import for immediate time series analysis
- Chunked reading for datasets that exceed available memory
- Categorical data types for memory efficiency on high-cardinality columns

### Data Cleaning and Validation

**Handle Missing Data**
- Identify missing values with `.isnull()` and `.notna()`
- Fill missing values with appropriate defaults (e.g., 'UNASSIGNED' for agent_id)
- Forward-fill or back-fill time series gaps
- Interpolate missing numeric values

**Standardize Data**
- Normalize categorical values (e.g., 'HIGH', 'high', 'High' → 'high')
- Convert date strings to datetime objects with proper timezone handling
- Standardize column names (lowercase, underscores instead of spaces)
- Remove duplicates based on ticket_id or other unique identifiers

**Validate Data Quality**
- Check for logical inconsistencies (resolved_at before created_at)
- Detect outliers in response times or resolution times
- Verify required fields are present
- Ensure foreign key relationships (customer_id, agent_id) are valid

### Aggregation and Analysis

**GroupBy Operations**
- Group by single dimension: team, agent, priority, channel, status
- Multi-level grouping: team → agent → priority
- Custom aggregation functions for percentiles (P95, P99)
- Named aggregations for clear, readable code

**Time-Based Analysis**
- Resample to different frequencies: daily, weekly, monthly, quarterly
- Rolling window calculations for trend detection
- Business day calculations excluding weekends and holidays
- Time zone conversions for global support teams

**Pivot Tables and Cross-tabulation**
- Create executive dashboards with pivot tables
- Cross-tabulate categories vs priorities
- Multi-index pivots for complex reporting
- Add margins for totals and subtotals

### Performance Optimization

**Memory Management**
- Downcast numeric types (int64 → int32, float64 → float32)
- Use categorical data types for low-cardinality columns
- Process large datasets in chunks
- Monitor memory usage with `.memory_usage(deep=True)`

**Query Optimization**
- Use `.query()` method for complex filtering (compiles to optimized code)
- Avoid loops - use vectorized operations
- Use `.loc[]` and `.iloc[]` for efficient indexing
- Set appropriate indices for faster lookups

**Computation Speed**
- Use eval() for complex arithmetic expressions
- Leverage NumPy for mathematical operations
- Apply functions in parallel where applicable
- Cache intermediate results to avoid recomputation

### Reporting and Export

**Excel Reports**
- Multi-sheet workbooks with different views
- Formatted output with proper column widths
- Conditional formatting support via styling
- Include charts and visualizations

**CSV for Data Sharing**
- Standard format for data exchange
- Configurable delimiters and encodings
- Header options for compatibility

**JSON for APIs**
- Export metrics for dashboard consumption
- Structure data for web applications
- Include metadata and timestamps

**Parquet for Archival**
- Highly compressed columnar format
- Fast read/write performance
- Preserves data types and schemas

## Common Use Cases

### SLA Tracking and Reporting

Track first response time and resolution time SLA compliance across priorities, channels, and teams. Identify which tickets breached SLA and why.

```python
# Calculate SLA breach analysis
sla_breaches = tickets[~tickets['sla_met']].groupby(['priority', 'team']).agg({
    'ticket_id': 'count',
    'response_time_hours': 'mean'
}).sort_values('ticket_id', ascending=False)
```

### Agent Performance Dashboards

Measure individual agent productivity, quality, and efficiency. Compare agents within teams and identify coaching opportunities.

```python
# Agent performance scorecard
agent_scorecard = tickets.groupby('agent_name').agg({
    'ticket_id': 'count',
    'response_time_hours': 'mean',
    'resolution_time_hours': 'mean',
    'csat_score': 'mean',
    'sla_met': 'mean',
    'reopened': 'sum'
})
```

### Ticket Volume Forecasting

Analyze historical ticket volume patterns to forecast future demand and plan staffing levels.

```python
# Weekly ticket volume with trends
weekly_volume = tickets.set_index('created_at').resample('W')['ticket_id'].count()
weekly_volume_trend = weekly_volume.rolling(4).mean()
```

### Customer Health Analysis

Identify at-risk customers based on ticket volume, resolution times, and satisfaction scores.

```python
# Customer health metrics
customer_health = tickets.groupby('customer_id').agg({
    'ticket_id': 'count',
    'resolution_time_hours': 'mean',
    'csat_score': 'mean',
    'escalated': 'sum'
})
at_risk_customers = customer_health[
    (customer_health['csat_score'] < 3) |
    (customer_health['escalated'] > 2)
]
```

### Channel Performance Comparison

Compare performance across support channels (email, chat, phone) to optimize channel strategy.

```python
# Channel comparison
channel_metrics = tickets.groupby('channel').agg({
    'ticket_id': 'count',
    'response_time_hours': 'mean',
    'resolution_time_hours': 'mean',
    'csat_score': 'mean'
})
```

## Performance Best Practices

### 1. Load Only What You Need

Don't load entire datasets if you only need recent data. Filter at the database level when possible:

```python
# Load only last 30 days
query = "SELECT * FROM tickets WHERE created_at >= NOW() - INTERVAL '30 days'"
tickets = pd.read_sql(query, engine)
```

### 2. Use Appropriate Data Types

Reduce memory usage by 50-90% by using appropriate data types:

```python
# Before optimization: 100 MB
# After optimization: 20 MB
tickets['priority'] = tickets['priority'].astype('category')
tickets['ticket_id'] = tickets['ticket_id'].astype('int32')
```

### 3. Avoid Loops - Use Vectorization

```python
# Slow (10 seconds for 100k rows)
for idx, row in tickets.iterrows():
    tickets.at[idx, 'response_hours'] = (row['responded_at'] - row['created_at']).hours

# Fast (0.1 seconds for 100k rows)
tickets['response_hours'] = (
    tickets['responded_at'] - tickets['created_at']
).dt.total_seconds() / 3600
```

### 4. Process in Chunks for Large Datasets

```python
# Process 10 million rows without memory issues
results = []
for chunk in pd.read_csv('large_tickets.csv', chunksize=100000):
    chunk_results = process_chunk(chunk)
    results.append(chunk_results)

final_results = pd.concat(results, ignore_index=True)
```

### 5. Use Query Method for Complex Filters

```python
# Readable and optimized
high_priority_unresolved = tickets.query(
    'priority == "high" and status != "resolved" and response_time_hours > 4'
)
```

## Troubleshooting Guide

### Common Issues and Solutions

**Issue: SettingWithCopyWarning**
```python
# Problem
filtered = tickets[tickets['priority'] == 'high']
filtered['new_col'] = 'value'  # Warning!

# Solution
filtered = tickets[tickets['priority'] == 'high'].copy()
filtered['new_col'] = 'value'  # No warning
```

**Issue: Memory Error on Large Datasets**
```python
# Problem
tickets = pd.read_csv('huge_file.csv')  # Memory error!

# Solution - use chunks
chunks = []
for chunk in pd.read_csv('huge_file.csv', chunksize=50000):
    processed = process_chunk(chunk)
    chunks.append(processed)
tickets = pd.concat(chunks, ignore_index=True)
```

**Issue: Slow GroupBy Operations**
```python
# Problem - slow on large datasets
result = tickets.groupby('agent_id').apply(complex_function)

# Solution - use built-in aggregations when possible
result = tickets.groupby('agent_id').agg({
    'ticket_id': 'count',
    'response_time': 'mean'
})
```

**Issue: DateTime Parsing Errors**
```python
# Problem
tickets['created_at'] = pd.to_datetime(tickets['created_at'])  # Error on invalid dates

# Solution - coerce errors
tickets['created_at'] = pd.to_datetime(tickets['created_at'], errors='coerce')
# Then handle NaT (Not a Time) values
tickets = tickets[tickets['created_at'].notna()]
```

**Issue: Merge Produces Unexpected Results**
```python
# Problem - cartesian product from duplicate keys
result = tickets.merge(customers, on='customer_id')  # Too many rows!

# Solution - validate before merging
assert tickets['customer_id'].is_unique, "Duplicate customer_ids in tickets"
assert customers['customer_id'].is_unique, "Duplicate customer_ids in customers"
result = tickets.merge(customers, on='customer_id', validate='m:1')
```

**Issue: Timezone Confusion**
```python
# Problem - mixing timezone-aware and naive datetimes
tickets['created_at'] = pd.to_datetime(tickets['created_at'])  # Naive
now = pd.Timestamp.now(tz='UTC')  # Aware
diff = now - tickets['created_at']  # Error!

# Solution - make all timezone-aware
tickets['created_at'] = pd.to_datetime(tickets['created_at'], utc=True)
now = pd.Timestamp.now(tz='UTC')
diff = now - tickets['created_at']  # Works!
```

## Integration with Support Tech Stack

### PostgreSQL Connection

```python
from sqlalchemy import create_engine

# Create database connection
engine = create_engine('postgresql://user:password@localhost:5432/support_db')

# Load data
tickets = pd.read_sql('SELECT * FROM tickets', engine)

# Save results
metrics.to_sql('daily_metrics', engine, if_exists='replace', index=False)
```

### pytest for Data Quality Tests

```python
import pytest

def test_no_duplicate_ticket_ids(tickets_df):
    """Ensure ticket_ids are unique."""
    assert tickets_df['ticket_id'].is_unique

def test_sla_calculation_logic():
    """Verify SLA calculation is correct."""
    # Test with known values
    df = pd.DataFrame({
        'response_time': [1, 5],
        'sla_target': [2, 4]
    })
    df['sla_met'] = df['response_time'] <= df['sla_target']
    assert df['sla_met'].tolist() == [True, False]
```

### Jupyter Notebooks for Exploration

Use Jupyter notebooks for interactive data exploration and ad-hoc analysis:

```bash
pip install jupyter
jupyter notebook
```

Then create notebooks for regular reporting that can be scheduled with tools like papermill.

## Additional Resources

### Official Documentation
- pandas Documentation: https://pandas.pydata.org/docs/
- User Guide: https://pandas.pydata.org/docs/user_guide/index.html
- API Reference: https://pandas.pydata.org/docs/reference/index.html

### Learning Resources
- "Python for Data Analysis" by Wes McKinney (creator of pandas)
- pandas Tutorial: https://pandas.pydata.org/docs/getting_started/intro_tutorials/
- Real Python pandas Tutorials: https://realpython.com/learning-paths/pandas-data-science/

### Community
- pandas GitHub: https://github.com/pandas-dev/pandas
- Stack Overflow: Tag [pandas]
- pandas Discord: https://discord.gg/pandas

## Version Information

This skill is built for pandas 2.2.0 and above. Key features added in recent versions:

- **pandas 2.2.0**: Performance improvements, copy-on-write by default
- **pandas 2.1.0**: PyArrow-backed string type for better performance
- **pandas 2.0.0**: Major release with backwards incompatible changes, better NA handling

## Contributing

To suggest improvements to this skill or report issues, please consult the skill documentation and follow standard contribution practices for skill development.

## License

This skill documentation is provided as-is for customer support tech enablement. pandas itself is licensed under BSD 3-Clause License.
