# Kafka Stream Processing Skill

A comprehensive Claude Code skill for building production-ready event-driven applications with Apache Kafka. This skill covers the complete Kafka ecosystem including producers, consumers, Kafka Streams, connectors, schema registry, and operational best practices.

## Overview

Apache Kafka is the industry-standard distributed streaming platform for building real-time data pipelines and streaming applications. This skill provides deep expertise in:

- **Kafka Producers**: Publishing messages with configurable reliability and performance
- **Kafka Consumers**: Reading messages with consumer groups and offset management
- **Kafka Streams**: Stream processing DSL for stateful transformations and aggregations
- **Kafka Connect**: Integrating external systems with source and sink connectors
- **Schema Registry**: Managing data contracts and schema evolution
- **Production Deployment**: Cluster setup, monitoring, security, and performance tuning

## What is Apache Kafka?

Apache Kafka is a distributed streaming platform that:

1. **Publishes and Subscribes**: Like a message queue or enterprise messaging system
2. **Stores Streams**: With fault-tolerant, durable storage
3. **Processes Streams**: Real-time stream processing as events occur

### Core Capabilities

**High Throughput**
- Handle millions of messages per second
- Linear scalability with partitions
- Batching and compression for efficiency

**Low Latency**
- Single-digit millisecond latency
- Zero-copy transfers
- Efficient binary protocol

**Durability and Reliability**
- Configurable replication (typically 3x)
- Persistent storage with configurable retention
- Automatic failover and recovery
- At-least-once, exactly-once delivery semantics

**Scalability**
- Horizontal scaling via partitions
- Independent scaling of producers and consumers
- Elastic cluster expansion

## Quick Start

### Prerequisites

- Java 11+ (Kafka and clients)
- Apache Kafka installed (or Docker)
- Understanding of distributed systems concepts

### Running Kafka Locally

```bash
# Start ZooKeeper (or use KRaft mode in Kafka 3.x+)
$ bin/zookeeper-server-start.sh config/zookeeper.properties

# Start Kafka broker
$ bin/kafka-server-start.sh config/server.properties

# Create a topic
$ bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic quickstart-events \
  --partitions 3 --replication-factor 1

# Verify topic created
$ bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --topic quickstart-events
```

### Simple Producer (Java)

```java
import org.apache.kafka.clients.producer.*;
import java.util.Properties;

Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

KafkaProducer<String, String> producer = new KafkaProducer<>(props);

ProducerRecord<String, String> record =
    new ProducerRecord<>("quickstart-events", "key1", "Hello Kafka!");

producer.send(record);
producer.close();
```

### Simple Consumer (Java)

```java
import org.apache.kafka.clients.consumer.*;
import java.time.Duration;
import java.util.*;

Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("group.id", "my-group");
props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
consumer.subscribe(Collections.singletonList("quickstart-events"));

while (true) {
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
    for (ConsumerRecord<String, String> record : records) {
        System.out.printf("Received: %s%n", record.value());
    }
}
```

### Simple Kafka Streams Application

```java
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.util.Properties;

Properties props = new Properties();
props.put(StreamsConfig.APPLICATION_ID_CONFIG, "wordcount-app");
props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> textLines = builder.stream("input-topic");

KTable<String, Long> wordCounts = textLines
    .flatMapValues(line -> Arrays.asList(line.toLowerCase().split("\\W+")))
    .groupBy((key, word) -> word)
    .count();

wordCounts.toStream().to("output-topic");

KafkaStreams streams = new KafkaStreams(builder.build(), props);
streams.start();
```

## Architecture Overview

### Kafka Cluster Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Kafka Cluster                          │
│                                                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │ Broker 1 │    │ Broker 2 │    │ Broker 3 │              │
│  │          │    │          │    │          │              │
│  │ Topic A  │    │ Topic A  │    │ Topic B  │              │
│  │ Part 0   │    │ Part 1   │    │ Part 0   │              │
│  │ (Leader) │    │ (Leader) │    │ (Leader) │              │
│  └──────────┘    └──────────┘    └──────────┘              │
│                                                               │
│  ┌────────────────────────────────────────────┐             │
│  │     ZooKeeper Ensemble (or KRaft)           │             │
│  │  (Metadata, Coordination, Leader Election)  │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
         ▲                                      ▼
         │                                      │
    ┌────┴────┐                          ┌─────┴────┐
    │Producers│                          │Consumers │
    │         │                          │(Groups)  │
    └─────────┘                          └──────────┘
```

### Topic and Partition Model

```
Topic: user-events
┌─────────────────────────────────────────────┐
│ Partition 0: [msg0][msg3][msg6][msg9]       │ → Consumer A
│ Partition 1: [msg1][msg4][msg7][msg10]      │ → Consumer B
│ Partition 2: [msg2][msg5][msg8][msg11]      │ → Consumer C
└─────────────────────────────────────────────┘

Replication:
Partition 0: Broker 1 (Leader), Broker 2, Broker 3
Partition 1: Broker 2 (Leader), Broker 1, Broker 3
Partition 2: Broker 3 (Leader), Broker 1, Broker 2
```

### Consumer Group Model

```
Topic with 4 partitions
┌──────┬──────┬──────┬──────┐
│ P0   │ P1   │ P2   │ P3   │
└──────┴──────┴──────┴──────┘
    │      │      │      │
    │      │      │      │
Consumer Group (CG-1)
    │      │      │      │
    ▼      ▼      ▼      ▼
┌───────┐  ┌───────┐  ┌───────┐
│ C1    │  │ C2    │  │ C3    │
│ P0,P1 │  │ P2    │  │ P3    │
└───────┘  └───────┘  └───────┘

- Each partition consumed by exactly one consumer in group
- Consumers can process messages in parallel
- Adding more consumers (up to partition count) increases throughput
```

### Kafka Streams Topology

```
Input Topics → Source Processors
                    ↓
            Stream Processors
        (map, filter, join, aggregate)
                    ↓
            State Stores (optional)
        (RocksDB, In-Memory)
                    ↓
             Sink Processors
                    ↓
            Output Topics
```

## When to Use Kafka

### Ideal Use Cases

**Event-Driven Microservices**
- Decouple services via events
- Asynchronous communication
- Event sourcing and CQRS

**Real-Time Data Pipelines**
- ETL between systems
- Data lake ingestion
- CDC (Change Data Capture)

**Stream Processing**
- Real-time analytics
- Fraud detection
- Real-time recommendations
- Monitoring and alerting

**Log Aggregation**
- Centralized logging
- Application metrics
- Audit trails

**Message Queue Replacement**
- High-throughput messaging
- Durable message storage
- Replay capability

### When NOT to Use Kafka

**Not Ideal For:**
- Simple request-response patterns (use REST/gRPC)
- Small-scale applications (overhead not justified)
- Strict ordering across entire dataset (only per-partition ordering)
- Transactional databases (Kafka is not a database)
- File storage (use object storage like S3)

## Key Concepts

### Topics and Partitions

- **Topic**: Logical channel for messages (e.g., "user-events", "orders")
- **Partition**: Ordered, immutable log within a topic
- **Offset**: Unique sequential ID for each message in partition
- **Replication**: Each partition replicated across multiple brokers

### Producers

- Publish records to topics
- Choose partition via key or custom partitioner
- Configure reliability (acks) and performance (batching)
- Support synchronous and asynchronous sends

### Consumers

- Subscribe to topics and consume records
- Consumer groups for parallel processing
- Offset management (automatic or manual)
- Rebalancing for fault tolerance

### Kafka Streams

- Library for building stream processing applications
- Supports stateless (map, filter) and stateful (aggregate, join) operations
- Exactly-once processing semantics
- Built-in state stores with changelog topics

### Kafka Connect

- Framework for integrating external systems
- Source connectors: Import data into Kafka
- Sink connectors: Export data from Kafka
- Hundreds of pre-built connectors available

### Schema Registry

- Centralized schema management
- Schema evolution with compatibility checking
- Support for Avro, JSON Schema, Protobuf
- Producer/consumer schema validation

## Message Delivery Semantics

### At-Most-Once (0-1 delivery)
- Messages may be lost but never duplicated
- Producer: acks=0, no retries
- Consumer: Commit offset before processing
- **Use Case**: Metrics, logs where occasional loss acceptable

### At-Least-Once (1+ delivery)
- Messages never lost but may be duplicated
- Producer: acks=all, retries enabled
- Consumer: Commit offset after processing
- **Use Case**: Most applications with idempotent processing

### Exactly-Once (1 delivery)
- Messages delivered exactly once
- Producer: Idempotent + transactions
- Consumer: isolation.level=read_committed
- Streams: processing.guarantee=exactly_once
- **Use Case**: Financial transactions, critical data

## Performance Characteristics

### Throughput

- **Producers**: Millions of messages/sec per broker
- **Consumers**: Limited by processing speed, not Kafka
- **Scaling**: Linear with partition count

### Latency

- **End-to-End**: 2-10ms typical
- **Producer**: <5ms for async sends
- **Consumer**: Depends on fetch settings and processing

### Storage

- **Retention**: Configurable by time or size
- **Compression**: gzip, snappy, lz4, zstd
- **Compaction**: Log compaction for changelog topics

## Skill Contents

This skill includes:

1. **Core Concepts**: Topics, partitions, brokers, replication
2. **Producer Guide**: Configuration, best practices, examples
3. **Consumer Guide**: Groups, offsets, rebalancing, error handling
4. **Kafka Streams**: DSL, stateful processing, windowing, joins
5. **Schema Registry**: Avro, evolution, compatibility
6. **Kafka Connect**: Source/sink connectors, CDC
7. **Performance Tuning**: Batching, compression, threading
8. **Production Deployment**: Cluster setup, monitoring, security
9. **Best Practices**: Patterns, anti-patterns, operational guidance
10. **Troubleshooting**: Common issues and solutions

## Examples Included

The skill includes 18+ comprehensive examples:

- Simple producer/consumer
- Exactly-once producer
- Consumer group coordination
- Manual offset management
- Kafka Streams WordCount
- Stateful stream processing
- Stream-stream joins
- Stream-table joins
- Windowed aggregations
- Avro serialization with Schema Registry
- JDBC source connector
- Elasticsearch sink connector
- CDC with Debezium
- Event sourcing pattern
- CQRS pattern
- Saga pattern
- Outbox pattern
- Dead letter queue pattern

## Additional Resources

- **SKILL.md**: Complete reference guide with all concepts and examples
- **EXAMPLES.md**: Detailed code examples and patterns
- **Apache Kafka Docs**: https://kafka.apache.org/documentation/
- **Confluent Platform**: https://docs.confluent.io/

## Version Information

- **Skill Version**: 1.0.0
- **Kafka Versions**: 2.x, 3.x
- **Last Updated**: October 2025
- **Context7 Integration**: Uses latest Apache Kafka documentation

## Getting Help

For Kafka-specific questions:
- Apache Kafka mailing lists: https://kafka.apache.org/contact
- Confluent Community: https://forum.confluent.io/
- Stack Overflow: `apache-kafka` tag

---

**Start with SKILL.md for the complete guide, then explore EXAMPLES.md for practical implementations.**
