# Kafka Stream Processing Examples

Comprehensive examples demonstrating Kafka producers, consumers, Kafka Streams, connectors, and production patterns.

## Table of Contents

1. [Producer Examples](#producer-examples)
2. [Consumer Examples](#consumer-examples)
3. [Kafka Streams Examples](#kafka-streams-examples)
4. [Schema Registry Examples](#schema-registry-examples)
5. [Kafka Connect Examples](#kafka-connect-examples)
6. [Production Patterns](#production-patterns)
7. [Testing Strategies](#testing-strategies)

## Producer Examples

### Example 1: Simple Synchronous Producer

Basic producer with synchronous sends and error handling.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class SimpleSyncProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            for (int i = 0; i < 100; i++) {
                ProducerRecord<String, String> record =
                    new ProducerRecord<>("events", "key-" + i, "message-" + i);

                try {
                    // Synchronous send - blocks until acknowledged
                    RecordMetadata metadata = producer.send(record).get();
                    System.out.printf("Sent record(key=%s value=%s) " +
                        "meta(partition=%d, offset=%d)%n",
                        record.key(), record.value(),
                        metadata.partition(), metadata.offset());
                } catch (ExecutionException | InterruptedException e) {
                    System.err.println("Error sending record: " + e.getMessage());
                }
            }
        }
    }
}
```

**When to Use:**
- Small number of messages
- Need confirmation before proceeding
- Testing and debugging

### Example 2: Asynchronous Producer with Callbacks

High-throughput producer with async sends and callback handling.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class AsyncProducerWithCallbacks {
    public static void main(String[] args) throws InterruptedException {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 32768);

        CountDownLatch latch = new CountDownLatch(1000);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            for (int i = 0; i < 1000; i++) {
                ProducerRecord<String, String> record =
                    new ProducerRecord<>("high-throughput-topic", "key-" + i, "data-" + i);

                // Async send with callback
                producer.send(record, new Callback() {
                    @Override
                    public void onCompletion(RecordMetadata metadata, Exception exception) {
                        if (exception != null) {
                            System.err.println("Error producing record: " + exception.getMessage());
                        } else {
                            System.out.printf("Produced: partition=%d offset=%d%n",
                                metadata.partition(), metadata.offset());
                        }
                        latch.countDown();
                    }
                });
            }

            // Wait for all callbacks to complete
            latch.await();
        }
    }
}
```

**Benefits:**
- High throughput via batching
- Non-blocking sends
- Error handling per message

### Example 3: Idempotent Producer (Exactly-Once)

Producer configured for exactly-once semantics to prevent duplicates.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class IdempotentProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Exactly-once producer settings
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);

        // Optional: Transactional ID for transactions
        props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "my-transactional-id");

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            // Initialize transactions
            producer.initTransactions();

            try {
                // Begin transaction
                producer.beginTransaction();

                // Send multiple records atomically
                for (int i = 0; i < 100; i++) {
                    ProducerRecord<String, String> record =
                        new ProducerRecord<>("transactions", "txn-" + i, "data-" + i);
                    producer.send(record);
                }

                // Commit transaction
                producer.commitTransaction();
                System.out.println("Transaction committed successfully");

            } catch (Exception e) {
                // Abort transaction on error
                producer.abortTransaction();
                System.err.println("Transaction aborted: " + e.getMessage());
            }
        }
    }
}
```

**Key Features:**
- No duplicate messages even with retries
- Atomic writes across partitions
- Exactly-once delivery guarantee

### Example 4: Custom Partitioner

Implement custom partitioning logic for specialized routing.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.Cluster;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.*;

// Custom partitioner routes VIP users to partition 0
class VIPPartitioner implements Partitioner {
    private Set<String> vipUsers = new HashSet<>(Arrays.asList("user1", "user2", "user3"));

    @Override
    public int partition(String topic, Object key, byte[] keyBytes,
                        Object value, byte[] valueBytes, Cluster cluster) {
        int partitionCount = cluster.partitionCountForTopic(topic);

        if (key != null && vipUsers.contains(key.toString())) {
            return 0; // VIP partition
        }

        // Default partitioning for others
        return Math.abs(key.hashCode()) % (partitionCount - 1) + 1;
    }

    @Override
    public void close() {}

    @Override
    public void configure(Map<String, ?> configs) {}
}

public class CustomPartitionerProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.PARTITIONER_CLASS_CONFIG, VIPPartitioner.class.getName());

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            String[] users = {"user1", "user4", "user2", "user5", "user3"};

            for (String user : users) {
                ProducerRecord<String, String> record =
                    new ProducerRecord<>("user-events", user, "event-data");

                producer.send(record, (metadata, exception) -> {
                    if (exception == null) {
                        System.out.printf("User %s -> Partition %d%n",
                            user, metadata.partition());
                    }
                });
            }
        }
    }
}
```

**Use Cases:**
- Priority routing
- Geographic partitioning
- Load balancing strategies

### Example 5: Producer with Compression

Configure compression to reduce network and storage overhead.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class CompressedProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Enable compression (options: none, gzip, snappy, lz4, zstd)
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "lz4");

        // Increase batch size to maximize compression benefits
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 65536);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 100);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            // Send large messages that benefit from compression
            String largeMessage = generateLargeMessage(10000);

            for (int i = 0; i < 100; i++) {
                ProducerRecord<String, String> record =
                    new ProducerRecord<>("large-messages", "key-" + i, largeMessage);

                producer.send(record, (metadata, exception) -> {
                    if (exception == null) {
                        System.out.printf("Compressed message sent: offset=%d%n", metadata.offset());
                    }
                });
            }
        }
    }

    private static String generateLargeMessage(int size) {
        StringBuilder sb = new StringBuilder(size);
        for (int i = 0; i < size; i++) {
            sb.append("Lorem ipsum dolor sit amet ");
        }
        return sb.toString();
    }
}
```

**Compression Comparison:**
- **lz4**: Fast compression/decompression, good compression ratio
- **snappy**: Very fast, moderate compression
- **gzip**: Best compression ratio, slower
- **zstd**: Excellent balance (Kafka 2.1+)

## Consumer Examples

### Example 6: Basic Consumer with Manual Commit

Consumer with manual offset management for at-least-once semantics.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class ManualCommitConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "manual-commit-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList("events"));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("Consumed: partition=%d offset=%d key=%s value=%s%n",
                        record.partition(), record.offset(), record.key(), record.value());

                    // Process record
                    processRecord(record);
                }

                // Commit offsets after processing all records in batch
                try {
                    consumer.commitSync();
                } catch (CommitFailedException e) {
                    System.err.println("Commit failed: " + e.getMessage());
                }
            }
        }
    }

    private static void processRecord(ConsumerRecord<String, String> record) {
        // Business logic here
        // If processing fails, exception prevents commit
    }
}
```

**Guarantees:**
- At-least-once delivery
- No message loss if processing fails
- Potential duplicates on rebalance

### Example 7: Consumer with Rebalance Listener

Handle partition rebalancing with state cleanup and offset management.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class RebalanceListenerConsumer {
    private static Map<TopicPartition, Long> currentOffsets = new HashMap<>();

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "rebalance-aware-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(
                Collections.singletonList("events"),
                new ConsumerRebalanceListener() {
                    @Override
                    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
                        System.out.println("Partitions revoked: " + partitions);
                        // Commit current offsets before losing partitions
                        consumer.commitSync(currentOffsets);
                        currentOffsets.clear();
                    }

                    @Override
                    public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
                        System.out.println("Partitions assigned: " + partitions);
                        // Seek to specific offset if needed
                        for (TopicPartition partition : partitions) {
                            System.out.printf("Starting position for %s: %d%n",
                                partition, consumer.position(partition));
                        }
                    }
                }
            );

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    processRecord(record);

                    // Track current offset for each partition
                    currentOffsets.put(
                        new TopicPartition(record.topic(), record.partition()),
                        record.offset() + 1
                    );
                }

                // Async commit with callback
                consumer.commitAsync((offsets, exception) -> {
                    if (exception != null) {
                        System.err.println("Async commit failed: " + exception.getMessage());
                    }
                });
            }
        }
    }

    private static void processRecord(ConsumerRecord<String, String> record) {
        System.out.printf("Processing: %s%n", record.value());
    }
}
```

**Features:**
- Clean shutdown before rebalance
- State management per partition
- Async commits for performance

### Example 8: Consumer Seek and Replay

Implement replay functionality by seeking to specific offsets.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class SeekAndReplayConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "seek-replay-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList("events"));

            // Initial poll to join group and get partition assignment
            consumer.poll(Duration.ofMillis(0));

            // Seek to beginning of all assigned partitions
            Set<TopicPartition> assignedPartitions = consumer.assignment();
            consumer.seekToBeginning(assignedPartitions);

            System.out.println("Replaying from beginning...");

            // Or seek to specific offset
            // for (TopicPartition partition : assignedPartitions) {
            //     consumer.seek(partition, 100); // Start from offset 100
            // }

            // Or seek to timestamp (messages after specific time)
            // Map<TopicPartition, Long> timestampsToSearch = new HashMap<>();
            // long timestamp = System.currentTimeMillis() - (24 * 60 * 60 * 1000); // 24h ago
            // for (TopicPartition partition : assignedPartitions) {
            //     timestampsToSearch.put(partition, timestamp);
            // }
            // Map<TopicPartition, OffsetAndTimestamp> offsets =
            //     consumer.offsetsForTimes(timestampsToSearch);
            // for (Map.Entry<TopicPartition, OffsetAndTimestamp> entry : offsets.entrySet()) {
            //     if (entry.getValue() != null) {
            //         consumer.seek(entry.getKey(), entry.getValue().offset());
            //     }
            // }

            int messageCount = 0;
            while (messageCount < 1000) { // Replay 1000 messages
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("Replayed: offset=%d key=%s value=%s%n",
                        record.offset(), record.key(), record.value());
                    messageCount++;
                }
            }

            System.out.println("Replay completed");
        }
    }
}
```

**Use Cases:**
- Reprocessing historical data
- Recovery from processing errors
- Testing with production data

### Example 9: Multi-Topic Consumer with Pattern

Subscribe to multiple topics using pattern matching.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;
import java.util.regex.Pattern;

public class MultiTopicPatternConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "multi-topic-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            // Subscribe to all topics matching pattern (e.g., user-events-*, order-events-*)
            Pattern pattern = Pattern.compile(".*-events-.*");
            consumer.subscribe(pattern, new ConsumerRebalanceListener() {
                @Override
                public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
                    System.out.println("Partitions revoked: " + partitions);
                }

                @Override
                public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
                    System.out.println("Partitions assigned: " + partitions);
                    // Print topics being consumed
                    Set<String> topics = new HashSet<>();
                    for (TopicPartition partition : partitions) {
                        topics.add(partition.topic());
                    }
                    System.out.println("Consuming from topics: " + topics);
                }
            });

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("Topic=%s Partition=%d Offset=%d Key=%s Value=%s%n",
                        record.topic(), record.partition(), record.offset(),
                        record.key(), record.value());

                    // Route processing based on topic
                    if (record.topic().startsWith("user-events")) {
                        processUserEvent(record);
                    } else if (record.topic().startsWith("order-events")) {
                        processOrderEvent(record);
                    }
                }
            }
        }
    }

    private static void processUserEvent(ConsumerRecord<String, String> record) {
        System.out.println("Processing user event: " + record.value());
    }

    private static void processOrderEvent(ConsumerRecord<String, String> record) {
        System.out.println("Processing order event: " + record.value());
    }
}
```

**Benefits:**
- Dynamic topic subscription
- Automatic inclusion of new matching topics
- Centralized processing logic

## Kafka Streams Examples

### Example 10: WordCount with Kafka Streams

Classic streaming example with stateful aggregation.

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.util.Arrays;
import java.util.Properties;

public class WordCountStreams {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "wordcount-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();

        // Read from input topic
        KStream<String, String> textLines = builder.stream("text-input");

        // WordCount processing
        KTable<String, Long> wordCounts = textLines
            // Split text into words
            .flatMapValues(textLine -> Arrays.asList(textLine.toLowerCase().split("\\W+")))
            // Group by word
            .groupBy((key, word) -> word)
            // Count occurrences
            .count(Materialized.as("counts-store"));

        // Write results to output topic
        wordCounts.toStream()
            .to("word-counts-output", Produced.with(Serdes.String(), Serdes.Long()));

        KafkaStreams streams = new KafkaStreams(builder.build(), props);

        // Add shutdown hook for graceful termination
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));

        streams.start();
    }
}
```

### Example 11: Stream-Stream Join

Join two streams based on time windows.

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.time.Duration;
import java.util.Properties;

public class StreamStreamJoin {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "stream-join-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();

        // Page view events
        KStream<String, String> pageViews = builder.stream("page-views");

        // Click events
        KStream<String, String> clicks = builder.stream("clicks");

        // Join within 5-minute window
        KStream<String, String> joined = pageViews.join(
            clicks,
            (pageView, click) -> "PageView: " + pageView + ", Click: " + click,
            JoinWindows.of(Duration.ofMinutes(5)),
            StreamJoined.with(Serdes.String(), Serdes.String(), Serdes.String())
        );

        joined.to("page-view-clicks");

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

### Example 12: Windowed Aggregations

Time-based aggregations with tumbling, hopping, and session windows.

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.time.Duration;
import java.util.Properties;

public class WindowedAggregations {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "windowed-agg-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

        StreamsBuilder builder = new StreamsBuilder();

        KStream<String, Long> events = builder.stream(
            "sensor-events",
            Consumed.with(Serdes.String(), Serdes.Long())
        );

        // Tumbling Window: Fixed, non-overlapping 5-minute windows
        KTable<Windowed<String>, Long> tumblingCounts = events
            .groupByKey()
            .windowedBy(TimeWindows.of(Duration.ofMinutes(5)))
            .count();

        tumblingCounts.toStream()
            .map((windowedKey, count) -> {
                String key = windowedKey.key() + "@" +
                    windowedKey.window().startTime() + "-" +
                    windowedKey.window().endTime();
                return new KeyValue<>(key, count);
            })
            .to("tumbling-counts", Produced.with(Serdes.String(), Serdes.Long()));

        // Hopping Window: Overlapping 5-minute windows advancing by 1 minute
        KTable<Windowed<String>, Long> hoppingCounts = events
            .groupByKey()
            .windowedBy(TimeWindows.of(Duration.ofMinutes(5))
                .advanceBy(Duration.ofMinutes(1)))
            .count();

        hoppingCounts.toStream()
            .map((windowedKey, count) -> {
                String key = windowedKey.key() + "@" +
                    windowedKey.window().startTime() + "-" +
                    windowedKey.window().endTime();
                return new KeyValue<>(key, count);
            })
            .to("hopping-counts", Produced.with(Serdes.String(), Serdes.Long()));

        // Session Window: Activity-based windows with 30-minute inactivity gap
        KTable<Windowed<String>, Long> sessionCounts = events
            .groupByKey()
            .windowedBy(SessionWindows.with(Duration.ofMinutes(30)))
            .count();

        sessionCounts.toStream()
            .map((windowedKey, count) -> {
                String key = windowedKey.key() + "@session-" +
                    windowedKey.window().startTime() + "-" +
                    windowedKey.window().endTime();
                return new KeyValue<>(key, count);
            })
            .to("session-counts", Produced.with(Serdes.String(), Serdes.Long()));

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

### Example 13: Stream-Table Join with GlobalKTable

Join stream with reference data from GlobalKTable.

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.util.Properties;

public class StreamTableJoin {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "stream-table-join-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

        StreamsBuilder builder = new StreamsBuilder();

        // Stream of user activity events
        KStream<String, String> userActivity = builder.stream(
            "user-activity",
            Consumed.with(Serdes.String(), Serdes.String())
        );

        // GlobalKTable of user profiles (fully replicated to all instances)
        GlobalKTable<String, String> userProfiles = builder.globalTable(
            "user-profiles",
            Consumed.with(Serdes.String(), Serdes.String())
        );

        // Join activity with profile data
        KStream<String, String> enrichedActivity = userActivity.join(
            userProfiles,
            (activityKey, activityValue) -> activityKey, // Key extractor
            (activity, profile) -> "Activity: " + activity + ", Profile: " + profile
        );

        enrichedActivity.to("enriched-activity");

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

### Example 14: Exactly-Once Streams Processing

Configure Kafka Streams for exactly-once semantics.

```java
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;
import java.util.Properties;

public class ExactlyOnceStreams {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "exactly-once-app");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

        // Enable exactly-once processing (EOS version 2)
        props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, StreamsConfig.EXACTLY_ONCE_V2);

        // Configure for exactly-once
        props.put(StreamsConfig.REPLICATION_FACTOR_CONFIG, 3);
        props.put(StreamsConfig.producerPrefix(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG), true);
        props.put(StreamsConfig.consumerPrefix(ConsumerConfig.ISOLATION_LEVEL_CONFIG), "read_committed");

        StreamsBuilder builder = new StreamsBuilder();

        KStream<String, Double> transactions = builder.stream(
            "financial-transactions",
            Consumed.with(Serdes.String(), Serdes.Double())
        );

        // Aggregate transaction amounts by account
        KTable<String, Double> accountBalances = transactions
            .groupByKey()
            .aggregate(
                () -> 0.0, // Initializer
                (key, value, aggregate) -> aggregate + value, // Aggregator
                Materialized.with(Serdes.String(), Serdes.Double())
            );

        accountBalances.toStream().to(
            "account-balances",
            Produced.with(Serdes.String(), Serdes.Double())
        );

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }
}
```

## Schema Registry Examples

### Example 15: Avro Producer with Schema Registry

Produce Avro-encoded messages with schema validation.

```java
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class AvroProducer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
        props.put("schema.registry.url", "http://localhost:8081");

        // Define Avro schema
        String userSchema = "{"
            + "\"type\":\"record\","
            + "\"name\":\"User\","
            + "\"namespace\":\"com.example\","
            + "\"fields\":["
            + "  {\"name\":\"id\",\"type\":\"string\"},"
            + "  {\"name\":\"name\",\"type\":\"string\"},"
            + "  {\"name\":\"age\",\"type\":\"int\"},"
            + "  {\"name\":\"email\",\"type\":[\"null\",\"string\"],\"default\":null}"
            + "]}";

        Schema.Parser parser = new Schema.Parser();
        Schema schema = parser.parse(userSchema);

        try (KafkaProducer<String, GenericRecord> producer = new KafkaProducer<>(props)) {
            // Create Avro record
            GenericRecord user = new GenericData.Record(schema);
            user.put("id", "user123");
            user.put("name", "John Doe");
            user.put("age", 30);
            user.put("email", "john@example.com");

            ProducerRecord<String, GenericRecord> record =
                new ProducerRecord<>("users-avro", "user123", user);

            producer.send(record, (metadata, exception) -> {
                if (exception == null) {
                    System.out.printf("Avro record sent: topic=%s partition=%d offset=%d%n",
                        metadata.topic(), metadata.partition(), metadata.offset());
                } else {
                    System.err.println("Error sending Avro record: " + exception.getMessage());
                }
            });
        }
    }
}
```

### Example 16: Avro Consumer with Schema Registry

Consume and deserialize Avro messages.

```java
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.*;

public class AvroConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "avro-consumer-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, KafkaAvroDeserializer.class);
        props.put("schema.registry.url", "http://localhost:8081");
        props.put("specific.avro.reader", "false");

        try (KafkaConsumer<String, GenericRecord> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList("users-avro"));

            while (true) {
                ConsumerRecords<String, GenericRecord> records =
                    consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, GenericRecord> record : records) {
                    GenericRecord user = record.value();

                    System.out.printf("Consumed Avro record:%n");
                    System.out.printf("  ID: %s%n", user.get("id"));
                    System.out.printf("  Name: %s%n", user.get("name"));
                    System.out.printf("  Age: %d%n", user.get("age"));
                    System.out.printf("  Email: %s%n", user.get("email"));
                }
            }
        }
    }
}
```

## Kafka Connect Examples

### Example 17: JDBC Source Connector Configuration

Stream database changes to Kafka using JDBC source connector.

```json
{
  "name": "postgres-source-connector",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
    "tasks.max": "1",

    "connection.url": "jdbc:postgresql://localhost:5432/mydb",
    "connection.user": "postgres",
    "connection.password": "password",

    "table.whitelist": "users,orders,products",
    "mode": "incrementing",
    "incrementing.column.name": "id",

    "topic.prefix": "postgres-",
    "poll.interval.ms": "1000",

    "transforms": "createKey,extractInt",
    "transforms.createKey.type": "org.apache.kafka.connect.transforms.ValueToKey",
    "transforms.createKey.fields": "id",
    "transforms.extractInt.type": "org.apache.kafka.connect.transforms.ExtractField$Key",
    "transforms.extractInt.field": "id"
  }
}
```

**Deploy Connector:**

```bash
# Create connector via REST API
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @postgres-source.json

# Check connector status
curl http://localhost:8083/connectors/postgres-source-connector/status

# List all connectors
curl http://localhost:8083/connectors
```

### Example 18: Elasticsearch Sink Connector

Stream Kafka data to Elasticsearch for search and analytics.

```json
{
  "name": "elasticsearch-sink-connector",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1",

    "topics": "user-events,order-events,product-events",

    "connection.url": "http://localhost:9200",
    "connection.username": "elastic",
    "connection.password": "password",

    "type.name": "_doc",
    "key.ignore": "false",
    "schema.ignore": "true",

    "behavior.on.null.values": "delete",
    "behavior.on.malformed.documents": "warn",

    "batch.size": "2000",
    "max.buffered.records": "20000",
    "linger.ms": "1000",

    "read.timeout.ms": "120000",
    "connection.timeout.ms": "30000"
  }
}
```

### Example 19: Debezium CDC Connector (MySQL)

Capture database changes in real-time using Debezium.

```json
{
  "name": "mysql-debezium-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",

    "database.hostname": "mysql-server",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "dbz",

    "database.server.id": "184054",
    "database.server.name": "mysql-prod",

    "database.include.list": "inventory",
    "table.include.list": "inventory.customers,inventory.orders",

    "database.history.kafka.bootstrap.servers": "localhost:9092",
    "database.history.kafka.topic": "schema-changes.inventory",

    "snapshot.mode": "initial",
    "snapshot.locking.mode": "minimal",

    "include.schema.changes": "true",
    "tombstones.on.delete": "true",

    "transforms": "route",
    "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
    "transforms.route.replacement": "$3"
  }
}
```

**CDC Benefits:**
- Real-time data synchronization
- Event sourcing from existing databases
- Zero application code changes
- Capture inserts, updates, deletes

## Production Patterns

### Example 20: Dead Letter Queue (DLQ) Pattern

Handle failed messages by routing to DLQ topic.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.*;
import java.time.Duration;
import java.util.*;

public class DLQConsumer {
    private final KafkaConsumer<String, String> consumer;
    private final KafkaProducer<String, String> dlqProducer;
    private final String dlqTopic;

    public DLQConsumer(String groupId, String inputTopic, String dlqTopic) {
        this.dlqTopic = dlqTopic;

        // Consumer configuration
        Properties consumerProps = new Properties();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        consumerProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

        this.consumer = new KafkaConsumer<>(consumerProps);
        consumer.subscribe(Collections.singletonList(inputTopic));

        // DLQ producer configuration
        Properties producerProps = new Properties();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);

        this.dlqProducer = new KafkaProducer<>(producerProps);
    }

    public void processMessages() {
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

            for (ConsumerRecord<String, String> record : records) {
                try {
                    // Attempt to process record
                    processRecord(record);

                } catch (RetriableException e) {
                    // Transient error - retry
                    System.err.println("Retrying record: " + e.getMessage());
                    retryRecord(record);

                } catch (NonRetriableException e) {
                    // Permanent error - send to DLQ
                    System.err.println("Sending to DLQ: " + e.getMessage());
                    sendToDLQ(record, e);
                }
            }

            consumer.commitSync();
        }
    }

    private void processRecord(ConsumerRecord<String, String> record)
            throws RetriableException, NonRetriableException {
        // Business logic that may throw exceptions
        if (record.value() == null) {
            throw new NonRetriableException("Null value not allowed");
        }
        // Process record...
    }

    private void retryRecord(ConsumerRecord<String, String> record) {
        // Implement retry logic (exponential backoff, max retries, etc.)
    }

    private void sendToDLQ(ConsumerRecord<String, String> record, Exception error) {
        // Add error metadata to headers
        Headers headers = record.headers();
        headers.add("dlq.error.message", error.getMessage().getBytes());
        headers.add("dlq.error.class", error.getClass().getName().getBytes());
        headers.add("dlq.original.topic", record.topic().getBytes());
        headers.add("dlq.original.partition", String.valueOf(record.partition()).getBytes());
        headers.add("dlq.original.offset", String.valueOf(record.offset()).getBytes());

        ProducerRecord<String, String> dlqRecord =
            new ProducerRecord<>(dlqTopic, null, record.key(), record.value(), headers);

        dlqProducer.send(dlqRecord, (metadata, exception) -> {
            if (exception != null) {
                System.err.println("Failed to send to DLQ: " + exception.getMessage());
            }
        });
    }

    static class RetriableException extends Exception {
        public RetriableException(String message) { super(message); }
    }

    static class NonRetriableException extends Exception {
        public NonRetriableException(String message) { super(message); }
    }
}
```

### Example 21: Outbox Pattern for Reliable Publishing

Ensure database and Kafka writes are atomic.

```sql
-- Database outbox table
CREATE TABLE outbox (
    id UUID PRIMARY KEY,
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Application writes to both business table and outbox in same transaction
BEGIN;
    INSERT INTO orders (id, customer_id, total)
    VALUES ('order-123', 'customer-456', 99.99);

    INSERT INTO outbox (id, aggregate_type, aggregate_id, event_type, payload)
    VALUES (
        uuid_generate_v4(),
        'Order',
        'order-123',
        'OrderCreated',
        '{"orderId": "order-123", "customerId": "customer-456", "total": 99.99}'::jsonb
    );
COMMIT;
```

**Debezium Connector for Outbox:**

```json
{
  "name": "outbox-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "localhost",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "password",
    "database.dbname": "myapp",
    "database.server.name": "myapp",

    "table.include.list": "public.outbox",

    "transforms": "outbox",
    "transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter",
    "transforms.outbox.table.field.event.id": "id",
    "transforms.outbox.table.field.event.key": "aggregate_id",
    "transforms.outbox.table.field.event.type": "event_type",
    "transforms.outbox.table.field.event.payload": "payload",
    "transforms.outbox.route.topic.replacement": "${routedByValue}",

    "tombstones.on.delete": "false"
  }
}
```

## Testing Strategies

### Example 22: Kafka Streams Testing with TopologyTestDriver

Unit test Kafka Streams topology without running Kafka.

```java
import org.apache.kafka.common.serialization.*;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.test.*;
import org.junit.jupiter.api.*;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

public class WordCountStreamTest {
    private TopologyTestDriver testDriver;
    private TestInputTopic<String, String> inputTopic;
    private TestOutputTopic<String, Long> outputTopic;

    @BeforeEach
    public void setup() {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "test");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "dummy:1234");

        // Build topology
        StreamsBuilder builder = new StreamsBuilder();
        KStream<String, String> input = builder.stream("input");
        input.flatMapValues(value -> Arrays.asList(value.toLowerCase().split("\\W+")))
             .groupBy((key, word) -> word)
             .count()
             .toStream()
             .to("output");

        Topology topology = builder.build();
        testDriver = new TopologyTestDriver(topology, props);

        // Create test topics
        inputTopic = testDriver.createInputTopic(
            "input",
            new StringSerializer(),
            new StringSerializer()
        );

        outputTopic = testDriver.createOutputTopic(
            "output",
            new StringDeserializer(),
            new LongDeserializer()
        );
    }

    @AfterEach
    public void tearDown() {
        testDriver.close();
    }

    @Test
    public void testWordCount() {
        // Send test data
        inputTopic.pipeInput("key1", "hello world");
        inputTopic.pipeInput("key2", "hello kafka streams");

        // Verify output
        Map<String, Long> expectedCounts = Map.of(
            "hello", 2L,
            "world", 1L,
            "kafka", 1L,
            "streams", 1L
        );

        Map<String, Long> actualCounts = outputTopic.readKeyValuesToMap();
        assertEquals(expectedCounts, actualCounts);
    }

    @Test
    public void testEmptyInput() {
        inputTopic.pipeInput("key", "");
        assertTrue(outputTopic.isEmpty());
    }
}
```

### Example 23: Integration Testing with Testcontainers

Integration test with real Kafka using Testcontainers.

```java
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.clients.producer.*;
import org.junit.jupiter.api.*;
import org.testcontainers.containers.KafkaContainer;
import org.testcontainers.utility.DockerImageName;
import java.time.Duration;
import java.util.*;

public class KafkaIntegrationTest {
    private static KafkaContainer kafka;

    @BeforeAll
    public static void setUp() {
        kafka = new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:7.4.0"));
        kafka.start();
    }

    @AfterAll
    public static void tearDown() {
        kafka.stop();
    }

    @Test
    public void testProducerConsumer() throws Exception {
        String topic = "test-topic";
        String testMessage = "integration-test-message";

        // Producer
        Properties producerProps = new Properties();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafka.getBootstrapServers());
        producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
            "org.apache.kafka.common.serialization.StringSerializer");
        producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
            "org.apache.kafka.common.serialization.StringSerializer");

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(producerProps)) {
            producer.send(new ProducerRecord<>(topic, "key", testMessage)).get();
        }

        // Consumer
        Properties consumerProps = new Properties();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafka.getBootstrapServers());
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, "test-group");
        consumerProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
            "org.apache.kafka.common.serialization.StringDeserializer");
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
            "org.apache.kafka.common.serialization.StringDeserializer");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(consumerProps)) {
            consumer.subscribe(Collections.singletonList(topic));

            ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(10));
            assertEquals(1, records.count());

            ConsumerRecord<String, String> record = records.iterator().next();
            assertEquals(testMessage, record.value());
        }
    }
}
```

---

## Summary

These 23 examples cover:

1. **Producers (5 examples)**: Sync/async, idempotent, custom partitioner, compression
2. **Consumers (4 examples)**: Manual commit, rebalance handling, seek/replay, multi-topic
3. **Kafka Streams (5 examples)**: WordCount, joins, windowing, exactly-once
4. **Schema Registry (2 examples)**: Avro producer/consumer
5. **Kafka Connect (3 examples)**: JDBC source, Elasticsearch sink, Debezium CDC
6. **Production Patterns (2 examples)**: DLQ, outbox pattern
7. **Testing (2 examples)**: Unit tests, integration tests

Each example is production-ready and demonstrates best practices for building robust, scalable Kafka applications.
