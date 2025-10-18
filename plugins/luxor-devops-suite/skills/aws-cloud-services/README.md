# AWS Cloud Services Skill

Comprehensive skill for building, deploying, and managing enterprise-grade applications on Amazon Web Services (AWS).

## Overview

This skill provides deep knowledge of AWS cloud services, covering infrastructure setup, serverless architectures, database management, security best practices, and cost optimization strategies. Whether you're building a simple API or a complex multi-region application, this skill guides you through AWS service selection, implementation, and operational excellence.

## What's Covered

### Core Services

**S3 (Simple Storage Service)**
- Object storage for files, images, backups, and static assets
- Presigned URLs for secure temporary access
- Multipart uploads for large files
- Lifecycle policies and storage class optimization
- Cross-region replication and versioning

**Lambda (Serverless Compute)**
- Event-driven function execution
- API Gateway integration for HTTP APIs
- S3, DynamoDB, and SNS event triggers
- Cold start optimization techniques
- Error handling and retry strategies

**DynamoDB (NoSQL Database)**
- Single-digit millisecond latency at any scale
- Primary key design (partition key + sort key)
- Global and local secondary indexes
- Single-table design patterns
- Streams for change data capture

**EC2 (Elastic Compute Cloud)**
- Virtual machine instances
- Instance types and sizing
- AMI management and user data scripts
- Security groups and networking
- Auto Scaling groups

**RDS (Relational Database Service)**
- Managed PostgreSQL, MySQL, MariaDB, Oracle, SQL Server
- Multi-AZ deployments for high availability
- Read replicas for read scaling
- Automated backups and point-in-time recovery
- Aurora for cloud-native relational databases

**IAM (Identity and Access Management)**
- Users, groups, and roles
- Policy-based access control
- Least privilege security model
- Cross-account access
- Service-to-service authentication

**CloudFormation (Infrastructure as Code)**
- YAML/JSON template-based resource provisioning
- Stack management and updates
- Cross-stack references and nested stacks
- Change sets for safe updates
- Drift detection

### Architecture Patterns

**Serverless Architectures**
- API Gateway + Lambda + DynamoDB
- Event-driven processing with S3 and Lambda
- Step Functions for workflow orchestration
- EventBridge for event routing

**Three-Tier Web Applications**
- Load balancers and auto-scaling web servers
- Application servers with business logic
- RDS or DynamoDB for data persistence
- ElastiCache for session management

**Microservices**
- Service isolation with Lambda or ECS
- API Gateway for service mesh
- DynamoDB for service-specific data
- SQS/SNS for async communication

**Data Processing Pipelines**
- S3 for data lake storage
- Lambda or Glue for ETL
- Kinesis for real-time streaming
- Athena for ad-hoc queries

### Best Practices

**Security**
- Enable encryption at rest and in transit
- Use IAM roles instead of access keys
- Implement least privilege access
- Enable CloudTrail and GuardDuty
- Use Secrets Manager for credentials

**Cost Optimization**
- Right-size resources based on usage
- Use Spot Instances and Savings Plans
- Implement S3 lifecycle policies
- Enable auto-scaling
- Monitor with Cost Explorer and Budgets

**Performance**
- Use CDN (CloudFront) for static content
- Implement caching (ElastiCache, DAX)
- Optimize database queries and indexes
- Use connection pooling
- Enable compression

**Reliability**
- Deploy across multiple Availability Zones
- Implement health checks and auto-recovery
- Use Route 53 for DNS failover
- Automate backups and test recovery
- Design for graceful degradation

## Getting Started

### Prerequisites

1. **AWS Account**: Create at https://aws.amazon.com
2. **IAM User**: Create with programmatic access
3. **AWS CLI**: Install from https://aws.amazon.com/cli/
4. **Node.js**: Version 18+ recommended
5. **AWS SDK v3**: Install service clients as needed

### AWS SDK Installation

```bash
# Install core SDK client
npm install @aws-sdk/client-s3

# Install DynamoDB DocumentClient
npm install @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb

# Install Lambda client
npm install @aws-sdk/client-lambda

# Install EC2 client
npm install @aws-sdk/client-ec2

# Install RDS client
npm install @aws-sdk/client-rds

# Install CloudFormation client
npm install @aws-sdk/client-cloudformation

# Install presigner for S3
npm install @aws-sdk/s3-request-presigner
```

### Credential Configuration

#### Option 1: Environment Variables

```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_REGION="us-east-1"
```

#### Option 2: Credentials File

Create `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[production]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

Create `~/.aws/config`:

```ini
[default]
region = us-east-1
output = json

[profile production]
region = us-west-2
output = json
```

#### Option 3: IAM Roles (Recommended for EC2/Lambda)

No configuration needed - SDK automatically uses instance metadata service.

### Basic Usage Examples

#### S3 File Upload

```javascript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { readFileSync } from 'fs';

const client = new S3Client({ region: 'us-east-1' });

const uploadFile = async (bucketName, key, filePath) => {
  const fileContent = readFileSync(filePath);

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    Body: fileContent,
    ContentType: 'image/jpeg'
  });

  await client.send(command);
  console.log(`Uploaded ${key} to ${bucketName}`);
};

await uploadFile('my-bucket', 'photos/vacation.jpg', './vacation.jpg');
```

#### DynamoDB Query

```javascript
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, QueryCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);

const getUserOrders = async (userId) => {
  const command = new QueryCommand({
    TableName: 'Orders',
    KeyConditionExpression: 'userId = :userId',
    ExpressionAttributeValues: {
      ':userId': userId
    }
  });

  const response = await docClient.send(command);
  return response.Items;
};

const orders = await getUserOrders('user-123');
console.log(`Found ${orders.length} orders`);
```

#### Lambda Function

```javascript
// index.js - Lambda handler
export const handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  // Process event
  const result = {
    message: 'Hello from Lambda!',
    timestamp: new Date().toISOString()
  };

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(result)
  };
};
```

## Service Selection Guide

### When to Use S3

- Storing static assets (images, videos, documents)
- Hosting static websites
- Backup and archival storage
- Data lake storage
- Content distribution with CloudFront

### When to Use Lambda

- Event-driven processing (file uploads, database changes)
- API endpoints with low to moderate traffic
- Scheduled tasks (cron jobs)
- Data transformation and ETL
- Webhooks and integrations

### When to Use DynamoDB

- High-throughput, low-latency workloads
- Key-value and document data models
- Event sourcing and CQRS patterns
- Session stores and user profiles
- IoT and gaming leaderboards

### When to Use EC2

- Long-running applications
- Specific OS or kernel requirements
- Legacy application migrations
- Full control over instance configuration
- High-performance computing

### When to Use RDS

- Relational data with complex queries
- ACID transaction requirements
- Existing SQL-based applications
- Multi-table joins and relationships
- Business intelligence and reporting

## Common Workflows

### Deploy Static Website

```bash
# 1. Create S3 bucket
aws s3 mb s3://my-website-bucket

# 2. Enable static website hosting
aws s3 website s3://my-website-bucket --index-document index.html

# 3. Upload files
aws s3 sync ./build s3://my-website-bucket

# 4. Set bucket policy for public access
aws s3api put-bucket-policy --bucket my-website-bucket --policy file://policy.json

# 5. Configure CloudFront for HTTPS and caching (optional)
```

### Deploy Serverless API

```bash
# 1. Create DynamoDB table
aws dynamodb create-table --table-name Users --attribute-definitions AttributeName=userId,AttributeType=S --key-schema AttributeName=userId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# 2. Create Lambda function
zip -r function.zip index.js node_modules
aws lambda create-function --function-name api-handler --runtime nodejs20.x --role arn:aws:iam::123456789012:role/lambda-role --handler index.handler --zip-file fileb://function.zip

# 3. Create API Gateway
aws apigatewayv2 create-api --name my-api --protocol-type HTTP --target arn:aws:lambda:us-east-1:123456789012:function:api-handler

# 4. Grant API Gateway permission to invoke Lambda
aws lambda add-permission --function-name api-handler --statement-id apigateway-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com
```

### Deploy CloudFormation Stack

```bash
# Validate template
aws cloudformation validate-template --template-body file://template.yaml

# Create stack
aws cloudformation create-stack --stack-name my-app --template-body file://template.yaml --parameters ParameterKey=Environment,ParameterValue=production --capabilities CAPABILITY_IAM

# Wait for stack creation
aws cloudformation wait stack-create-complete --stack-name my-app

# Get stack outputs
aws cloudformation describe-stacks --stack-name my-app --query 'Stacks[0].Outputs'

# Update stack
aws cloudformation update-stack --stack-name my-app --template-body file://template.yaml --parameters ParameterKey=Environment,ParameterValue=production --capabilities CAPABILITY_IAM

# Delete stack
aws cloudformation delete-stack --stack-name my-app
```

## Region Selection

Choose regions based on:

**Latency**: Deploy close to your users
- US East (N. Virginia): us-east-1
- US West (Oregon): us-west-2
- EU (Ireland): eu-west-1
- Asia Pacific (Singapore): ap-southeast-1

**Compliance**: Data residency requirements
- EU data must stay in EU regions
- US GovCloud for government workloads

**Cost**: Pricing varies by region
- us-east-1 typically cheapest
- New regions may be more expensive

**Service Availability**: Not all services in all regions
- Check https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

## Error Handling

### Common SDK Errors

```javascript
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';

const client = new S3Client({ region: 'us-east-1' });

try {
  const command = new GetObjectCommand({
    Bucket: 'my-bucket',
    Key: 'file.txt'
  });

  const response = await client.send(command);

} catch (error) {
  // Handle specific errors
  if (error.name === 'NoSuchKey') {
    console.log('File not found');
  } else if (error.name === 'AccessDenied') {
    console.log('Permission denied');
  } else if (error.name === 'ThrottlingException') {
    console.log('Rate limited, retry with backoff');
  } else {
    console.error('Unexpected error:', error);
    throw error;
  }
}
```

### Retry Strategy

```javascript
import { S3Client } from '@aws-sdk/client-s3';

const client = new S3Client({
  region: 'us-east-1',
  maxAttempts: 3, // Default: 3
  retryMode: 'adaptive' // adaptive | standard | legacy
});
```

## Monitoring and Debugging

### CloudWatch Logs

```javascript
// Lambda automatically logs to CloudWatch
console.log('Info message');
console.error('Error message');
console.warn('Warning message');

// Structured logging
console.log(JSON.stringify({
  level: 'info',
  message: 'User logged in',
  userId: 'user-123',
  timestamp: new Date().toISOString()
}));
```

### X-Ray Tracing

```javascript
import AWSXRay from 'aws-xray-sdk-core';
import AWS from 'aws-sdk';

// Instrument AWS SDK
const instrumentedAWS = AWSXRay.captureAWS(AWS);
const s3 = new instrumentedAWS.S3();

// Custom subsegments
const segment = AWSXRay.getSegment();
const subsegment = segment.addNewSubsegment('custom-operation');

try {
  // Your code
  subsegment.addAnnotation('userId', 'user-123');
  subsegment.addMetadata('data', { key: 'value' });
} catch (error) {
  subsegment.addError(error);
} finally {
  subsegment.close();
}
```

### CloudWatch Metrics

```javascript
import { CloudWatchClient, PutMetricDataCommand } from '@aws-sdk/client-cloudwatch';

const cloudwatch = new CloudWatchClient({ region: 'us-east-1' });

const publishMetric = async (metricName, value) => {
  const command = new PutMetricDataCommand({
    Namespace: 'MyApplication',
    MetricData: [
      {
        MetricName: metricName,
        Value: value,
        Unit: 'Count',
        Timestamp: new Date(),
        Dimensions: [
          { Name: 'Environment', Value: 'production' }
        ]
      }
    ]
  });

  await cloudwatch.send(command);
};

await publishMetric('OrdersProcessed', 42);
```

## Security Best Practices

### Never Hardcode Credentials

```javascript
// ❌ NEVER DO THIS
const client = new S3Client({
  region: 'us-east-1',
  credentials: {
    accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
    secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
  }
});

// ✅ DO THIS - Use environment variables or IAM roles
const client = new S3Client({ region: 'us-east-1' });
```

### Use Secrets Manager

```javascript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const secretsManager = new SecretsManagerClient({ region: 'us-east-1' });

const getSecret = async (secretName) => {
  const command = new GetSecretValueCommand({
    SecretId: secretName
  });

  const response = await secretsManager.send(command);
  return JSON.parse(response.SecretString);
};

const dbCredentials = await getSecret('prod/database/credentials');
console.log('Database password:', dbCredentials.password);
```

### Implement Least Privilege

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
      "Resource": "arn:aws:s3:::my-bucket/uploads/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:Query",
        "dynamodb:GetItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/Users"
    }
  ]
}
```

## Resources

### Official Documentation

- AWS Documentation: https://docs.aws.amazon.com/
- AWS SDK for JavaScript v3: https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/
- AWS Architecture Center: https://aws.amazon.com/architecture/
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/

### Training and Certification

- AWS Training: https://aws.amazon.com/training/
- AWS Certification: https://aws.amazon.com/certification/
- AWS Skill Builder: https://skillbuilder.aws/

### Tools and SDKs

- AWS CLI: https://aws.amazon.com/cli/
- AWS CloudShell: https://aws.amazon.com/cloudshell/
- AWS CDK (Cloud Development Kit): https://aws.amazon.com/cdk/
- AWS SAM (Serverless Application Model): https://aws.amazon.com/serverless/sam/

### Community

- AWS Forums: https://forums.aws.amazon.com/
- AWS on GitHub: https://github.com/aws
- AWS Blog: https://aws.amazon.com/blogs/
- re:Post (Community Q&A): https://repost.aws/

## Next Steps

1. **Create AWS Account**: Sign up at https://aws.amazon.com
2. **Set Up IAM User**: Create user with programmatic access
3. **Install AWS CLI**: Download from https://aws.amazon.com/cli/
4. **Configure Credentials**: Run `aws configure`
5. **Try Examples**: Start with S3 and Lambda examples in EXAMPLES.md
6. **Build Project**: Deploy a complete application using CloudFormation
7. **Implement Monitoring**: Set up CloudWatch alarms and dashboards
8. **Optimize Costs**: Review Cost Explorer and implement optimization strategies

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintainer**: AWS Cloud Services Skill
**License**: MIT
