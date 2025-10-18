# AWS Cloud Architecture - Quick Start Guide

## Overview

This skill provides comprehensive guidance for designing and implementing production-grade AWS cloud architectures. Whether you're building a simple web application or a complex microservices platform, this guide covers all essential AWS services and best practices.

## What You'll Learn

- **Compute**: EC2, Lambda, ECS/Fargate, Auto Scaling
- **Storage**: S3, EBS, EFS, Glacier
- **Databases**: RDS, DynamoDB, Aurora, ElastiCache
- **Networking**: VPC, Load Balancers, CloudFront, Route53
- **Security**: IAM, KMS, CloudTrail, Secrets Manager
- **Serverless**: Lambda, Step Functions, EventBridge
- **Cost Optimization**: Reserved Instances, Savings Plans, Cost Explorer

## Prerequisites

Before you begin, ensure you have:

1. **AWS Account**: Sign up at https://aws.amazon.com
2. **AWS CLI**: Install and configure
3. **IAM Credentials**: Access key and secret key configured
4. **Basic Knowledge**: Understanding of cloud computing concepts

## Quick Setup

### 1. Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify installation
aws --version
```

### 2. Configure AWS CLI

```bash
# Configure credentials
aws configure

# Enter your credentials:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-east-1
# Default output format: json

# Test configuration
aws sts get-caller-identity
```

### 3. Install Additional Tools

```bash
# Install CloudFormation linter
pip install cfn-lint

# Install AWS SAM CLI for serverless
brew tap aws/tap
brew install aws-sam-cli

# Install Terraform (alternative to CloudFormation)
brew install terraform
```

## AWS Services Overview

### Compute Services

#### Amazon EC2 (Elastic Compute Cloud)
Virtual servers in the cloud. Use for applications requiring full OS control.

**Use Cases**: Web servers, application servers, batch processing

```bash
# Launch an EC2 instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name my-key-pair \
  --security-group-ids sg-0123456789abcdef \
  --subnet-id subnet-0123456789abcdef
```

#### AWS Lambda
Serverless compute - run code without managing servers.

**Use Cases**: API backends, data processing, automation tasks

```python
# Simple Lambda function
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
```

#### Amazon ECS/Fargate
Container orchestration for Docker applications.

**Use Cases**: Microservices, containerized applications

### Storage Services

#### Amazon S3 (Simple Storage Service)
Object storage for any type of data.

**Use Cases**: Backups, data lakes, static websites, media files

```bash
# Create a bucket
aws s3 mb s3://my-unique-bucket-name

# Upload a file
aws s3 cp myfile.txt s3://my-unique-bucket-name/

# List bucket contents
aws s3 ls s3://my-unique-bucket-name/
```

#### Amazon EBS (Elastic Block Store)
Block storage for EC2 instances.

**Use Cases**: Database storage, file systems, application data

#### Amazon EFS (Elastic File System)
Managed NFS file system that can be mounted by multiple EC2 instances.

**Use Cases**: Shared storage, content management, web serving

### Database Services

#### Amazon RDS (Relational Database Service)
Managed relational databases (MySQL, PostgreSQL, Oracle, SQL Server).

**Use Cases**: Traditional applications, OLTP workloads

```bash
# Create a PostgreSQL RDS instance
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password MyPassword123 \
  --allocated-storage 20
```

#### Amazon DynamoDB
Fully managed NoSQL database.

**Use Cases**: High-scale applications, gaming, IoT, mobile backends

```python
# DynamoDB operations
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

# Put item
table.put_item(Item={'userId': '123', 'name': 'John Doe'})

# Get item
response = table.get_item(Key={'userId': '123'})
```

#### Amazon Aurora
MySQL and PostgreSQL-compatible database with enhanced performance.

**Use Cases**: Enterprise applications, SaaS platforms

### Networking Services

#### Amazon VPC (Virtual Private Cloud)
Isolated virtual network for your AWS resources.

**Use Cases**: All AWS deployments requiring network isolation

```bash
# Create a VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create a subnet
aws ec2 create-subnet \
  --vpc-id vpc-0123456789abcdef \
  --cidr-block 10.0.1.0/24
```

#### Elastic Load Balancer
Distribute traffic across multiple targets.

**Types**: Application Load Balancer (ALB), Network Load Balancer (NLB), Gateway Load Balancer

**Use Cases**: High availability, auto scaling, SSL termination

#### Amazon CloudFront
Content Delivery Network (CDN) for fast content delivery.

**Use Cases**: Static websites, video streaming, API acceleration

#### Amazon Route 53
DNS and domain management service.

**Use Cases**: Domain registration, DNS routing, health checks

## Common Architecture Patterns

### 1. Three-Tier Web Application

Classic architecture with presentation, application, and data tiers.

```
┌─────────────────────────────────────────────────┐
│              Internet Gateway                    │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Application Load Balancer                │
│              (Public Subnet)                     │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│         Auto Scaling Group                       │
│    EC2 Instances (Private Subnet)               │
│         Application Tier                         │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│              RDS Database                        │
│         (Private Subnet)                         │
│            Data Tier                             │
└─────────────────────────────────────────────────┘
```

**Components**:
- CloudFront for CDN
- ALB for load balancing
- EC2 Auto Scaling Group for application servers
- RDS Multi-AZ for database
- S3 for static assets
- ElastiCache for caching

### 2. Serverless Microservices

Event-driven architecture using serverless components.

```
┌─────────────────────────────────────────────────┐
│          Amazon CloudFront                       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│          API Gateway                             │
└──┬────────┬────────┬────────┬───────────────────┘
   │        │        │        │
   ▼        ▼        ▼        ▼
┌────┐  ┌────┐  ┌────┐  ┌────┐
│ λ  │  │ λ  │  │ λ  │  │ λ  │  Lambda Functions
└─┬──┘  └─┬──┘  └─┬──┘  └─┬──┘
  │       │       │       │
  └───────┴───────┴───────┘
           │
┌──────────▼──────────────────────────────────────┐
│        DynamoDB / RDS / S3                       │
└─────────────────────────────────────────────────┘
```

**Components**:
- API Gateway for REST APIs
- Lambda for business logic
- DynamoDB for data storage
- S3 for file storage
- EventBridge for event routing
- Step Functions for workflows

### 3. Data Lake Architecture

Centralized repository for structured and unstructured data.

```
┌─────────────────────────────────────────────────┐
│          Data Sources                            │
│  (Applications, IoT, Logs, Databases)           │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│        Kinesis Data Streams                      │
│        Kinesis Firehose                          │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│              S3 Data Lake                        │
│  Raw → Processed → Curated                      │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│   Analytics & Processing                        │
│ Athena | Glue | EMR | Redshift                  │
└─────────────────────────────────────────────────┘
```

**Components**:
- Kinesis for data ingestion
- S3 for data lake storage
- Glue for ETL
- Athena for SQL queries
- Redshift for data warehousing

### 4. Multi-Region Active-Active

High availability across multiple AWS regions.

```
┌─────────────────────────────────────────────────┐
│           Route 53 (Global DNS)                  │
│        Latency/Geolocation Routing               │
└──────────┬──────────────────────┬────────────────┘
           │                      │
┌──────────▼──────────┐  ┌────────▼────────────────┐
│   Region: us-east-1  │  │  Region: eu-west-1      │
│                      │  │                         │
│  CloudFront          │  │  CloudFront             │
│  ALB                 │  │  ALB                    │
│  EC2 Auto Scaling    │  │  EC2 Auto Scaling       │
│  RDS (Primary)       │  │  RDS (Read Replica)     │
│  DynamoDB Global Tbl │◄─┼─►DynamoDB Global Table  │
└──────────────────────┘  └─────────────────────────┘
```

**Components**:
- Route 53 for global traffic management
- CloudFront for CDN
- DynamoDB Global Tables
- RDS Cross-Region Replication
- S3 Cross-Region Replication

## Architecture Best Practices

### Security

1. **Use VPC**: Always deploy resources in a VPC
2. **Security Groups**: Implement least-privilege access
3. **Encryption**: Enable encryption at rest and in transit
4. **IAM**: Use roles instead of access keys
5. **CloudTrail**: Enable for audit logging
6. **Secrets Manager**: Store credentials securely

```bash
# Create a secret in Secrets Manager
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string "MySecurePassword123"
```

### High Availability

1. **Multi-AZ**: Deploy across multiple Availability Zones
2. **Auto Scaling**: Automatically adjust capacity
3. **Load Balancing**: Distribute traffic evenly
4. **Health Checks**: Monitor application health
5. **Backups**: Automated and tested regularly

### Cost Optimization

1. **Right-Sizing**: Use appropriate instance types
2. **Reserved Instances**: Commit for 1-3 years to save up to 75%
3. **Spot Instances**: Use for fault-tolerant workloads (up to 90% savings)
4. **Auto Scaling**: Scale down during off-peak hours
5. **S3 Lifecycle**: Move data to cheaper storage classes
6. **CloudWatch**: Monitor and optimize resource usage

```bash
# Set up S3 lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration file://lifecycle.json
```

### Performance

1. **CDN**: Use CloudFront for static content
2. **Caching**: Implement ElastiCache for databases
3. **Database Optimization**: Use read replicas, connection pooling
4. **Async Processing**: Use SQS/SNS for decoupling
5. **Serverless**: Use Lambda for event-driven workloads

## Learning Path

### Beginner (Week 1-2)
1. Set up AWS account and CLI
2. Create a VPC with public and private subnets
3. Launch an EC2 instance and connect via SSH
4. Create an S3 bucket and upload files
5. Set up RDS database instance

### Intermediate (Week 3-4)
1. Deploy a load-balanced web application
2. Implement Auto Scaling
3. Set up CloudFront CDN
4. Create Lambda functions
5. Configure DynamoDB tables
6. Implement CloudWatch monitoring

### Advanced (Week 5-6)
1. Design multi-tier architecture with CloudFormation
2. Implement serverless microservices
3. Set up CI/CD pipeline with CodePipeline
4. Configure multi-region deployment
5. Implement disaster recovery strategy
6. Optimize costs using Reserved Instances

## Common Commands Cheat Sheet

### EC2
```bash
# List instances
aws ec2 describe-instances

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Create snapshot
aws ec2 create-snapshot --volume-id vol-1234567890abcdef0
```

### S3
```bash
# Create bucket
aws s3 mb s3://bucket-name

# Sync directory
aws s3 sync ./local-dir s3://bucket-name/

# Delete bucket (must be empty)
aws s3 rb s3://bucket-name --force
```

### Lambda
```bash
# List functions
aws lambda list-functions

# Invoke function
aws lambda invoke --function-name my-function output.json

# Update function code
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip
```

### RDS
```bash
# List instances
aws rds describe-db-instances

# Create snapshot
aws rds create-db-snapshot \
  --db-instance-identifier mydb \
  --db-snapshot-identifier mydb-snapshot

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier mydb-restored \
  --db-snapshot-identifier mydb-snapshot
```

### CloudFormation
```bash
# Create stack
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# Update stack
aws cloudformation update-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# Delete stack
aws cloudformation delete-stack --stack-name my-stack

# Describe stack
aws cloudformation describe-stacks --stack-name my-stack
```

## Monitoring and Troubleshooting

### CloudWatch Logs

```bash
# Stream logs in real-time
aws logs tail /aws/lambda/my-function --follow

# Query logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "ERROR"
```

### CloudWatch Metrics

```bash
# Get CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

## Cost Management

### Cost Explorer
```bash
# Get cost and usage
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Budgets
```bash
# Create budget
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

## Additional Resources

- **AWS Documentation**: https://docs.aws.amazon.com
- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/
- **AWS Training**: https://aws.amazon.com/training/
- **AWS Solutions Library**: https://aws.amazon.com/solutions/
- **AWS Architecture Center**: https://aws.amazon.com/architecture/

## Support and Community

- **AWS Forums**: https://forums.aws.amazon.com
- **AWS re:Post**: https://repost.aws/
- **AWS Support**: https://console.aws.amazon.com/support/
- **Stack Overflow**: Tag questions with `amazon-web-services`

## Next Steps

1. Review the **SKILL.md** for comprehensive service documentation
2. Explore **EXAMPLES.md** for production-ready code examples
3. Start with a simple project and gradually add complexity
4. Follow the Well-Architected Framework for best practices
5. Set up billing alerts to monitor costs
6. Join AWS community forums and stay updated

---

**Remember**: Start small, iterate, and always follow security best practices. AWS is powerful but requires careful planning and implementation.
