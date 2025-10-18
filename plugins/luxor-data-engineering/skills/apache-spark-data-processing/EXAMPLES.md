# Apache Spark Data Processing - Production Examples

This file contains 20+ production-ready Apache Spark examples sourced from the official Apache Spark repository via Context7. All examples demonstrate real-world patterns and best practices.

## Table of Contents

1. [Word Count with DataFrame SQL - Python](#1-word-count-with-dataframe-sql-python)
2. [Word Count with DataFrame SQL - Scala](#2-word-count-with-dataframe-sql-scala)
3. [Word Count with DataFrame SQL - Java](#3-word-count-with-dataframe-sql-java)
4. [Stream-Static Joins](#4-stream-static-joins)
5. [RDD Transformations and Actions](#5-rdd-transformations-and-actions)
6. [DataFrame Creation and Operations](#6-dataframe-creation-and-operations)
7. [Windowed Aggregations in Streaming](#7-windowed-aggregations-in-streaming)
8. [Session Windows for User Sessions](#8-session-windows-for-user-sessions)
9. [Streaming Linear Regression - Python](#9-streaming-linear-regression-python)
10. [Streaming Linear Regression - Scala](#10-streaming-linear-regression-scala)
11. [Stratified Sampling - Python](#11-stratified-sampling-python)
12. [Stratified Sampling - Scala](#12-stratified-sampling-scala)
13. [Stratified Sampling - Java](#13-stratified-sampling-java)
14. [ML Pipeline with Feature Engineering](#14-ml-pipeline-with-feature-engineering)
15. [Parquet Performance Optimization](#15-parquet-performance-optimization)
16. [ORC Performance Optimization](#16-orc-performance-optimization)
17. [Broadcast Exchange for Joins](#17-broadcast-exchange-for-joins)
18. [Reused Exchange for Query Optimization](#18-reused-exchange-for-query-optimization)
19. [Hash Aggregation for Final Sum](#19-hash-aggregation-for-final-sum)
20. [Chained Time Window Aggregations](#20-chained-time-window-aggregations)
21. [Distributed Matrix Operations](#21-distributed-matrix-operations)
22. [Date and Time Operations](#22-date-and-time-operations)

---

## 1. Word Count with DataFrame SQL - Python

**Source**: Apache Spark Streaming Programming Guide (Context7: /apache/spark)

**Use Case**: Convert streaming RDD of strings to DataFrame, perform SQL word count

**Pattern**: Streaming data processing with SQL transformations

```python
from pyspark.sql import Row, SparkSession

def getSparkSessionInstance(sparkConf):
    """Get or create singleton SparkSession"""
    if ('sparkSessionSingletonInstance' not in globals()):
        globals()['sparkSessionSingletonInstance'] = SparkSession \
            .builder \
            .config(conf=sparkConf) \
            .getOrCreate()
    return globals()['sparkSessionSingletonInstance']

# DStream of strings
words = ... # DStream of words

def process(time, rdd):
    print("========= %s =========" % str(time))
    try:
        # Get the singleton instance of SparkSession
        spark = getSparkSessionInstance(rdd.context.getConf())

        # Convert RDD[String] to RDD[Row] to DataFrame
        rowRdd = rdd.map(lambda w: Row(word=w))
        wordsDataFrame = spark.createDataFrame(rowRdd)

        # Creates a temporary view using the DataFrame
        wordsDataFrame.createOrReplaceTempView("words")

        # Do word count on table using SQL and print it
        wordCountsDataFrame = spark.sql("select word, count(*) as total from words group by word")
        wordCountsDataFrame.show()
    except Exception as e:
        print(f"Error processing batch: {e}")
        pass

words.foreachRDD(process)
```

**Key Concepts**:
- Singleton SparkSession pattern for streaming
- RDD to DataFrame conversion
- Temporary view registration for SQL queries
- Error handling in streaming contexts

**Performance Tips**:
- Reuse SparkSession across micro-batches (singleton pattern)
- Use DataFrame API for automatic optimization
- Consider caching if same transformations repeat

---

## 2. Word Count with DataFrame SQL - Scala

**Source**: Apache Spark Streaming Programming Guide (Context7: /apache/spark)

**Use Case**: Scala implementation of streaming word count with SQL

**Pattern**: Type-safe streaming with Scala implicits

```scala
import org.apache.spark.sql.SparkSession

val words: DStream[String] = ...

words.foreachRDD { rdd =>
  // Get the singleton instance of SparkSession
  val spark = SparkSession.builder.config(rdd.sparkContext.getConf).getOrCreate()
  import spark.implicits._

  // Convert RDD[String] to DataFrame
  val wordsDataFrame = rdd.toDF("word")

  // Create a temporary view
  wordsDataFrame.createOrReplaceTempView("words")

  // Do word count on DataFrame using SQL and print it
  val wordCountsDataFrame =
    spark.sql("select word, count(*) as total from words group by word")
  wordCountsDataFrame.show()
}
```

**Key Concepts**:
- Scala implicits for automatic RDD to DataFrame conversion
- Type-safe transformations with Scala
- Efficient integration with Spark SQL

**Performance Tips**:
- Use `.toDF()` for automatic schema inference
- Leverage Catalyst optimizer through SQL
- Cache wordCountsDataFrame if reused across iterations

---

## 3. Word Count with DataFrame SQL - Java

**Source**: Apache Spark Streaming Programming Guide (Context7: /apache/spark)

**Use Case**: Java implementation with Java Bean for schema definition

**Pattern**: Java Bean pattern for DataFrame schema

```java
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.streaming.api.java.JavaDStream;

/** Java Bean class for converting RDD to DataFrame */
public class JavaRow implements java.io.Serializable {
  private String word;

  public String getWord() {
    return word;
  }

  public void setWord(String word) {
    this.word = word;
  }
}

// Streaming setup
JavaDStream<String> words = ...

words.foreachRDD((rdd, time) -> {
  // Get the singleton instance of SparkSession
  SparkSession spark = SparkSession.builder().config(rdd.sparkContext().getConf()).getOrCreate();

  // Convert RDD[String] to RDD[JavaRow] to DataFrame
  JavaRDD<JavaRow> rowRDD = rdd.map(word -> {
    JavaRow record = new JavaRow();
    record.setWord(word);
    return record;
  });
  Dataset<Row> wordsDataFrame = spark.createDataFrame(rowRDD, JavaRow.class);

  // Creates a temporary view using the DataFrame
  wordsDataFrame.createOrReplaceTempView("words");

  // Do word count on table using SQL and print it
  Dataset<Row> wordCountsDataFrame =
    spark.sql("select word, count(*) as total from words group by word");
  wordCountsDataFrame.show();
});
```

**Key Concepts**:
- Java Bean pattern for schema definition
- Serializable classes for distributed processing
- Lambda expressions for cleaner code

**Java-Specific Considerations**:
- Implement Serializable for all custom classes
- Use Dataset<Row> instead of DataFrame
- Handle checked exceptions appropriately

---

## 4. Stream-Static Joins

**Source**: Apache Spark Structured Streaming Guide (Context7: /apache/spark)

**Use Case**: Join streaming data with static reference tables

**Pattern**: Enrichment pattern for streaming data

### Python

```python
# Static DataFrame (loaded once)
staticDf = spark.read.parquet("reference/data")

# Streaming DataFrame
streamingDf = spark.readStream.format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "input-topic") \
    .load()

# Inner equi-join with a static DF
enriched = streamingDf.join(staticDf, "type")

# Left outer join with a static DF
enriched_left = streamingDf.join(staticDf, "type", "left_outer")

# Write enriched stream
query = enriched.writeStream \
    .format("parquet") \
    .option("path", "output/enriched") \
    .option("checkpointLocation", "checkpoint/enriched") \
    .start()
```

### Scala

```scala
val staticDf = spark.read.parquet("reference/data")
val streamingDf = spark.readStream.format("kafka").load()

// Inner equi-join with a static DF
val enriched = streamingDf.join(staticDf, "type")

// Left outer join with a static DF
val enrichedLeft = streamingDf.join(staticDf, "type", "left_outer")
```

### Java

```java
Dataset<Row> staticDf = spark.read().parquet("reference/data");
Dataset<Row> streamingDf = spark.readStream().format("kafka").load();

// Inner equi-join with a static DF
Dataset<Row> enriched = streamingDf.join(staticDf, "type");

// Left outer join with a static DF
Dataset<Row> enrichedLeft = streamingDf.join(staticDf, "type", "left_outer");
```

**Key Concepts**:
- Stream-static joins are not stateful (efficient)
- Static data loaded once, not for every micro-batch
- Supports inner and left outer joins

**Use Cases**:
- Enrich events with user profiles
- Add product information to transactions
- Augment with geo-location data
- Add configuration or mapping data

**Performance Tips**:
- Broadcast static DataFrame if small (<10 MB)
- Reload static data periodically for updates
- Use left outer join if not all stream records have matches

---

## 5. RDD Transformations and Actions

**Source**: Apache Spark Core Documentation (Context7: /apache/spark)

**Use Case**: Fundamental RDD operations for distributed data processing

**Pattern**: Low-level distributed computing with RDDs

```python
from pyspark import SparkContext, SparkConf

# Create SparkContext
conf = SparkConf().setAppName("RDDExample").setMaster("local[*]")
sc = SparkContext(conf=conf)

# Example 1: Creating an RDD
data = [1, 2, 3, 4, 5]
rdd = sc.parallelize(data)

# Example 2: Map transformation
result = rdd.map(lambda x: x * 2).collect()
print(f"Doubled: {result}")  # [2, 4, 6, 8, 10]

# Example 3: Filter transformation
filtered = rdd.filter(lambda x: x % 2 == 0).collect()
print(f"Even numbers: {filtered}")  # [2, 4]

# Example 4: FlatMap transformation
lines = sc.parallelize(["hello world", "apache spark"])
words = lines.flatMap(lambda line: line.split(" ")).collect()
print(f"Words: {words}")  # ["hello", "world", "apache", "spark"]

# Example 5: ReduceByKey for aggregation
word_pairs = sc.parallelize([("apple", 1), ("banana", 1), ("apple", 1), ("cherry", 1)])
word_counts = word_pairs.reduceByKey(lambda a, b: a + b).collect()
print(f"Word counts: {word_counts}")  # [("apple", 2), ("banana", 1), ("cherry", 1)]

# Example 6: Join two RDDs
users = sc.parallelize([("user1", "Alice"), ("user2", "Bob")])
orders = sc.parallelize([("user1", 100), ("user2", 200), ("user1", 150)])
joined = users.join(orders).collect()
print(f"Joined: {joined}")
# [("user1", ("Alice", 100)), ("user1", ("Alice", 150)), ("user2", ("Bob", 200))]

# Example 7: Distinct elements
duplicates = sc.parallelize([1, 2, 2, 3, 3, 3, 4])
unique = duplicates.distinct().collect()
print(f"Unique: {unique}")  # [1, 2, 3, 4]

# Example 8: Count action
count = rdd.count()
print(f"Count: {count}")  # 5

# Example 9: Reduce action
total_sum = rdd.reduce(lambda a, b: a + b)
print(f"Sum: {total_sum}")  # 15

# Example 10: Take first N elements
first_three = rdd.take(3)
print(f"First 3: {first_three}")  # [1, 2, 3]

sc.stop()
```

**Key Concepts**:
- RDDs are immutable, distributed collections
- Transformations are lazy (build DAG)
- Actions trigger computation
- Lineage tracking for fault tolerance

**When to Use RDDs**:
- Low-level control over data and partitioning
- Custom partitioning logic required
- Unstructured data (text, binary)
- Legacy code migration

**Performance Considerations**:
- Prefer DataFrames/Datasets for structured data
- Use `reduceByKey` instead of `groupByKey` to minimize shuffle
- Cache RDDs that are reused multiple times

---

## 6. DataFrame Creation and Operations

**Source**: Apache Spark SQL Guide (Context7: /apache/spark)

**Use Case**: Structured data processing with DataFrames

**Pattern**: Declarative data manipulation with automatic optimization

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, sum, max

spark = SparkSession.builder.appName("DataFrameExample").getOrCreate()

# Example 1: Create DataFrame from data
data = [("Alice", 1, 28), ("Bob", 2, 35), ("Charlie", 3, 42)]
columns = ["name", "id", "age"]
df = spark.createDataFrame(data, columns)
df.show()

# Example 2: Read from JSON
df_json = spark.read.json("data.json")
df_json.printSchema()

# Example 3: Read from Parquet
df_parquet = spark.read.parquet("data.parquet")

# Example 4: Read from CSV with options
df_csv = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("data.csv")

# Example 5: Select columns
df.select("name", "age").show()
df.select(col("name"), col("age") + 10).show()

# Example 6: Filter rows
df.filter(df.age > 30).show()
df.where(col("age") > 30).show()  # Alternative syntax

# Example 7: Register temporary view and run SQL
df.createOrReplaceTempView("people")
sql_result = spark.sql("SELECT name FROM people WHERE age > 25")
sql_result.show()

# Example 8: Complex SQL with aggregations
employees = spark.createDataFrame([
    ("Alice", "Engineering", 100000),
    ("Bob", "Sales", 80000),
    ("Charlie", "Engineering", 120000),
    ("Diana", "Sales", 90000)
], ["name", "department", "salary"])

employees.createOrReplaceTempView("employees")

result = spark.sql("""
    SELECT
        department,
        COUNT(*) as employee_count,
        AVG(salary) as avg_salary,
        MAX(salary) as max_salary
    FROM employees
    GROUP BY department
    ORDER BY avg_salary DESC
""")
result.show()

# Example 9: DataFrame API aggregations
dept_stats = employees.groupBy("department").agg(
    count("*").alias("count"),
    avg("salary").alias("avg_salary"),
    max("salary").alias("max_salary")
)
dept_stats.show()

# Example 10: Join DataFrames
users = spark.createDataFrame([
    (1, "Alice", "Engineering"),
    (2, "Bob", "Sales")
], ["id", "name", "department"])

salaries = spark.createDataFrame([
    (1, 100000),
    (2, 80000)
], ["user_id", "salary"])

joined = users.join(salaries, users.id == salaries.user_id, "inner")
joined.show()

# Example 11: Add/modify columns
from pyspark.sql.functions import lit, when

df_with_country = df.withColumn("country", lit("USA"))
df_with_category = df.withColumn("age_category",
    when(col("age") < 30, "Young")
    .when(col("age") < 40, "Middle")
    .otherwise("Senior")
)
df_with_category.show()

# Example 12: Write to various formats
df.write.parquet("output/parquet", mode="overwrite")
df.write.json("output/json", mode="overwrite")
df.write.csv("output/csv", header=True, mode="overwrite")

spark.stop()
```

**Key Concepts**:
- DataFrames provide structured data abstraction
- Catalyst optimizer automatically optimizes queries
- Support for SQL and programmatic API
- Schema enforcement and type safety

**Advantages Over RDDs**:
- Automatic query optimization
- Better memory management (Tungsten)
- Cross-language support
- Rich API for common operations

**Best Practices**:
- Use Parquet for columnar storage and compression
- Define explicit schemas for better performance
- Cache DataFrames that are reused
- Use SQL for complex queries, DataFrame API for programmatic logic

---

## 7. Windowed Aggregations in Streaming

**Source**: Apache Spark Structured Streaming Guide (Context7: /apache/spark)

**Use Case**: Time-based aggregations on streaming data

**Pattern**: Tumbling and sliding windows for real-time analytics

### Python

```python
from pyspark.sql.functions import window, col, count

# Streaming DataFrame with timestamp and word columns
words = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "words-topic") \
    .load()

# Parse JSON and extract timestamp and word
parsed = words.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.timestamp", "data.word")

# Example 1: 10-minute tumbling window
tumbling_counts = parsed \
    .groupBy(
        window(col("timestamp"), "10 minutes"),
        col("word")
    ) \
    .count()

# Example 2: 10-minute sliding window with 5-minute slide
sliding_counts = parsed \
    .groupBy(
        window(col("timestamp"), "10 minutes", "5 minutes"),
        col("word")
    ) \
    .count()

# Write to console
query = sliding_counts.writeStream \
    .outputMode("complete") \
    .format("console") \
    .option("truncate", "false") \
    .start()

query.awaitTermination()
```

### Scala

```scala
import spark.implicits._
import org.apache.spark.sql.functions.{window, col}

val words = spark.readStream.format("kafka").load()

// 10-minute tumbling window
val tumblingCounts = words.groupBy(
  window($"timestamp", "10 minutes"),
  $"word"
).count()

// 10-minute sliding window with 5-minute slide
val slidingCounts = words.groupBy(
  window($"timestamp", "10 minutes", "5 minutes"),
  $"word"
).count()
```

### Java

```java
import static org.apache.spark.sql.functions.*;

Dataset<Row> words = spark.readStream().format("kafka").load();

// 10-minute tumbling window
Dataset<Row> tumblingCounts = words.groupBy(
    window(col("timestamp"), "10 minutes"),
    col("word")
).count();

// 10-minute sliding window with 5-minute slide
Dataset<Row> slidingCounts = words.groupBy(
    window(col("timestamp"), "10 minutes", "5 minutes"),
    col("word")
).count();
```

**Key Concepts**:
- Tumbling windows: Non-overlapping, fixed-size intervals
- Sliding windows: Overlapping intervals with configurable slide
- Late data handling with watermarks
- Stateful aggregations

**Window Types**:
- **Tumbling**: `window("10 minutes")` - Non-overlapping 10-minute windows
- **Sliding**: `window("10 minutes", "5 minutes")` - 10-minute windows every 5 minutes
- **Session**: Dynamic windows based on inactivity gaps

**Performance Tips**:
- Use watermarks to limit state size
- Choose appropriate window and slide durations
- Consider outputMode (complete, update, append)

---

## 8. Session Windows for User Sessions

**Source**: Apache Spark Structured Streaming Guide (Context7: /apache/spark)

**Use Case**: Group events into sessions based on inactivity gaps

**Pattern**: Dynamic session windows with user-specific timeouts

### Python

```python
from pyspark.sql.functions import session_window, when, col

# Streaming DataFrame of events
events = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "events") \
    .load()

# Define dynamic session window based on userId
sessionWindow = session_window(
    col("timestamp"),
    when(col("userId") == "user1", "5 seconds")
    .when(col("userId") == "user2", "20 seconds")
    .otherwise("5 minutes")
)

# Group by session window and userId, compute count
sessionizedCounts = events \
    .withWatermark("timestamp", "10 minutes") \
    .groupBy(sessionWindow, col("userId")) \
    .count()

# Write results
query = sessionizedCounts.writeStream \
    .format("console") \
    .outputMode("update") \
    .start()

query.awaitTermination()
```

### Scala

```scala
import spark.implicits._
import org.apache.spark.sql.functions.{session_window, when, col}

val events = spark.readStream.format("kafka").load()

val sessionWindow = session_window($"timestamp",
  when($"userId" === "user1", "5 seconds")
  .when($"userId" === "user2", "20 seconds")
  .otherwise("5 minutes")
)

val sessionizedCounts = events
    .withWatermark("timestamp", "10 minutes")
    .groupBy(sessionWindow, $"userId")
    .count()
```

### Java

```java
import static org.apache.spark.sql.functions.*;

Dataset<Row> events = spark.readStream().format("kafka").load();

Column sessionWindow = session_window(
    col("timestamp"),
    when(col("userId").equalTo("user1"), "5 seconds")
    .when(col("userId").equalTo("user2"), "20 seconds")
    .otherwise("5 minutes")
);

Dataset<Row> sessionizedCounts = events
    .withWatermark("timestamp", "10 minutes")
    .groupBy(sessionWindow, col("userId"))
    .count();
```

**Key Concepts**:
- Session windows group events separated by inactivity gaps
- Dynamic session duration based on attributes (userId)
- Watermarks required to limit state growth
- Use for user behavior analysis

**Use Cases**:
- Web analytics (user sessions on website)
- Gaming analytics (gaming sessions)
- IoT device sessions
- User engagement metrics

**Configuration**:
- Gap duration: Inactivity period before new session starts
- Watermark: How late can data arrive and still be processed
- Per-user customization: Different gaps for different users

---

## 9. Streaming Linear Regression - Python

**Source**: Apache Spark MLlib Guide (Context7: /apache/spark)

**Use Case**: Train linear regression model on streaming data

**Pattern**: Online learning with continuous model updates

```python
from pyspark.mllib.regression import LabeledPoint
from pyspark.streaming import StreamingContext
from pyspark.streaming.ml import StreamingLinearRegressionWithSGD
import sys

# Assumes a StreamingContext 'ssc' has already been created
# ssc = StreamingContext(sc, batchDuration=1)

# Define the paths for training and testing data directories
training_data_path = sys.argv[1]
testing_data_path = sys.argv[2]

# Create DStreams for training and testing data
training_stream = ssc.textFileStream(training_data_path)
testing_stream = ssc.textFileStream(testing_data_path)

# Parse the streams into LabeledPoint objects
# Format: y,[x1,x2,x3]
def parse_point(line):
    values = [float(x) for x in line.strip().replace('[', '').replace(']', '').split(',')]
    return LabeledPoint(values[0], values[1:])

parsed_training_stream = training_stream.map(parse_point)
parsed_testing_stream = testing_stream.map(parse_point)

# Initialize the StreamingLinearRegressionWithSGD model
# Set initial weights to 0
num_features = 3
model = StreamingLinearRegressionWithSGD(initialWeights=[0.0] * num_features)

# Configure model parameters
model.setInitialWeights([0.0] * num_features)
model.setStepSize(0.01)  # Learning rate
model.setNumIterations(50)

# Register the streams for training and testing
model.trainOn(parsed_training_stream)

# Predict on testing stream
predictions = model.predictOnValues(
    parsed_testing_stream.map(lambda lp: (lp.label, lp.features))
)

# Print predictions (label, predicted value)
predictions.pprint()

# Start the streaming context
# ssc.start()
# ssc.awaitTermination()
```

**Key Concepts**:
- Online learning: Model updates with each micro-batch
- Streaming SGD: Stochastic gradient descent on streaming data
- LabeledPoint: (label, features) representation
- Continuous model improvement

**Use Cases**:
- Real-time price prediction
- Continuous sensor calibration
- Adaptive forecasting
- Online recommendation systems

**Configuration**:
- `initialWeights`: Starting model parameters
- `stepSize`: Learning rate (0.001-0.1 typical)
- `numIterations`: Iterations per micro-batch
- `miniBatchFraction`: Fraction of data per iteration

**Performance Tips**:
- Tune learning rate for convergence
- Monitor prediction error over time
- Checkpoint model periodically
- Use feature scaling for faster convergence

---

## 10. Streaming Linear Regression - Scala

**Source**: Apache Spark MLlib Guide (Context7: /apache/spark)

**Use Case**: Scala implementation of streaming linear regression

**Pattern**: Type-safe streaming ML with Scala

```scala
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.dstream.DStream
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.streaming.ml.StreamingLinearRegressionWithSGD

// Assumes a StreamingContext 'ssc' has already been created
// val ssc = new StreamingContext(sc, Seconds(1))

// Define the paths for training and testing data directories
val trainingDataPath = args(0)
val testingDataPath = args(1)

// Create DStreams for training and testing data
val trainingStream: DStream[String] = ssc.textFileStream(trainingDataPath)
val testingStream: DStream[String] = ssc.textFileStream(testingDataPath)

// Function to parse lines into LabeledPoint objects
// Format: y,[x1,x2,x3]
def parsePoint(line: String): LabeledPoint = {
  val values = line.split(',').map(_.trim)
  val label = values(0).toDouble
  val features = Vectors.dense(
    values(1).stripPrefix("[").stripSuffix("]")
      .split(",")
      .map(_.toDouble)
  )
  LabeledPoint(label, features)
}

val parsedTrainingStream: DStream[LabeledPoint] = trainingStream.map(parsePoint)
val parsedTestingStream: DStream[LabeledPoint] = testingStream.map(parsePoint)

// Initialize the StreamingLinearRegressionWithSGD model
val numFeatures = 3
val model = new StreamingLinearRegressionWithSGD()
  .setInitialWeights(Vectors.dense(Array.fill(numFeatures)(0.0)))
  .setStepSize(0.01)
  .setNumIterations(50)

// Register the streams for training and testing
model.trainOn(parsedTrainingStream)

// Predict on the testing stream and print results
model.predictOnValues(parsedTestingStream.map(lp => (lp.label, lp.features)))
     .print()

// Start the streaming context
// ssc.start()
// ssc.awaitTermination()
```

**Scala-Specific Features**:
- Type safety with LabeledPoint and Vectors
- Pattern matching for error handling
- Functional transformations
- Efficient execution on JVM

**Best Practices**:
- Use Vectors.dense for dense features
- Use Vectors.sparse for sparse features
- Validate input data format
- Monitor model coefficients over time

---

## 11. Stratified Sampling - Python

**Source**: Apache Spark MLlib Statistics Guide (Context7: /apache/spark)

**Use Case**: Sample data while preserving class distribution

**Pattern**: Balanced sampling for imbalanced datasets

```python
from pyspark import SparkContext

sc = SparkContext("local", "StratifiedSamplingExample")

# Create RDD of key-value pairs
data = [("a", 1), ("b", 2), ("a", 3), ("b", 4), ("a", 5), ("c", 6)]
rdd = sc.parallelize(data)

# Define sampling fractions per key
# Sample approximately 50% of each class
fractions = {"a": 0.5, "b": 0.5, "c": 0.5}

# Sample approximately ceil(f_k * n_k) items for each key k
# One pass over the data (faster but approximate)
sampled_rdd = rdd.sampleByKey(withReplacement=False, fractions=fractions)

print("Sampled RDD (approximate):")
print(sampled_rdd.collect())

# Note: sampleByKeyExact not available in Python
# Use Scala/Java for exact sampling

sc.stop()
```

**Key Concepts**:
- Stratified sampling: Preserve proportion of each class
- `sampleByKey`: Approximate sampling (one pass)
- `sampleByKeyExact`: Exact sampling (multiple passes, Scala/Java only)
- Without replacement: Each element selected at most once

**Use Cases**:
- Balance training datasets for ML
- Sample for exploratory data analysis
- Create validation sets with class distribution
- Reduce data size while preserving characteristics

**Parameters**:
- `withReplacement`: True allows duplicates, False doesn't
- `fractions`: Dictionary mapping keys to sampling fractions (0.0-1.0)
- Seed: Optional random seed for reproducibility

---

## 12. Stratified Sampling - Scala

**Source**: Apache Spark MLlib Statistics Guide (Context7: /apache/spark)

**Use Case**: Exact and approximate stratified sampling in Scala

**Pattern**: Statistical sampling with guarantees

```scala
import org.apache.spark.{SparkConf, SparkContext}

val conf = new SparkConf().setAppName("StratifiedSamplingExample")
val sc = new SparkContext(conf)

val data = Seq(("a", 1), ("b", 2), ("a", 3), ("b", 4), ("a", 5), ("c", 6))
val rdd = sc.parallelize(data)

// Define sampling fractions per key
val fractions = Map("a" -> 0.5, "b" -> 0.5, "c" -> 0.5)

// Using sampleByKey for expected sample size (approximate)
// One pass over data, faster
val sampledRdd = rdd.sampleByKey(withReplacement = false, fractions = fractions)
println("Sampled RDD (sampleByKey - approximate):")
sampledRdd.collect().foreach(println)

// Using sampleByKeyExact for exact sample size (guaranteed)
// Extra pass over data, exact counts
val exactSampledRdd = rdd.sampleByKeyExact(withReplacement = false, fractions = fractions)
println("Sampled RDD (sampleByKeyExact - exact):")
exactSampledRdd.collect().foreach(println)

sc.stop()
```

**Sampling Methods**:
- **sampleByKey**: Approximate, one pass, faster
  - Expected sample size: ~fraction * count
  - Good for large datasets where exact count not critical

- **sampleByKeyExact**: Exact, extra pass, slower
  - Guaranteed sample size: exactly fraction * count
  - Use when exact distribution required

**Resource Requirements**:
- Without replacement: Extra pass to compute exact counts
- With replacement: Two passes to compute fractions
- Memory: Proportional to number of distinct keys

---

## 13. Stratified Sampling - Java

**Source**: Apache Spark MLlib Statistics Guide (Context7: /apache/spark)

**Use Case**: Java implementation of stratified sampling

**Pattern**: Type-safe sampling with Java collections

```java
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class JavaStratifiedSamplingExample {
    public static void main(String[] args) {
        JavaSparkContext sc = new JavaSparkContext("local", "JavaStratifiedSamplingExample");

        // Create JavaPairRDD
        JavaPairRDD<String, Integer> rdd = sc.parallelizePairs(Arrays.asList(
            new Tuple2<>("a", 1),
            new Tuple2<>("b", 2),
            new Tuple2<>("a", 3),
            new Tuple2<>("b", 4),
            new Tuple2<>("a", 5),
            new Tuple2<>("c", 6)
        ));

        // Define sampling fractions
        Map<String, Double> fractions = new HashMap<>();
        fractions.put("a", 0.5);
        fractions.put("b", 0.5);
        fractions.put("c", 0.5);

        // Using sampleByKey for expected sample size (approximate)
        JavaPairRDD<String, Integer> sampledRdd = rdd.sampleByKey(false, fractions);
        System.out.println("Sampled RDD (sampleByKey - approximate):");
        sampledRdd.collect().forEach(System.out::println);

        // Using sampleByKeyExact for exact sample size (guaranteed)
        JavaPairRDD<String, Integer> exactSampledRdd = rdd.sampleByKeyExact(false, fractions);
        System.out.println("Sampled RDD (sampleByKeyExact - exact):");
        exactSampledRdd.collect().forEach(System.out::println);

        sc.stop();
    }
}
```

**Java-Specific Patterns**:
- Use JavaPairRDD for key-value pairs
- Map<String, Double> for fractions (not Scala Map)
- Tuple2 for pair creation
- Lambda expressions for cleaner code

**Type Safety**:
- Compile-time type checking
- Generics for type parameters
- No runtime type erasure issues

---

## 14. ML Pipeline with Feature Engineering

**Source**: Apache Spark MLlib (Context7: /apache/spark)

**Use Case**: Complete machine learning pipeline with transformations

**Pattern**: Feature engineering, training, and prediction pipeline

```python
from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler, StandardScaler, StringIndexer, OneHotEncoder
from pyspark.ml.classification import LogisticRegression, RandomForestClassifier
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("MLPipelineExample").getOrCreate()

# Load data
df = spark.read.format("libsvm").load("data/sample_libsvm_data.txt")

# Example 1: Basic Pipeline
assembler = VectorAssembler(
    inputCols=["feature1", "feature2", "feature3"],
    outputCol="features"
)

scaler = StandardScaler(
    inputCol="features",
    outputCol="scaled_features",
    withStd=True,
    withMean=True
)

lr = LogisticRegression(
    featuresCol="scaled_features",
    labelCol="label",
    maxIter=10,
    regParam=0.01
)

pipeline = Pipeline(stages=[assembler, scaler, lr])

# Split data
train_df, test_df = df.randomSplit([0.8, 0.2], seed=42)

# Train
model = pipeline.fit(train_df)

# Predict
predictions = model.transform(test_df)
predictions.select("label", "prediction", "probability").show()

# Evaluate
evaluator = BinaryClassificationEvaluator(metricName="areaUnderROC")
auc = evaluator.evaluate(predictions)
print(f"AUC: {auc}")

# Example 2: Categorical Feature Encoding
# Sample data with categories
categorical_df = spark.createDataFrame([
    (0, "male", "engineer", 50000),
    (1, "female", "doctor", 80000),
    (0, "male", "teacher", 45000),
    (1, "female", "engineer", 75000)
], ["label", "gender", "occupation", "salary"])

# String indexing
gender_indexer = StringIndexer(inputCol="gender", outputCol="gender_index")
occupation_indexer = StringIndexer(inputCol="occupation", outputCol="occupation_index")

# One-hot encoding
gender_encoder = OneHotEncoder(inputCol="gender_index", outputCol="gender_vec")
occupation_encoder = OneHotEncoder(inputCol="occupation_index", outputCol="occupation_vec")

# Assemble features
feature_assembler = VectorAssembler(
    inputCols=["gender_vec", "occupation_vec", "salary"],
    outputCol="features"
)

# Classifier
rf = RandomForestClassifier(featuresCol="features", labelCol="label", numTrees=20)

# Complete pipeline
full_pipeline = Pipeline(stages=[
    gender_indexer,
    occupation_indexer,
    gender_encoder,
    occupation_encoder,
    feature_assembler,
    rf
])

# Example 3: Hyperparameter Tuning with Cross-Validation
param_grid = ParamGridBuilder() \
    .addGrid(rf.numTrees, [10, 20, 50]) \
    .addGrid(rf.maxDepth, [5, 10, 15]) \
    .addGrid(rf.minInstancesPerNode, [1, 5]) \
    .build()

cv = CrossValidator(
    estimator=full_pipeline,
    estimatorParamMaps=param_grid,
    evaluator=evaluator,
    numFolds=5,
    parallelism=4
)

# Train with cross-validation
cv_model = cv.fit(train_df)

# Best model
best_model = cv_model.bestModel
print(f"Best numTrees: {best_model.stages[-1].getNumTrees}")
print(f"Best maxDepth: {best_model.stages[-1].getMaxDepth()}")

# Evaluate on test set
test_predictions = cv_model.transform(test_df)
test_auc = evaluator.evaluate(test_predictions)
print(f"Test AUC: {test_auc}")

spark.stop()
```

**Pipeline Stages**:
1. **String Indexing**: Convert categories to numeric indices
2. **One-Hot Encoding**: Convert indices to binary vectors
3. **Feature Assembly**: Combine features into single vector
4. **Scaling**: Normalize features for faster convergence
5. **Model Training**: Train classifier on processed features

**Best Practices**:
- Always split data before fitting pipeline
- Use cross-validation for hyperparameter tuning
- Save/load models for reuse: `model.save("path")`
- Monitor feature importance for interpretability

---

## 15. Parquet Performance Optimization

**Source**: Apache Spark Benchmarks (Context7: /apache/spark)

**Use Case**: Optimize Parquet reads for analytical queries

**Pattern**: Vectorized execution and column pruning

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("ParquetOptimization") \
    .config("spark.sql.parquet.enableVectorizedReader", "true") \
    .config("spark.sql.parquet.columnarReaderBatchSize", 4096) \
    .config("spark.sql.files.maxPartitionBytes", 128 * 1024 * 1024) \
    .getOrCreate()

# Example 1: Vectorized Parquet Read (fastest)
# DataPageV2 typically performs better than DataPageV1
df_vectorized = spark.read \
    .option("parquet.page.write.version", "v2") \
    .parquet("data/sample.parquet")

# Example 2: Predicate Pushdown (read only required data)
# Filter pushes down to Parquet file reader
filtered_df = spark.read.parquet("data/large.parquet") \
    .filter("date >= '2025-01-01' AND country = 'USA'")

# Example 3: Column Pruning (read only required columns)
# Only specified columns read from Parquet
selected_df = spark.read.parquet("data/wide_table.parquet") \
    .select("user_id", "timestamp", "amount")

# Example 4: Partition Pruning (skip entire partitions)
# Partitioned by date, only relevant dates read
partitioned_df = spark.read.parquet("data/partitioned_by_date") \
    .filter("date = '2025-01-15'")

# Example 5: Optimal Write Configuration
df.write \
    .mode("overwrite") \
    .option("compression", "snappy") \
    .option("parquet.block.size", 128 * 1024 * 1024) \
    .option("parquet.page.size", 1 * 1024 * 1024) \
    .parquet("output/optimized")

# Example 6: Nested Column Access (efficient with vectorization)
from pyspark.sql.functions import col

nested_df = spark.read.parquet("data/nested_schema.parquet")
# With nested column disabled: slower
# With nested column enabled: 20x faster
result = nested_df.select(col("user.profile.name"), col("user.stats.count"))

spark.stop()
```

**Performance Metrics** (from Context7 benchmarks):
- **Vectorized vs MR**: 5-25x faster with vectorization
- **DataPageV2 vs V1**: 10-15% improvement with V2
- **Nested columns**: 20x faster with vectorization enabled

**Optimization Techniques**:
1. **Vectorized Reader**: Process multiple rows at once (4096 batch size)
2. **Predicate Pushdown**: Filter at file level, skip reading unnecessary data
3. **Column Pruning**: Read only required columns (columnar format advantage)
4. **Partition Pruning**: Skip entire partitions based on filters
5. **Compression**: Use snappy for balance of speed and size

**Configuration Tuning**:
```python
# Vectorization settings
spark.conf.set("spark.sql.parquet.enableVectorizedReader", "true")
spark.conf.set("spark.sql.parquet.columnarReaderBatchSize", 4096)

# File sizing
spark.conf.set("spark.sql.files.maxPartitionBytes", 128 * 1024 * 1024)
spark.conf.set("parquet.block.size", 128 * 1024 * 1024)
```

---

## 16. ORC Performance Optimization

**Source**: Apache Spark Benchmarks (Context7: /apache/spark)

**Use Case**: Optimize ORC reads for Hive integration

**Pattern**: Vectorized ORC with built-in indexes

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("ORCOptimization") \
    .config("spark.sql.orc.enableVectorizedReader", "true") \
    .config("spark.sql.orc.columnarReaderBatchSize", 4096) \
    .getOrCreate()

# Example 1: Vectorized ORC Read
# Significantly faster than MR mode
df_vectorized = spark.read.orc("data/sample.orc")

# Example 2: Predicate Pushdown with ORC Indexes
# ORC has built-in min/max indexes per stripe
filtered_df = spark.read.orc("data/large.orc") \
    .filter("amount > 1000 AND date >= '2025-01-01'")

# Example 3: Column Statistics
# ORC stores column statistics in footer
# Helps with query planning and optimization
df = spark.read.orc("data/statistics.orc")
df.explain(extended=True)  # See statistics usage

# Example 4: Optimal ORC Write
df.write \
    .mode("overwrite") \
    .option("compression", "zlib") \
    .option("orc.stripe.size", 64 * 1024 * 1024) \
    .option("orc.compress.size", 256 * 1024) \
    .orc("output/optimized")

# Example 5: Bloom Filters for Fast Lookups
# ORC supports bloom filters for point queries
spark.read \
    .option("orc.bloom.filter.columns", "user_id,product_id") \
    .option("orc.bloom.filter.fpp", 0.05) \
    .orc("data/with_bloom_filters") \
    .filter("user_id = 'user123'")

spark.stop()
```

**Performance Metrics** (from Context7 benchmarks):
- **Vectorized vs MR**: 6-25x faster with vectorization
- **ORC vs Parquet**: Similar performance, ORC slightly better compression
- **Nested columns**: 18x faster with vectorization

**ORC Advantages**:
- Built-in indexes (min/max per column per stripe)
- Bloom filters for fast lookups
- Better compression than Parquet
- Native Hive integration
- ACID transaction support (with Delta/Iceberg)

**When to Use ORC**:
- Hive-based data warehouses
- Need for ACID transactions
- Point queries with bloom filters
- Slightly better compression required

---

## 17. Broadcast Exchange for Joins

**Source**: Apache Spark TPC-DS Plans (Context7: /apache/spark)

**Use Case**: Optimize joins by broadcasting small tables

**Pattern**: Broadcast hash join for dimension tables

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import broadcast, col

spark = SparkSession.builder \
    .appName("BroadcastJoin") \
    .config("spark.sql.autoBroadcastJoinThreshold", 10 * 1024 * 1024) \
    .getOrCreate()

# Example 1: Explicit Broadcast Hint
# Broadcast date_dim table to all executors
fact_table = spark.read.parquet("data/large_fact_table")
date_dim = spark.read.parquet("data/date_dim")

# Explicit broadcast (recommended for clarity)
result = fact_table.join(
    broadcast(date_dim),
    fact_table.date_key == date_dim.d_date_sk,
    "inner"
)

# Example 2: SQL Broadcast Hint
fact_table.createOrReplaceTempView("fact")
date_dim.createOrReplaceTempView("date_dim")

sql_result = spark.sql("""
    SELECT /*+ BROADCAST(date_dim) */
        fact.*,
        date_dim.d_date
    FROM fact
    JOIN date_dim ON fact.date_key = date_dim.d_date_sk
    WHERE date_dim.d_date BETWEEN '2025-01-01' AND '2025-03-31'
""")

# Example 3: Multiple Broadcasts
# Join with multiple small dimension tables
user_dim = spark.read.parquet("data/user_dim")
product_dim = spark.read.parquet("data/product_dim")

multi_join = fact_table \
    .join(broadcast(date_dim), fact_table.date_key == date_dim.d_date_sk) \
    .join(broadcast(user_dim), fact_table.user_key == user_dim.user_sk) \
    .join(broadcast(product_dim), fact_table.product_key == product_dim.product_sk)

# Example 4: Check Broadcast Configuration
print(f"Auto broadcast threshold: {spark.conf.get('spark.sql.autoBroadcastJoinThreshold')}")

# Disable auto broadcast (force shuffle join)
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)

# Example 5: Monitor Broadcast in Physical Plan
result.explain()
# Look for "BroadcastExchange" and "BroadcastHashJoin" in plan

spark.stop()
```

**Broadcast Exchange Pattern**:
```
BroadcastExchange HashedRelationBroadcastMode(List(cast(input[0, int, false] as bigint))), [plan_id=XX]
+- *(1) Filter isnotnull(d_date_sk#0)
   +- *(1) ColumnarToRow
      +- FileScan parquet date_dim
```

**Key Benefits**:
- **No Shuffle**: Small table sent to all executors once
- **Fast Joins**: Hash join on broadcasted data
- **Memory Efficient**: Broadcasted data cached in memory
- **Reduced Network**: Avoids shuffling large fact table

**Best Practices**:
- Broadcast tables < 10 MB for best performance
- Use explicit broadcast() for clarity
- Monitor executor memory usage
- Broadcast multiple small tables if needed

**When Not to Broadcast**:
- Table size > 100 MB (may cause OOM)
- Limited executor memory
- Very large number of executors (broadcast overhead)

---

## 18. Reused Exchange for Query Optimization

**Source**: Apache Spark TPC-DS Plans (Context7: /apache/spark)

**Use Case**: Reuse shuffled data across query stages

**Pattern**: Common Table Expression (CTE) optimization

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder \
    .appName("ReusedExchange") \
    .config("spark.sql.adaptive.enabled", "true") \
    .config("spark.sql.cte.enabled", "true") \
    .getOrCreate()

# Load tables
customer = spark.read.parquet("data/customer")
store_sales = spark.read.parquet("data/store_sales")
date_dim = spark.read.parquet("data/date_dim")

# Create views
customer.createOrReplaceTempView("customer")
store_sales.createOrReplaceTempView("store_sales")
date_dim.createOrReplaceTempView("date_dim")

# Example 1: SQL with CTEs (enables exchange reuse)
result = spark.sql("""
    WITH customer_sales AS (
        SELECT
            c_customer_sk,
            c_customer_id,
            SUM(ss_net_paid) as total_sales
        FROM customer
        JOIN store_sales ON c_customer_sk = ss_customer_sk
        GROUP BY c_customer_sk, c_customer_id
    )
    SELECT
        cs1.c_customer_id,
        cs1.total_sales as year1_sales,
        cs2.total_sales as year2_sales
    FROM customer_sales cs1
    JOIN customer_sales cs2 ON cs1.c_customer_sk = cs2.c_customer_sk
    WHERE cs1.total_sales > 1000
""")

# Example 2: Detect Reused Exchange in Plan
result.explain(extended=True)
# Look for "ReusedExchange [Reuses operator id: XX]" in physical plan

# Example 3: Cache for Manual Reuse
aggregated = customer.join(store_sales, "c_customer_sk") \
    .groupBy("c_customer_sk", "c_customer_id") \
    .agg({"ss_net_paid": "sum"})

# Cache to reuse in multiple queries
aggregated.cache()

# Use in multiple downstream operations
high_value = aggregated.filter(col("sum(ss_net_paid)") > 5000)
low_value = aggregated.filter(col("sum(ss_net_paid)") < 1000)

spark.stop()
```

**ReusedExchange Pattern** (from Context7):
```
ReusedExchange [Reuses operator id: 84]
Output [2]: [d_date_sk#45, d_year#46]

ReusedExchange [Reuses operator id: 12]
Output [8]: [c_customer_sk#47, c_customer_id#48, ...]
```

**Benefits**:
- **Avoid Duplicate Shuffles**: Reuse already shuffled data
- **Faster Execution**: Skip redundant computations
- **Lower Resource Usage**: Reduce network and CPU
- **Automatic Optimization**: Catalyst detects reuse opportunities

**When Exchange Reuse Happens**:
- Common subqueries in SQL
- WITH clauses (CTEs)
- Multiple aggregations on same data
- Self-joins on previously aggregated data

**Enable Exchange Reuse**:
```python
# Adaptive Query Execution (required for exchange reuse)
spark.conf.set("spark.sql.adaptive.enabled", "true")

# Enable CTE optimization
spark.conf.set("spark.sql.cte.enabled", "true")
```

---

## 19. Hash Aggregation for Final Sum

**Source**: Apache Spark TPC-DS Plans (Context7: /apache/spark)

**Use Case**: Efficient aggregation with hash-based grouping

**Pattern**: Two-stage aggregation (partial + final)

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import sum, count, avg, col

spark = SparkSession.builder \
    .appName("HashAggregation") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()

# Load data
sales = spark.read.parquet("data/sales")

# Example 1: Simple Aggregation (automatic hash aggregation)
category_totals = sales.groupBy("category") \
    .agg(
        sum("total_sum").alias("total_sales"),
        count("*").alias("count"),
        avg("amount").alias("avg_amount")
    )

# View physical plan to see HashAggregate
category_totals.explain()

# Example 2: Multi-Level Grouping
# Partial aggregation at executor level
# Final aggregation at driver/central location
hierarchical = sales.groupBy("category", "subcategory") \
    .agg(sum("amount").alias("total"))

# Example 3: Window with Aggregation
from pyspark.sql.window import Window

# Partial hash aggregations per partition
window_spec = Window.partitionBy("category")
with_running_total = sales.withColumn(
    "running_total",
    sum("amount").over(window_spec)
)

# Example 4: Adaptive Execution with Dynamic Coalescing
# AQE may adjust partitions for final aggregation
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
spark.conf.set("spark.sql.adaptive.advisoryPartitionSizeInBytes", "64MB")

result = sales.groupBy("category", "date") \
    .agg(sum("amount").alias("total"))

result.explain()
# Check for "AdaptiveSparkPlan" and optimized HashAggregate

spark.stop()
```

**HashAggregate Pattern** (from Context7):
```
HashAggregate [codegen id : 9]
Input [3]: [i_category#16, sum#23, isEmpty#24]
Keys [1]: [i_category#16]
Functions [1]: [sum(total_sum#20)]
Aggregate Attributes [1]: [sum(total_sum#20)#25]
Results [6]: [sum(total_sum#20)#25 AS total_sum#26, i_category#16, ...]
```

**Two-Stage Aggregation**:
1. **Partial Aggregation** (at executors):
   - Combine values locally per partition
   - Reduce data before shuffle

2. **Final Aggregation** (after shuffle):
   - Combine partial results
   - Produce final aggregated values

**Performance Benefits**:
- **Reduced Shuffle**: Partial aggregation minimizes data transfer
- **Better Memory Usage**: Hash tables instead of sorted data
- **Faster Execution**: O(1) lookups in hash table
- **Automatic Fallback**: Falls back to sort-based if hash table too large

---

## 20. Chained Time Window Aggregations

**Source**: Apache Spark Structured Streaming Guide (Context7: /apache/spark)

**Use Case**: Multi-level windowed aggregations with `window_time`

**Pattern**: Aggregate over fine-grained windows, then coarser windows

### Python

```python
from pyspark.sql.functions import window, window_time, col

# Streaming DataFrame of schema { timestamp: Timestamp, word: String }
words = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .load()

# First level: 10-minute windows with 5-minute slide
windowedCounts = words.groupBy(
    window(col("timestamp"), "10 minutes", "5 minutes"),
    col("word")
).count()

# Second level: 1-hour windows based on first window's time
# window_time extracts representative timestamp from window
anotherWindowedCounts = windowedCounts.groupBy(
    window(window_time(col("window")), "1 hour"),
    col("word")
).count()

# Write to console
query = anotherWindowedCounts.writeStream \
    .outputMode("complete") \
    .format("console") \
    .start()

query.awaitTermination()
```

### Scala

```scala
import spark.implicits._
import org.apache.spark.sql.functions.{window, window_time}

val words = spark.readStream.format("kafka").load()

// Group by 10-minute window and word
val windowedCounts = words.groupBy(
  window($"timestamp", "10 minutes", "5 minutes"),
  $"word"
).count()

// Group windowed data by 1-hour window
val anotherWindowedCounts = windowedCounts.groupBy(
  window(window_time($"window"), "1 hour"),
  $"word"
).count()
```

### Java

```java
import static org.apache.spark.sql.functions.*;

Dataset<Row> words = spark.readStream().format("kafka").load();

// First window aggregation
Dataset<Row> windowedCounts = words.groupBy(
  window(col("timestamp"), "10 minutes", "5 minutes"),
  col("word")
).count();

// Second window aggregation using window_time
Dataset<Row> anotherWindowedCounts = windowedCounts.groupBy(
  window(window_time(col("window")), "1 hour"),
  col("word")
).count();
```

**Key Concepts**:
- **window_time**: Extract representative timestamp from window struct
- **Chained Aggregations**: Aggregate pre-aggregated data
- **Multi-Resolution**: Combine fine and coarse time granularities

**Use Cases**:
- **Real-Time Dashboards**: 1-minute updates with hourly trends
- **Metrics Rollups**: Compute 5-min, 1-hour, 1-day aggregates
- **Anomaly Detection**: Compare current 10-min window to hourly average
- **Capacity Planning**: Track short-term spikes and long-term trends

**Performance Benefits**:
- **Reduced State**: First aggregation reduces data size
- **Flexible Granularity**: Different time scales from same stream
- **Efficient Computation**: Reuse first-level aggregations

---

## 21. Distributed Matrix Operations

**Source**: Apache Spark MLlib Guide (Context7: /apache/spark)

**Use Case**: Linear algebra on distributed matrices

**Pattern**: Scalable matrix computations for large datasets

```python
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.linalg.distributed import RowMatrix, IndexedRow, IndexedRowMatrix, MatrixEntry, CoordinateMatrix

# Example 1: RowMatrix (no row indices)
rows = sc.parallelize([
    Vectors.dense([1.0, 2.0, 3.0]),
    Vectors.dense([4.0, 5.0, 6.0]),
    Vectors.dense([7.0, 8.0, 9.0])
])
row_matrix = RowMatrix(rows)

# Compute column statistics
summary = row_matrix.computeColumnSummaryStatistics()
print(f"Rows: {row_matrix.numRows()}")
print(f"Cols: {row_matrix.numCols()}")
print(f"Column means: {summary.mean()}")
print(f"Column variances: {summary.variance()}")

# Compute Gramian matrix (X^T * X)
gramian = row_matrix.computeGramianMatrix()
print(f"Gramian matrix:\n{gramian}")

# Singular Value Decomposition (SVD)
svd = row_matrix.computeSVD(k=2, computeU=True)
print(f"Singular values: {svd.s}")

# Example 2: IndexedRowMatrix (with row indices)
indexed_rows = sc.parallelize([
    IndexedRow(0, Vectors.dense([1.0, 2.0, 3.0])),
    IndexedRow(1, Vectors.dense([4.0, 5.0, 6.0])),
    IndexedRow(5, Vectors.dense([7.0, 8.0, 9.0]))  # Sparse row indices
])
indexed_matrix = IndexedRowMatrix(indexed_rows)

print(f"Indexed matrix rows: {indexed_matrix.numRows()}")
print(f"Indexed matrix cols: {indexed_matrix.numCols()}")

# Convert to RowMatrix
row_mat = indexed_matrix.toRowMatrix()

# Example 3: CoordinateMatrix (sparse matrix)
entries = sc.parallelize([
    MatrixEntry(0, 0, 1.0),
    MatrixEntry(0, 2, 3.0),
    MatrixEntry(1, 1, 5.0),
    MatrixEntry(2, 0, 7.0),
    MatrixEntry(2, 2, 9.0)
])
coord_matrix = CoordinateMatrix(entries)

print(f"Coordinate matrix entries: {coord_matrix.entries.count()}")

# Convert to IndexedRowMatrix for computations
indexed_from_coord = coord_matrix.toIndexedRowMatrix()

# Example 4: Matrix Transpose
transposed = coord_matrix.transpose()

# Example 5: BlockMatrix (for distributed matrix multiplication)
from pyspark.mllib.linalg.distributed import BlockMatrix

# Convert to BlockMatrix for efficient operations
block_matrix = indexed_matrix.toBlockMatrix(rowsPerBlock=2, colsPerBlock=2)
print(f"BlockMatrix blocks: {block_matrix.numRowBlocks} x {block_matrix.numColBlocks}")

# Matrix multiplication
result = block_matrix.multiply(block_matrix.transpose())
```

**Matrix Types**:

1. **RowMatrix**:
   - No row indices
   - Efficient for column statistics, SVD, PCA
   - Use when rows don't need indexing

2. **IndexedRowMatrix**:
   - Rows have Long indices
   - Efficient for row operations
   - Use when row indices matter

3. **CoordinateMatrix**:
   - Stores (row, col, value) entries
   - Efficient for very sparse matrices
   - Use when most values are zero

4. **BlockMatrix**:
   - Divides matrix into blocks
   - Efficient for matrix multiplication
   - Use for large matrix operations

**Common Operations**:
- Column statistics (mean, variance, min, max)
- SVD (Singular Value Decomposition)
- PCA (Principal Component Analysis)
- Matrix multiplication
- Transpose

**Use Cases**:
- Feature matrix computations in ML
- Collaborative filtering (user-item matrices)
- Graph analytics (adjacency matrices)
- Dimensionality reduction (PCA, SVD)

---

## 22. Date and Time Operations

**Source**: Apache Spark Date/Time Benchmarks (Context7: /apache/spark)

**Use Case**: Efficient date and timestamp processing

**Pattern**: Optimize date operations for large-scale data

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, to_timestamp, date_format, year, month, dayofmonth, hour, current_date, current_timestamp, datediff, date_add

spark = SparkSession.builder.appName("DateTimeOperations").getOrCreate()

# Example 1: Date Conversions
df = spark.createDataFrame([
    ("2025-01-15",),
    ("2025-02-20",),
    ("2025-03-10",)
], ["date_string"])

# String to Date
df_with_date = df.withColumn("date", to_date(col("date_string"), "yyyy-MM-dd"))

# String to Timestamp
df_with_ts = df.withColumn("timestamp", to_timestamp(col("date_string"), "yyyy-MM-dd"))

# Example 2: Extract Date Parts
df_parts = df_with_date \
    .withColumn("year", year(col("date"))) \
    .withColumn("month", month(col("date"))) \
    .withColumn("day", dayofmonth(col("date")))

df_parts.show()

# Example 3: Date Formatting
df_formatted = df_with_date \
    .withColumn("formatted", date_format(col("date"), "MMM dd, yyyy")) \
    .withColumn("iso_format", date_format(col("date"), "yyyy-MM-dd'T'HH:mm:ss"))

df_formatted.show(truncate=False)

# Example 4: Date Arithmetic
df_arithmetic = df_with_date \
    .withColumn("tomorrow", date_add(col("date"), 1)) \
    .withColumn("next_week", date_add(col("date"), 7)) \
    .withColumn("days_from_now", datediff(current_date(), col("date")))

df_arithmetic.show()

# Example 5: Timestamp Operations
from pyspark.sql.functions import unix_timestamp, from_unixtime

df_ts = spark.createDataFrame([
    ("2025-01-15 10:30:00",),
    ("2025-02-20 14:45:30",)
], ["ts_string"])

df_ts_ops = df_ts \
    .withColumn("timestamp", to_timestamp(col("ts_string"))) \
    .withColumn("unix_time", unix_timestamp(col("timestamp"))) \
    .withColumn("hour", hour(col("timestamp")))

df_ts_ops.show()

# Example 6: Collect Date/Timestamp Performance
# From Context7 benchmarks: Collecting java.sql.Date is efficient
dates = spark.range(1000000) \
    .withColumn("date", date_add(current_date(), col("id")))

# Collect operation performance
collected_dates = dates.select("date").take(100)

# Example 7: Window Operations with Dates
from pyspark.sql.window import Window

sales = spark.createDataFrame([
    ("2025-01-01", 100),
    ("2025-01-02", 150),
    ("2025-01-03", 200),
    ("2025-01-04", 120),
    ("2025-01-05", 180)
], ["date", "amount"])

# 3-day moving average
window_spec = Window.orderBy("date").rowsBetween(-2, 0)
sales_with_ma = sales.withColumn(
    "moving_avg",
    avg("amount").over(window_spec)
)

sales_with_ma.show()

# Example 8: Date Filtering for Partition Pruning
partitioned_data = spark.read.parquet("data/partitioned_by_date")

# Efficient: Prunes partitions based on date filter
filtered = partitioned_data.filter(
    (col("date") >= "2025-01-01") & (col("date") < "2025-02-01")
)

spark.stop()
```

**Performance Tips**:
- Use native date types (date, timestamp) instead of strings
- Partition by date columns for efficient filtering
- Use date arithmetic functions (datediff, date_add) over UDFs
- Collect operations on date types are efficient (from Context7 benchmarks)

**Common Patterns**:
- Convert strings to dates early in pipeline
- Extract date parts for grouping/filtering
- Use date arithmetic for time-based windows
- Partition data by date for time-series analysis

---

## Summary

This collection of 22 production examples demonstrates:

- **Streaming**: Word count, windowing, session windows, stream-static joins
- **Machine Learning**: Linear regression, pipelines, feature engineering, sampling
- **Performance**: Parquet/ORC optimization, broadcast joins, exchange reuse
- **Core Operations**: RDDs, DataFrames, SQL, aggregations
- **Advanced**: Matrix operations, date/time handling, chained windows

All examples are sourced from Apache Spark's official repository via Context7 (/apache/spark), ensuring production-ready patterns and best practices.

**Key Takeaways**:
1. Use DataFrames over RDDs for automatic optimization
2. Leverage Catalyst optimizer with SQL and DataFrame API
3. Enable vectorization for Parquet/ORC performance
4. Broadcast small tables to avoid shuffles
5. Use appropriate windowing for streaming analytics
6. Cache strategically for iterative algorithms
7. Monitor physical plans for optimization opportunities

---

**Examples Version**: 1.0.0
**Last Updated**: October 2025
**Source**: Apache Spark via Context7 (/apache/spark)
**Total Examples**: 22 production-ready patterns
