---
name: kafka-stream-processing
description: Complete guide for Apache Kafka stream processing including producers, consumers, Kafka Streams, connectors, schema registry, and production deployment
tags: [kafka, streaming, event-driven, producers, consumers, kafka-streams, connectors, real-time]
tier: tier-1
---

# Kafka Stream Processing

A comprehensive skill for building event-driven applications with Apache Kafka. Master producers, consumers, Kafka Streams, connectors, schema registry, and production deployment patterns for real-time data processing at scale.

## When to Use This Skill

Use this skill when:

- Building event-driven microservices architectures
- Processing real-time data streams and event logs
- Implementing publish-subscribe messaging systems
- Creating data pipelines for analytics and ETL
- Building streaming data applications with stateful processing
- Integrating heterogeneous systems with Kafka Connect
- Implementing change data capture (CDC) patterns
- Building real-time dashboards and monitoring systems
- Processing IoT sensor data at scale
- Implementing event sourcing and CQRS patterns
- Building distributed systems requiring guaranteed message delivery
- Creating real-time recommendation engines
- Processing financial transactions with exactly-once semantics
- Building log aggregation and monitoring pipelines

## Core Concepts

### Apache Kafka Architecture

Kafka is a distributed streaming platform designed for high-throughput, fault-tolerant, real-time data processing.

**Key Components:**

1. **Topics**: Named categories for organizing messages
2. **Partitions**: Ordered, immutable sequences of records within topics
3. **Brokers**: Kafka servers that store and serve data
4. **Producers**: Applications that publish records to topics
5. **Consumers**: Applications that read records from topics
6. **Consumer Groups**: Coordinated consumers sharing workload
7. **ZooKeeper/KRaft**: Cluster coordination (ZooKeeper legacy, KRaft modern)

**Design Principles:**

```APIDOC
Kafka Design Philosophy:
  - High Throughput: Millions of messages per second
  - Low Latency: Single-digit millisecond latency
  - Durability: Replicated, persistent storage
  - Scalability: Horizontal scaling via partitions
  - Fault Tolerance: Automatic failover and recovery
  - Message Delivery Semantics: At-least-once, exactly-once support
```

### Topics and Partitions

**Topics** are logical channels for data streams. Each topic is divided into **partitions** for parallelism and scalability.

```bash
# Create a topic with 20 partitions and replication factor 3
$ bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my_topic_name \
--partitions 20 --replication-factor 3 --config x=y
```

**Partition Characteristics:**

- **Ordered**: Messages within a partition are strictly ordered
- **Immutable**: Records cannot be modified after written
- **Append-only**: New records appended to partition end
- **Retention**: Configurable retention by time or size
- **Replication**: Each partition replicated across brokers

**Adding Partitions:**

```bash
# Increase partition count (cannot decrease)
$ bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic my_topic_name \
--partitions 40
```

**Note**: Adding partitions doesn't redistribute existing data and may affect consumers using custom partitioning.

### Stream Partitions and Tasks

```html
<h3>Stream Partitions and Tasks</h3>
<p> The messaging layer of Kafka partitions data for storing and transporting it. Kafka Streams partitions data for processing it. In both cases, this partitioning is what enables data locality, elasticity, scalability, high performance, and fault tolerance. Kafka Streams uses the concepts of <b>partitions</b> and <b>tasks</b> as logical units of its parallelism model based on Kafka topic partitions. There are close links between Kafka Streams and Kafka in the context of parallelism: </p>
<ul>
<li>Each <b>stream partition</b> is a totally ordered sequence of data records and maps to a Kafka <b>topic partition</b>.</li>
<li>A <b>data record</b> in the stream maps to a Kafka <b>message</b> from that topic.</li>
<li>The <b>keys</b> of data records determine the partitioning of data in both Kafka and Kafka Streams, i.e., how data is routed to specific partitions within topics.</li>
</ul>
<p> An application's processor topology is scaled by breaking it into multiple tasks. More specifically, Kafka Streams creates a fixed number of tasks based on the input stream partitions for the application, with each task assigned a list of partitions from the input streams (i.e., Kafka topics). The assignment of partitions to tasks never changes so that each task is a fixed unit of parallelism of the application. Tasks can then instantiate their own processor topology based on the assigned partitions; they also maintain a buffer for each of its assigned partitions and process messages one-at-a-time from these record buffers. As a result stream tasks can be processed independently and in parallel without manual intervention. </p>
<p> Slightly simplified, the maximum parallelism at which your application may run is bounded by the maximum number of stream tasks, which itself is determined by maximum number of partitions of the input topic(s) the application is reading from. For example, if your input topic has 5 partitions, then you can run up to 5 applications instances. These instances will collaboratively process the topic's data. If you run a larger number of app instances than partitions of the input topic, the "excess" app instances will launch but remain idle; however, if one of the busy instances goes down, one of the idle instances will resume the former's work. </p>
<p> It is important to understand that Kafka Streams is not a resource manager, but a library that "runs" anywhere its stream processing application runs. Multiple instances of the application are executed either on the same machine, or spread across multiple machines and tasks can be distributed automatically by the library to those running application instances. The assignment of partitions to tasks never changes; if an application instance fails, all its assigned tasks will be automatically restarted on other instances and continue to consume from the same stream partitions. </p>
```

### Message Delivery Semantics

```APIDOC
Design:
  - The Producer: Design considerations.
  - The Consumer: Design considerations.
  - Message Delivery Semantics: At-least-once, at-most-once, exactly-once.
  - Using Transactions for atomic operations.
```

**At-Least-Once Delivery:**
- Producer retries until acknowledgment received
- Consumer commits offset after processing
- Risk: Duplicate processing on failures
- Use case: When duplicates are acceptable or idempotent processing

**At-Most-Once Delivery:**
- Consumer commits offset before processing
- No producer retries
- Risk: Message loss on failures
- Use case: When data loss acceptable (e.g., metrics)

**Exactly-Once Semantics (EOS):**
- Transactional writes with idempotent producers
- Consumer reads committed messages only
- Use case: Financial transactions, critical data processing

### Producer Load Balancing

```APIDOC
ProducerClient:
  publish(topic: str, message: bytes, partition_key: Optional[str] = None)
    topic: The topic to publish the message to.
    message: The message payload to send.
    partition_key: Optional key to determine the partition. If None, random partitioning is used.

  get_metadata(topic: str) -> dict
    topic: The topic to get metadata for.
    Returns: A dictionary containing broker information and partition leader details.
```

The producer directs data to the partition leader broker without a routing tier. Kafka nodes provide metadata to producers for directing requests to the correct partition leaders. Producers can implement custom partitioning logic or use random distribution.

## Producers

Kafka producers publish records to topics with configurable reliability and performance characteristics.

### Producer API

```APIDOC
Producer API:
  - send(record): Sends a record to a Kafka topic.
    - Parameters:
      - record: The record to send, including topic, key, and value.
    - Returns: A Future representing the result of the send operation.
  - flush(): Forces any buffered records to be sent.
  - close(): Closes the producer, releasing any resources.
  - metrics(): Returns metrics about the producer.

  Configuration:
  - bootstrap.servers: A list of host/port pairs to use for establishing the initial connection to the Kafka cluster.
  - key.serializer: The serializer class for key that implements the org.apache.kafka.common.serialization.Serializer interface.
  - value.serializer: The serializer class for value that implements the org.apache.kafka.common.serialization.Serializer interface.
  - acks: The number of acknowledgments the producer requires the leader to have received before considering a request complete.
  - linger.ms: The producer groups together any records that arrive in between request transmissions into a single batched request.
  - batch.size: The producer will attempt to batch records together into fewer requests whenever multiple records are being sent to the same partition.
```

### Producer Configuration

**Essential Settings:**

1. **bootstrap.servers**: Kafka cluster connection string
   - Format: `host1:9092,host2:9092,host3:9092`
   - Use multiple brokers for fault tolerance

2. **key.serializer / value.serializer**: Data serialization
   - `org.apache.kafka.common.serialization.StringSerializer`
   - `org.apache.kafka.common.serialization.ByteArraySerializer`
   - Custom serializers for complex types

3. **acks**: Acknowledgment level
   - `0`: No acknowledgment (fire and forget)
   - `1`: Leader acknowledgment only
   - `all` / `-1`: All in-sync replicas acknowledge (strongest durability)

4. **retries**: Retry count for failed sends
   - Default: 2147483647 (Integer.MAX_VALUE)
   - Set to 0 to disable retries

5. **enable.idempotence**: Exactly-once semantics
   - `true`: Enables idempotent producer (prevents duplicates)
   - `false`: Default behavior

**Performance Tuning:**

1. **linger.ms**: Batching delay
   - Default: 0 (send immediately)
   - Higher values (5-100ms) increase throughput via batching
   - Trade-off: Latency vs throughput

2. **batch.size**: Batch size in bytes
   - Default: 16384 (16KB)
   - Larger batches improve throughput
   - Maximum single batch size per partition

3. **compression.type**: Message compression
   - Options: `none`, `gzip`, `snappy`, `lz4`, `zstd`
   - Reduces network bandwidth and storage
   - CPU overhead for compression/decompression

4. **buffer.memory**: Total producer buffer memory
   - Default: 33554432 (32MB)
   - Memory for buffering unsent records
   - Producer blocks when buffer full

### Producer Example (Java)

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class SimpleProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 32768);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            ProducerRecord<String, String> record =
                new ProducerRecord<>("my-topic", "key1", "Hello Kafka!");

            // Async send with callback
            producer.send(record, (metadata, exception) -> {
                if (exception != null) {
                    System.err.println("Error producing: " + exception);
                } else {
                    System.out.printf("Sent to partition %d, offset %d%n",
                        metadata.partition(), metadata.offset());
                }
            });
        }
    }
}
```

### Producer Best Practices

1. **Use Batching**: Configure linger.ms and batch.size for throughput
2. **Enable Idempotence**: Set enable.idempotence=true for reliability
3. **Handle Errors**: Implement proper callback error handling
4. **Use Compression**: Enable compression for large messages
5. **Partition Keys**: Use meaningful keys for ordered processing
6. **Close Producers**: Always close producers in finally blocks
7. **Monitor Metrics**: Track producer metrics (record-send-rate, compression-rate)
8. **Resource Pools**: Reuse producer instances when possible

## Consumers

Kafka consumers read records from topics, supporting both individual and group-based consumption.

### Consumer Groups

Consumer groups enable parallel processing with automatic load balancing and fault tolerance.

**Key Concepts:**

- **Group ID**: Unique identifier for consumer group
- **Partition Assignment**: Each partition consumed by one consumer in group
- **Rebalancing**: Automatic reassignment when consumers join/leave
- **Offset Management**: Group tracks committed offsets per partition

**Consumer Group Monitoring:**

```bash
# List consumer groups
$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Describe consumer group members with partition assignments
$ bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --members --verbose
CONSUMER-ID HOST CLIENT-ID #PARTITIONS ASSIGNMENT
consumer1-3fc8d6f1-581a-4472-bdf3-3515b4aee8c1 /127.0.0.1 consumer1 2 topic1(0), topic2(0)
consumer4-117fe4d3-c6c1-4178-8ee9-eb4a3954bee0 /127.0.0.1 consumer4 1 topic3(2)
consumer2-e76ea8c3-5d30-4299-9005-47eb41f3d3c4 /127.0.0.1 consumer2 3 topic2(1), topic3(0,1)
consumer3-ecea43e4-1f01-479f-8349-f9130b75d8ee /127.0.0.1 consumer3 0 -
```

### Consumer Configuration

**Essential Settings:**

1. **bootstrap.servers**: Kafka cluster connection
2. **group.id**: Consumer group identifier
3. **key.deserializer / value.deserializer**: Data deserialization
4. **enable.auto.commit**: Automatic offset commits
   - `true`: Auto-commit offsets periodically
   - `false`: Manual offset management
5. **auto.offset.reset**: Behavior when no offset found
   - `earliest`: Start from beginning
   - `latest`: Start from end
   - `none`: Throw exception

**Consumer-Specific Kafka Streams Defaults:**

```APIDOC
Parameter Name: max.poll.records
Corresponding Client: Consumer
Streams Default: 100

Parameter Name: client.id
Corresponding Client: -
Streams Default: <application.id>-<random-UUID>

Parameter Name: enable.auto.commit
Description: Controls whether the consumer automatically commits offsets. When true, the consumer will automatically commit offsets periodically based on the poll interval.
Default Value: true
```

### Consumer Example (Java)

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class SimpleConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "my-consumer-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList("my-topic"));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("Partition: %d, Offset: %d, Key: %s, Value: %s%n",
                        record.partition(), record.offset(), record.key(), record.value());

                    // Process record
                    processRecord(record);
                }

                // Manual commit after processing batch
                consumer.commitSync();
            }
        }
    }

    private static void processRecord(ConsumerRecord<String, String> record) {
        // Business logic here
    }
}
```

### Consumer Offset Management

**Offset Commit Strategies:**

1. **Auto-commit (default):**
   - Simple but risky for at-least-once delivery
   - May commit before processing completes

2. **Manual Synchronous Commit:**
   - Blocks until commit succeeds
   - Guarantees offset committed before continuing
   - Lower throughput

3. **Manual Asynchronous Commit:**
   - Non-blocking commit
   - Higher throughput
   - Handle failures in callback

4. **Hybrid Approach:**
   - Async commits during processing
   - Sync commit before rebalance/shutdown

```java
// Async commit with callback
consumer.commitAsync((offsets, exception) -> {
    if (exception != null) {
        System.err.println("Commit failed: " + exception);
    }
});

// Sync commit for reliability
try {
    consumer.commitSync();
} catch (CommitFailedException e) {
    System.err.println("Commit failed: " + e);
}
```

### Consumer Best Practices

1. **Choose Right Auto-commit**: Disable for at-least-once semantics
2. **Handle Rebalancing**: Implement ConsumerRebalanceListener
3. **Process Efficiently**: Minimize poll() call duration
4. **Graceful Shutdown**: Close consumers properly
5. **Monitor Lag**: Track consumer lag metrics
6. **Partition Assignment**: Understand assignment strategies
7. **Thread Safety**: Kafka consumers are NOT thread-safe
8. **Error Handling**: Retry logic for transient failures

## Kafka Streams

Kafka Streams is a client library for building real-time streaming applications with stateful processing.

### Kafka Streams Architecture

**Processor Topology:**

```markdown
There are two special processors in the topology:
<ul>
<li><b>Source Processor</b>: A special type of stream processor that does not have any upstream processors. It produces an input stream to its topology from one or multiple Kafka topics by consuming records from these topics and forwarding them to its down-stream processors.</li>
<li><b>Sink Processor</b>: A special type of stream processor that does not have down-stream processors. It sends any received records from its up-stream processors to a specified Kafka topic.</li>
</ul>
Note that in normal processor nodes other remote systems can also be accessed while processing the current record. Therefore the processed results can either be streamed back into Kafka or written to an external system.
```

**Sub-topologies:**

Applications are decomposed into sub-topologies connected by repartition topics. Each sub-topology can scale independently.

### KStream vs KTable vs GlobalKTable

**KStream**: Immutable stream of records

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.kstream.KStream;

StreamsBuilder builder = new StreamsBuilder();
KStream<String, Long> wordCounts = builder.stream(
    "word-counts-input-topic", /* input topic */
    Consumed.with(
        Serdes.String(), /* key serde */
        Serdes.Long() /* value serde */
    )
);
```

**KTable**: Changelog stream (latest value per key)

```java
import org.apache.kafka.streams.StreamsBuilder;

StreamsBuilder builder = new StreamsBuilder();
builder.table("input-topic");
```

**GlobalKTable**: Fully replicated table available to all instances

```kafka-streams
KTable: Each application instance gets data from only 1 partition.
GlobalKTable: Each application instance gets data from all partitions.
```

### Writing Streams to Kafka

```java
KStream<String, Long> stream = ...;
// Write the stream to the output topic, using the configured default key
// and value serdes.
stream.to("my-stream-output-topic");

// Write the stream to the output topic, using explicit key and value serdes,
// (thus overriding the defaults in the config properties).
stream.to("my-stream-output-topic", Produced.with(Serdes.String(), Serdes.Long()));
```

Any streams and tables may be (continuously) written back to a Kafka topic. The output data might be re-partitioned depending on the situation.

### Repartitioning

Manual repartitioning with specified partition count:

```java
KStream<byte[], String> stream = ... ;
KStream<byte[], String> repartitionedStream = stream.repartition(Repartitioned.numberOfPartitions(10));
```

Kafka Streams manages the generated topic as an internal topic, ensuring data purging and allowing for scaling downstream sub-topologies. This operation is useful when key-changing operations are performed beforehand and auto-repartitioning is not triggered.

### Joins and Co-partitioning

```APIDOC
Join Co-partitioning Requirements:

For equi-joins in Kafka Streams, input data must be co-partitioned. This ensures that records with the same key from both sides of the join are delivered to the same stream task.

Requirements for data co-partitioning:
1. Input topics (left and right sides) must have the same number of partitions.
2. All applications writing to the input topics must use the same partitioning strategy to ensure records with the same key are delivered to the same partition number.
   - This applies to producer settings like `partitioner.class` (e.g., `ProducerConfig.PARTITIONER_CLASS_CONFIG`) and Kafka Streams `StreamPartitioner` for operations like `KStream#to()`.
   - Using default partitioner settings across all applications generally satisfies this requirement.

Why co-partitioning is required:
- KStream-KStream, KTable-KTable, and KStream-KTable joins are performed based on record keys (e.g., `leftRecord.key == rightRecord.key`). Co-partitioning by key ensures these records meet.

Exceptions where co-partitioning is NOT required:
1. KStream-GlobalKTable joins:
   - All partitions of the GlobalKTable's underlying changelog stream are available to each KafkaStreams instance.
   - A `KeyValueMapper` allows non-key based joins from KStream to GlobalKTable.
2. KTable-KTable Foreign-Key joins:
   - Kafka Streams internally ensures co-partitioning for these joins.
```

### Stateful Operations

Kafka Streams supports stateful operations like aggregations, windowing, and joins using state stores.

**State Store Types:**
- **Key-Value Stores**: For aggregations and joins
- **Window Stores**: For time-based operations
- **Session Stores**: For session-based aggregations

**State Store Configuration:**

```APIDOC
Internal Topic Configuration:

- message.timestamp.type: 'CreateTime' for all internal topics.

- Internal Repartition Topics:
  - compaction.policy: 'delete'
  - retention.time: -1 (infinite)

- Internal Changelog Topics for Key-Value Stores:
  - compaction.policy: 'compact'

- Internal Changelog Topics for Windowed Key-Value Stores:
  - compaction.policy: 'delete,compact'
  - retention.time: 24 hours + windowed store setting

- Internal Changelog Topics for Versioned State Stores:
  - cleanup.policy: 'compact'
  - min.compaction.lag.ms: 24 hours + store's historyRetentionMs
```

### Application Parallelism

```java
The parallelism of a Kafka Streams application is primarily determined by how many partitions the input topics have. For example, if your application reads from a single topic that has ten partitions, then you can run up to ten instances of your applications. You can run further instances, but these will be idle.
The number of topic partitions is the upper limit for the parallelism of your Kafka Streams application and for the number of running instances of your application.
To achieve balanced workload processing across application instances and to prevent processing hotpots, you should distribute data and processing workloads:
Data should be equally distributed across topic partitions. For example, if two topic partitions each have 1 million messages, this is better than a single partition with 2 million messages and none in the other.
Processing workload should be equally distributed across topic partitions. For example, if the time to process messages varies widely, then it is better to spread the processing-intensive messages across partitions rather than storing these messages within the same partition.
```

### Kafka Streams Configuration

**Client Prefixes:**

```java
Properties streamsSettings = new Properties();
// same value for consumer, producer, and admin client
streamsSettings.put("PARAMETER_NAME", "value");
// different values for consumer and producer
streamsSettings.put("consumer.PARAMETER_NAME", "consumer-value");
streamsSettings.put("producer.PARAMETER_NAME", "producer-value");
streamsSettings.put("admin.PARAMETER_NAME", "admin-value");
// alternatively, you can use
streamsSettings.put(StreamsConfig.consumerPrefix("PARAMETER_NAME"), "consumer-value");
streamsSettings.put(StreamsConfig.producerPrefix("PARAMETER_NAME"), "producer-value");
streamsSettings.put(StreamsConfig.adminClientPrefix("PARAMETER_NAME"), "admin-value");
```

**Specific Consumer Types:**

```java
Properties streamsSettings = new Properties();
// same config value for all consumer types
streamsSettings.put("consumer.PARAMETER_NAME", "general-consumer-value");
// set a different restore consumer config. This would make restore consumer take restore-consumer-value,
// while main consumer and global consumer stay with general-consumer-value
streamsSettings.put("restore.consumer.PARAMETER_NAME", "restore-consumer-value");
// alternatively, you can use
streamsSettings.put(StreamsConfig.restoreConsumerPrefix("PARAMETER_NAME"), "restore-consumer-value");
```

**Topic Configuration:**

```java
Properties streamsSettings = new Properties();
// Override default for both changelog and repartition topics
streamsSettings.put("topic.PARAMETER_NAME", "topic-value");
// alternatively, you can use
streamsSettings.put(StreamsConfig.topicPrefix("PARAMETER_NAME"), "topic-value");
```

### Exactly-Once Semantics in Streams

```APIDOC
Producer Client ID Naming Schema:

  - at-least-once (default):
    `[client.Id]-StreamThread-[sequence-number]`

  - exactly-once (EOS version 1):
    `[client.Id]-StreamThread-[sequence-number]-[taskId]`

  - exactly-once-beta (EOS version 2):
    `[client.Id]-StreamThread-[sequence-number]`

Where `[client.Id]` is either set via Streams configuration parameter `client.id` or defaults to `[application.id]-[processId]` (`[processId]` is a random UUID).
```

**EOS Configuration:**

```APIDOC
Parameter Name: isolation.level
Corresponding Client: Consumer
Streams Default: READ_COMMITTED

Parameter Name: enable.idempotence
Corresponding Client: Producer
Streams Default: true
```

```APIDOC
Parameter Name: transaction.timeout.ms
Corresponding Client: Producer
Streams Default: 10000

Parameter Name: delivery.timeout.ms
Corresponding Client: Producer
Streams Default: Integer.MAX_VALUE
```

### Topology Naming and Stability

**Default Topology (Auto-generated names):**

```text
Topologies: Sub-topology: 0
Source: KSTREAM-SOURCE-0000000000 (topics: [input]) --> KSTREAM-FILTER-0000000001
Processor: KSTREAM-FILTER-0000000001 (stores: []) --> KSTREAM-MAPVALUES-0000000002
<-- KSTREAM-SOURCE-0000000000
Processor: KSTREAM-MAPVALUES-0000000002 (stores: []) --> KSTREAM-SINK-0000000003
<-- KSTREAM-FILTER-0000000001
Sink: KSTREAM-SINK-0000000003 (topic: output)
<-- KSTREAM-MAPVALUES-0000000002
```

**Explicit Naming for Stability:**

```APIDOC
Kafka Streams Topology Naming:

- Aggregation repartition topics: Grouped
- KStream-KTable Join repartition topic: Joined
- KStream-KStream Join repartition topics: StreamJoined
- KStream-KTable Join state stores: Joined
- KStream-KStream Join state stores: StreamJoined
- State Stores (for aggregations and KTable-KTable joins): Materialized
- Stream/Table non-stateful operations: Named
```

```APIDOC
Operation							Naming Class
------------------------------------------------------------------
Aggregation repartition topics			Grouped
KStream-KStream Join repartition topics		StreamJoined
KStream-KTable Join repartition topic		Joined
KStream-KStream Join state stores		StreamJoined
State Stores (for aggregations and KTable-KTable joins)	Materialized
Stream/Table non-stateful operations		Named
```

**Enforce Explicit Naming:**

```java
Properties props = new Properties();
props.put(StreamsConfig.ENSURE_EXPLICIT_INTERNAL_RESOURCE_NAMING_CONFIG, true);
```

This prevents the application from starting with auto-generated names, guaranteeing stability across topology updates.

### Topology Optimization

```properties
"topology.optimization":"all"
```

```properties
"topology.optimization":"none"
```

Topology optimization allows reuse of source topics as changelog topics, crucial when migrating from KStreamBuilder to StreamsBuilder.

### WordCount Example with Topology

```Bash
$ mvn clean package
$ mvn exec:java -Dexec.mainClass=myapps.WordCount
Sub-topologies:
Sub-topology: 0
  Source: KSTREAM-SOURCE-0000000000(topics: streams-plaintext-input) --> KSTREAM-FLATMAPVALUES-0000000001
  Processor: KSTREAM-FLATMAPVALUES-0000000001(stores: \[\]) --> KSTREAM-KEY-SELECT-0000000002 <-- KSTREAM-SOURCE-0000000000
  Processor: KSTREAM-KEY-SELECT-0000000002(stores: \[\]) --> KSTREAM-FILTER-0000000005 <-- KSTREAM-FLATMAPVALUES-0000000001
  Processor: KSTREAM-FILTER-0000000005(stores: \[\]) --> KSTREAM-SINK-0000000004 <-- KSTREAM-KEY-SELECT-0000000002
  Sink: KSTREAM-SINK-0000000004(topic: counts-store-repartition) <-- KSTREAM-FILTER-0000000005
Sub-topology: 1
  Source: KSTREAM-SOURCE-0000000006(topics: counts-store-repartition) --> KSTREAM-AGGREGATE-0000000003
  Processor: KSTREAM-AGGREGATE-0000000003(stores: \[counts-store\]) --> KTABLE-TOSTREAM-0000000007 <-- KSTREAM-SOURCE-0000000006
  Processor: KTABLE-TOSTREAM-0000000007(stores: \[\]) --> KSTREAM-SINK-0000000008 <-- KSTREAM-AGGREGATE-0000000003
  Sink: KSTREAM-SINK-0000000008(topic: streams-wordcount-output) <-- KTABLE-TOSTREAM-0000000007
Global Stores: none
```

This topology shows two disconnected sub-topologies, their sources, processors, sinks, and the repartition topic (counts-store-repartition) used for shuffling data by aggregation key.

## Schema Registry

Schema registries enforce data contracts between producers and consumers, ensuring data integrity and preventing malformed events.

```APIDOC
Data Contracts with Schema Registry:
  - Purpose: Ensure events written to Kafka can be read properly and prevent malformed events.
  - Implementation: Deploy a schema registry alongside the Kafka cluster.
  - Functionality: Manages event schemas and maps them to topics, guiding producers on correct event formats.
  - Note: Kafka does not include a schema registry; third-party implementations are available.
```

### Schema Registry Benefits

1. **Schema Evolution**: Manage schema changes over time
2. **Compatibility Checking**: Enforce backward/forward compatibility
3. **Centralized Management**: Single source of truth for schemas
4. **Type Safety**: Compile-time type checking
5. **Documentation**: Auto-generated schema documentation
6. **Versioning**: Track schema versions per subject

### Schema Formats

**Supported Formats:**
- **Avro**: Compact binary format with rich schema evolution
- **JSON Schema**: Human-readable with schema validation
- **Protobuf**: Google's Protocol Buffers

### Schema Evolution Compatibility Modes

1. **BACKWARD**: New schema can read old data
2. **FORWARD**: Old schema can read new data
3. **FULL**: Both backward and forward compatible
4. **NONE**: No compatibility checking

### Avro Producer Example

```java
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.clients.producer.*;

Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
props.put("schema.registry.url", "http://localhost:8081");

String userSchema = "{"
    + "\"type\":\"record\","
    + "\"name\":\"User\","
    + "\"fields\":["
    + "  {\"name\":\"name\",\"type\":\"string\"},"
    + "  {\"name\":\"age\",\"type\":\"int\"}"
    + "]}";

Schema.Parser parser = new Schema.Parser();
Schema schema = parser.parse(userSchema);

GenericRecord user = new GenericData.Record(schema);
user.put("name", "John Doe");
user.put("age", 30);

ProducerRecord<String, GenericRecord> record =
    new ProducerRecord<>("users", "user1", user);

producer.send(record);
```

## Kafka Connect

Kafka Connect is a framework for streaming data between Kafka and external systems.

```APIDOC
Kafka Connect Sink Connector Input Topics

Configuration options for sink connectors to specify input topics using a comma-separated list or a regular expression.

topics
topics.regex
```

### Connector Types

**Source Connectors**: Import data into Kafka
- Database CDC (Debezium)
- File systems
- Message queues
- Cloud services (S3, BigQuery)
- APIs and webhooks

**Sink Connectors**: Export data from Kafka
- Databases (JDBC, Elasticsearch)
- Data warehouses
- Object storage
- Search engines
- Analytics platforms

### Connector Configuration

**Source Connector Example (JDBC):**

```json
{
  "name": "jdbc-source-connector",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
    "tasks.max": "1",
    "connection.url": "jdbc:postgresql://localhost:5432/mydb",
    "connection.user": "postgres",
    "connection.password": "password",
    "table.whitelist": "users,orders",
    "mode": "incrementing",
    "incrementing.column.name": "id",
    "topic.prefix": "postgres-"
  }
}
```

**Sink Connector Example (Elasticsearch):**

```json
{
  "name": "elasticsearch-sink-connector",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1",
    "topics": "user-events,order-events",
    "connection.url": "http://localhost:9200",
    "type.name": "_doc",
    "key.ignore": "false"
  }
}
```

### Change Data Capture (CDC)

CDC captures database changes and streams them to Kafka in real-time.

**Benefits:**
- Real-time data synchronization
- Event sourcing from existing databases
- Microservices data integration
- Zero-downtime migrations

**Popular CDC Connectors:**
- Debezium (MySQL, PostgreSQL, MongoDB, SQL Server)
- Oracle GoldenGate
- Maxwell's Daemon

## Topic Management

```APIDOC
Kafka Streams Topic Management:

User Topics:
  - Input Topics: Specified via source processors (e.g., StreamsBuilder#stream(), StreamsBuilder#table(), Topology#addSource()).
  - Output Topics: Specified via sink processors (e.g., KStream#to(), KTable.to(), Topology#addSink()).
  - Management: Must be created and managed manually ahead of time (e.g., via topic tools).
  - Sharing: If shared, users must coordinate topic management.
  - Auto-creation: Discouraged due to potential cluster configuration and default topic settings (e.g., replication factor).

Internal Topics:
  - Purpose: Used internally by the application for state stores (e.g., changelog topics).
  - Creation: Created by the application itself.
  - Usage: Only used by the specific stream application.
  - Permissions: Requires underlying clients to have admin permissions on Kafka brokers if security is enabled.
  - Naming Convention: Typically follows '<application.id>-<operatorName>-<suffix>', but not guaranteed for future releases.
```

### Topic Operations

```APIDOC
DESCRIBE_PRODUCERS:
  - Action: Read
  - Resource: Topic

DESCRIBE_TOPIC_PARTITIONS:
  - Action: Describe
  - Resource: Topic
```

### Produce Test Messages

```bash
$ bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic streams-plaintext-input
>all streams lead to kafka
>hello kafka streams
>join kafka summit
```

## Monitoring and Metrics

### Common Metrics

```APIDOC
Metric Name: outgoing-byte-rate
Description: The average number of outgoing bytes sent per second for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: outgoing-byte-total
Description: The total number of outgoing bytes sent for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: request-rate
Description: The average number of requests sent per second for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: request-total
Description: The total number of requests sent for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: request-size-avg
Description: The average size of all requests in the window for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: request-size-max
Description: The maximum size of any request sent in the window for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)

Metric Name: incoming-byte-rate
Description: The average number of incoming bytes received per second for a node.
Mbean Name Pattern: kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.w]+),node-id=([0-9]+)
```

### Key Monitoring Areas

1. **Producer Metrics:**
   - record-send-rate
   - record-error-rate
   - compression-rate-avg
   - buffer-available-bytes

2. **Consumer Metrics:**
   - records-consumed-rate
   - fetch-latency-avg
   - records-lag-max
   - commit-latency-avg

3. **Broker Metrics:**
   - UnderReplicatedPartitions
   - OfflinePartitionsCount
   - ActiveControllerCount
   - RequestHandlerAvgIdlePercent

4. **Streams Metrics:**
   - process-rate
   - process-latency-avg
   - commit-rate
   - poll-rate

## Production Deployment

### Cluster Architecture

**Multi-Broker Setup:**

1. **Brokers**: Typically 3+ brokers for fault tolerance
2. **Replication**: Replication factor 3 for production
3. **Partitions**: More partitions = more parallelism
4. **ZooKeeper/KRaft**: 3 or 5 nodes for quorum

### High Availability Configuration

**Broker Configuration:**

```properties
# Broker ID
broker.id=1

# Listeners
listeners=PLAINTEXT://broker1:9092,SSL://broker1:9093

# Log directories (use multiple disks)
log.dirs=/data/kafka-logs-1,/data/kafka-logs-2

# Replication
default.replication.factor=3
min.insync.replicas=2

# Leader election
unclean.leader.election.enable=false
auto.leader.rebalance.enable=true

# Log retention
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
```

### Eligible Leader Replicas (ELR)

```APIDOC
API: DescribeTopicPartitions

Purpose: Fetches detailed information about topic partitions, including Eligible Leader Replicas (ELR).

Usage:
- Via Admin Client: The admin client can fetch ELR info by describing topics.
- Direct API Call: Use the DescribeTopicPartitions API endpoint.

ELR Selection Logic:
- If ELR is not empty, select a replica that is not fenced.
- Select the last known leader if it is unfenced, mimicking pre-4.0 behavior when all replicas are offline.

Dependencies/Side Effects:
- Updating `min.insync.replicas` for a topic will clean the ELR field for that topic.
- Updating the cluster default `min.insync.replicas` will clean ELR fields for all topics.

Return Values:
- ELR status and related replica information for partitions.
```

### Security Configuration

**SSL/TLS Encryption:**

```properties
# SSL configuration
listeners=SSL://broker:9093
security.inter.broker.protocol=SSL
ssl.keystore.location=/var/private/ssl/kafka.server.keystore.jks
ssl.keystore.password=password
ssl.key.password=password
ssl.truststore.location=/var/private/ssl/kafka.server.truststore.jks
ssl.truststore.password=password
ssl.client.auth=required
```

**SASL Authentication:**

```properties
# SASL/PLAIN configuration
listeners=SASL_SSL://broker:9093
security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN

# JAAS configuration
listener.name.sasl_ssl.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
   username="admin" \
   password="admin-secret" \
   user_admin="admin-secret" \
   user_alice="alice-secret";
```

### Performance Tuning

**Broker Tuning:**

```properties
# Network threads
num.network.threads=8

# I/O threads
num.io.threads=16

# Socket buffer sizes
socket.send.buffer.bytes=1048576
socket.receive.buffer.bytes=1048576
socket.request.max.bytes=104857600

# Replication
num.replica.fetchers=4
replica.fetch.max.bytes=1048576

# Log flush (rely on OS page cache)
log.flush.interval.messages=9223372036854775807
log.flush.interval.ms=null
```

**Producer Tuning for Throughput:**

```properties
acks=1
linger.ms=100
batch.size=65536
compression.type=lz4
buffer.memory=67108864
max.in.flight.requests.per.connection=5
```

**Consumer Tuning:**

```properties
fetch.min.bytes=1
fetch.max.wait.ms=500
max.partition.fetch.bytes=1048576
max.poll.records=500
session.timeout.ms=30000
heartbeat.interval.ms=3000
```

## Best Practices

### Producer Best Practices

1. **Enable Idempotence**: Prevent duplicate messages
2. **Configure Acks Properly**: Balance durability and throughput
3. **Use Compression**: Reduce network and storage costs
4. **Batch Messages**: Configure linger.ms and batch.size
5. **Handle Retries**: Implement proper retry logic
6. **Monitor Metrics**: Track send rates and error rates
7. **Partition Strategy**: Use meaningful keys for ordering
8. **Close Gracefully**: Call close() with timeout

### Consumer Best Practices

1. **Manual Offset Management**: For at-least-once semantics
2. **Handle Rebalancing**: Implement ConsumerRebalanceListener
3. **Minimize Poll Duration**: Process efficiently
4. **Monitor Consumer Lag**: Alert on high lag
5. **Thread Safety**: One consumer per thread
6. **Graceful Shutdown**: Close consumers properly
7. **Error Handling**: Retry transient failures, DLQ for permanent
8. **Seek Capability**: Use seek() for replay scenarios

### Kafka Streams Best Practices

1. **Explicit Naming**: Use Named, Grouped, Materialized for stability
2. **State Store Management**: Configure changelog topics properly
3. **Error Handling**: Implement ProductionExceptionHandler
4. **Scaling**: Match application instances to input partitions
5. **Testing**: Use TopologyTestDriver for unit tests
6. **Monitoring**: Track lag, processing rate, error rate
7. **Exactly-Once**: Enable for critical applications
8. **Graceful Shutdown**: Handle signals properly

### Topic Design Best Practices

1. **Partition Count**: Based on throughput requirements
2. **Replication Factor**: 3 for production topics
3. **Retention**: Set based on use case (time or size)
4. **Compaction**: Use for changelog and lookup topics
5. **Naming Convention**: Consistent naming scheme
6. **Documentation**: Document topic purpose and schema
7. **Access Control**: Implement proper ACLs
8. **Monitoring**: Track partition metrics

### Operational Best Practices

1. **Monitoring**: Comprehensive metrics collection
2. **Alerting**: Alert on critical metrics
3. **Capacity Planning**: Monitor disk, network, CPU
4. **Backup**: Implement disaster recovery strategy
5. **Upgrades**: Rolling upgrades with testing
6. **Security**: Enable encryption and authentication
7. **Documentation**: Maintain runbooks
8. **Testing**: Load test before production

## Common Patterns

### Pattern 1: Event Sourcing

Store all state changes as immutable events:

```java
// Order events
OrderCreated -> OrderPaid -> OrderShipped -> OrderDelivered

// Event store as Kafka topic
Topic: order-events
Compaction: None (keep full history)
Retention: Infinite or very long
```

### Pattern 2: CQRS (Command Query Responsibility Segregation)

Separate read and write models:

```java
// Write side: Commands produce events
commands -> producers -> events-topic

// Read side: Consumers build projections
events-topic -> streams -> materialized-view (KTable)
```

### Pattern 3: Saga Pattern

Distributed transaction coordination:

```java
// Order saga
order-requested -> payment-requested -> payment-completed ->
inventory-reserved -> order-confirmed

// Compensating transactions on failure
payment-failed -> order-cancelled
```

### Pattern 4: Outbox Pattern

Reliably publish database changes:

```java
// Database transaction writes to outbox table
BEGIN TRANSACTION;
  INSERT INTO orders VALUES (...);
  INSERT INTO outbox VALUES (event_data);
COMMIT;

// CDC connector reads outbox and publishes to Kafka
Debezium -> outbox-topic -> downstream consumers
```

### Pattern 5: Fan-out Pattern

Broadcast events to multiple consumers:

```java
// Single topic, multiple consumer groups
user-events topic
  -> email-service (consumer group: email)
  -> analytics-service (consumer group: analytics)
  -> notification-service (consumer group: notifications)
```

### Pattern 6: Dead Letter Queue (DLQ)

Handle processing failures:

```java
try {
  processRecord(record);
} catch (RetriableException e) {
  // Retry
  retry(record);
} catch (NonRetriableException e) {
  // Send to DLQ
  sendToDLQ(record, e);
}
```

### Pattern 7: Windowed Aggregations

Time-based aggregations:

```java
KStream<String, PageView> views = ...;

// Tumbling window: non-overlapping fixed windows
views.groupByKey()
     .windowedBy(TimeWindows.of(Duration.ofMinutes(5)))
     .count();

// Hopping window: overlapping windows
views.groupByKey()
     .windowedBy(TimeWindows.of(Duration.ofMinutes(5))
                            .advanceBy(Duration.ofMinutes(1)))
     .count();

// Session window: activity-based windows
views.groupByKey()
     .windowedBy(SessionWindows.with(Duration.ofMinutes(30)))
     .count();
```

## Troubleshooting

### Common Issues

**Issue: Consumer lag increasing**
- Check consumer processing time
- Scale consumer group (add instances)
- Optimize processing logic
- Increase max.poll.records if appropriate

**Issue: Messages not arriving**
- Check producer send() error callbacks
- Verify topic exists and is accessible
- Check network connectivity
- Review broker logs for errors

**Issue: Duplicate messages**
- Enable idempotent producer
- Implement idempotent consumer processing
- Check offset commit strategy
- Verify exactly-once configuration

**Issue: Rebalancing taking too long**
- Reduce max.poll.interval.ms
- Increase session.timeout.ms
- Optimize poll() processing time
- Check consumer health

**Issue: Partition leader unavailable**
- Check broker health and logs
- Verify replication status
- Check network between brokers
- Review ISR (In-Sync Replicas)

**Issue: Out of memory errors**
- Reduce batch.size and buffer.memory
- Tune JVM heap settings
- Monitor memory usage
- Check for memory leaks in processing

## Migration and Upgrade Strategies

### Kafka Streams Migration

**KStreamBuilder to StreamsBuilder:**

```Java
kstream.repartition(...);
// or for user-managed topics:
kstream.to("user-topic");
streamsBuilder.stream("user-topic");
```

Replaces KStream.through() for managing topic repartitioning.

**Topic Prefix Configuration:**

```Java
Properties props = new Properties();
props.put(StreamsConfig.topicPrefix("my-prefix.") + "replication.factor", "3");
KafkaStreams streams = new KafkaStreams(topology, props);
```

### Rolling Upgrades

1. **Prepare**: Test new version in staging
2. **Upgrade Brokers**: One broker at a time
3. **Verify**: Check cluster health after each broker
4. **Upgrade Clients**: Producers, consumers, streams apps
5. **Monitor**: Watch metrics throughout process

## Resources and References

- Apache Kafka Documentation: https://kafka.apache.org/documentation/
- Confluent Platform: https://docs.confluent.io/
- Kafka Streams Documentation: https://kafka.apache.org/documentation/streams/
- Schema Registry: https://docs.confluent.io/platform/current/schema-registry/
- Kafka Connect: https://kafka.apache.org/documentation/#connect

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Stream Processing, Event-Driven Architecture, Real-Time Data
**Compatible With**: Apache Kafka 2.x, 3.x, Confluent Platform
