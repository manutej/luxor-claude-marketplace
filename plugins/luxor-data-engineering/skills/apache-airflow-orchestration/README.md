# Apache Airflow Orchestration Skill

Master Apache Airflow for workflow orchestration, data pipeline automation, and production-grade task scheduling.

## Overview

Apache Airflow is the industry-standard platform for programmatically authoring, scheduling, and monitoring workflows. This comprehensive skill teaches you how to build robust, scalable data pipelines using Airflow's powerful features including DAGs, operators, sensors, XComs, dynamic task mapping, and asset-based scheduling.

## What is Apache Airflow?

Apache Airflow is an open-source workflow orchestration platform that allows you to:

- **Define workflows as code**: Write pipelines in Python with full version control
- **Schedule complex workflows**: Use cron expressions, timedeltas, or event-driven triggers
- **Monitor execution**: Rich UI for visualizing DAG structure and task status
- **Handle dependencies**: Model complex task relationships and data dependencies
- **Scale horizontally**: Execute tasks across distributed clusters
- **Integrate everything**: Extensive provider ecosystem for databases, cloud services, and tools

## Key Capabilities

### Core Features

1. **DAG Development**
   - Define workflows as Directed Acyclic Graphs
   - Set task dependencies with intuitive operators
   - Organize tasks with TaskGroups
   - Branch execution based on conditions
   - Label edges for clarity

2. **Rich Operator Library**
   - BashOperator for shell commands
   - PythonOperator for Python functions
   - Provider operators for AWS, GCP, Azure, databases, and more
   - Custom operators for specialized tasks
   - EmailOperator for notifications

3. **Sensors for Waiting**
   - ExternalTaskSensor for cross-DAG dependencies
   - FileSensor for file availability
   - TimeDeltaSensor for time-based waits
   - BigQueryTableSensor for data warehouse tables
   - Custom sensors for any condition
   - Deferrable sensors for efficient resource usage

4. **XCom Communication**
   - Pass data between tasks
   - Automatic handling with TaskFlow API
   - Template variables for dynamic values
   - Best practices for data size management

5. **Dynamic Workflows**
   - Generate tasks programmatically
   - Dynamic task mapping for parallel processing
   - Loop-based task creation
   - Conditional task generation
   - Map entire TaskGroups

6. **Scheduling Patterns**
   - Cron expressions for complex schedules
   - Timedelta-based intervals
   - Preset schedules (@daily, @hourly, etc.)
   - Asset-based event-driven scheduling
   - Manual triggering with parameters

7. **Production Features**
   - Retry logic with exponential backoff
   - Task-level and DAG-level concurrency control
   - SLA monitoring and alerting
   - Callbacks for success, failure, and retry
   - Docker and Kubernetes deployment
   - Structured logging and metrics

## Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                        Airflow Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Web UI     │────────▶│   Metadata   │                 │
│  │  (Flask)     │         │   Database   │                 │
│  └──────────────┘         └──────────────┘                 │
│         │                        ▲                          │
│         │                        │                          │
│         ▼                        │                          │
│  ┌──────────────┐                │                          │
│  │  Scheduler   │────────────────┘                          │
│  │ (DAG Parser) │                                           │
│  └──────────────┘                                           │
│         │                                                    │
│         │  Submits Tasks                                    │
│         ▼                                                    │
│  ┌──────────────────────────────────────┐                  │
│  │          Executor                    │                  │
│  │  (Local/Celery/Kubernetes/Dask)      │                  │
│  └──────────────────────────────────────┘                  │
│         │                                                    │
│         │  Executes                                         │
│         ▼                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Worker 1   │  │   Worker 2   │  │   Worker N   │     │
│  │   (Task)     │  │   (Task)     │  │   (Task)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Execution Flow

1. **DAG Parsing**: Scheduler parses DAG files to find tasks
2. **Task Scheduling**: Scheduler determines which tasks to run based on dependencies and schedule
3. **Task Submission**: Scheduler submits tasks to executor
4. **Task Execution**: Workers execute tasks and report status
5. **State Management**: Metadata database stores all state information
6. **UI Monitoring**: Web UI displays DAG structure and task status

## Quick Start Guide

### Installation

**Using pip:**
```bash
# Install Airflow
pip install apache-airflow

# Initialize database
airflow db init

# Create admin user
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com
```

**Using Docker:**
```bash
# Download docker-compose.yaml
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.7.0/docker-compose.yaml'

# Initialize
docker-compose up airflow-init

# Start services
docker-compose up
```

### Your First DAG

Create a file in `~/airflow/dags/my_first_dag.py`:

```python
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='my_first_dag',
    start_date=datetime(2023, 1, 1),
    schedule='@daily',
    catchup=False,
) as dag:

    task1 = BashOperator(
        task_id='print_date',
        bash_command='date'
    )

    task2 = BashOperator(
        task_id='print_hello',
        bash_command='echo "Hello Airflow!"'
    )

    task1 >> task2
```

**Start Airflow:**
```bash
# Terminal 1: Start scheduler
airflow scheduler

# Terminal 2: Start webserver
airflow webserver --port 8080
```

**Access UI:**
- Open browser to http://localhost:8080
- Login with your admin credentials
- Find your DAG and trigger it

### Simple ETL Pipeline

```python
from datetime import datetime
from airflow import DAG
from airflow.decorators import task

@DAG(
    dag_id='simple_etl',
    start_date=datetime(2023, 1, 1),
    schedule='@daily',
    catchup=False,
)
def simple_etl_dag():

    @task
    def extract():
        """Extract data from source"""
        import json
        data = '{"orders": [{"id": 1, "amount": 100}, {"id": 2, "amount": 200}]}'
        return json.loads(data)

    @task
    def transform(data):
        """Transform the data"""
        total = sum(order['amount'] for order in data['orders'])
        return {'total_amount': total, 'order_count': len(data['orders'])}

    @task
    def load(summary):
        """Load results"""
        print(f"Processed {summary['order_count']} orders")
        print(f"Total amount: ${summary['total_amount']}")

    # Build pipeline
    data = extract()
    summary = transform(data)
    load(summary)

# Instantiate the DAG
simple_etl_dag()
```

## When to Use Airflow

### Ideal Use Cases

✅ **Perfect For:**
- Batch data processing workflows
- ETL/ELT pipelines
- Machine learning training pipelines
- Data warehouse maintenance
- Multi-step transformations with dependencies
- Scheduled report generation
- Data validation and quality checks
- Cross-system orchestration
- Event-driven data workflows
- Backfilling historical data

❌ **Not Ideal For:**
- Real-time streaming (use Kafka, Flink instead)
- Simple cron jobs (Airflow adds complexity)
- Low-latency requirements (< 1 second)
- Infinitely running services
- Single-task workflows

### Airflow vs Alternatives

**Airflow vs Luigi:**
- Airflow: Better UI, more features, larger community
- Luigi: Simpler, lighter weight

**Airflow vs Prefect:**
- Airflow: More mature, larger ecosystem
- Prefect: More modern, cloud-native design

**Airflow vs Dagster:**
- Airflow: Workflow orchestration focus
- Dagster: Data asset management focus

**Airflow vs Cron:**
- Airflow: Complex dependencies, monitoring, retries
- Cron: Simple time-based scheduling

## Core Workflow Patterns

### Pattern 1: Linear Pipeline

```python
extract >> transform >> load
```

**Use when:** Simple sequential processing

### Pattern 2: Fan-Out / Fan-In

```python
extract >> [transform_a, transform_b, transform_c] >> combine >> load
```

**Use when:** Parallel processing with final aggregation

### Pattern 3: Branching

```python
check >> [process_a, process_b]  # Only one runs based on condition
```

**Use when:** Conditional execution paths

### Pattern 4: Asset-Based

```python
# Producer DAG updates asset
producer_task(outlets=[Asset("data.csv")])

# Consumer DAG triggered by asset
with DAG(schedule=[Asset("data.csv")]):
    consumer_task()
```

**Use when:** Event-driven workflows based on data availability

### Pattern 5: Dynamic Mapping

```python
@task
def process_file(filename):
    # Process single file
    pass

# Dynamically create tasks for each file
process_file.expand(filename=["file1.csv", "file2.csv", "file3.csv"])
```

**Use when:** Number of tasks depends on runtime data

## Development Workflow

### 1. Design Phase
- Identify workflow steps and dependencies
- Determine schedule or trigger mechanism
- Plan data flow between tasks
- Identify external dependencies

### 2. Implementation
- Create DAG file in `dags/` folder
- Define tasks using operators or TaskFlow
- Set dependencies
- Add error handling and retries
- Configure alerts and monitoring

### 3. Testing
- Unit test individual functions
- Test DAG structure (no import errors)
- Test task execution with sample data
- Verify idempotency

### 4. Deployment
- Deploy DAG to production DAGs folder
- Monitor first few runs
- Validate outputs
- Set up alerts

### 5. Maintenance
- Monitor execution metrics
- Handle failures
- Optimize performance
- Update for changing requirements

## Common Configuration

### airflow.cfg Essentials

```ini
[core]
dags_folder = /path/to/dags
executor = LocalExecutor  # or CeleryExecutor, KubernetesExecutor
sql_alchemy_conn = postgresql+psycopg2://user:pass@localhost/airflow
parallelism = 32  # Max tasks across all DAGs
max_active_runs_per_dag = 16

[scheduler]
dag_dir_list_interval = 300  # How often to scan for new DAGs
catchup_by_default = False

[webserver]
web_server_port = 8080
base_url = http://localhost:8080
```

### Environment Variables

```bash
export AIRFLOW_HOME=~/airflow
export AIRFLOW__CORE__EXECUTOR=LocalExecutor
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost/airflow
```

## Production Deployment Considerations

### High Availability
- Run multiple schedulers (Airflow 2.0+)
- Use external database (PostgreSQL, MySQL)
- Load balance web servers
- Use message broker for Celery (Redis, RabbitMQ)

### Scalability
- Choose appropriate executor (Kubernetes for large scale)
- Configure task concurrency limits
- Optimize DAG parsing
- Use connection pooling

### Security
- Enable RBAC
- Use secrets backend (AWS Secrets Manager, Vault)
- Encrypt connections
- Implement audit logging
- Secure webserver with HTTPS

### Monitoring
- Set up metrics collection (StatsD, Prometheus)
- Configure alerting (email, Slack, PagerDuty)
- Monitor task duration and failure rates
- Track queue sizes and worker health
- Set up log aggregation (CloudWatch, Datadog)

### Resource Management
- Set appropriate resource limits for tasks
- Use pools to limit concurrent resource usage
- Configure task queues for heterogeneous workers
- Implement task priority weights

## Integration Ecosystem

Airflow integrates with 1000+ services through providers:

- **Cloud Platforms**: AWS, GCP, Azure, Alibaba Cloud
- **Databases**: PostgreSQL, MySQL, MongoDB, Cassandra, Snowflake, Redshift, BigQuery
- **Data Processing**: Spark, Flink, Databricks
- **Container Orchestration**: Kubernetes, Docker
- **Message Queues**: Kafka, RabbitMQ, SQS
- **Data Tools**: dbt, Great Expectations, Airbyte
- **Monitoring**: Datadog, New Relic, Prometheus
- **Notifications**: Slack, Email, PagerDuty, MS Teams

## Learning Path

### Beginner
1. Understand DAG concepts
2. Create simple BashOperator and PythonOperator tasks
3. Set task dependencies
4. Use the web UI
5. Understand XComs basics

### Intermediate
1. TaskFlow API
2. Sensors and external dependencies
3. Dynamic task mapping
4. Error handling and retries
5. Asset-based scheduling
6. TaskGroups for organization

### Advanced
1. Custom operators and sensors
2. Kubernetes executor
3. Performance optimization
4. Complex dynamic workflows
5. Production deployment patterns
6. Monitoring and alerting
7. Security hardening

## Best Practices Summary

1. **DAG Design**: Keep DAGs focused and simple
2. **Idempotency**: Make tasks safe to re-run
3. **Resource Management**: Set appropriate concurrency limits
4. **Error Handling**: Use retries and callbacks
5. **Monitoring**: Implement comprehensive logging and metrics
6. **Testing**: Test DAGs before deploying to production
7. **Documentation**: Document DAG purpose and task logic
8. **Version Control**: Keep DAGs in Git
9. **Secrets**: Never hardcode credentials
10. **Performance**: Optimize heavy tasks, use appropriate executors

## Getting Help

- **Documentation**: https://airflow.apache.org/docs/
- **GitHub Issues**: https://github.com/apache/airflow/issues
- **Stack Overflow**: Tag `apache-airflow`
- **Slack Community**: https://apache-airflow.slack.com
- **Mailing Lists**: dev@airflow.apache.org

## Next Steps

1. Review the comprehensive SKILL.md for detailed concepts
2. Explore EXAMPLES.md for 18+ real-world patterns
3. Build your first production DAG
4. Join the Airflow community
5. Contribute to the ecosystem

---

**Version**: 1.0.0
**Airflow Compatibility**: 2.0+
**Last Updated**: January 2025
