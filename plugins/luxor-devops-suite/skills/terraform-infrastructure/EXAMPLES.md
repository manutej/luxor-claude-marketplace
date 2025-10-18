# Terraform Infrastructure Examples

Comprehensive real-world examples demonstrating Terraform patterns, best practices, and multi-cloud infrastructure implementations.

## Table of Contents

1. [AWS VPC with Public and Private Subnets](#example-1-aws-vpc-with-public-and-private-subnets)
2. [AWS Three-Tier Web Application](#example-2-aws-three-tier-web-application)
3. [AWS Auto-Scaling Web Application](#example-3-aws-auto-scaling-web-application)
4. [AWS RDS PostgreSQL Database](#example-4-aws-rds-postgresql-database)
5. [Creating and Using Terraform Modules](#example-5-creating-and-using-terraform-modules)
6. [Multi-Environment with Workspaces](#example-6-multi-environment-with-workspaces)
7. [Remote State with S3 Backend](#example-7-remote-state-with-s3-backend)
8. [Azure Virtual Network and Virtual Machines](#example-8-azure-virtual-network-and-virtual-machines)
9. [Azure App Service with Database](#example-9-azure-app-service-with-database)
10. [Azure Kubernetes Service (AKS)](#example-10-azure-kubernetes-service-aks)
11. [GCP Compute Instance and Network](#example-11-gcp-compute-instance-and-network)
12. [GCP Google Kubernetes Engine (GKE)](#example-12-gcp-google-kubernetes-engine-gke)
13. [Terraform Cloud Integration](#example-13-terraform-cloud-integration)
14. [Kubernetes Deployment with Terraform](#example-14-kubernetes-deployment-with-terraform)
15. [Multi-Cloud Architecture](#example-15-multi-cloud-architecture)
16. [AWS Lambda Function with API Gateway](#example-16-aws-lambda-function-with-api-gateway)
17. [AWS ECS Fargate Application](#example-17-aws-ecs-fargate-application)
18. [Disaster Recovery Multi-Region Setup](#example-18-disaster-recovery-multi-region-setup)
19. [Testing Infrastructure with Terraform](#example-19-testing-infrastructure-with-terraform)
20. [Complete GitOps Workflow](#example-20-complete-gitops-workflow)

---

## Example 1: AWS VPC with Public and Private Subnets

Create a production-ready VPC with public and private subnets across multiple availability zones.

### Directory Structure

```
vpc-infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

### main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

### variables.tf

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT gateway for private subnets"
  default     = true
}
```

### outputs.tf

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = aws_nat_gateway.main[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}
```

### terraform.tfvars

```hcl
aws_region     = "us-east-1"
project_name   = "myapp"
environment    = "prod"
vpc_cidr       = "10.0.0.0/16"

availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
enable_nat_gateway     = true
```

### Usage

```bash
terraform init
terraform plan
terraform apply
```

---

## Example 2: AWS Three-Tier Web Application

Complete infrastructure for a three-tier web application with load balancer, web servers, and database.

### main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

# Security Group for Web Servers
resource "aws_security_group" "web" {
  name        = "${var.app_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from bastion or VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-web-sg"
  }
}

# Security Group for Database
resource "aws_security_group" "database" {
  name        = "${var.app_name}-db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from web servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-db-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.app_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    db_host = aws_db_instance.main.address
    db_name = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.app_name}-web-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.app_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
  identifier           = "${var.app_name}-db"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  multi_az               = var.multi_az
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  tags = {
    Name = "${var.app_name}-db"
  }
}
```

### variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for web servers and database"
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH"
  default     = ["10.0.0.0/16"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 6
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}
```

### user-data.sh

```bash
#!/bin/bash
yum update -y
yum install -y httpd postgresql15

# Start Apache
systemctl start httpd
systemctl enable httpd

# Create test page
cat > /var/www/html/index.html <<EOF
<html>
<head><title>Three-Tier App</title></head>
<body>
<h1>Three-Tier Web Application</h1>
<p>Database: ${db_host}</p>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF

# Configure application
export DB_HOST="${db_host}"
export DB_NAME="${db_name}"
```

---

## Example 3: AWS Auto-Scaling Web Application

Advanced auto-scaling configuration with scheduled scaling and CloudWatch alarms.

### main.tf

```hcl
# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.app_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_description = "Scale up if CPU > 70%"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.app_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_description = "Scale down if CPU < 30%"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

# Scheduled Scaling - Scale up during business hours
resource "aws_autoscaling_schedule" "scale_up_morning" {
  scheduled_action_name  = "${var.app_name}-scale-up-morning"
  min_size               = 4
  max_size               = 10
  desired_capacity       = 4
  recurrence             = "0 8 * * MON-FRI"  # 8 AM weekdays
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Scheduled Scaling - Scale down after business hours
resource "aws_autoscaling_schedule" "scale_down_evening" {
  scheduled_action_name  = "${var.app_name}-scale-down-evening"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  recurrence             = "0 18 * * MON-FRI"  # 6 PM weekdays
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "${var.app_name}-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
```

---

## Example 4: AWS RDS PostgreSQL Database

Production-ready RDS configuration with read replicas, backups, and monitoring.

### main.tf

```hcl
# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "postgres" {
  name   = "${var.app_name}-postgres15"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = {
    Name = "${var.app_name}-postgres15-params"
  }
}

# Security Group
resource "aws_security_group" "rds" {
  name        = "${var.app_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from application"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.application_security_group_ids
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-sg"
  }
}

# KMS Key for encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "${var.app_name}-rds-key"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.app_name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# Primary RDS Instance
resource "aws_db_instance" "primary" {
  identifier     = "${var.app_name}-db-primary"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.postgres.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # High availability
  multi_az = var.multi_az

  # Backups
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.app_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled    = true
  performance_insights_retention_period = 7

  # Protection
  deletion_protection = var.deletion_protection

  tags = {
    Name = "${var.app_name}-db-primary"
  }
}

# Read Replica
resource "aws_db_instance" "replica" {
  count              = var.create_read_replica ? 1 : 0
  identifier         = "${var.app_name}-db-replica-${count.index + 1}"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class     = var.db_replica_instance_class

  # Override settings from primary
  publicly_accessible = false
  skip_final_snapshot = true

  # Monitoring
  monitoring_interval  = 60
  monitoring_role_arn  = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "${var.app_name}-db-replica-${count.index + 1}"
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.app_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.app_name}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Database CPU utilization is too high"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }
}

resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name          = "${var.app_name}-db-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240  # 10 GB in bytes
  alarm_description   = "Database free storage space is low"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.app_name}-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Database connection count is high"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }
}
```

### outputs.tf

```hcl
output "primary_endpoint" {
  description = "Primary database endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "primary_address" {
  description = "Primary database address"
  value       = aws_db_instance.primary.address
}

output "replica_endpoints" {
  description = "Read replica endpoints"
  value       = aws_db_instance.replica[*].endpoint
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.primary.db_name
}
```

---

## Example 5: Creating and Using Terraform Modules

Build reusable infrastructure modules for team-wide use.

### Module Structure

```
modules/
└── ec2-instance/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

### modules/ec2-instance/main.tf

```hcl
# Data source for AMI
data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_owners

  dynamic "filter" {
    for_each = var.ami_filters

    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# EC2 Instance
resource "aws_instance" "this" {
  count = var.instance_count

  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.this.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]

  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  monitoring = var.enable_monitoring

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.root_encrypted
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes

    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${count.index + 1}"
    }
  )

  lifecycle {
    create_before_destroy = var.create_before_destroy
    ignore_changes        = var.lifecycle_ignore_changes
  }
}

# Elastic IPs (optional)
resource "aws_eip" "this" {
  count = var.create_eip ? var.instance_count : 0

  instance = aws_instance.this[count.index].id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-eip-${count.index + 1}"
    }
  )
}
```

### modules/ec2-instance/variables.tf

```hcl
variable "name" {
  type        = string
  description = "Name prefix for resources"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
}

variable "ami_id" {
  type        = string
  description = "AMI ID (leave empty to use ami_filters)"
  default     = ""
}

variable "ami_owners" {
  type        = list(string)
  description = "AMI owners for filtering"
  default     = ["amazon"]
}

variable "ami_filters" {
  type = list(object({
    name   = string
    values = list(string)
  }))
  description = "AMI filters"
  default = [
    {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  ]
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.micro"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for instance placement"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
  default     = null
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = null
}

variable "user_data" {
  type        = string
  description = "User data script"
  default     = null
}

variable "user_data_replace_on_change" {
  type        = bool
  description = "Replace instance when user data changes"
  default     = false
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed monitoring"
  default     = false
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type"
  default     = "gp3"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 20
}

variable "root_delete_on_termination" {
  type        = bool
  description = "Delete root volume on instance termination"
  default     = true
}

variable "root_encrypted" {
  type        = bool
  description = "Encrypt root volume"
  default     = true
}

variable "ebs_volumes" {
  type = list(object({
    device_name           = string
    volume_type           = string
    volume_size           = number
    delete_on_termination = bool
    encrypted             = bool
  }))
  description = "Additional EBS volumes"
  default     = []
}

variable "require_imdsv2" {
  type        = bool
  description = "Require IMDSv2 for instance metadata"
  default     = true
}

variable "create_eip" {
  type        = bool
  description = "Create and associate Elastic IPs"
  default     = false
}

variable "create_before_destroy" {
  type        = bool
  description = "Create replacement before destroying"
  default     = false
}

variable "lifecycle_ignore_changes" {
  type        = list(string)
  description = "Lifecycle ignore changes"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
```

### modules/ec2-instance/outputs.tf

```hcl
output "instance_ids" {
  description = "Instance IDs"
  value       = aws_instance.this[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "instance_public_ips" {
  description = "Public IP addresses"
  value       = aws_instance.this[*].public_ip
}

output "eip_public_ips" {
  description = "Elastic IP addresses"
  value       = aws_eip.this[*].public_ip
}

output "instance_arns" {
  description = "Instance ARNs"
  value       = aws_instance.this[*].arn
}
```

### Using the Module

```hcl
# Root main.tf
module "web_servers" {
  source = "./modules/ec2-instance"

  name           = "web-server"
  instance_count = 3
  instance_type  = "t3.small"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.web.id]
  key_name           = aws_key_pair.deployer.key_name

  user_data = templatefile("${path.module}/web-user-data.sh", {
    environment = "production"
  })

  root_volume_size = 30
  enable_monitoring = true

  tags = {
    Environment = "production"
    Tier        = "web"
    ManagedBy   = "Terraform"
  }
}

module "app_servers" {
  source = "./modules/ec2-instance"

  name           = "app-server"
  instance_count = 2
  instance_type  = "t3.medium"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.app.id]

  ebs_volumes = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 100
      delete_on_termination = true
      encrypted             = true
    }
  ]

  tags = {
    Environment = "production"
    Tier        = "application"
    ManagedBy   = "Terraform"
  }
}

# Use module outputs
output "web_server_ips" {
  value = module.web_servers.instance_private_ips
}
```

---

## Example 6: Multi-Environment with Workspaces

Manage multiple environments using Terraform workspaces.

### main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "myapp-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
      Workspace   = terraform.workspace
    }
  }
}

# Environment-specific configuration
locals {
  environment_config = {
    dev = {
      vpc_cidr          = "10.0.0.0/16"
      instance_type     = "t3.micro"
      instance_count    = 1
      db_instance_class = "db.t3.micro"
      multi_az          = false
      backup_retention  = 1
      enable_monitoring = false
    }
    staging = {
      vpc_cidr          = "10.1.0.0/16"
      instance_type     = "t3.small"
      instance_count    = 2
      db_instance_class = "db.t3.small"
      multi_az          = false
      backup_retention  = 3
      enable_monitoring = true
    }
    prod = {
      vpc_cidr          = "10.2.0.0/16"
      instance_type     = "t3.large"
      instance_count    = 5
      db_instance_class = "db.t3.large"
      multi_az          = true
      backup_retention  = 7
      enable_monitoring = true
    }
  }

  config = local.environment_config[terraform.workspace]

  common_tags = {
    Project     = var.project_name
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = local.config.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${terraform.workspace}-vpc"
    }
  )
}

# Application Instances
resource "aws_instance" "app" {
  count         = local.config.instance_count
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = local.config.instance_type

  monitoring = local.config.enable_monitoring

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${terraform.workspace}-app-${count.index + 1}"
    }
  )
}

# Database
resource "aws_db_instance" "main" {
  identifier          = "${var.project_name}-${terraform.workspace}-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = local.config.db_instance_class
  allocated_storage   = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az                = local.config.multi_az
  backup_retention_period = local.config.backup_retention
  skip_final_snapshot     = terraform.workspace != "prod"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${terraform.workspace}-db"
    }
  )
}
```

### Usage

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to dev
terraform workspace select dev
terraform plan
terraform apply

# Deploy to staging
terraform workspace select staging
terraform plan
terraform apply

# Deploy to production
terraform workspace select prod
terraform plan
terraform apply

# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

---

## Example 7: Remote State with S3 Backend

Configure remote state storage with locking for team collaboration.

### Step 1: Create State Backend Resources

```hcl
# bootstrap/main.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform State Bucket"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# KMS Key for encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name    = "Terraform State Key"
    Project = var.project_name
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "Terraform State Lock Table"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Outputs
output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_lock_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}
```

### Step 2: Bootstrap State Backend

```bash
# Initialize and create state backend resources
cd bootstrap
terraform init
terraform apply

# Note the bucket and table names from outputs
```

### Step 3: Configure Backend in Main Project

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "myproject-terraform-locks"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}
```

### Step 4: Use Backend Configuration Files

```hcl
# backend-config-dev.hcl
bucket         = "myproject-terraform-state"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "myproject-terraform-locks"

# backend-config-staging.hcl
bucket         = "myproject-terraform-state"
key            = "staging/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "myproject-terraform-locks"

# backend-config-prod.hcl
bucket         = "myproject-terraform-state"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "myproject-terraform-locks"
```

### Usage

```bash
# Initialize with specific backend config
terraform init -backend-config=backend-config-dev.hcl

# Migrate existing local state to remote
terraform init -migrate-state

# Verify remote state
terraform state list

# Pull remote state
terraform state pull > terraform.tfstate.backup
```

---

## Example 8: Azure Virtual Network and Virtual Machines

Deploy Azure infrastructure with VNet, subnets, and virtual machines.

### main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.azure_region

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = azurerm_resource_group.main.tags
}

# Subnets
resource "azurerm_subnet" "web" {
  name                 = "${var.project_name}-web-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_cidr]
}

resource "azurerm_subnet" "app" {
  name                 = "${var.project_name}-app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet" "data" {
  name                 = "${var.project_name}-data-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_subnet_cidr]
}

# Network Security Group
resource "azurerm_network_security_group" "web" {
  name                = "${var.project_name}-web-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.main.tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# Public IP
resource "azurerm_public_ip" "web" {
  count               = var.vm_count
  name                = "${var.project_name}-web-pip-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.main.tags
}

# Network Interface
resource "azurerm_network_interface" "web" {
  count               = var.vm_count
  name                = "${var.project_name}-web-nic-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web[count.index].id
  }

  tags = azurerm_resource_group.main.tags
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "web" {
  count               = var.vm_count
  name                = "${var.project_name}-web-vm-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.web[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "${var.project_name}-web-osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yaml"))

  tags = merge(
    azurerm_resource_group.main.tags,
    {
      Name = "${var.project_name}-web-vm-${count.index + 1}"
    }
  )
}

# Load Balancer
resource "azurerm_lb" "web" {
  name                = "${var.project_name}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_public_ip" "lb" {
  name                = "${var.project_name}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "WebBackendPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}

resource "azurerm_lb_probe" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

resource "azurerm_lb_rule" "web" {
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.web.id
}
```

### variables.tf

```hcl
variable "azure_region" {
  type    = string
  default = "East US"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "web_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "data_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "ssh_source_address" {
  type        = string
  description = "Source IP address for SSH access"
  default     = "*"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
```

---

This file contains 8 comprehensive examples covering AWS VPC, three-tier applications, auto-scaling, RDS databases, modules, workspaces, remote state, and Azure infrastructure. The next part will continue with Examples 9-20 covering Azure App Service, AKS, GCP, Kubernetes, multi-cloud, Lambda, ECS, disaster recovery, testing, and GitOps workflows.

Would you like me to continue with the remaining 12 examples?
