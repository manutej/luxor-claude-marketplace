---
name: aws-cloud-architecture
description: Comprehensive guide to AWS cloud architecture covering compute, storage, databases, networking, security, serverless, and cost optimization with production-ready patterns
version: 1.0.0
category: cloud-infrastructure
tags:
  - aws
  - cloud-architecture
  - infrastructure
  - devops
  - cloudformation
  - terraform
  - serverless
  - well-architected
prerequisites:
  - Basic understanding of cloud computing concepts
  - AWS account with appropriate permissions
  - AWS CLI installed and configured
  - Familiarity with YAML/JSON
---

# AWS Cloud Architecture

A comprehensive skill for designing, implementing, and operating production-grade AWS cloud architectures following the AWS Well-Architected Framework.

## Table of Contents

1. [AWS Well-Architected Framework](#aws-well-architected-framework)
2. [Compute Services](#compute-services)
3. [Storage Services](#storage-services)
4. [Database Services](#database-services)
5. [Networking and Content Delivery](#networking-and-content-delivery)
6. [Security, Identity, and Compliance](#security-identity-and-compliance)
7. [Serverless Architecture](#serverless-architecture)
8. [Cost Optimization](#cost-optimization)
9. [Monitoring and Operations](#monitoring-and-operations)
10. [High Availability and Disaster Recovery](#high-availability-and-disaster-recovery)

## AWS Well-Architected Framework

The AWS Well-Architected Framework provides best practices across six pillars:

### 1. Operational Excellence
- Automate infrastructure provisioning and configuration
- Monitor and measure system performance
- Continuously improve processes and procedures

### 2. Security
- Implement strong identity foundation
- Enable traceability and audit logging
- Apply security at all layers
- Protect data in transit and at rest

### 3. Reliability
- Automatically recover from failure
- Test recovery procedures
- Scale horizontally for resilience
- Manage change through automation

### 4. Performance Efficiency
- Use appropriate resource types and sizes
- Monitor performance and adapt
- Leverage serverless architectures
- Experiment with new technologies

### 5. Cost Optimization
- Adopt consumption-based pricing
- Measure and monitor spending
- Use cost-effective resources
- Optimize over time

### 6. Sustainability
- Understand environmental impact
- Maximize utilization of resources
- Use managed services
- Reduce downstream impact

## Compute Services

### Amazon EC2 (Elastic Compute Cloud)

EC2 provides resizable compute capacity in the cloud, offering complete control over computing resources.

#### EC2 Instance Types

```bash
# List available instance types in a region
aws ec2 describe-instance-types \
  --region us-east-1 \
  --query 'InstanceTypes[*].[InstanceType,VCpuInfo.DefaultVCpus,MemoryInfo.SizeInMiB]' \
  --output table
```

#### Launch EC2 Instance with User Data

```yaml
# CloudFormation: EC2 Instance with Auto Scaling
AWSTemplateFormatVersion: '2010-09-09'
Description: EC2 instance with user data for web server

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
    Description: EC2 instance type

  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: EC2 key pair for SSH access

Resources:
  WebServerInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: !Sub '{{resolve:ssm:/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2}}'
      KeyName: !Ref KeyName
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Hello from AWS CloudFormation</h1>" > /var/www/html/index.html
      Tags:
        - Key: Name
          Value: WebServer
        - Key: Environment
          Value: Production

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for web server
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.0.0.0/8
      Tags:
        - Key: Name
          Value: WebServerSG

Outputs:
  InstanceId:
    Description: EC2 instance ID
    Value: !Ref WebServerInstance
  PublicIP:
    Description: Public IP address
    Value: !GetAtt WebServerInstance.PublicIp
```

#### EC2 Auto Scaling Group

```yaml
# CloudFormation: Auto Scaling Group with Launch Template
LaunchTemplate:
  Type: AWS::EC2::LaunchTemplate
  Properties:
    LaunchTemplateName: WebServerLaunchTemplate
    LaunchTemplateData:
      ImageId: !Sub '{{resolve:ssm:/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2}}'
      InstanceType: t3.micro
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      IamInstanceProfile:
        Arn: !GetAtt InstanceProfile.Arn
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd aws-cli
          systemctl start httpd
          systemctl enable httpd
          INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
          echo "<h1>Instance: $INSTANCE_ID</h1>" > /var/www/html/index.html
      TagSpecifications:
        - ResourceType: instance
          Tags:
            - Key: Name
              Value: WebServer-ASG

AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    AutoScalingGroupName: WebServerASG
    MinSize: 2
    MaxSize: 10
    DesiredCapacity: 2
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
    LaunchTemplate:
      LaunchTemplateId: !Ref LaunchTemplate
      Version: !GetAtt LaunchTemplate.LatestVersionNumber
    VPCZoneIdentifier:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    TargetGroupARNs:
      - !Ref TargetGroup
    Tags:
      - Key: Environment
        Value: Production
        PropagateAtLaunch: true

ScaleUpPolicy:
  Type: AWS::AutoScaling::ScalingPolicy
  Properties:
    AdjustmentType: ChangeInCapacity
    AutoScalingGroupName: !Ref AutoScalingGroup
    Cooldown: 300
    ScalingAdjustment: 1

ScaleDownPolicy:
  Type: AWS::AutoScaling::ScalingPolicy
  Properties:
    AdjustmentType: ChangeInCapacity
    AutoScalingGroupName: !Ref AutoScalingGroup
    Cooldown: 300
    ScalingAdjustment: -1

CPUAlarmHigh:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmDescription: Scale up when CPU exceeds 70%
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 70
    AlarmActions:
      - !Ref ScaleUpPolicy
    Dimensions:
      - Name: AutoScalingGroupName
        Value: !Ref AutoScalingGroup
    ComparisonOperator: GreaterThanThreshold

CPUAlarmLow:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmDescription: Scale down when CPU is below 30%
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 30
    AlarmActions:
      - !Ref ScaleDownPolicy
    Dimensions:
      - Name: AutoScalingGroupName
        Value: !Ref AutoScalingGroup
    ComparisonOperator: LessThanThreshold
```

### AWS Lambda

Serverless compute service that runs code in response to events.

#### Lambda Function with Python

```yaml
# CloudFormation: Lambda Function with API Gateway
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
      - arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess
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
                - dynamodb:Scan
              Resource: !GetAtt DynamoDBTable.Arn

HelloWorldFunction:
  Type: AWS::Lambda::Function
  Properties:
    FunctionName: HelloWorldFunction
    Runtime: python3.11
    Handler: index.lambda_handler
    Role: !GetAtt LambdaExecutionRole.Arn
    Timeout: 30
    MemorySize: 256
    Environment:
      Variables:
        TABLE_NAME: !Ref DynamoDBTable
        STAGE: production
    Code:
      ZipFile: |
        import json
        import os
        import boto3
        from datetime import datetime

        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(os.environ['TABLE_NAME'])

        def lambda_handler(event, context):
            try:
                # Log the event
                print(f"Event: {json.dumps(event)}")

                # Extract data from event
                body = json.loads(event.get('body', '{}'))

                # Store in DynamoDB
                response = table.put_item(
                    Item={
                        'id': context.request_id,
                        'timestamp': datetime.now().isoformat(),
                        'data': body,
                        'stage': os.environ['STAGE']
                    }
                )

                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'message': 'Success',
                        'requestId': context.request_id
                    })
                }
            except Exception as e:
                print(f"Error: {str(e)}")
                return {
                    'statusCode': 500,
                    'body': json.dumps({'error': str(e)})
                }
    TracingConfig:
      Mode: Active
```

#### Lambda with S3 Event Trigger

```python
# Python Lambda function for S3 event processing
import json
import urllib.parse
import boto3
from PIL import Image
import io

s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Process images uploaded to S3:
    - Create thumbnails
    - Extract metadata
    - Store results in destination bucket
    """

    # Get bucket and key from S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    try:
        # Download image from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        image_content = response['Body'].read()

        # Open image with PIL
        image = Image.open(io.BytesIO(image_content))

        # Create thumbnail
        thumbnail_size = (200, 200)
        image.thumbnail(thumbnail_size)

        # Save thumbnail to buffer
        buffer = io.BytesIO()
        image.save(buffer, format=image.format)
        buffer.seek(0)

        # Upload thumbnail to destination bucket
        thumbnail_key = f"thumbnails/{key}"
        s3.put_object(
            Bucket=f"{bucket}-processed",
            Key=thumbnail_key,
            Body=buffer,
            ContentType=response['ContentType']
        )

        print(f"Successfully created thumbnail: {thumbnail_key}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'original': key,
                'thumbnail': thumbnail_key,
                'size': image.size
            })
        }

    except Exception as e:
        print(f"Error processing image {key}: {str(e)}")
        raise e
```

### Amazon ECS (Elastic Container Service)

Container orchestration service supporting Docker containers.

#### ECS Cluster with Fargate

```yaml
# CloudFormation: ECS Cluster with Fargate
ECSCluster:
  Type: AWS::ECS::Cluster
  Properties:
    ClusterName: production-cluster
    ClusterSettings:
      - Name: containerInsights
        Value: enabled
    Tags:
      - Key: Environment
        Value: Production

TaskDefinition:
  Type: AWS::ECS::TaskDefinition
  Properties:
    Family: web-app
    NetworkMode: awsvpc
    RequiresCompatibilities:
      - FARGATE
    Cpu: 512
    Memory: 1024
    ExecutionRoleArn: !GetAtt ECSExecutionRole.Arn
    TaskRoleArn: !GetAtt ECSTaskRole.Arn
    ContainerDefinitions:
      - Name: web-container
        Image: nginx:latest
        PortMappings:
          - ContainerPort: 80
            Protocol: tcp
        LogConfiguration:
          LogDriver: awslogs
          Options:
            awslogs-group: !Ref CloudWatchLogsGroup
            awslogs-region: !Ref AWS::Region
            awslogs-stream-prefix: web-app
        Environment:
          - Name: ENVIRONMENT
            Value: production
        HealthCheck:
          Command:
            - CMD-SHELL
            - curl -f http://localhost/ || exit 1
          Interval: 30
          Timeout: 5
          Retries: 3
          StartPeriod: 60

ECSService:
  Type: AWS::ECS::Service
  DependsOn: LoadBalancerListener
  Properties:
    ServiceName: web-service
    Cluster: !Ref ECSCluster
    TaskDefinition: !Ref TaskDefinition
    DesiredCount: 2
    LaunchType: FARGATE
    NetworkConfiguration:
      AwsvpcConfiguration:
        AssignPublicIp: DISABLED
        SecurityGroups:
          - !Ref ECSSecurityGroup
        Subnets:
          - !Ref PrivateSubnet1
          - !Ref PrivateSubnet2
    LoadBalancers:
      - ContainerName: web-container
        ContainerPort: 80
        TargetGroupArn: !Ref TargetGroup
    HealthCheckGracePeriodSeconds: 60
    DeploymentConfiguration:
      MaximumPercent: 200
      MinimumHealthyPercent: 100
      DeploymentCircuitBreaker:
        Enable: true
        Rollback: true

ECSExecutionRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ecs-tasks.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
    Policies:
      - PolicyName: SecretsManagerAccess
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - secretsmanager:GetSecretValue
              Resource: !Ref DatabaseSecret

ECSTaskRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ecs-tasks.amazonaws.com
          Action: sts:AssumeRole
    Policies:
      - PolicyName: S3Access
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:PutObject
              Resource: !Sub '${S3Bucket.Arn}/*'
```

## Storage Services

### Amazon S3 (Simple Storage Service)

Object storage service offering scalability, data availability, security, and performance.

#### S3 Bucket with Lifecycle Policy

```yaml
# CloudFormation: S3 Bucket with comprehensive configuration
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub 'production-data-${AWS::AccountId}'
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
    VersioningConfiguration:
      Status: Enabled
    LifecycleConfiguration:
      Rules:
        - Id: TransitionToIA
          Status: Enabled
          Transitions:
            - TransitionInDays: 30
              StorageClass: STANDARD_IA
            - TransitionInDays: 90
              StorageClass: GLACIER
            - TransitionInDays: 365
              StorageClass: DEEP_ARCHIVE
          ExpirationInDays: 2555
          NoncurrentVersionTransitions:
            - TransitionInDays: 30
              StorageClass: STANDARD_IA
            - TransitionInDays: 90
              StorageClass: GLACIER
          NoncurrentVersionExpirationInDays: 365
        - Id: DeleteIncompleteMultipartUploads
          Status: Enabled
          AbortIncompleteMultipartUpload:
            DaysAfterInitiation: 7
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    LoggingConfiguration:
      DestinationBucketName: !Ref LoggingBucket
      LogFilePrefix: s3-access-logs/
    NotificationConfiguration:
      LambdaConfigurations:
        - Event: s3:ObjectCreated:*
          Function: !GetAtt ProcessingLambda.Arn
          Filter:
            S3Key:
              Rules:
                - Name: prefix
                  Value: uploads/
                - Name: suffix
                  Value: .jpg
    Tags:
      - Key: Environment
        Value: Production

S3BucketPolicy:
  Type: AWS::S3::BucketPolicy
  Properties:
    Bucket: !Ref S3Bucket
    PolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Sid: EnforceTLSRequestsOnly
          Effect: Deny
          Principal: '*'
          Action: 's3:*'
          Resource:
            - !GetAtt S3Bucket.Arn
            - !Sub '${S3Bucket.Arn}/*'
          Condition:
            Bool:
              'aws:SecureTransport': false
        - Sid: DenyUnencryptedObjectUploads
          Effect: Deny
          Principal: '*'
          Action: 's3:PutObject'
          Resource: !Sub '${S3Bucket.Arn}/*'
          Condition:
            StringNotEquals:
              's3:x-amz-server-side-encryption': AES256
```

#### S3 CLI Operations

```bash
# Upload file with server-side encryption
aws s3 cp myfile.txt s3://my-bucket/ \
  --server-side-encryption AES256 \
  --metadata '{"project":"webapp","environment":"production"}'

# Sync directory with S3 bucket
aws s3 sync ./local-dir s3://my-bucket/backup/ \
  --delete \
  --storage-class STANDARD_IA

# Create presigned URL for temporary access
aws s3 presign s3://my-bucket/private-file.pdf \
  --expires-in 3600

# List objects with specific prefix
aws s3api list-objects-v2 \
  --bucket my-bucket \
  --prefix "uploads/2024/" \
  --query 'Contents[?Size > `1048576`].[Key,Size,LastModified]' \
  --output table

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# Configure bucket lifecycle
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration file://lifecycle.json
```

### Amazon EBS (Elastic Block Store)

Block storage volumes for EC2 instances.

#### EBS Volume with Snapshots

```yaml
# CloudFormation: EBS Volume with automated snapshots
DataVolume:
  Type: AWS::EC2::Volume
  Properties:
    Size: 100
    VolumeType: gp3
    Iops: 3000
    Throughput: 125
    Encrypted: true
    KmsKeyId: !Ref KMSKey
    AvailabilityZone: !GetAtt EC2Instance.AvailabilityZone
    Tags:
      - Key: Name
        Value: DataVolume
      - Key: SnapshotSchedule
        Value: daily

VolumeAttachment:
  Type: AWS::EC2::VolumeAttachment
  Properties:
    Device: /dev/sdf
    InstanceId: !Ref EC2Instance
    VolumeId: !Ref DataVolume
```

```bash
# Create EBS snapshot
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Daily backup - $(date +%Y-%m-%d)" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=DailyBackup}]'

# Copy snapshot to another region
aws ec2 copy-snapshot \
  --source-region us-east-1 \
  --source-snapshot-id snap-1234567890abcdef0 \
  --destination-region us-west-2 \
  --description "DR copy"

# Create volume from snapshot
aws ec2 create-volume \
  --snapshot-id snap-1234567890abcdef0 \
  --availability-zone us-east-1a \
  --volume-type gp3 \
  --iops 3000
```

### Amazon EFS (Elastic File System)

Managed NFS file system for EC2 instances.

```yaml
# CloudFormation: EFS File System
EFSFileSystem:
  Type: AWS::EFS::FileSystem
  Properties:
    Encrypted: true
    KmsKeyId: !Ref KMSKey
    PerformanceMode: generalPurpose
    ThroughputMode: bursting
    LifecyclePolicies:
      - TransitionToIA: AFTER_30_DAYS
      - TransitionToPrimaryStorageClass: AFTER_1_ACCESS
    FileSystemTags:
      - Key: Name
        Value: SharedStorage

MountTargetSubnet1:
  Type: AWS::EFS::MountTarget
  Properties:
    FileSystemId: !Ref EFSFileSystem
    SubnetId: !Ref PrivateSubnet1
    SecurityGroups:
      - !Ref EFSSecurityGroup

MountTargetSubnet2:
  Type: AWS::EFS::MountTarget
  Properties:
    FileSystemId: !Ref EFSFileSystem
    SubnetId: !Ref PrivateSubnet2
    SecurityGroups:
      - !Ref EFSSecurityGroup

EFSSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for EFS mount targets
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 2049
        ToPort: 2049
        SourceSecurityGroupId: !Ref EC2SecurityGroup
```

## Database Services

### Amazon RDS (Relational Database Service)

Managed relational database service supporting multiple engines.

#### RDS Multi-AZ with Read Replicas

```yaml
# CloudFormation: RDS PostgreSQL with Multi-AZ
DBSubnetGroup:
  Type: AWS::RDS::DBSubnetGroup
  Properties:
    DBSubnetGroupName: rds-subnet-group
    DBSubnetGroupDescription: Subnet group for RDS instances
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
      - !Ref PrivateSubnet3
    Tags:
      - Key: Name
        Value: RDS-SubnetGroup

DBSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for RDS database
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 5432
        ToPort: 5432
        SourceSecurityGroupId: !Ref AppSecurityGroup
    Tags:
      - Key: Name
        Value: RDS-SecurityGroup

RDSInstance:
  Type: AWS::RDS::DBInstance
  DeletionPolicy: Snapshot
  Properties:
    DBInstanceIdentifier: production-db
    DBInstanceClass: db.r6g.xlarge
    Engine: postgres
    EngineVersion: '15.3'
    MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
    MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
    AllocatedStorage: 100
    MaxAllocatedStorage: 1000
    StorageType: gp3
    Iops: 3000
    StorageEncrypted: true
    KmsKeyId: !Ref KMSKey
    MultiAZ: true
    DBSubnetGroupName: !Ref DBSubnetGroup
    VPCSecurityGroups:
      - !Ref DBSecurityGroup
    BackupRetentionPeriod: 30
    PreferredBackupWindow: '03:00-04:00'
    PreferredMaintenanceWindow: 'sun:04:00-sun:05:00'
    EnableCloudwatchLogsExports:
      - postgresql
      - upgrade
    DeletionProtection: true
    EnableIAMDatabaseAuthentication: true
    MonitoringInterval: 60
    MonitoringRoleArn: !GetAtt MonitoringRole.Arn
    EnablePerformanceInsights: true
    PerformanceInsightsRetentionPeriod: 7
    PerformanceInsightsKMSKeyId: !Ref KMSKey
    Tags:
      - Key: Environment
        Value: Production

ReadReplica1:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: production-db-replica-1
    SourceDBInstanceIdentifier: !Ref RDSInstance
    DBInstanceClass: db.r6g.large
    PubliclyAccessible: false
    Tags:
      - Key: Name
        Value: ReadReplica1
      - Key: Purpose
        Value: Analytics

DBSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: rds-database-credentials
    Description: RDS database master credentials
    GenerateSecretString:
      SecretStringTemplate: '{"username": "dbadmin"}'
      GenerateStringKey: password
      PasswordLength: 32
      ExcludeCharacters: '"@/\'
      RequireEachIncludedType: true

SecretRDSAttachment:
  Type: AWS::SecretsManager::SecretTargetAttachment
  Properties:
    SecretId: !Ref DBSecret
    TargetId: !Ref RDSInstance
    TargetType: AWS::RDS::DBInstance
```

### Amazon DynamoDB

Fully managed NoSQL database service.

#### DynamoDB Table with GSI and Streams

```yaml
# CloudFormation: DynamoDB Table
DynamoDBTable:
  Type: AWS::DynamoDB::Table
  Properties:
    TableName: Users
    BillingMode: PAY_PER_REQUEST
    AttributeDefinitions:
      - AttributeName: userId
        AttributeType: S
      - AttributeName: email
        AttributeType: S
      - AttributeName: createdAt
        AttributeType: N
      - AttributeName: status
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
      - IndexName: StatusIndex
        KeySchema:
          - AttributeName: status
            KeyType: HASH
          - AttributeName: createdAt
            KeyType: RANGE
        Projection:
          ProjectionType: ALL
    StreamSpecification:
      StreamViewType: NEW_AND_OLD_IMAGES
    PointInTimeRecoverySpecification:
      PointInTimeRecoveryEnabled: true
    SSESpecification:
      SSEEnabled: true
      SSEType: KMS
      KMSMasterKeyId: !Ref KMSKey
    Tags:
      - Key: Environment
        Value: Production

DynamoDBStreamProcessor:
  Type: AWS::Lambda::Function
  Properties:
    FunctionName: DynamoDBStreamProcessor
    Runtime: python3.11
    Handler: index.lambda_handler
    Role: !GetAtt StreamProcessorRole.Arn
    Code:
      ZipFile: |
        import json

        def lambda_handler(event, context):
            for record in event['Records']:
                if record['eventName'] == 'INSERT':
                    new_image = record['dynamodb']['NewImage']
                    print(f"New user created: {json.dumps(new_image)}")
                elif record['eventName'] == 'MODIFY':
                    print(f"User modified")
                elif record['eventName'] == 'REMOVE':
                    print(f"User deleted")
            return {'statusCode': 200}

EventSourceMapping:
  Type: AWS::Lambda::EventSourceMapping
  Properties:
    EventSourceArn: !GetAtt DynamoDBTable.StreamArn
    FunctionName: !Ref DynamoDBStreamProcessor
    StartingPosition: LATEST
    BatchSize: 100
    MaximumBatchingWindowInSeconds: 10
```

#### DynamoDB Operations with Python

```python
# Python SDK (boto3) for DynamoDB operations
import boto3
from boto3.dynamodb.conditions import Key, Attr
from decimal import Decimal
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

# Put item
def create_user(user_id, email, name):
    response = table.put_item(
        Item={
            'userId': user_id,
            'email': email,
            'name': name,
            'createdAt': int(time.time()),
            'status': 'active',
            'metadata': {
                'loginCount': 0,
                'lastLogin': None
            }
        },
        ConditionExpression='attribute_not_exists(userId)'
    )
    return response

# Get item
def get_user(user_id):
    response = table.get_item(
        Key={'userId': user_id},
        ProjectionExpression='userId, email, #n, #s',
        ExpressionAttributeNames={
            '#n': 'name',
            '#s': 'status'
        }
    )
    return response.get('Item')

# Query with GSI
def get_user_by_email(email):
    response = table.query(
        IndexName='EmailIndex',
        KeyConditionExpression=Key('email').eq(email)
    )
    return response.get('Items', [])

# Update item
def update_user_status(user_id, new_status):
    response = table.update_item(
        Key={'userId': user_id},
        UpdateExpression='SET #s = :status, updatedAt = :timestamp',
        ExpressionAttributeNames={
            '#s': 'status'
        },
        ExpressionAttributeValues={
            ':status': new_status,
            ':timestamp': int(time.time())
        },
        ReturnValues='ALL_NEW'
    )
    return response.get('Attributes')

# Batch write
def batch_create_users(users):
    with table.batch_writer() as batch:
        for user in users:
            batch.put_item(Item=user)

# Scan with filter
def get_active_users():
    response = table.scan(
        FilterExpression=Attr('status').eq('active')
    )
    return response.get('Items', [])

# Transaction write
def transfer_credits(from_user_id, to_user_id, amount):
    client = boto3.client('dynamodb')
    response = client.transact_write_items(
        TransactItems=[
            {
                'Update': {
                    'TableName': 'Users',
                    'Key': {'userId': {'S': from_user_id}},
                    'UpdateExpression': 'SET credits = credits - :amount',
                    'ExpressionAttributeValues': {':amount': {'N': str(amount)}},
                    'ConditionExpression': 'credits >= :amount'
                }
            },
            {
                'Update': {
                    'TableName': 'Users',
                    'Key': {'userId': {'S': to_user_id}},
                    'UpdateExpression': 'SET credits = credits + :amount',
                    'ExpressionAttributeValues': {':amount': {'N': str(amount)}}
                }
            }
        ]
    )
    return response
```

### Amazon Aurora

MySQL and PostgreSQL-compatible relational database with enhanced performance.

```yaml
# CloudFormation: Aurora PostgreSQL Cluster
AuroraCluster:
  Type: AWS::RDS::DBCluster
  Properties:
    DBClusterIdentifier: production-aurora-cluster
    Engine: aurora-postgresql
    EngineVersion: '15.3'
    MasterUsername: !Sub '{{resolve:secretsmanager:${AuroraSecret}:SecretString:username}}'
    MasterUserPassword: !Sub '{{resolve:secretsmanager:${AuroraSecret}:SecretString:password}}'
    DatabaseName: productiondb
    DBSubnetGroupName: !Ref DBSubnetGroup
    VpcSecurityGroupIds:
      - !Ref DBSecurityGroup
    BackupRetentionPeriod: 35
    PreferredBackupWindow: '03:00-04:00'
    PreferredMaintenanceWindow: 'sun:04:00-sun:05:00'
    StorageEncrypted: true
    KmsKeyId: !Ref KMSKey
    EnableCloudwatchLogsExports:
      - postgresql
    DeletionProtection: true
    EnableIAMDatabaseAuthentication: true
    Tags:
      - Key: Environment
        Value: Production

AuroraInstance1:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: aurora-instance-1
    DBClusterIdentifier: !Ref AuroraCluster
    DBInstanceClass: db.r6g.xlarge
    Engine: aurora-postgresql
    PubliclyAccessible: false
    EnablePerformanceInsights: true
    PerformanceInsightsRetentionPeriod: 7
    MonitoringInterval: 60
    MonitoringRoleArn: !GetAtt MonitoringRole.Arn

AuroraInstance2:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: aurora-instance-2
    DBClusterIdentifier: !Ref AuroraCluster
    DBInstanceClass: db.r6g.large
    Engine: aurora-postgresql
    PubliclyAccessible: false
```

## Networking and Content Delivery

### Amazon VPC (Virtual Private Cloud)

Isolated cloud resources in a virtual network.

#### Production VPC with Public and Private Subnets

```yaml
# CloudFormation: Complete VPC Setup
VPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 10.0.0.0/16
    EnableDnsSupport: true
    EnableDnsHostnames: true
    Tags:
      - Key: Name
        Value: Production-VPC

# Internet Gateway
InternetGateway:
  Type: AWS::EC2::InternetGateway
  Properties:
    Tags:
      - Key: Name
        Value: Production-IGW

AttachGateway:
  Type: AWS::EC2::VPCGatewayAttachment
  Properties:
    VpcId: !Ref VPC
    InternetGatewayId: !Ref InternetGateway

# Public Subnets
PublicSubnet1:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: 10.0.1.0/24
    AvailabilityZone: !Select [0, !GetAZs '']
    MapPublicIpOnLaunch: true
    Tags:
      - Key: Name
        Value: Public-Subnet-1
      - Key: Type
        Value: Public

PublicSubnet2:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: 10.0.2.0/24
    AvailabilityZone: !Select [1, !GetAZs '']
    MapPublicIpOnLaunch: true
    Tags:
      - Key: Name
        Value: Public-Subnet-2
      - Key: Type
        Value: Public

# Private Subnets
PrivateSubnet1:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: 10.0.11.0/24
    AvailabilityZone: !Select [0, !GetAZs '']
    Tags:
      - Key: Name
        Value: Private-Subnet-1
      - Key: Type
        Value: Private

PrivateSubnet2:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: 10.0.12.0/24
    AvailabilityZone: !Select [1, !GetAZs '']
    Tags:
      - Key: Name
        Value: Private-Subnet-2
      - Key: Type
        Value: Private

# NAT Gateways
NATGateway1EIP:
  Type: AWS::EC2::EIP
  DependsOn: AttachGateway
  Properties:
    Domain: vpc
    Tags:
      - Key: Name
        Value: NAT-Gateway-1-EIP

NATGateway1:
  Type: AWS::EC2::NatGateway
  Properties:
    AllocationId: !GetAtt NATGateway1EIP.AllocationId
    SubnetId: !Ref PublicSubnet1
    Tags:
      - Key: Name
        Value: NAT-Gateway-1

NATGateway2EIP:
  Type: AWS::EC2::EIP
  DependsOn: AttachGateway
  Properties:
    Domain: vpc
    Tags:
      - Key: Name
        Value: NAT-Gateway-2-EIP

NATGateway2:
  Type: AWS::EC2::NatGateway
  Properties:
    AllocationId: !GetAtt NATGateway2EIP.AllocationId
    SubnetId: !Ref PublicSubnet2
    Tags:
      - Key: Name
        Value: NAT-Gateway-2

# Route Tables
PublicRouteTable:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref VPC
    Tags:
      - Key: Name
        Value: Public-RouteTable

PublicRoute:
  Type: AWS::EC2::Route
  DependsOn: AttachGateway
  Properties:
    RouteTableId: !Ref PublicRouteTable
    DestinationCidrBlock: 0.0.0.0/0
    GatewayId: !Ref InternetGateway

PublicSubnet1RouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PublicSubnet1
    RouteTableId: !Ref PublicRouteTable

PublicSubnet2RouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PublicSubnet2
    RouteTableId: !Ref PublicRouteTable

PrivateRouteTable1:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref VPC
    Tags:
      - Key: Name
        Value: Private-RouteTable-1

PrivateRoute1:
  Type: AWS::EC2::Route
  Properties:
    RouteTableId: !Ref PrivateRouteTable1
    DestinationCidrBlock: 0.0.0.0/0
    NatGatewayId: !Ref NATGateway1

PrivateSubnet1RouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PrivateSubnet1
    RouteTableId: !Ref PrivateRouteTable1

PrivateRouteTable2:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref VPC
    Tags:
      - Key: Name
        Value: Private-RouteTable-2

PrivateRoute2:
  Type: AWS::EC2::Route
  Properties:
    RouteTableId: !Ref PrivateRouteTable2
    DestinationCidrBlock: 0.0.0.0/0
    NatGatewayId: !Ref NATGateway2

PrivateSubnet2RouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PrivateSubnet2
    RouteTableId: !Ref PrivateRouteTable2
```

#### VPC Endpoints

```yaml
# CloudFormation: VPC Endpoints for AWS Services
S3VPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.s3'
    RouteTableIds:
      - !Ref PrivateRouteTable1
      - !Ref PrivateRouteTable2
    PolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal: '*'
          Action:
            - 's3:GetObject'
            - 's3:PutObject'
          Resource: '*'

DynamoDBVPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.dynamodb'
    RouteTableIds:
      - !Ref PrivateRouteTable1
      - !Ref PrivateRouteTable2

SecretsManagerVPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcEndpointType: Interface
    PrivateDnsEnabled: true
    VpcId: !Ref VPC
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.secretsmanager'
    SecurityGroupIds:
      - !Ref VPCEndpointSecurityGroup

SSMVPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcEndpointType: Interface
    PrivateDnsEnabled: true
    VpcId: !Ref VPC
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ssm'
    SecurityGroupIds:
      - !Ref VPCEndpointSecurityGroup
```

### Application Load Balancer

```yaml
# CloudFormation: Application Load Balancer
ApplicationLoadBalancer:
  Type: AWS::ElasticLoadBalancingV2::LoadBalancer
  Properties:
    Name: production-alb
    Type: application
    Scheme: internet-facing
    IpAddressType: ipv4
    Subnets:
      - !Ref PublicSubnet1
      - !Ref PublicSubnet2
    SecurityGroups:
      - !Ref ALBSecurityGroup
    Tags:
      - Key: Name
        Value: Production-ALB

ALBListener:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    DefaultActions:
      - Type: forward
        TargetGroupArn: !Ref TargetGroup
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 443
    Protocol: HTTPS
    SslPolicy: ELBSecurityPolicy-TLS-1-2-2017-01
    Certificates:
      - CertificateArn: !Ref SSLCertificate

ALBListenerHTTP:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    DefaultActions:
      - Type: redirect
        RedirectConfig:
          Protocol: HTTPS
          Port: 443
          StatusCode: HTTP_301
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 80
    Protocol: HTTP

TargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: web-servers
    Port: 80
    Protocol: HTTP
    VpcId: !Ref VPC
    HealthCheckEnabled: true
    HealthCheckPath: /health
    HealthCheckProtocol: HTTP
    HealthCheckIntervalSeconds: 30
    HealthCheckTimeoutSeconds: 5
    HealthyThresholdCount: 2
    UnhealthyThresholdCount: 3
    Matcher:
      HttpCode: 200
    TargetType: instance
    TargetGroupAttributes:
      - Key: deregistration_delay.timeout_seconds
        Value: 30
      - Key: stickiness.enabled
        Value: true
      - Key: stickiness.type
        Value: lb_cookie
      - Key: stickiness.lb_cookie.duration_seconds
        Value: 86400
```

### Amazon CloudFront

Content delivery network (CDN) service.

```yaml
# CloudFormation: CloudFront Distribution
CloudFrontDistribution:
  Type: AWS::CloudFront::Distribution
  Properties:
    DistributionConfig:
      Enabled: true
      Comment: Production CDN
      DefaultRootObject: index.html
      PriceClass: PriceClass_All
      HttpVersion: http2and3
      Origins:
        - Id: S3Origin
          DomainName: !GetAtt S3Bucket.RegionalDomainName
          S3OriginConfig:
            OriginAccessIdentity: !Sub 'origin-access-identity/cloudfront/${CloudFrontOAI}'
        - Id: ALBOrigin
          DomainName: !GetAtt ApplicationLoadBalancer.DNSName
          CustomOriginConfig:
            HTTPPort: 80
            HTTPSPort: 443
            OriginProtocolPolicy: https-only
            OriginSSLProtocols:
              - TLSv1.2
      DefaultCacheBehavior:
        TargetOriginId: S3Origin
        ViewerProtocolPolicy: redirect-to-https
        AllowedMethods:
          - GET
          - HEAD
          - OPTIONS
        CachedMethods:
          - GET
          - HEAD
        Compress: true
        CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6  # Managed-CachingOptimized
        OriginRequestPolicyId: 88a5eaf4-2fd4-4709-b370-b4c650ea3fcf  # Managed-CORS-S3Origin
      CacheBehaviors:
        - PathPattern: '/api/*'
          TargetOriginId: ALBOrigin
          ViewerProtocolPolicy: https-only
          AllowedMethods:
            - DELETE
            - GET
            - HEAD
            - OPTIONS
            - PATCH
            - POST
            - PUT
          CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad  # Managed-CachingDisabled
          OriginRequestPolicyId: 216adef6-5c7f-47e4-b989-5492eafa07d3  # Managed-AllViewer
      ViewerCertificate:
        AcmCertificateArn: !Ref SSLCertificate
        SslSupportMethod: sni-only
        MinimumProtocolVersion: TLSv1.2_2021
      Logging:
        Bucket: !GetAtt LoggingBucket.DomainName
        Prefix: cloudfront-logs/
        IncludeCookies: false
      CustomErrorResponses:
        - ErrorCode: 403
          ResponseCode: 404
          ResponsePagePath: /404.html
        - ErrorCode: 404
          ResponseCode: 404
          ResponsePagePath: /404.html

CloudFrontOAI:
  Type: AWS::CloudFront::CloudFrontOriginAccessIdentity
  Properties:
    CloudFrontOriginAccessIdentityConfig:
      Comment: OAI for S3 bucket access
```

## Security, Identity, and Compliance

### AWS IAM (Identity and Access Management)

#### IAM Roles and Policies

```yaml
# CloudFormation: IAM Role with least privilege
EC2InstanceRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: EC2-WebServer-Role
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
      - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    Policies:
      - PolicyName: S3BucketAccess
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Sid: ListBucket
              Effect: Allow
              Action:
                - s3:ListBucket
              Resource: !GetAtt S3Bucket.Arn
            - Sid: GetPutObjects
              Effect: Allow
              Action:
                - s3:GetObject
                - s3:PutObject
              Resource: !Sub '${S3Bucket.Arn}/*'
      - PolicyName: DynamoDBAccess
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - dynamodb:GetItem
                - dynamodb:PutItem
                - dynamodb:Query
              Resource: !GetAtt DynamoDBTable.Arn
              Condition:
                StringEquals:
                  'dynamodb:LeadingKeys':
                    - '${aws:username}'

InstanceProfile:
  Type: AWS::IAM::InstanceProfile
  Properties:
    InstanceProfileName: EC2-WebServer-Profile
    Roles:
      - !Ref EC2InstanceRole
```

#### Cross-Account Access Role

```yaml
# CloudFormation: Cross-account IAM role
CrossAccountRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: CrossAccountAccessRole
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            AWS: !Sub 'arn:aws:iam::${TrustedAccountId}:root'
          Action: sts:AssumeRole
          Condition:
            StringEquals:
              'sts:ExternalId': !Ref ExternalId
    Policies:
      - PolicyName: ReadOnlyAccess
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:ListBucket
              Resource:
                - !GetAtt S3Bucket.Arn
                - !Sub '${S3Bucket.Arn}/*'
```

### AWS KMS (Key Management Service)

```yaml
# CloudFormation: KMS Key with key policy
KMSKey:
  Type: AWS::KMS::Key
  Properties:
    Description: Master encryption key for production resources
    KeyPolicy:
      Version: '2012-10-17'
      Statement:
        - Sid: Enable IAM User Permissions
          Effect: Allow
          Principal:
            AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
          Action: 'kms:*'
          Resource: '*'
        - Sid: Allow services to use the key
          Effect: Allow
          Principal:
            Service:
              - s3.amazonaws.com
              - rds.amazonaws.com
              - lambda.amazonaws.com
          Action:
            - 'kms:Decrypt'
            - 'kms:GenerateDataKey'
          Resource: '*'
        - Sid: Allow administrators to manage the key
          Effect: Allow
          Principal:
            AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:role/Admin'
          Action:
            - 'kms:Create*'
            - 'kms:Describe*'
            - 'kms:Enable*'
            - 'kms:List*'
            - 'kms:Put*'
            - 'kms:Update*'
            - 'kms:Revoke*'
            - 'kms:Disable*'
            - 'kms:Get*'
            - 'kms:Delete*'
            - 'kms:ScheduleKeyDeletion'
            - 'kms:CancelKeyDeletion'
          Resource: '*'

KMSKeyAlias:
  Type: AWS::KMS::Alias
  Properties:
    AliasName: alias/production-master-key
    TargetKeyId: !Ref KMSKey
```

### AWS CloudTrail

```yaml
# CloudFormation: CloudTrail for audit logging
CloudTrailBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub 'cloudtrail-logs-${AWS::AccountId}'
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    LifecycleConfiguration:
      Rules:
        - Id: MoveToGlacier
          Status: Enabled
          Transitions:
            - TransitionInDays: 90
              StorageClass: GLACIER
          ExpirationInDays: 2555

CloudTrailBucketPolicy:
  Type: AWS::S3::BucketPolicy
  Properties:
    Bucket: !Ref CloudTrailBucket
    PolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Sid: AWSCloudTrailAclCheck
          Effect: Allow
          Principal:
            Service: cloudtrail.amazonaws.com
          Action: 's3:GetBucketAcl'
          Resource: !GetAtt CloudTrailBucket.Arn
        - Sid: AWSCloudTrailWrite
          Effect: Allow
          Principal:
            Service: cloudtrail.amazonaws.com
          Action: 's3:PutObject'
          Resource: !Sub '${CloudTrailBucket.Arn}/*'
          Condition:
            StringEquals:
              's3:x-amz-acl': bucket-owner-full-control

CloudTrail:
  Type: AWS::CloudTrail::Trail
  DependsOn: CloudTrailBucketPolicy
  Properties:
    TrailName: organization-trail
    S3BucketName: !Ref CloudTrailBucket
    IncludeGlobalServiceEvents: true
    IsLogging: true
    IsMultiRegionTrail: true
    EnableLogFileValidation: true
    EventSelectors:
      - ReadWriteType: All
        IncludeManagementEvents: true
        DataResources:
          - Type: 'AWS::S3::Object'
            Values:
              - !Sub '${S3Bucket.Arn}/*'
          - Type: 'AWS::Lambda::Function'
            Values:
              - 'arn:aws:lambda:*:*:function/*'
```

## Serverless Architecture

### AWS Step Functions

```yaml
# CloudFormation: Step Functions State Machine
StateMachine:
  Type: AWS::StepFunctions::StateMachine
  Properties:
    StateMachineName: OrderProcessingWorkflow
    RoleArn: !GetAtt StateMachineRole.Arn
    DefinitionString: !Sub |
      {
        "Comment": "Order processing workflow",
        "StartAt": "ValidateOrder",
        "States": {
          "ValidateOrder": {
            "Type": "Task",
            "Resource": "${ValidateOrderFunction.Arn}",
            "Next": "CheckInventory",
            "Catch": [{
              "ErrorEquals": ["ValidationError"],
              "ResultPath": "$.error",
              "Next": "OrderFailed"
            }]
          },
          "CheckInventory": {
            "Type": "Task",
            "Resource": "${CheckInventoryFunction.Arn}",
            "Next": "IsInventoryAvailable",
            "ResultPath": "$.inventory"
          },
          "IsInventoryAvailable": {
            "Type": "Choice",
            "Choices": [{
              "Variable": "$.inventory.available",
              "BooleanEquals": true,
              "Next": "ProcessPayment"
            }],
            "Default": "OrderFailed"
          },
          "ProcessPayment": {
            "Type": "Task",
            "Resource": "${ProcessPaymentFunction.Arn}",
            "Next": "UpdateInventory",
            "Retry": [{
              "ErrorEquals": ["PaymentServiceError"],
              "IntervalSeconds": 2,
              "MaxAttempts": 3,
              "BackoffRate": 2.0
            }],
            "Catch": [{
              "ErrorEquals": ["PaymentFailed"],
              "ResultPath": "$.error",
              "Next": "OrderFailed"
            }]
          },
          "UpdateInventory": {
            "Type": "Task",
            "Resource": "${UpdateInventoryFunction.Arn}",
            "Next": "SendConfirmation"
          },
          "SendConfirmation": {
            "Type": "Task",
            "Resource": "arn:aws:states:::sns:publish",
            "Parameters": {
              "TopicArn": "${OrderConfirmationTopic}",
              "Message.$": "$.confirmationMessage"
            },
            "Next": "OrderSucceeded"
          },
          "OrderSucceeded": {
            "Type": "Succeed"
          },
          "OrderFailed": {
            "Type": "Fail",
            "Error": "OrderProcessingFailed",
            "Cause": "Order could not be processed"
          }
        }
      }
```

### Amazon EventBridge

```yaml
# CloudFormation: EventBridge Rule
EventBridgeRule:
  Type: AWS::Events::Rule
  Properties:
    Name: S3ObjectCreatedRule
    Description: Trigger processing when objects are created in S3
    State: ENABLED
    EventPattern:
      source:
        - aws.s3
      detail-type:
        - 'AWS API Call via CloudTrail'
      detail:
        eventSource:
          - s3.amazonaws.com
        eventName:
          - PutObject
          - CompleteMultipartUpload
        requestParameters:
          bucketName:
            - !Ref S3Bucket
    Targets:
      - Arn: !GetAtt ProcessingFunction.Arn
        Id: ProcessingLambda
      - Arn: !Ref ProcessingQueue
        Id: SQSQueue
      - Arn: !GetAtt StateMachine.Arn
        Id: StepFunctionsWorkflow
        RoleArn: !GetAtt EventBridgeRole.Arn
```

## Cost Optimization

### EC2 Reserved Instances and Savings Plans

```bash
# Describe Reserved Instance offerings
aws ec2 describe-reserved-instances-offerings \
  --instance-type t3.medium \
  --offering-class standard \
  --product-description "Linux/UNIX" \
  --query 'ReservedInstancesOfferings[*].[InstanceType,Duration,FixedPrice,UsagePrice,OfferingClass]' \
  --output table

# Purchase Reserved Instance
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id <offering-id> \
  --instance-count 2

# Describe Savings Plans
aws savingsplans describe-savings-plans \
  --query 'savingsPlans[*].[savingsPlanId,savingsPlanType,commitment,ec2InstanceFamily]' \
  --output table
```

### AWS Cost Explorer and Budgets

```yaml
# CloudFormation: Budget with alerts
MonthlyBudget:
  Type: AWS::Budgets::Budget
  Properties:
    Budget:
      BudgetName: Monthly-AWS-Budget
      BudgetLimit:
        Amount: 1000
        Unit: USD
      TimeUnit: MONTHLY
      BudgetType: COST
      CostFilters:
        TagKeyValue:
          - 'user:Environment$Production'
      CostTypes:
        IncludeTax: true
        IncludeSubscription: true
        UseBlended: false
    NotificationsWithSubscribers:
      - Notification:
          NotificationType: ACTUAL
          ComparisonOperator: GREATER_THAN
          Threshold: 80
        Subscribers:
          - SubscriptionType: EMAIL
            Address: admin@example.com
      - Notification:
          NotificationType: FORECASTED
          ComparisonOperator: GREATER_THAN
          Threshold: 100
        Subscribers:
          - SubscriptionType: EMAIL
            Address: admin@example.com
          - SubscriptionType: SNS
            Address: !Ref AlertTopic
```

### S3 Intelligent-Tiering

```bash
# Enable S3 Intelligent-Tiering
aws s3api put-bucket-intelligent-tiering-configuration \
  --bucket my-bucket \
  --id EntirePrefix \
  --intelligent-tiering-configuration '{
    "Id": "EntirePrefix",
    "Status": "Enabled",
    "Tierings": [
      {
        "Days": 90,
        "AccessTier": "ARCHIVE_ACCESS"
      },
      {
        "Days": 180,
        "AccessTier": "DEEP_ARCHIVE_ACCESS"
      }
    ]
  }'
```

## Monitoring and Operations

### Amazon CloudWatch

```yaml
# CloudFormation: CloudWatch Dashboard and Alarms
CloudWatchDashboard:
  Type: AWS::CloudWatch::Dashboard
  Properties:
    DashboardName: Production-Dashboard
    DashboardBody: !Sub |
      {
        "widgets": [
          {
            "type": "metric",
            "properties": {
              "metrics": [
                ["AWS/EC2", "CPUUtilization", {"stat": "Average"}],
                ["AWS/ApplicationELB", "TargetResponseTime"],
                ["AWS/RDS", "DatabaseConnections", {"stat": "Sum"}]
              ],
              "period": 300,
              "stat": "Average",
              "region": "${AWS::Region}",
              "title": "System Metrics"
            }
          }
        ]
      }

HighCPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: High-CPU-Utilization
    AlarmDescription: Alert when CPU exceeds 80%
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopic
    Dimensions:
      - Name: InstanceId
        Value: !Ref EC2Instance

DatabaseConnectionsAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: High-Database-Connections
    MetricName: DatabaseConnections
    Namespace: AWS/RDS
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopic
    Dimensions:
      - Name: DBInstanceIdentifier
        Value: !Ref RDSInstance
```

## High Availability and Disaster Recovery

### Multi-Region Architecture

```yaml
# CloudFormation: Route53 Health Check and Failover
HealthCheck:
  Type: AWS::Route53::HealthCheck
  Properties:
    HealthCheckConfig:
      Type: HTTPS
      ResourcePath: /health
      FullyQualifiedDomainName: !GetAtt ApplicationLoadBalancer.DNSName
      Port: 443
      RequestInterval: 30
      FailureThreshold: 3
    HealthCheckTags:
      - Key: Name
        Value: Primary-Region-HealthCheck

DNSRecord:
  Type: AWS::Route53::RecordSet
  Properties:
    HostedZoneId: !Ref HostedZone
    Name: api.example.com
    Type: A
    SetIdentifier: Primary
    Failover: PRIMARY
    AliasTarget:
      HostedZoneId: !GetAtt ApplicationLoadBalancer.CanonicalHostedZoneID
      DNSName: !GetAtt ApplicationLoadBalancer.DNSName
      EvaluateTargetHealth: true
    HealthCheckId: !Ref HealthCheck

DNSRecordSecondary:
  Type: AWS::Route53::RecordSet
  Properties:
    HostedZoneId: !Ref HostedZone
    Name: api.example.com
    Type: A
    SetIdentifier: Secondary
    Failover: SECONDARY
    AliasTarget:
      HostedZoneId: !GetAtt SecondaryLoadBalancer.CanonicalHostedZoneID
      DNSName: !GetAtt SecondaryLoadBalancer.DNSName
      EvaluateTargetHealth: true
```

### Backup and Recovery

```yaml
# CloudFormation: AWS Backup Plan
BackupVault:
  Type: AWS::Backup::BackupVault
  Properties:
    BackupVaultName: ProductionBackupVault
    EncryptionKeyArn: !GetAtt KMSKey.Arn

BackupPlan:
  Type: AWS::Backup::BackupPlan
  Properties:
    BackupPlan:
      BackupPlanName: DailyBackupPlan
      BackupPlanRule:
        - RuleName: DailyBackup
          TargetBackupVault: !Ref BackupVault
          ScheduleExpression: 'cron(0 5 ? * * *)'
          StartWindowMinutes: 60
          CompletionWindowMinutes: 120
          Lifecycle:
            DeleteAfterDays: 35
            MoveToColdStorageAfterDays: 30
        - RuleName: WeeklyBackup
          TargetBackupVault: !Ref BackupVault
          ScheduleExpression: 'cron(0 5 ? * 1 *)'
          Lifecycle:
            DeleteAfterDays: 365
            MoveToColdStorageAfterDays: 90

BackupSelection:
  Type: AWS::Backup::BackupSelection
  Properties:
    BackupPlanId: !Ref BackupPlan
    BackupSelection:
      SelectionName: ProductionResources
      IamRoleArn: !GetAtt BackupRole.Arn
      Resources:
        - !GetAtt RDSInstance.Arn
        - !Sub 'arn:aws:ec2:${AWS::Region}:${AWS::AccountId}:volume/*'
      ListOfTags:
        - ConditionType: STRINGEQUALS
          ConditionKey: Backup
          ConditionValue: 'true'
```

## Best Practices Summary

1. **Security**: Always encrypt data at rest and in transit, use least privilege IAM policies, enable MFA
2. **High Availability**: Deploy across multiple Availability Zones, use Auto Scaling
3. **Cost Optimization**: Right-size resources, use Reserved Instances/Savings Plans, implement lifecycle policies
4. **Performance**: Use caching (CloudFront, ElastiCache), optimize database queries, leverage CDN
5. **Reliability**: Implement automated backups, test disaster recovery procedures, monitor everything
6. **Operational Excellence**: Automate deployment with Infrastructure as Code, implement CI/CD pipelines
7. **Sustainability**: Use managed services, optimize resource utilization, shutdown non-production resources

---

This skill provides comprehensive coverage of AWS cloud architecture following the Well-Architected Framework pillars. All examples are production-ready and follow AWS best practices.
