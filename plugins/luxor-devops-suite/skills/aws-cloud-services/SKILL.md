---
name: aws-cloud-services
description: Comprehensive AWS cloud services skill covering S3, Lambda, DynamoDB, EC2, RDS, IAM, CloudFormation, and enterprise cloud architecture patterns with AWS SDK
---

# AWS Cloud Services

A comprehensive skill for building, deploying, and managing cloud infrastructure on Amazon Web Services (AWS). Master S3 object storage, Lambda serverless functions, DynamoDB NoSQL databases, EC2 compute instances, RDS relational databases, IAM security, CloudFormation infrastructure as code, and enterprise-grade cloud architecture patterns.

## When to Use This Skill

Use this skill when:

- Building scalable cloud applications on AWS infrastructure
- Implementing serverless architectures with Lambda and API Gateway
- Managing object storage and file uploads with S3
- Designing NoSQL database solutions with DynamoDB
- Deploying EC2 instances and managing compute resources
- Setting up RDS databases for relational data storage
- Implementing IAM security policies and access control
- Automating infrastructure deployment with CloudFormation
- Architecting multi-region, highly available systems
- Optimizing cloud costs and performance
- Migrating on-premises applications to AWS
- Implementing event-driven architectures
- Building data pipelines and analytics solutions
- Managing secrets and credentials securely
- Setting up CI/CD pipelines with AWS services

## Core Concepts

### AWS Fundamentals

AWS is Amazon's comprehensive cloud computing platform offering 200+ services across compute, storage, databases, networking, security, and more.

#### Key Concepts

**Regions and Availability Zones**
- **Regions**: Geographic areas with multiple data centers (e.g., us-east-1, eu-west-1)
- **Availability Zones (AZs)**: Isolated data centers within a region
- **Edge Locations**: CDN endpoints for CloudFront content delivery
- **Local Zones**: Extensions of regions for ultra-low latency

**AWS Account Structure**
- **Root Account**: Primary account with full access (use sparingly)
- **IAM Users**: Individual user accounts with specific permissions
- **IAM Roles**: Temporary credentials for services and applications
- **Organizations**: Multi-account management for enterprises

**Service Categories**
- **Compute**: EC2, Lambda, ECS, EKS, Fargate
- **Storage**: S3, EBS, EFS, Glacier
- **Database**: RDS, DynamoDB, Aurora, ElastiCache, Redshift
- **Networking**: VPC, Route 53, CloudFront, API Gateway, ELB
- **Security**: IAM, Cognito, Secrets Manager, KMS, WAF
- **Infrastructure**: CloudFormation, CDK, Systems Manager
- **Monitoring**: CloudWatch, X-Ray, CloudTrail

### AWS SDK for JavaScript v3

The AWS SDK v3 is modular, tree-shakable, and optimized for modern JavaScript/TypeScript applications.

#### Key Improvements

**Modular Architecture**
```javascript
// v2 (monolithic)
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

// v3 (modular)
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
const client = new S3Client({ region: 'us-east-1' });
```

**Command Pattern**
- Each operation is a command class
- Clear separation between client and commands
- Better TypeScript support and type inference

**Middleware Stack**
- Customizable request/response pipeline
- Built-in retry and exponential backoff
- Request signing and authentication

### Identity and Access Management (IAM)

IAM controls authentication and authorization across all AWS services.

#### Core IAM Components

**Users**
- Individual identities with long-term credentials
- Access keys for programmatic access
- Passwords for console access
- MFA (Multi-Factor Authentication) support

**Groups**
- Collections of users
- Attach policies to manage permissions collectively
- Users can belong to multiple groups

**Roles**
- Temporary credentials assumed by users, services, or applications
- Cross-account access
- Service-to-service communication
- Federation with external identity providers

**Policies**
- JSON documents defining permissions
- Identity-based policies (attached to users/groups/roles)
- Resource-based policies (attached to resources like S3 buckets)
- Service control policies (SCPs) for Organizations

#### Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

**Policy Elements**
- **Effect**: Allow or Deny
- **Action**: Services and operations (e.g., s3:GetObject)
- **Resource**: ARN of resources affected
- **Condition**: Optional constraints (IP, time, MFA, etc.)
- **Principal**: Who the policy applies to (for resource-based policies)

#### Least Privilege Principle

Always grant minimum permissions necessary:
- Start with no permissions
- Add permissions incrementally as needed
- Use managed policies for common patterns
- Create custom policies for specific use cases
- Regularly audit and remove unused permissions

### Credential Management

#### Credential Chain

The SDK searches for credentials in this order:

1. **Environment variables**: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
2. **Shared credentials file**: ~/.aws/credentials
3. **Shared config file**: ~/.aws/config
4. **IAM role (EC2/ECS/Lambda)**: Instance metadata service
5. **Process credentials**: From a custom executable

#### Best Practices

- **Never hardcode credentials** in source code
- **Use IAM roles** for EC2, Lambda, ECS
- **Use temporary credentials** whenever possible
- **Rotate access keys** regularly (90 days recommended)
- **Use AWS Secrets Manager** for application secrets
- **Enable MFA** for privileged accounts
- **Use AWS SSO** for centralized access management

### Regions and Endpoint Configuration

```javascript
import { S3Client } from '@aws-sdk/client-s3';

// Specify region explicitly
const client = new S3Client({
  region: 'us-west-2',
  endpoint: 'https://s3.us-west-2.amazonaws.com' // Optional custom endpoint
});

// Use default region from environment/config
const defaultClient = new S3Client({}); // Uses AWS_REGION or default region
```

## S3 (Simple Storage Service)

S3 is AWS's object storage service for storing and retrieving any amount of data from anywhere.

### Core S3 Concepts

#### Buckets

- **Globally unique names**: Must be unique across all AWS accounts
- **Regional resources**: Created in a specific region
- **Unlimited objects**: No limit on number of objects
- **Bucket policies**: Resource-based access control
- **Versioning**: Keep multiple versions of objects
- **Encryption**: Server-side and client-side encryption

#### Objects

- **Key-value store**: Key is the object name, value is the data
- **Metadata**: System and user-defined metadata
- **Size limit**: 5TB per object
- **Multipart upload**: For objects > 100MB (required for > 5GB)
- **Storage classes**: Standard, IA, Glacier, etc.

#### S3 Storage Classes

**S3 Standard**
- Frequently accessed data
- 99.99% availability
- Millisecond latency

**S3 Intelligent-Tiering**
- Automatic cost optimization
- Moves data between access tiers

**S3 Standard-IA (Infrequent Access)**
- Lower cost for infrequently accessed data
- Retrieval fees apply

**S3 One Zone-IA**
- Single AZ storage for less critical data
- 20% cheaper than Standard-IA

**S3 Glacier**
- Long-term archival
- Minutes to hours retrieval
- Very low cost

**S3 Glacier Deep Archive**
- Lowest cost storage
- 12-hour retrieval
- Ideal for compliance archives

### S3 Operations

#### Upload Objects

```javascript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { readFileSync } from 'fs';

const client = new S3Client({ region: 'us-east-1' });

// Simple upload
const uploadFile = async (bucketName, key, filePath) => {
  const fileContent = readFileSync(filePath);

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    Body: fileContent,
    ContentType: 'image/jpeg', // Optional
    Metadata: { // Optional custom metadata
      'uploaded-by': 'user-123',
      'upload-date': new Date().toISOString()
    },
    ServerSideEncryption: 'AES256', // Enable encryption
    ACL: 'private' // Access control
  });

  const response = await client.send(command);
  return response;
};
```

#### Download Objects

```javascript
import { GetObjectCommand } from '@aws-sdk/client-s3';
import { writeFileSync } from 'fs';

const downloadFile = async (bucketName, key, destinationPath) => {
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: key
  });

  const response = await client.send(command);

  // Convert stream to buffer
  const chunks = [];
  for await (const chunk of response.Body) {
    chunks.push(chunk);
  }
  const buffer = Buffer.concat(chunks);

  writeFileSync(destinationPath, buffer);
  return response.Metadata;
};
```

#### List Objects

```javascript
import { ListObjectsV2Command } from '@aws-sdk/client-s3';

const listObjects = async (bucketName, prefix = '') => {
  const command = new ListObjectsV2Command({
    Bucket: bucketName,
    Prefix: prefix, // Filter by prefix
    MaxKeys: 1000, // Max 1000 per request
    Delimiter: '/' // Treat / as folder separator
  });

  const response = await client.send(command);
  return response.Contents; // Array of objects
};

// Pagination for large buckets
const listAllObjects = async (bucketName) => {
  let allObjects = [];
  let continuationToken;

  do {
    const command = new ListObjectsV2Command({
      Bucket: bucketName,
      ContinuationToken: continuationToken
    });

    const response = await client.send(command);
    allObjects = allObjects.concat(response.Contents || []);
    continuationToken = response.NextContinuationToken;
  } while (continuationToken);

  return allObjects;
};
```

#### Delete Objects

```javascript
import { DeleteObjectCommand, DeleteObjectsCommand } from '@aws-sdk/client-s3';

// Delete single object
const deleteObject = async (bucketName, key) => {
  const command = new DeleteObjectCommand({
    Bucket: bucketName,
    Key: key
  });

  await client.send(command);
};

// Delete multiple objects (up to 1000 at once)
const deleteMultipleObjects = async (bucketName, keys) => {
  const command = new DeleteObjectsCommand({
    Bucket: bucketName,
    Delete: {
      Objects: keys.map(key => ({ Key: key })),
      Quiet: false // Return list of deleted objects
    }
  });

  const response = await client.send(command);
  return response.Deleted;
};
```

### Presigned URLs

Generate temporary URLs for secure file uploads/downloads without AWS credentials.

```javascript
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';

// Presigned URL for upload
const createUploadUrl = async (bucketName, key, expiresIn = 3600) => {
  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    ContentType: 'image/jpeg'
  });

  const url = await getSignedUrl(client, command, { expiresIn });
  return url; // Client can PUT to this URL
};

// Presigned URL for download
const createDownloadUrl = async (bucketName, key, expiresIn = 3600) => {
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: key
  });

  const url = await getSignedUrl(client, command, { expiresIn });
  return url; // Client can GET from this URL
};
```

### Multipart Upload

For large files (> 100MB), use multipart upload for better performance and reliability.

```javascript
import {
  CreateMultipartUploadCommand,
  UploadPartCommand,
  CompleteMultipartUploadCommand,
  AbortMultipartUploadCommand
} from '@aws-sdk/client-s3';

const multipartUpload = async (bucketName, key, fileBuffer, partSize = 5 * 1024 * 1024) => {
  // 1. Initiate multipart upload
  const createCommand = new CreateMultipartUploadCommand({
    Bucket: bucketName,
    Key: key
  });

  const { UploadId } = await client.send(createCommand);

  try {
    // 2. Upload parts
    const parts = [];
    const numParts = Math.ceil(fileBuffer.length / partSize);

    for (let i = 0; i < numParts; i++) {
      const start = i * partSize;
      const end = Math.min(start + partSize, fileBuffer.length);
      const partBody = fileBuffer.slice(start, end);

      const uploadCommand = new UploadPartCommand({
        Bucket: bucketName,
        Key: key,
        UploadId,
        PartNumber: i + 1,
        Body: partBody
      });

      const { ETag } = await client.send(uploadCommand);
      parts.push({ PartNumber: i + 1, ETag });
    }

    // 3. Complete multipart upload
    const completeCommand = new CompleteMultipartUploadCommand({
      Bucket: bucketName,
      Key: key,
      UploadId,
      MultipartUpload: { Parts: parts }
    });

    const result = await client.send(completeCommand);
    return result;

  } catch (error) {
    // Abort on error to avoid storage charges for incomplete uploads
    const abortCommand = new AbortMultipartUploadCommand({
      Bucket: bucketName,
      Key: key,
      UploadId
    });
    await client.send(abortCommand);
    throw error;
  }
};
```

## Lambda

AWS Lambda is a serverless compute service that runs code in response to events without provisioning servers.

### Lambda Core Concepts

#### Execution Model

- **Event-driven**: Triggered by events from AWS services or HTTP requests
- **Stateless**: Each invocation is independent
- **Concurrent execution**: Automatically scales based on demand
- **Timeout**: 15-minute maximum execution time
- **Memory**: 128MB to 10GB (CPU scales with memory)

#### Handler Function

```javascript
// Lambda handler signature
export const handler = async (event, context) => {
  // event: Input data (API request, S3 event, etc.)
  // context: Runtime information (request ID, remaining time, etc.)

  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Request ID:', context.requestId);
  console.log('Remaining time:', context.getRemainingTimeInMillis());

  // Process event
  const result = await processEvent(event);

  // Return response
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(result)
  };
};
```

#### Invocation Types

**Synchronous (RequestResponse)**
- API Gateway, SDK invoke
- Caller waits for response
- Error returned to caller

**Asynchronous (Event)**
- S3, SNS, CloudWatch Events
- Lambda queues event and returns immediately
- Built-in retry (2 attempts)
- Dead letter queue for failures

**Poll-based (Stream)**
- DynamoDB Streams, Kinesis
- Lambda polls stream and invokes function
- Ordered processing within shard

### Lambda Configuration

```javascript
// Using AWS SDK to create/update Lambda function
import {
  LambdaClient,
  CreateFunctionCommand,
  UpdateFunctionCodeCommand,
  UpdateFunctionConfigurationCommand
} from '@aws-sdk/client-lambda';

const lambdaClient = new LambdaClient({ region: 'us-east-1' });

const createFunction = async () => {
  const command = new CreateFunctionCommand({
    FunctionName: 'myFunction',
    Runtime: 'nodejs20.x',
    Role: 'arn:aws:iam::123456789012:role/lambda-execution-role',
    Handler: 'index.handler',
    Code: {
      ZipFile: zipBuffer // Or S3Bucket/S3Key for S3-stored code
    },
    Environment: {
      Variables: {
        'BUCKET_NAME': 'my-bucket',
        'TABLE_NAME': 'my-table'
      }
    },
    MemorySize: 512, // MB
    Timeout: 30, // seconds
    Tags: {
      'Environment': 'production',
      'Team': 'backend'
    }
  });

  const response = await lambdaClient.send(command);
  return response.FunctionArn;
};
```

### Lambda Event Sources

#### API Gateway Integration

```javascript
// Lambda function for API Gateway
export const handler = async (event) => {
  // Parse request
  const { httpMethod, path, queryStringParameters, body } = event;
  const requestBody = body ? JSON.parse(body) : null;

  // Route based on HTTP method and path
  if (httpMethod === 'GET' && path === '/users') {
    const users = await getUsers();
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(users)
    };
  }

  if (httpMethod === 'POST' && path === '/users') {
    const newUser = await createUser(requestBody);
    return {
      statusCode: 201,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newUser)
    };
  }

  // Not found
  return {
    statusCode: 404,
    body: JSON.stringify({ message: 'Not found' })
  };
};
```

#### S3 Event Integration

```javascript
// Lambda function triggered by S3 events
export const handler = async (event) => {
  // Process each S3 event record
  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    const eventName = record.eventName;

    console.log(`Event: ${eventName}, Bucket: ${bucket}, Key: ${key}`);

    if (eventName.startsWith('ObjectCreated:')) {
      await processNewFile(bucket, key);
    } else if (eventName.startsWith('ObjectRemoved:')) {
      await handleFileDeleted(bucket, key);
    }
  }

  return { statusCode: 200 };
};
```

#### DynamoDB Streams Integration

```javascript
// Lambda function for DynamoDB Streams
export const handler = async (event) => {
  for (const record of event.Records) {
    const { eventName, dynamodb } = record;

    // INSERT, MODIFY, REMOVE
    console.log(`Event: ${eventName}`);

    if (eventName === 'INSERT') {
      const newItem = AWS.DynamoDB.Converter.unmarshall(dynamodb.NewImage);
      await handleNewItem(newItem);
    }

    if (eventName === 'MODIFY') {
      const oldItem = AWS.DynamoDB.Converter.unmarshall(dynamodb.OldImage);
      const newItem = AWS.DynamoDB.Converter.unmarshall(dynamodb.NewImage);
      await handleItemUpdate(oldItem, newItem);
    }

    if (eventName === 'REMOVE') {
      const oldItem = AWS.DynamoDB.Converter.unmarshall(dynamodb.OldImage);
      await handleItemDeleted(oldItem);
    }
  }
};
```

### Lambda Best Practices

**Cold Start Optimization**
- Keep deployment package small
- Minimize external dependencies
- Use provisioned concurrency for latency-sensitive functions
- Initialize SDK clients outside handler

**Error Handling**
```javascript
export const handler = async (event) => {
  try {
    // Process event
    const result = await processEvent(event);
    return { statusCode: 200, body: JSON.stringify(result) };

  } catch (error) {
    console.error('Error processing event:', error);

    // Log to CloudWatch
    console.error('Error details:', {
      message: error.message,
      stack: error.stack,
      event
    });

    // Return error response
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: 'Internal server error',
        requestId: context.requestId
      })
    };
  }
};
```

**Environment Variables**
```javascript
// Access environment variables
const BUCKET_NAME = process.env.BUCKET_NAME;
const TABLE_NAME = process.env.TABLE_NAME;
const API_KEY = process.env.API_KEY; // Use Secrets Manager for sensitive data
```

## DynamoDB

DynamoDB is a fully managed NoSQL database service for single-digit millisecond performance at any scale.

### DynamoDB Core Concepts

#### Tables and Items

**Table**: Collection of items (like a table in SQL)
**Item**: Individual record (like a row), max 400KB
**Attribute**: Key-value pair (like a column)
**Primary Key**: Uniquely identifies each item

#### Primary Key Types

**Partition Key (Simple Primary Key)**
```
User Table:
- userId (Partition Key) -> "user-123"
- name -> "John Doe"
- email -> "john@example.com"
```

**Partition Key + Sort Key (Composite Primary Key)**
```
Order Table:
- userId (Partition Key) -> "user-123"
- orderId (Sort Key) -> "order-456"
- total -> 99.99
- status -> "shipped"
```

#### Indexes

**Global Secondary Index (GSI)**
- Different partition key and/or sort key
- Spans all partitions
- Eventually consistent
- Can be created/deleted anytime

**Local Secondary Index (LSI)**
- Same partition key, different sort key
- Scoped to partition
- Strongly or eventually consistent
- Must be created with table

### DynamoDB Operations

#### Put Item

```javascript
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);

const putItem = async (tableName, item) => {
  const command = new PutCommand({
    TableName: tableName,
    Item: item,
    ConditionExpression: 'attribute_not_exists(userId)', // Prevent overwrite
    ReturnValues: 'ALL_OLD' // Return previous item if existed
  });

  try {
    const response = await docClient.send(command);
    return response;
  } catch (error) {
    if (error.name === 'ConditionalCheckFailedException') {
      console.log('Item already exists');
    }
    throw error;
  }
};

// Example usage
await putItem('Users', {
  userId: 'user-123',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: new Date().toISOString(),
  preferences: {
    theme: 'dark',
    notifications: true
  }
});
```

#### Get Item

```javascript
import { GetCommand } from '@aws-sdk/lib-dynamodb';

const getItem = async (tableName, key) => {
  const command = new GetCommand({
    TableName: tableName,
    Key: key,
    ConsistentRead: true, // Strong consistency (default: false)
    ProjectionExpression: 'userId, #n, email', // Return specific attributes
    ExpressionAttributeNames: {
      '#n': 'name' // name is reserved word, use placeholder
    }
  });

  const response = await docClient.send(command);
  return response.Item;
};

// Example usage
const user = await getItem('Users', { userId: 'user-123' });
```

#### Update Item

```javascript
import { UpdateCommand } from '@aws-sdk/lib-dynamodb';

const updateItem = async (tableName, key, updates) => {
  const command = new UpdateCommand({
    TableName: tableName,
    Key: key,
    UpdateExpression: 'SET #n = :name, email = :email, updatedAt = :now',
    ExpressionAttributeNames: {
      '#n': 'name'
    },
    ExpressionAttributeValues: {
      ':name': updates.name,
      ':email': updates.email,
      ':now': new Date().toISOString()
    },
    ConditionExpression: 'attribute_exists(userId)', // Only update if exists
    ReturnValues: 'ALL_NEW' // Return updated item
  });

  const response = await docClient.send(command);
  return response.Attributes;
};

// Atomic counter increment
const incrementCounter = async (tableName, key, counterAttribute) => {
  const command = new UpdateCommand({
    TableName: tableName,
    Key: key,
    UpdateExpression: 'ADD #counter :inc',
    ExpressionAttributeNames: {
      '#counter': counterAttribute
    },
    ExpressionAttributeValues: {
      ':inc': 1
    },
    ReturnValues: 'UPDATED_NEW'
  });

  const response = await docClient.send(command);
  return response.Attributes[counterAttribute];
};
```

#### Query

Query items with same partition key (efficient).

```javascript
import { QueryCommand } from '@aws-sdk/lib-dynamodb';

const queryItems = async (tableName, partitionKeyValue) => {
  const command = new QueryCommand({
    TableName: tableName,
    KeyConditionExpression: 'userId = :userId AND orderId BETWEEN :start AND :end',
    ExpressionAttributeValues: {
      ':userId': partitionKeyValue,
      ':start': 'order-100',
      ':end': 'order-200'
    },
    FilterExpression: 'orderStatus = :status', // Filter results (applied after query)
    ExpressionAttributeValues: {
      ':status': 'completed'
    },
    Limit: 100, // Max items to return
    ScanIndexForward: false // Sort descending (default: ascending)
  });

  const response = await docClient.send(command);
  return response.Items;
};

// Pagination
const queryAllItems = async (tableName, partitionKeyValue) => {
  let allItems = [];
  let lastEvaluatedKey;

  do {
    const command = new QueryCommand({
      TableName: tableName,
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': partitionKeyValue
      },
      ExclusiveStartKey: lastEvaluatedKey
    });

    const response = await docClient.send(command);
    allItems = allItems.concat(response.Items);
    lastEvaluatedKey = response.LastEvaluatedKey;
  } while (lastEvaluatedKey);

  return allItems;
};
```

#### Scan

Scan entire table (inefficient, avoid in production).

```javascript
import { ScanCommand } from '@aws-sdk/lib-dynamodb';

const scanTable = async (tableName, filterExpression) => {
  const command = new ScanCommand({
    TableName: tableName,
    FilterExpression: 'age > :minAge',
    ExpressionAttributeValues: {
      ':minAge': 18
    },
    Limit: 1000
  });

  const response = await docClient.send(command);
  return response.Items;
};

// Parallel scan for performance
const parallelScan = async (tableName, totalSegments = 4) => {
  const scanSegment = async (segment) => {
    const command = new ScanCommand({
      TableName: tableName,
      Segment: segment,
      TotalSegments: totalSegments
    });

    const response = await docClient.send(command);
    return response.Items;
  };

  // Scan all segments in parallel
  const promises = [];
  for (let i = 0; i < totalSegments; i++) {
    promises.push(scanSegment(i));
  }

  const results = await Promise.all(promises);
  return results.flat();
};
```

#### Delete Item

```javascript
import { DeleteCommand } from '@aws-sdk/lib-dynamodb';

const deleteItem = async (tableName, key) => {
  const command = new DeleteCommand({
    TableName: tableName,
    Key: key,
    ConditionExpression: 'attribute_exists(userId)', // Only delete if exists
    ReturnValues: 'ALL_OLD' // Return deleted item
  });

  const response = await docClient.send(command);
  return response.Attributes;
};
```

#### Batch Operations

```javascript
import { BatchGetCommand, BatchWriteCommand } from '@aws-sdk/lib-dynamodb';

// Batch get (up to 100 items)
const batchGetItems = async (tableName, keys) => {
  const command = new BatchGetCommand({
    RequestItems: {
      [tableName]: {
        Keys: keys // Array of key objects
      }
    }
  });

  const response = await docClient.send(command);
  return response.Responses[tableName];
};

// Batch write (up to 25 items)
const batchWriteItems = async (tableName, items) => {
  const command = new BatchWriteCommand({
    RequestItems: {
      [tableName]: items.map(item => ({
        PutRequest: { Item: item }
      }))
    }
  });

  await docClient.send(command);
};

// Batch delete
const batchDeleteItems = async (tableName, keys) => {
  const command = new BatchWriteCommand({
    RequestItems: {
      [tableName]: keys.map(key => ({
        DeleteRequest: { Key: key }
      }))
    }
  });

  await docClient.send(command);
};
```

### DynamoDB Patterns

#### Single-Table Design

Use one table with overloaded keys for complex data models.

```javascript
// User entity
{
  PK: "USER#user-123",
  SK: "METADATA",
  type: "user",
  name: "John Doe",
  email: "john@example.com"
}

// User's order
{
  PK: "USER#user-123",
  SK: "ORDER#order-456",
  type: "order",
  total: 99.99,
  status: "shipped"
}

// Access patterns:
// 1. Get user: PK = "USER#user-123", SK = "METADATA"
// 2. Get all user's orders: PK = "USER#user-123", SK begins_with "ORDER#"
// 3. Get specific order: PK = "USER#user-123", SK = "ORDER#order-456"
```

## EC2 (Elastic Compute Cloud)

EC2 provides resizable compute capacity in the cloud with virtual machines (instances).

### EC2 Core Concepts

#### Instance Types

**General Purpose (T3, M6i)**
- Balanced CPU, memory, and networking
- Web servers, development environments

**Compute Optimized (C6i)**
- High-performance processors
- Batch processing, gaming servers

**Memory Optimized (R6i, X2idn)**
- Large in-memory workloads
- Databases, caching layers

**Storage Optimized (I4i, D3)**
- High sequential read/write
- Data warehouses, distributed file systems

**Accelerated Computing (P4, G5)**
- GPU instances
- Machine learning, graphics rendering

#### AMI (Amazon Machine Image)

Pre-configured templates for instances containing:
- Operating system (Amazon Linux, Ubuntu, Windows, etc.)
- Application software
- Configuration settings

### EC2 Operations

```javascript
import {
  EC2Client,
  RunInstancesCommand,
  DescribeInstancesCommand,
  StartInstancesCommand,
  StopInstancesCommand,
  TerminateInstancesCommand
} from '@aws-sdk/client-ec2';

const ec2Client = new EC2Client({ region: 'us-east-1' });

// Launch instance
const launchInstance = async () => {
  const command = new RunInstancesCommand({
    ImageId: 'ami-0c55b159cbfafe1f0', // Amazon Linux 2 AMI
    InstanceType: 't3.micro',
    MinCount: 1,
    MaxCount: 1,
    KeyName: 'my-key-pair',
    SecurityGroupIds: ['sg-0123456789abcdef0'],
    SubnetId: 'subnet-0123456789abcdef0',
    IamInstanceProfile: {
      Name: 'ec2-instance-profile'
    },
    UserData: Buffer.from(`#!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "Hello from EC2" > /var/www/html/index.html
    `).toString('base64'),
    TagSpecifications: [{
      ResourceType: 'instance',
      Tags: [
        { Key: 'Name', Value: 'WebServer' },
        { Key: 'Environment', Value: 'production' }
      ]
    }]
  });

  const response = await ec2Client.send(command);
  return response.Instances[0].InstanceId;
};

// Describe instances
const describeInstances = async (instanceIds) => {
  const command = new DescribeInstancesCommand({
    InstanceIds: instanceIds,
    Filters: [
      { Name: 'instance-state-name', Values: ['running'] }
    ]
  });

  const response = await ec2Client.send(command);
  return response.Reservations.flatMap(r => r.Instances);
};

// Stop instance
const stopInstance = async (instanceId) => {
  const command = new StopInstancesCommand({
    InstanceIds: [instanceId]
  });

  await ec2Client.send(command);
};

// Terminate instance
const terminateInstance = async (instanceId) => {
  const command = new TerminateInstancesCommand({
    InstanceIds: [instanceId]
  });

  await ec2Client.send(command);
};
```

## RDS (Relational Database Service)

RDS provides managed relational databases (PostgreSQL, MySQL, MariaDB, Oracle, SQL Server, Aurora).

### RDS Operations

```javascript
import {
  RDSClient,
  CreateDBInstanceCommand,
  DescribeDBInstancesCommand,
  ModifyDBInstanceCommand,
  DeleteDBInstanceCommand
} from '@aws-sdk/client-rds';

const rdsClient = new RDSClient({ region: 'us-east-1' });

// Create database instance
const createDatabase = async () => {
  const command = new CreateDBInstanceCommand({
    DBInstanceIdentifier: 'mydb',
    DBInstanceClass: 'db.t3.micro',
    Engine: 'postgres',
    EngineVersion: '15.3',
    MasterUsername: 'admin',
    MasterUserPassword: 'SecurePassword123!',
    AllocatedStorage: 20, // GB
    StorageType: 'gp3',
    BackupRetentionPeriod: 7, // days
    MultiAZ: true, // High availability
    PubliclyAccessible: false,
    VpcSecurityGroupIds: ['sg-0123456789abcdef0'],
    DBSubnetGroupName: 'my-db-subnet-group',
    StorageEncrypted: true,
    Tags: [
      { Key: 'Environment', Value: 'production' },
      { Key: 'Application', Value: 'api' }
    ]
  });

  const response = await rdsClient.send(command);
  return response.DBInstance;
};

// Describe database
const describeDatabase = async (dbInstanceId) => {
  const command = new DescribeDBInstancesCommand({
    DBInstanceIdentifier: dbInstanceId
  });

  const response = await rdsClient.send(command);
  return response.DBInstances[0];
};
```

## CloudFormation

Infrastructure as Code (IaC) service for defining and provisioning AWS resources.

### CloudFormation Template

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Full-stack web application infrastructure'

Parameters:
  Environment:
    Type: String
    Default: production
    AllowedValues:
      - development
      - staging
      - production

Resources:
  # S3 Bucket for static assets
  AssetsBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-assets-${Environment}'
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256

  # DynamoDB Table
  UsersTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${AWS::StackName}-users-${Environment}'
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: userId
          AttributeType: S
        - AttributeName: email
          AttributeType: S
      KeySchema:
        - AttributeName: userId
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: EmailIndex
          KeySchema:
            - AttributeName: email
              KeyType: HASH
          Projection:
            ProjectionType: ALL
      StreamSpecification:
        StreamViewType: NEW_AND_OLD_IMAGES

  # Lambda Execution Role
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: DynamoDBAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:GetItem
                  - dynamodb:PutItem
                  - dynamodb:UpdateItem
                  - dynamodb:Query
                Resource: !GetAtt UsersTable.Arn

  # Lambda Function
  ApiFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${AWS::StackName}-api-${Environment}'
      Runtime: nodejs20.x
      Handler: index.handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          exports.handler = async (event) => {
            return {
              statusCode: 200,
              body: JSON.stringify({ message: 'Hello from Lambda!' })
            };
          };
      Environment:
        Variables:
          TABLE_NAME: !Ref UsersTable
          BUCKET_NAME: !Ref AssetsBucket
          ENVIRONMENT: !Ref Environment
      Timeout: 30
      MemorySize: 512

  # API Gateway
  RestApi:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: !Sub '${AWS::StackName}-api-${Environment}'
      Description: REST API for application

  ApiResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Ref RestApi
      ParentId: !GetAtt RestApi.RootResourceId
      PathPart: users

  ApiMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref RestApi
      ResourceId: !Ref ApiResource
      HttpMethod: GET
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub 'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${ApiFunction.Arn}/invocations'

  ApiDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: ApiMethod
    Properties:
      RestApiId: !Ref RestApi
      StageName: !Ref Environment

  LambdaApiPermission:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref ApiFunction
      Action: lambda:InvokeFunction
      Principal: apigateway.amazonaws.com
      SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*'

Outputs:
  ApiUrl:
    Description: API Gateway URL
    Value: !Sub 'https://${RestApi}.execute-api.${AWS::Region}.amazonaws.com/${Environment}'
    Export:
      Name: !Sub '${AWS::StackName}-api-url'

  BucketName:
    Description: S3 Bucket Name
    Value: !Ref AssetsBucket
    Export:
      Name: !Sub '${AWS::StackName}-bucket-name'

  TableName:
    Description: DynamoDB Table Name
    Value: !Ref UsersTable
    Export:
      Name: !Sub '${AWS::StackName}-table-name'
```

### CloudFormation Operations

```javascript
import {
  CloudFormationClient,
  CreateStackCommand,
  DescribeStacksCommand,
  UpdateStackCommand,
  DeleteStackCommand
} from '@aws-sdk/client-cloudformation';
import { readFileSync } from 'fs';

const cfClient = new CloudFormationClient({ region: 'us-east-1' });

// Create stack
const createStack = async (stackName, templatePath, parameters = {}) => {
  const templateBody = readFileSync(templatePath, 'utf8');

  const command = new CreateStackCommand({
    StackName: stackName,
    TemplateBody: templateBody,
    Parameters: Object.entries(parameters).map(([key, value]) => ({
      ParameterKey: key,
      ParameterValue: value
    })),
    Capabilities: ['CAPABILITY_IAM'],
    Tags: [
      { Key: 'ManagedBy', Value: 'CloudFormation' },
      { Key: 'Application', Value: 'MyApp' }
    ]
  });

  const response = await cfClient.send(command);
  return response.StackId;
};

// Get stack status
const getStackStatus = async (stackName) => {
  const command = new DescribeStacksCommand({
    StackName: stackName
  });

  const response = await cfClient.send(command);
  const stack = response.Stacks[0];

  return {
    status: stack.StackStatus,
    outputs: stack.Outputs || []
  };
};
```

## Best Practices

### Security

**IAM Best Practices**
- Enable MFA for root and privileged accounts
- Use IAM roles instead of access keys
- Apply least privilege principle
- Rotate credentials regularly
- Use IAM Access Analyzer to identify overly permissive policies
- Enable CloudTrail for audit logging

**Data Encryption**
- Encrypt data at rest (S3, EBS, RDS, DynamoDB)
- Use SSL/TLS for data in transit
- Store secrets in AWS Secrets Manager or Parameter Store
- Use KMS for encryption key management

**Network Security**
- Use VPCs for network isolation
- Implement security groups and NACLs
- Enable VPC Flow Logs
- Use AWS WAF for web application protection
- Implement DDoS protection with AWS Shield

### Cost Optimization

**Compute**
- Use Auto Scaling to match capacity to demand
- Choose appropriate instance types and sizes
- Use Spot Instances for fault-tolerant workloads
- Leverage Lambda for event-driven workloads
- Use Savings Plans and Reserved Instances for steady-state workloads

**Storage**
- Implement S3 lifecycle policies
- Use appropriate storage classes
- Enable S3 Intelligent-Tiering
- Delete unused EBS volumes and snapshots
- Use compression and deduplication

**Database**
- Right-size database instances
- Use read replicas to offload read traffic
- Enable DynamoDB auto-scaling
- Use Aurora Serverless for variable workloads
- Archive old data to cheaper storage

### Performance

**Application Design**
- Implement caching (ElastiCache, CloudFront)
- Use content delivery networks (CloudFront)
- Optimize database queries and indexes
- Implement connection pooling
- Use async/parallel operations

**Monitoring and Optimization**
- Use CloudWatch for metrics and alarms
- Implement X-Ray for distributed tracing
- Set up performance budgets
- Conduct regular performance testing
- Use AWS Compute Optimizer recommendations

### Reliability

**High Availability**
- Deploy across multiple Availability Zones
- Use Auto Scaling for automatic recovery
- Implement health checks and automatic failover
- Use Route 53 for DNS-based failover
- Design for graceful degradation

**Disaster Recovery**
- Implement automated backups
- Test recovery procedures regularly
- Use multi-region replication for critical data
- Document recovery time objectives (RTO) and recovery point objectives (RPO)
- Implement chaos engineering practices

**Error Handling**
- Implement retry logic with exponential backoff
- Use dead letter queues for failed messages
- Set up CloudWatch alarms for errors
- Implement circuit breakers
- Log errors comprehensively

### Operational Excellence

**Infrastructure as Code**
- Version control all infrastructure code
- Use CloudFormation or CDK for resource provisioning
- Implement CI/CD for infrastructure changes
- Use stack sets for multi-account/region deployments
- Validate templates before deployment

**Monitoring and Logging**
- Centralize logs with CloudWatch Logs
- Set up custom metrics and dashboards
- Implement log aggregation and analysis
- Use CloudTrail for API auditing
- Set up alarms for critical metrics

**Automation**
- Automate deployments with CodePipeline
- Use Systems Manager for patch management
- Implement automated scaling policies
- Use Lambda for operational tasks
- Automate backup and recovery procedures

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Cloud Infrastructure, Serverless, Database, DevOps
**Compatible With**: AWS SDK v3, CloudFormation, AWS CLI, Terraform
