# Apache Airflow Orchestration Examples

Comprehensive collection of real-world Apache Airflow patterns and examples demonstrating DAGs, operators, sensors, XComs, dynamic workflows, and production deployment strategies.

## Table of Contents

1. [ETL Pipeline Examples](#etl-pipeline-examples)
2. [Dynamic Task Generation](#dynamic-task-generation)
3. [Sensor Patterns](#sensor-patterns)
4. [Asset-Based Scheduling](#asset-based-scheduling)
5. [Branching and Conditional Logic](#branching-and-conditional-logic)
6. [XCom Communication Patterns](#xcom-communication-patterns)
7. [TaskFlow API Examples](#taskflow-api-examples)
8. [Production Deployment Patterns](#production-deployment-patterns)
9. [Error Handling and Resilience](#error-handling-and-resilience)
10. [Advanced Orchestration](#advanced-orchestration)

---

## ETL Pipeline Examples

### Example 1: Traditional ETL with PythonOperator

Classic ETL pattern using PythonOperator with manual XCom management.

```python
import json
import pendulum
from airflow.sdk import DAG
from airflow.providers.standard.operators.python import PythonOperator

def extract():
    """Extract data from source"""
    # Simulate extracting data from an API or database
    data_string = '{"1001": 301.27, "1002": 433.21, "1003": 502.22}'
    order_data = json.loads(data_string)
    return order_data

def transform(ti):
    """Transform the extracted data"""
    # Pull data from XCom
    order_data_dict = ti.xcom_pull(task_ids="extract")

    # Transform: calculate total
    total_order_value = sum(order_data_dict.values())

    # Return transformed data
    return {"total_order_value": total_order_value}

def load(ti):
    """Load transformed data to destination"""
    # Pull transformed data
    total = ti.xcom_pull(task_ids="transform")["total_order_value"]

    # Simulate loading to database or data warehouse
    print(f"Total order value is: {total:.2f}")
    print("Data loaded successfully to warehouse")

with DAG(
    dag_id="traditional_etl_pipeline",
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["etl", "example"],
) as dag:
    extract_task = PythonOperator(task_id="extract", python_callable=extract)
    transform_task = PythonOperator(task_id="transform", python_callable=transform)
    load_task = PythonOperator(task_id="load", python_callable=load)

    extract_task >> transform_task >> load_task
```

**Key Concepts:**
- Manual XCom push/pull using `ti.xcom_pull()`
- Explicit task dependency definition
- Return values automatically pushed to XCom

---

### Example 2: Modern ETL with TaskFlow API

Same ETL pattern using TaskFlow API with automatic XCom handling.

```python
from airflow.decorators import dag, task
import pendulum
import json

@dag(
    dag_id="taskflow_etl_pipeline",
    schedule=None,
    start_date=pendulum.datetime(2023, 10, 26, tz="UTC"),
    catchup=False,
    tags=["etl", "taskflow", "example"],
)
def modern_etl():
    """Modern ETL pipeline using TaskFlow API"""

    @task
    def extract():
        """Extract data from source"""
        data_string = '{"1001": 301.27, "1002": 433.21, "1003": 502.22}'
        return json.loads(data_string)

    @task
    def transform(order_data_dict):
        """Transform extracted data"""
        total_order_value = sum(order_data_dict.values())
        return {"total_order_value": total_order_value}

    @task
    def load(summary):
        """Load transformed data"""
        print(f"Total order value: {summary['total_order_value']:.2f}")
        print("Data loaded successfully")

    # Build pipeline - XComs handled automatically
    order_data = extract()
    summary = transform(order_data)
    load(summary)

modern_etl()
```

**Key Concepts:**
- Automatic XCom management
- Cleaner, more Pythonic syntax
- Function calls create dependencies automatically

---

### Example 3: Multi-Source ETL with Fan-In Pattern

Extract from multiple sources, transform each, then combine and load.

```python
from airflow.decorators import dag, task
import pendulum

@dag(
    dag_id="multi_source_etl",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["etl", "multi-source"],
)
def multi_source_pipeline():
    """ETL from multiple sources with fan-in aggregation"""

    @task
    def extract_postgres():
        """Extract from PostgreSQL"""
        # Simulate database extraction
        return {"source": "postgres", "records": 1000, "sum": 50000}

    @task
    def extract_s3():
        """Extract from S3"""
        # Simulate S3 extraction
        return {"source": "s3", "records": 500, "sum": 25000}

    @task
    def extract_api():
        """Extract from external API"""
        # Simulate API extraction
        return {"source": "api", "records": 750, "sum": 37500}

    @task
    def transform_data(data):
        """Transform individual source data"""
        return {
            "source": data["source"],
            "avg_value": data["sum"] / data["records"],
            "record_count": data["records"]
        }

    @task
    def combine_and_load(transformed_data_list):
        """Combine all transformed data and load"""
        total_records = sum(d["record_count"] for d in transformed_data_list)
        sources = [d["source"] for d in transformed_data_list]

        print(f"Combined {total_records} records from {len(sources)} sources")
        for data in transformed_data_list:
            print(f"  {data['source']}: {data['record_count']} records, "
                  f"avg value: {data['avg_value']:.2f}")

        return {"total_records": total_records, "sources": sources}

    # Extract from all sources
    postgres_data = extract_postgres()
    s3_data = extract_s3()
    api_data = extract_api()

    # Transform each source
    transformed_postgres = transform_data(postgres_data)
    transformed_s3 = transform_data(s3_data)
    transformed_api = transform_data(api_data)

    # Combine and load
    combine_and_load([transformed_postgres, transformed_s3, transformed_api])

multi_source_pipeline()
```

**Key Concepts:**
- Multiple independent extract tasks
- Parallel transformation
- Fan-in aggregation pattern
- List comprehension in final task

---

## Dynamic Task Generation

### Example 4: Dynamic Tasks from Configuration

Generate tasks dynamically based on configuration data.

```python
from airflow.sdk import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.bash import BashOperator
from datetime import datetime

# Configuration - could be loaded from file or database
PROCESSING_CONFIG = [
    {"name": "customer_data", "path": "/data/customers", "format": "parquet"},
    {"name": "order_data", "path": "/data/orders", "format": "csv"},
    {"name": "product_data", "path": "/data/products", "format": "json"},
    {"name": "inventory_data", "path": "/data/inventory", "format": "parquet"},
]

with DAG(
    dag_id="dynamic_tasks_from_config",
    start_date=datetime(2023, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["dynamic", "config-driven"],
) as dag:

    start = EmptyOperator(task_id="start")
    end = EmptyOperator(task_id="end")

    # Dynamically create tasks for each configuration
    for config in PROCESSING_CONFIG:
        task = BashOperator(
            task_id=f"process_{config['name']}",
            bash_command=f"python process_data.py --path {config['path']} --format {config['format']}"
        )

        start >> task >> end
```

**Key Concepts:**
- Configuration-driven task generation
- Loop-based dynamic creation
- Fan-out from start, fan-in to end

---

### Example 5: Dynamic Task Mapping

Use dynamic task mapping to create parallel tasks based on runtime data.

```python
from airflow.decorators import dag, task
import pendulum

@dag(
    dag_id="dynamic_task_mapping",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["dynamic", "mapping"],
)
def dynamic_mapping_example():
    """Dynamic task mapping for parallel processing"""

    @task
    def get_file_list():
        """Get list of files to process"""
        # This could query a database, API, or file system
        return [
            "sales_2023_01.csv",
            "sales_2023_02.csv",
            "sales_2023_03.csv",
            "sales_2023_04.csv",
            "sales_2023_05.csv",
        ]

    @task
    def process_file(filename):
        """Process a single file"""
        print(f"Processing {filename}")
        # Simulate processing
        record_count = len(filename) * 100  # Fake processing
        return {"file": filename, "records": record_count}

    @task
    def aggregate_results(results):
        """Aggregate all processing results"""
        total_files = len(results)
        total_records = sum(r["records"] for r in results)

        print(f"Processed {total_files} files with {total_records} total records")
        for result in results:
            print(f"  {result['file']}: {result['records']} records")

        return {"total_files": total_files, "total_records": total_records}

    # Dynamic mapping creates parallel tasks
    files = get_file_list()
    results = process_file.expand(filename=files)
    aggregate_results(results)

dynamic_mapping_example()
```

**Key Concepts:**
- `.expand()` for dynamic task mapping
- Automatic parallelization
- Results automatically collected as list
- Number of tasks determined at runtime

---

### Example 6: Mapped Task Groups

Map entire task groups for complex parallel processing.

```python
from airflow.decorators import dag, task, task_group
import pendulum

@dag(
    dag_id="mapped_task_groups",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["dynamic", "taskgroup"],
)
def mapped_taskgroup_example():
    """Map entire task groups for complex workflows"""

    @task
    def get_datasets():
        """Get list of datasets to process"""
        return ["dataset_A", "dataset_B", "dataset_C"]

    @task_group
    def process_dataset(dataset_name):
        """Task group for processing a single dataset"""

        @task
        def extract(name):
            print(f"Extracting {name}")
            return {"dataset": name, "raw_records": 1000}

        @task
        def validate(data):
            print(f"Validating {data['dataset']}")
            data["valid_records"] = int(data["raw_records"] * 0.95)
            return data

        @task
        def transform(data):
            print(f"Transforming {data['dataset']}")
            data["transformed_records"] = data["valid_records"]
            return data

        @task
        def load(data):
            print(f"Loading {data['dataset']}: {data['transformed_records']} records")
            return data

        # Build task group workflow
        extracted = extract(dataset_name)
        validated = validate(extracted)
        transformed = transform(validated)
        return load(transformed)

    @task
    def create_summary(results):
        """Create summary of all processed datasets"""
        print("Processing Summary:")
        for result in results:
            print(f"  {result['dataset']}: {result['transformed_records']} records")

    # Map task group over datasets
    datasets = get_datasets()
    results = process_dataset.expand(dataset_name=datasets)
    create_summary(results)

mapped_taskgroup_example()
```

**Key Concepts:**
- TaskGroup mapping with `.expand()`
- Complex multi-step processing per item
- Automatic aggregation of task group results
- Clean organization of parallel workflows

---

## Sensor Patterns

### Example 7: External Task Sensor

Wait for a task in another DAG to complete.

```python
from airflow.sdk import DAG
from airflow.providers.standard.sensors.external_task import ExternalTaskSensor
from airflow.operators.empty import EmptyOperator
from airflow.operators.bash import BashOperator
import pendulum

# Upstream DAG
with DAG(
    dag_id="upstream_data_processor",
    start_date=pendulum.datetime(2021, 10, 20, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["upstream"],
) as upstream_dag:

    process_data = BashOperator(
        task_id="process_daily_data",
        bash_command="echo 'Processing data for {{ ds }}'"
    )

    mark_complete = EmptyOperator(task_id="mark_complete")

    process_data >> mark_complete

# Downstream DAG - waits for upstream
with DAG(
    dag_id="downstream_report_generator",
    start_date=pendulum.datetime(2021, 10, 20, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["downstream", "sensor"],
) as downstream_dag:

    start = EmptyOperator(task_id="start")

    # Wait for upstream DAG task to complete
    wait_for_upstream = ExternalTaskSensor(
        task_id="wait_for_data_processing",
        external_dag_id="upstream_data_processor",
        external_task_id="mark_complete",
        allowed_states=["success"],
        failed_states=["failed", "skipped"],
        execution_delta=None,  # Same execution_date
        timeout=3600,  # 1 hour timeout
        poke_interval=60,  # Check every 60 seconds
    )

    generate_report = BashOperator(
        task_id="generate_report",
        bash_command="echo 'Generating report from processed data'"
    )

    end = EmptyOperator(task_id="end")

    start >> wait_for_upstream >> generate_report >> end
```

**Key Concepts:**
- Cross-DAG dependencies with ExternalTaskSensor
- Configurable timeout and poke interval
- State-based waiting (success, failed)
- Execution date alignment

---

### Example 8: Deferrable Sensor for Efficiency

Use deferrable sensors to release worker slots while waiting.

```python
from airflow.sdk import DAG
from airflow.providers.standard.sensors.external_task import ExternalTaskSensor
from airflow.operators.bash import BashOperator
import pendulum

with DAG(
    dag_id="deferrable_sensor_example",
    start_date=pendulum.datetime(2021, 10, 20, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["sensor", "deferrable"],
) as dag:

    # Traditional sensor - holds worker slot
    traditional_sensor = ExternalTaskSensor(
        task_id="traditional_wait",
        external_dag_id="upstream_dag",
        external_task_id="upstream_task",
        allowed_states=["success"],
        timeout=3600,
        poke_interval=60,
        deferrable=False,  # Blocks worker
    )

    # Deferrable sensor - releases worker slot
    deferrable_sensor = ExternalTaskSensor(
        task_id="deferrable_wait",
        external_dag_id="upstream_dag",
        external_task_id="upstream_task",
        allowed_states=["success"],
        deferrable=True,  # Releases worker, uses triggerer
    )

    process = BashOperator(
        task_id="process_data",
        bash_command="echo 'Processing after wait'"
    )

    # Use deferrable for better resource utilization
    deferrable_sensor >> process
```

**Key Concepts:**
- Deferrable sensors release worker slots
- More efficient for long waits
- Requires triggerer component
- Same functionality, better resource usage

---

### Example 9: Custom Sensor with Deferrable Support

Create a custom sensor with deferrable capability.

```python
from datetime import timedelta
from airflow.sdk import BaseSensorOperator, Context, StartTriggerArgs, DAG
from airflow.operators.bash import BashOperator
import pendulum

class WaitHoursSensor(BaseSensorOperator):
    """Custom sensor that waits for specified hours"""

    start_trigger_args = StartTriggerArgs(
        trigger_cls="airflow.providers.standard.triggers.temporal.TimeDeltaTrigger",
        trigger_kwargs={"moment": timedelta(hours=1)},
        next_method="execute_complete",
        next_kwargs=None,
        timeout=None,
    )
    start_from_trigger = True

    def __init__(
        self,
        *args,
        trigger_kwargs=None,
        start_from_trigger=True,
        **kwargs
    ):
        super().__init__(*args, **kwargs)
        if trigger_kwargs:
            self.start_trigger_args.trigger_kwargs = trigger_kwargs
        self.start_from_trigger = start_from_trigger

    def execute_complete(self, context: Context, event=None):
        """Called when trigger completes"""
        self.log.info("Wait period completed")
        return

with DAG(
    dag_id="custom_deferrable_sensor",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
) as dag:

    wait = WaitHoursSensor(
        task_id="wait_2_hours",
        trigger_kwargs={"moment": timedelta(hours=2)}
    )

    process = BashOperator(
        task_id="process_after_wait",
        bash_command="echo 'Processing after 2 hour wait'"
    )

    wait >> process
```

**Key Concepts:**
- Custom deferrable sensor implementation
- StartTriggerArgs for trigger configuration
- execute_complete callback
- Configurable wait time

---

## Asset-Based Scheduling

### Example 10: Producer-Consumer Asset Pattern

Event-driven workflow triggered by data asset updates.

```python
from airflow.sdk import DAG, Asset
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from datetime import datetime

# Define assets
customer_data_asset = Asset("s3://my-bucket/customers.parquet")
order_data_asset = Asset("s3://my-bucket/orders.parquet")

# PRODUCER DAG - Updates assets
with DAG(
    dag_id="producer_customer_orders",
    start_date=datetime(2023, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["producer", "asset"],
) as producer:

    extract_customers = BashOperator(
        task_id="extract_customers",
        bash_command="python extract_customers.py",
        outlets=[customer_data_asset]  # Marks asset as updated
    )

    extract_orders = BashOperator(
        task_id="extract_orders",
        bash_command="python extract_orders.py",
        outlets=[order_data_asset]  # Marks asset as updated
    )

# CONSUMER DAG - Triggered when BOTH assets update
with DAG(
    dag_id="consumer_customer_analytics",
    schedule=[customer_data_asset & order_data_asset],  # AND condition
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=["consumer", "asset"],
) as consumer:

    @task
    def process_customer_orders(*, triggering_asset_events):
        """Process when both assets are ready"""
        print("Processing customer analytics with fresh data")

        for event in triggering_asset_events:
            print(f"Asset updated: {event.asset.uri}")
            print(f"Update time: {event.timestamp}")

        # Process data from both sources
        print("Combining customer and order data for analytics")

    process_customer_orders()
```

**Key Concepts:**
- Asset-based event-driven scheduling
- Producer marks assets as updated with `outlets`
- Consumer triggered by asset updates
- AND logic with `&` operator
- Access to triggering asset event metadata

---

### Example 11: Complex Asset Scheduling Logic

Advanced asset scheduling with OR and AND combinations.

```python
from airflow.datasets import Dataset
from airflow.models.dag import DAG
from airflow.decorators import task
from datetime import datetime

# Define multiple data assets
daily_sales = Dataset("s3://data/daily_sales.parquet")
weekly_inventory = Dataset("s3://data/weekly_inventory.parquet")
monthly_forecast = Dataset("s3://data/monthly_forecast.parquet")

# Producer 1: Daily sales data
with DAG(
    dag_id="producer_daily_sales",
    start_date=datetime(2023, 1, 1),
    schedule="@daily",
    catchup=False,
) as producer1:

    @task(outlets=[daily_sales])
    def generate_daily_sales():
        print("Generating daily sales report")

    generate_daily_sales()

# Producer 2: Weekly inventory
with DAG(
    dag_id="producer_weekly_inventory",
    start_date=datetime(2023, 1, 1),
    schedule="@weekly",
    catchup=False,
) as producer2:

    @task(outlets=[weekly_inventory])
    def generate_weekly_inventory():
        print("Generating weekly inventory snapshot")

    generate_weekly_inventory()

# Producer 3: Monthly forecast
with DAG(
    dag_id="producer_monthly_forecast",
    start_date=datetime(2023, 1, 1),
    schedule="@monthly",
    catchup=False,
) as producer3:

    @task(outlets=[monthly_forecast])
    def generate_monthly_forecast():
        print("Generating monthly forecast")

    generate_monthly_forecast()

# Consumer with complex logic:
# Trigger when: daily_sales OR (weekly_inventory AND monthly_forecast)
with DAG(
    dag_id="consumer_complex_analytics",
    schedule=(daily_sales | (weekly_inventory & monthly_forecast)),
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=["asset", "complex-logic"],
) as complex_consumer:

    @task
    def analyze_data(*, triggering_asset_events):
        """Run analytics based on which assets triggered"""
        triggered_assets = [event.asset.uri for event in triggering_asset_events]

        print(f"Triggered by {len(triggered_assets)} asset(s):")
        for asset in triggered_assets:
            print(f"  - {asset}")

        if "s3://data/daily_sales.parquet" in triggered_assets:
            print("Running daily sales analysis")

        if all(a in triggered_assets for a in [
            "s3://data/weekly_inventory.parquet",
            "s3://data/monthly_forecast.parquet"
        ]):
            print("Running comprehensive inventory + forecast analysis")

    analyze_data()
```

**Key Concepts:**
- Complex asset logic with OR (`|`) and AND (`&`)
- Multiple producers with different schedules
- Conditional processing based on triggering assets
- Event metadata access

---

### Example 12: Asset Aliases for Flexibility

Use asset aliases for dynamic asset resolution.

```python
from airflow.datasets import Dataset, AssetAlias
from airflow.models.dag import DAG
from airflow.decorators import task
from datetime import datetime

# Producer with dynamic asset determination
with DAG(
    dag_id="producer_with_alias",
    start_date=datetime(2023, 1, 1),
    schedule="@daily",
    catchup=False,
) as alias_producer:

    @task(outlets=[AssetAlias("daily-data-output")])
    def produce_data(*, outlet_events, **context):
        """Dynamically determine which asset to update"""
        execution_date = context['ds']

        # Determine actual asset based on date
        if execution_date.endswith('01'):  # First of month
            actual_asset = Dataset("s3://bucket/monthly_data.parquet")
        else:
            actual_asset = Dataset("s3://bucket/daily_data.parquet")

        # Register the actual asset with the alias
        outlet_events[AssetAlias("daily-data-output")].add(actual_asset)

        print(f"Updated asset: {actual_asset.uri}")

    produce_data()

# Consumer depends on alias - gets actual asset at runtime
with DAG(
    dag_id="consumer_from_alias",
    schedule=AssetAlias("daily-data-output"),
    start_date=datetime(2023, 1, 1),
    catchup=False,
) as alias_consumer:

    @task
    def process_data(*, triggering_asset_events):
        """Process whichever asset was actually updated"""
        for event in triggering_asset_events:
            print(f"Processing: {event.asset.uri}")

    process_data()
```

**Key Concepts:**
- AssetAlias for flexible asset references
- Dynamic asset resolution at runtime
- Alias resolution to actual datasets
- Decoupling producer from consumer

---

## Branching and Conditional Logic

### Example 13: Branch Operator for Conditional Execution

Execute different paths based on runtime conditions.

```python
from airflow.sdk import DAG
from airflow.operators.python import BranchPythonOperator
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
import pendulum

def choose_branch(**context):
    """Decide which branch to take based on execution date"""
    execution_date = context['data_interval_start']

    # Run monthly task on first day of month
    if execution_date.day == 1:
        return 'monthly_processing'
    # Run weekly task on Mondays
    elif execution_date.weekday() == 0:
        return ['daily_processing', 'weekly_processing']
    # Run daily task on other days
    else:
        return 'daily_processing'

with DAG(
    dag_id="conditional_branching",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["branching", "conditional"],
) as dag:

    start = EmptyOperator(task_id='start')

    branch = BranchPythonOperator(
        task_id='branch_task',
        python_callable=choose_branch
    )

    daily_processing = BashOperator(
        task_id='daily_processing',
        bash_command='echo "Running daily processing for {{ ds }}"'
    )

    weekly_processing = BashOperator(
        task_id='weekly_processing',
        bash_command='echo "Running weekly processing for week of {{ ds }}"'
    )

    monthly_processing = BashOperator(
        task_id='monthly_processing',
        bash_command='echo "Running monthly processing for month of {{ ds }}"'
    )

    end = EmptyOperator(
        task_id='end',
        trigger_rule='none_failed_min_one_success'  # Run if any branch succeeded
    )

    # Set dependencies
    start >> branch >> [daily_processing, weekly_processing, monthly_processing] >> end
```

**Key Concepts:**
- BranchPythonOperator for conditional execution
- Return task_id(s) to execute
- Trigger rules for convergence points
- Date-based branching logic

---

### Example 14: Custom Branch Operator

Implement custom branching logic with BaseBranchOperator.

```python
from airflow.operators.branch import BaseBranchOperator
from airflow.sdk import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
import pendulum

class DataVolumeBranchOperator(BaseBranchOperator):
    """Branch based on data volume thresholds"""

    def __init__(self, volume_threshold=1000, **kwargs):
        super().__init__(**kwargs)
        self.volume_threshold = volume_threshold

    def choose_branch(self, context):
        """Determine branch based on data volume"""
        # Simulate checking data volume
        # In reality, query database or check file size
        import random
        data_volume = random.randint(100, 2000)

        self.log.info(f"Data volume: {data_volume}")

        if data_volume > self.volume_threshold:
            self.log.info("High volume detected - using distributed processing")
            return 'distributed_processing'
        else:
            self.log.info("Normal volume - using standard processing")
            return 'standard_processing'

with DAG(
    dag_id="custom_branch_operator",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["branching", "custom-operator"],
) as dag:

    start = EmptyOperator(task_id='start')

    check_volume = DataVolumeBranchOperator(
        task_id='check_data_volume',
        volume_threshold=1000
    )

    standard_processing = BashOperator(
        task_id='standard_processing',
        bash_command='echo "Running standard single-node processing"'
    )

    distributed_processing = BashOperator(
        task_id='distributed_processing',
        bash_command='echo "Running distributed Spark processing"'
    )

    end = EmptyOperator(
        task_id='end',
        trigger_rule='none_failed_min_one_success'
    )

    start >> check_volume >> [standard_processing, distributed_processing] >> end
```

**Key Concepts:**
- Custom operator inheriting from BaseBranchOperator
- choose_branch method for logic
- Configurable parameters
- Data-driven branching

---

## XCom Communication Patterns

### Example 15: Advanced XCom Usage with Multiple Outputs

Complex XCom patterns with multiple outputs and transformations.

```python
from airflow.decorators import dag, task
import pendulum

@dag(
    dag_id="advanced_xcom_patterns",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["xcom", "advanced"],
)
def xcom_advanced():
    """Demonstrate advanced XCom patterns"""

    @task(multiple_outputs=True)
    def extract_multiple_sources():
        """Extract data from multiple sources and return as dict"""
        return {
            'database_records': 1500,
            'api_records': 800,
            'file_records': 1200,
            'total_records': 3500
        }

    @task
    def validate_database(record_count):
        """Validate database records"""
        print(f"Validating {record_count} database records")
        valid_count = int(record_count * 0.98)  # 98% valid
        return {
            'source': 'database',
            'total': record_count,
            'valid': valid_count,
            'invalid': record_count - valid_count
        }

    @task
    def validate_api(record_count):
        """Validate API records"""
        print(f"Validating {record_count} API records")
        valid_count = int(record_count * 0.95)  # 95% valid
        return {
            'source': 'api',
            'total': record_count,
            'valid': valid_count,
            'invalid': record_count - valid_count
        }

    @task
    def validate_files(record_count):
        """Validate file records"""
        print(f"Validating {record_count} file records")
        valid_count = int(record_count * 0.97)  # 97% valid
        return {
            'source': 'files',
            'total': record_count,
            'valid': valid_count,
            'invalid': record_count - valid_count
        }

    @task
    def create_summary(db_result, api_result, file_result):
        """Create summary from all validation results"""
        total_valid = db_result['valid'] + api_result['valid'] + file_result['valid']
        total_invalid = db_result['invalid'] + api_result['invalid'] + file_result['invalid']

        summary = {
            'total_records': total_valid + total_invalid,
            'total_valid': total_valid,
            'total_invalid': total_invalid,
            'validation_rate': (total_valid / (total_valid + total_invalid)) * 100,
            'by_source': {
                'database': db_result,
                'api': api_result,
                'files': file_result
            }
        }

        print(f"\nValidation Summary:")
        print(f"Total Records: {summary['total_records']}")
        print(f"Valid: {summary['total_valid']} ({summary['validation_rate']:.2f}%)")
        print(f"Invalid: {summary['total_invalid']}")

        for source_name, source_data in summary['by_source'].items():
            print(f"\n{source_name.upper()}:")
            print(f"  Total: {source_data['total']}")
            print(f"  Valid: {source_data['valid']}")
            print(f"  Invalid: {source_data['invalid']}")

        return summary

    # Build workflow
    sources = extract_multiple_sources()

    # Validate each source in parallel
    db_validated = validate_database(sources['database_records'])
    api_validated = validate_api(sources['api_records'])
    file_validated = validate_files(sources['file_records'])

    # Create final summary
    create_summary(db_validated, api_validated, file_validated)

xcom_advanced()
```

**Key Concepts:**
- multiple_outputs=True for dictionary returns
- Access individual keys from task output
- Parallel validation tasks
- Complex aggregation from multiple XComs

---

### Example 16: XCom with External Storage

Handle large data by storing in external systems and passing references via XCom.

```python
from airflow.decorators import dag, task
import pendulum
import json

@dag(
    dag_id="xcom_external_storage",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["xcom", "s3", "large-data"],
)
def xcom_with_s3():
    """Handle large datasets by storing in S3 and passing references"""

    @task
    def extract_large_dataset():
        """Extract large dataset and store in S3"""
        # Simulate extracting large data
        large_data = {
            'records': list(range(1000000)),  # 1M records
            'metadata': {'source': 'database', 'timestamp': '2023-01-01'}
        }

        # In real implementation, use boto3 to upload to S3
        s3_path = "s3://my-bucket/data/extract_{{ ds }}.parquet"

        print(f"Extracted {len(large_data['records'])} records")
        print(f"Stored in: {s3_path}")

        # Return only the reference, not the data!
        return {
            's3_path': s3_path,
            'record_count': len(large_data['records']),
            'file_size_mb': 150.5
        }

    @task
    def transform_large_dataset(extract_metadata):
        """Transform large dataset from S3"""
        s3_path = extract_metadata['s3_path']

        print(f"Loading data from: {s3_path}")
        # In real implementation: data = load_from_s3(s3_path)

        print(f"Transforming {extract_metadata['record_count']} records")

        # Store transformed data in S3
        transformed_path = s3_path.replace('extract', 'transform')

        print(f"Stored transformed data in: {transformed_path}")

        return {
            's3_path': transformed_path,
            'record_count': extract_metadata['record_count'],
            'file_size_mb': 120.3
        }

    @task
    def load_to_warehouse(transform_metadata):
        """Load transformed data to data warehouse"""
        s3_path = transform_metadata['s3_path']

        print(f"Loading from S3: {s3_path}")
        print(f"Loading {transform_metadata['record_count']} records to warehouse")

        # Simulate loading
        print("Data successfully loaded to warehouse")

        return {
            'status': 'success',
            'records_loaded': transform_metadata['record_count'],
            'source': s3_path
        }

    # Build pipeline
    extracted = extract_large_dataset()
    transformed = transform_large_dataset(extracted)
    load_to_warehouse(transformed)

xcom_with_s3()
```

**Key Concepts:**
- Store large data externally (S3, GCS, etc.)
- Pass only metadata/references via XCom
- Keep XCom size small (< 1MB)
- File paths and metadata in XCom

---

## TaskFlow API Examples

### Example 17: TaskFlow with Virtual Environments

Isolate task dependencies using virtual environments.

```python
from airflow.decorators import dag, task
import pendulum

@dag(
    dag_id="taskflow_virtualenv",
    start_date=pendulum.datetime(2023, 10, 26, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["taskflow", "virtualenv"],
)
def virtualenv_example():
    """Use virtual environments for dependency isolation"""

    @task.virtualenv(
        requirements=["pandas==2.0.0", "numpy==1.24.0"],
        system_site_packages=False
    )
    def analyze_with_pandas():
        """Analyze data using specific pandas version"""
        import pandas as pd
        import numpy as np

        # Create sample data
        data = {
            'product': ['A', 'B', 'C', 'D', 'E'],
            'sales': [100, 200, 150, 300, 250],
            'profit': [20, 40, 30, 60, 50]
        }

        df = pd.DataFrame(data)

        # Analysis
        total_sales = df['sales'].sum()
        total_profit = df['profit'].sum()
        profit_margin = (total_profit / total_sales) * 100

        print(f"Total Sales: ${total_sales}")
        print(f"Total Profit: ${total_profit}")
        print(f"Profit Margin: {profit_margin:.2f}%")

        return {
            'total_sales': float(total_sales),
            'total_profit': float(total_profit),
            'profit_margin': float(profit_margin)
        }

    @task.virtualenv(
        requirements=["scikit-learn==1.3.0"],
        system_site_packages=False
    )
    def ml_prediction(sales_data):
        """Run ML prediction with specific sklearn version"""
        from sklearn.linear_model import LinearRegression
        import numpy as np

        # Simple prediction example
        X = np.array([[1], [2], [3], [4], [5]])
        y = np.array([100, 200, 150, 300, 250])

        model = LinearRegression()
        model.fit(X, y)

        # Predict next period
        next_period = model.predict([[6]])

        print(f"Predicted sales for next period: ${next_period[0]:.2f}")

        return {
            'predicted_sales': float(next_period[0]),
            'model_score': float(model.score(X, y))
        }

    @task
    def create_report(analysis, prediction):
        """Create final report"""
        print("\n=== SALES REPORT ===")
        print(f"Current Period Analysis:")
        print(f"  Total Sales: ${analysis['total_sales']}")
        print(f"  Total Profit: ${analysis['total_profit']}")
        print(f"  Profit Margin: {analysis['profit_margin']:.2f}%")
        print(f"\nNext Period Prediction:")
        print(f"  Predicted Sales: ${prediction['predicted_sales']:.2f}")
        print(f"  Model Confidence: {prediction['model_score']:.2%}")

    # Build workflow
    analysis_result = analyze_with_pandas()
    prediction_result = ml_prediction(analysis_result)
    create_report(analysis_result, prediction_result)

virtualenv_example()
```

**Key Concepts:**
- task.virtualenv decorator
- Isolated dependencies per task
- Different library versions per task
- Automatic environment creation

---

### Example 18: TaskFlow with Traditional Operators

Mix TaskFlow tasks with traditional operators seamlessly.

```python
from airflow.decorators import dag, task
from airflow.providers.standard.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
import pendulum

@dag(
    dag_id="mixed_taskflow_traditional",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["taskflow", "mixed"],
)
def mixed_operators():
    """Mix TaskFlow and traditional operators"""

    # Traditional BashOperator
    check_data = BashOperator(
        task_id="check_data_availability",
        bash_command="ls /data/input/*.csv | wc -l"
    )

    @task
    def get_file_list():
        """Get list of files to process"""
        # In reality, list files from directory or S3
        return ["file1.csv", "file2.csv", "file3.csv"]

    @task
    def validate_files(files):
        """Validate file integrity"""
        print(f"Validating {len(files)} files")
        valid_files = [f for f in files if 'file' in f]  # Simple validation
        return {
            'total_files': len(files),
            'valid_files': valid_files,
            'validation_rate': len(valid_files) / len(files)
        }

    # Traditional PythonOperator
    def process_function(**context):
        # Pull XCom from TaskFlow task
        validation_result = context['ti'].xcom_pull(task_ids='validate_files')
        print(f"Processing {validation_result['total_files']} files")

    process_data = PythonOperator(
        task_id="process_data",
        python_callable=process_function
    )

    @task(multiple_outputs=True)
    def generate_email_content(validation_result):
        """Generate email content from validation"""
        return {
            'subject': f"Data Processing Complete - {validation_result['total_files']} files",
            'body': f"""
                <h2>Processing Summary</h2>
                <p>Total Files: {validation_result['total_files']}</p>
                <p>Valid Files: {len(validation_result['valid_files'])}</p>
                <p>Validation Rate: {validation_result['validation_rate']:.1%}</p>
            """
        }

    # Traditional EmailOperator using TaskFlow output
    email_content = generate_email_content(validate_files(get_file_list()))

    send_email = EmailOperator(
        task_id="send_notification",
        to="team@example.com",
        subject="{{ ti.xcom_pull(task_ids='generate_email_content', key='subject') }}",
        html_content="{{ ti.xcom_pull(task_ids='generate_email_content', key='body') }}"
    )

    # Dependencies
    check_data >> get_file_list()
    process_data << validate_files(get_file_list())
    email_content >> send_email

mixed_operators()
```

**Key Concepts:**
- Mixing TaskFlow and traditional operators
- XCom between different operator types
- Template variables with XCom
- Flexible workflow composition

---

## Production Deployment Patterns

### Example 19: Production DAG with Full Error Handling

Comprehensive production-ready DAG with retries, callbacks, and monitoring.

```python
from airflow.sdk import DAG
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import pendulum

def on_failure_callback(context):
    """Called when task fails"""
    task_instance = context['task_instance']
    dag_id = context['dag'].dag_id

    print(f"ALERT: Task {task_instance.task_id} in DAG {dag_id} failed!")
    print(f"Execution date: {context['ds']}")
    print(f"Log URL: {task_instance.log_url}")

    # In production: send to Slack, PagerDuty, etc.
    # send_slack_alert(f"Task {task_instance.task_id} failed!")

def on_success_callback(context):
    """Called when task succeeds"""
    task_instance = context['task_instance']
    print(f"SUCCESS: Task {task_instance.task_id} completed successfully")

def on_retry_callback(context):
    """Called when task retries"""
    task_instance = context['task_instance']
    print(f"RETRY: Task {task_instance.task_id} is retrying (attempt {context['ti'].try_number})")

def sla_miss_callback(dag, task_list, blocking_task_list, slas, blocking_tis):
    """Called when SLA is missed"""
    print(f"SLA MISS: Tasks {task_list} missed their SLA")
    # send_sla_alert(task_list)

# Default arguments for all tasks
default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email': ['alerts@company.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
    'max_retry_delay': timedelta(hours=1),
    'sla': timedelta(hours=2),  # Task should complete within 2 hours
}

with DAG(
    dag_id="production_data_pipeline",
    default_args=default_args,
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="0 2 * * *",  # 2 AM daily
    catchup=False,
    max_active_runs=3,
    sla_miss_callback=sla_miss_callback,
    tags=["production", "critical"],
    doc_md="""
    # Production Data Pipeline

    Critical pipeline for processing daily business data.

    ## Schedule
    Runs daily at 2 AM UTC

    ## SLA
    Must complete within 2 hours

    ## Alerts
    - Failures: Email + Slack
    - SLA Miss: Email + PagerDuty
    """,
) as dag:

    @task(
        on_failure_callback=on_failure_callback,
        on_success_callback=on_success_callback,
        on_retry_callback=on_retry_callback,
    )
    def extract_critical_data():
        """Extract critical business data"""
        print("Extracting critical data from production database")
        # Simulate extraction
        return {"records": 10000, "timestamp": str(datetime.now())}

    @task(
        on_failure_callback=on_failure_callback,
        execution_timeout=timedelta(minutes=30),  # Task-specific timeout
    )
    def validate_data(data):
        """Validate extracted data"""
        print(f"Validating {data['records']} records")

        # Simulate validation
        if data['records'] < 1000:
            raise ValueError("Too few records - data quality issue!")

        return {"valid": True, "record_count": data['records']}

    @task(
        on_failure_callback=on_failure_callback,
        pool='heavy_compute',  # Use resource pool
        max_active_tis_per_dag=2,  # Limit concurrent instances
    )
    def transform_data(validation_result):
        """Transform validated data"""
        print(f"Transforming {validation_result['record_count']} records")
        # Heavy transformation logic
        return {"transformed_records": validation_result['record_count']}

    load_to_warehouse = BashOperator(
        task_id="load_to_warehouse",
        bash_command="python /scripts/load_to_warehouse.py --date {{ ds }}",
        on_failure_callback=on_failure_callback,
        on_success_callback=on_success_callback,
    )

    @task
    def data_quality_checks():
        """Run data quality checks on loaded data"""
        print("Running comprehensive data quality checks")
        # Run Great Expectations or custom checks
        return {"quality_score": 0.98, "issues": []}

    @task
    def send_success_report(transform_result, quality_result):
        """Send success report"""
        print(f"\n=== PIPELINE SUCCESS REPORT ===")
        print(f"Records Processed: {transform_result['transformed_records']}")
        print(f"Quality Score: {quality_result['quality_score']:.2%}")
        print(f"Issues Found: {len(quality_result['issues'])}")
        # Send to monitoring dashboard

    # Build pipeline
    extracted = extract_critical_data()
    validated = validate_data(extracted)
    transformed = transform_data(validated)
    transformed >> load_to_warehouse

    quality = data_quality_checks()
    load_to_warehouse >> quality

    send_success_report(transformed, quality)
```

**Key Concepts:**
- Comprehensive error handling
- Callbacks for monitoring
- SLA configuration
- Retry strategies with exponential backoff
- Resource pools
- Execution timeouts
- Detailed documentation

---

### Example 20: Kubernetes Executor Configuration

Configure tasks for Kubernetes executor with custom resources.

```python
from airflow.sdk import DAG
from airflow.decorators import task
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from kubernetes.client import models as k8s
import pendulum

with DAG(
    dag_id="kubernetes_executor_example",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["kubernetes", "production"],
) as dag:

    # Task with GPU requirement
    @task(
        executor_config={
            "pod_override": k8s.V1Pod(
                spec=k8s.V1PodSpec(
                    containers=[
                        k8s.V1Container(
                            name="base",
                            resources=k8s.V1ResourceRequirements(
                                requests={"memory": "4Gi", "cpu": "2"},
                                limits={"memory": "8Gi", "cpu": "4", "nvidia.com/gpu": "1"}
                            )
                        )
                    ]
                )
            )
        }
    )
    def train_ml_model():
        """Train ML model with GPU"""
        print("Training model on GPU")
        # ML training code
        return {"model_accuracy": 0.95}

    # Heavy memory task
    @task(
        executor_config={
            "pod_override": k8s.V1Pod(
                spec=k8s.V1PodSpec(
                    containers=[
                        k8s.V1Container(
                            name="base",
                            resources=k8s.V1ResourceRequirements(
                                requests={"memory": "16Gi", "cpu": "4"},
                                limits={"memory": "32Gi", "cpu": "8"}
                            )
                        )
                    ]
                )
            )
        }
    )
    def process_large_dataset():
        """Process large dataset requiring lots of memory"""
        print("Processing large dataset")
        return {"records_processed": 10000000}

    # Standard Kubernetes Pod Operator
    spark_job = KubernetesPodOperator(
        task_id="run_spark_job",
        name="spark-job",
        namespace="airflow",
        image="my-registry/spark:3.4.0",
        cmds=["spark-submit"],
        arguments=["--master", "k8s://https://kubernetes.default.svc", "/app/job.py"],
        resources=k8s.V1ResourceRequirements(
            requests={"memory": "8Gi", "cpu": "4"},
            limits={"memory": "16Gi", "cpu": "8"}
        ),
    )

    # Dependencies
    model_result = train_ml_model()
    data_result = process_large_dataset()

    [model_result, data_result] >> spark_job
```

**Key Concepts:**
- Kubernetes executor configuration
- Custom resource requirements
- GPU allocation
- Memory and CPU limits
- KubernetesPodOperator for complex workloads

---

## Continued in next examples...

---

**Document Version**: 1.0.0
**Last Updated**: January 2025
**Total Examples**: 20+
**Coverage**: ETL, Dynamic Tasks, Sensors, Assets, Branching, XComs, TaskFlow, Production Patterns
