---
name: terraform-infrastructure-as-code
description: Comprehensive Terraform Infrastructure as Code skill covering resources, modules, state management, workspaces, providers, and advanced patterns for cloud-agnostic infrastructure deployment
version: 1.0.0
category: Infrastructure
tags:
  - terraform
  - infrastructure-as-code
  - cloud
  - devops
  - automation
  - aws
  - azure
  - gcp
  - state-management
  - modules
prerequisites:
  - Basic understanding of cloud infrastructure concepts
  - Familiarity with command-line interfaces
  - Knowledge of at least one cloud provider (AWS, Azure, or GCP)
  - Understanding of version control systems (Git)
---

# Terraform Infrastructure as Code - Comprehensive Guide

## Table of Contents

1. [Introduction to Terraform](#introduction-to-terraform)
2. [Core Concepts](#core-concepts)
3. [Resources](#resources)
4. [Data Sources](#data-sources)
5. [Variables and Outputs](#variables-and-outputs)
6. [Modules](#modules)
7. [State Management](#state-management)
8. [Workspaces](#workspaces)
9. [Provider Configuration](#provider-configuration)
10. [Advanced Features](#advanced-features)
11. [Dependencies](#dependencies)
12. [Provisioners](#provisioners)
13. [Best Practices](#best-practices)
14. [CI/CD Integration](#cicd-integration)

## Introduction to Terraform

Terraform is an open-source Infrastructure as Code (IaC) tool created by HashiCorp that enables you to define and provision infrastructure using a declarative configuration language called HashiCorp Configuration Language (HCL). Terraform manages external resources such as public cloud infrastructure, private cloud infrastructure, network appliances, and software as a service.

### Key Benefits

- **Declarative Configuration**: Define what your infrastructure should look like, not how to create it
- **Cloud-Agnostic**: Works with multiple cloud providers and services
- **Version Control**: Infrastructure code can be versioned and reviewed
- **Plan Before Apply**: Preview changes before applying them
- **Resource Graph**: Automatically manages dependencies between resources
- **State Management**: Tracks the current state of your infrastructure

### Terraform Workflow

```bash
# Initialize Terraform working directory
terraform init

# Initialize and upgrade provider versions
terraform init -upgrade

# Initialize with backend configuration
terraform init -backend-config="bucket=my-state-bucket"

# Generate a plan
terraform plan

# Save plan to file for later apply
terraform plan -out=tfplan

# Plan with specific variable values
terraform plan -var="region=us-west-2" -var="instance_type=t2.micro"

# Apply with interactive approval
terraform apply

# Auto-approve without confirmation
terraform apply -auto-approve

# Apply a saved plan file
terraform apply tfplan

# Destroy with confirmation prompt
terraform destroy

# Auto-approve destruction
terraform destroy -auto-approve
```

## Core Concepts

### 1. Resources

Resources are the most fundamental elements in Terraform. They represent infrastructure objects like virtual machines, networks, databases, or DNS records.

```hcl
# Basic resource declaration
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "WebServer"
    Environment = "production"
  }
}
```

### 2. Providers

Providers are plugins that allow Terraform to interact with cloud platforms, SaaS providers, and other APIs.

```hcl
# AWS provider configuration
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "MyApp"
    }
  }
}
```

### 3. State

Terraform stores information about your infrastructure in a state file. This state is used to map real-world resources to your configuration and track metadata.

### 4. Configuration Language (HCL)

HCL is designed to be both human-readable and machine-friendly, making it ideal for infrastructure configuration.

## Resources

Resources are the building blocks of Terraform configurations. Each resource block describes one or more infrastructure objects.

### Basic Resource Syntax

```hcl
resource "resource_type" "resource_name" {
  argument1 = "value1"
  argument2 = "value2"

  nested_block {
    nested_argument = "nested_value"
  }
}
```

### Resource Examples

#### AWS EC2 Instance

```hcl
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "my-keypair"

  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = aws_subnet.public.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name        = "AppServer"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

#### AWS VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private-subnet"
  }
}
```

#### AWS S3 Bucket

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-app-data-bucket-12345"

  tags = {
    Name        = "Data Bucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

#### AWS Security Group

```hcl
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}
```

### Resource Lifecycle

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
  }
}
```

**Lifecycle options:**
- `create_before_destroy`: Create new resource before destroying the old one
- `prevent_destroy`: Prevent accidental destruction of resources
- `ignore_changes`: Ignore changes to specified attributes
- `replace_triggered_by`: Force replacement when specific resources change

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  lifecycle {
    replace_triggered_by = [
      aws_iam_policy.example.id
    ]
  }
}
```

## Data Sources

Data sources allow Terraform to use information defined outside of Terraform, or defined by another separate Terraform configuration.

### Data Source Syntax

```hcl
data "resource_type" "name" {
  # Query parameters
}
```

### Data Source Examples

```hcl
# Query existing AWS resources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Use data source in resource
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

# Query availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Query VPC
data "aws_vpc" "default" {
  default = true
}

# Query remote state
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}

# Use remote state outputs
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.subnet_id

  availability_zone = data.aws_availability_zones.available.names[0]
}
```

### Common Data Sources

```hcl
# AWS Account ID
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# AWS Region
data "aws_region" "current" {}

output "region" {
  value = data.aws_region.current.name
}

# Route53 Zone
data "aws_route53_zone" "primary" {
  name = "example.com"
}

# IAM Policy Document
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
```

## Variables and Outputs

### Input Variables

Variables allow you to parameterize your configurations for reusability.

```hcl
# Simple variable
variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region for resources"
}

# Variable with validation
variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "Instance type must be t2.micro, t2.small, or t2.medium."
  }
}

# Complex type variable
variable "vpc_config" {
  type = object({
    cidr_block = string
    azs        = list(string)
    private_subnets = list(string)
    public_subnets  = list(string)
  })

  default = {
    cidr_block      = "10.0.0.0/16"
    azs             = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  }
}
```

### Variable Types

```hcl
# String variable
variable "environment" {
  type    = string
  default = "development"
}

# Number variable
variable "instance_count" {
  type    = number
  default = 3
}

# Boolean variable
variable "enable_monitoring" {
  type    = bool
  default = true
}

# List variable
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# Map variable
variable "ami_ids" {
  type = map(string)
  default = {
    us-west-2 = "ami-0c55b159cbfafe1f0"
    us-east-1 = "ami-0b69ea66ff7391e80"
  }
}

# Object variable
variable "database_config" {
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })

  default = {
    engine            = "postgres"
    engine_version    = "13.7"
    instance_class    = "db.t3.micro"
    allocated_storage = 20
  }
}
```

### Setting Variables

```bash
# Command line
terraform apply -var="region=us-east-1" -var="instance_count=5"

# Variable files
terraform apply -var-file="production.tfvars"

# Environment variables
export TF_VAR_region=us-east-1
terraform apply
```

**terraform.tfvars:**
```hcl
region         = "us-west-2"
instance_count = 3
environment    = "production"
```

### Output Values

Outputs make information about your infrastructure available for other configurations or display to users.

```hcl
# Simple output
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP of the web server"
}

# Output with sensitive data
output "database_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}

# Complex output
output "instance_details" {
  value = {
    id         = aws_instance.web.id
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
    arn        = aws_instance.web.arn
  }
  description = "Complete instance information"
}

# Output with depends_on
output "vpc_ready" {
  value = "VPC and subnets are ready"
  depends_on = [
    aws_vpc.main,
    aws_subnet.private,
    aws_subnet.public
  ]
}
```

### Using Outputs

```bash
# Show all outputs
terraform output

# Get specific output value
terraform output instance_ip

# Output in JSON format
terraform output -json

# Use output in scripts
INSTANCE_IP=$(terraform output -raw instance_ip)
echo "Server IP: $INSTANCE_IP"
```

### Local Values

Local values assign a name to an expression for reuse within a module.

```hcl
locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = "MyApp"
  }

  name_prefix = "${var.project_name}-${var.environment}"

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-web-server"
    }
  )
}
```

## Modules

Modules are containers for multiple resources that are used together. They enable you to create reusable components.

### Module Structure

```
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### Creating a Module

**modules/vpc/main.tf:**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${count.index + 1}"
      Type = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${count.index + 1}"
      Type = "private"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}
```

**modules/vpc/variables.tf:**
```hcl
variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

**modules/vpc/outputs.tf:**
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

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}
```

### Using Modules

```hcl
# Using a module from local path
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  region     = var.region

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Using a module from Terraform Registry
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"

  bucket = "my-application-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }
}

# Using module outputs
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnet_ids[0]

  tags = {
    Name = "App Server"
  }
}

# Module with count
module "web_servers" {
  count  = 3
  source = "./modules/web-server"

  name   = "web-${count.index}"
  subnet = module.vpc.public_subnet_ids[count.index]
}

# Module with for_each
module "environments" {
  for_each = toset(["dev", "staging", "prod"])
  source   = "./modules/environment"

  env_name = each.key
  vpc_cidr = "10.${index(["dev", "staging", "prod"], each.key)}.0.0/16"
}
```

### Module Sources

```hcl
# Local path
module "vpc" {
  source = "./modules/vpc"
}

# Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"
}

# GitHub
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
}

# GitHub with specific branch
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.1.0"
}

# Git
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
}

# S3 bucket
module "vpc" {
  source = "s3::https://s3.amazonaws.com/my-bucket/vpc-module.zip"
}
```

### Module Versioning

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Any version 5.x
}

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 3.0, < 4.0"  # Between 3.0 and 4.0
}
```

## State Management

Terraform state is a critical component that maps your configuration to real-world resources.

### Local State

By default, Terraform stores state locally in a file named `terraform.tfstate`.

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### Remote State

Remote state enables team collaboration and provides better security and reliability.

#### S3 Backend

```hcl
# S3 backend configuration
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Setup DynamoDB for state locking:**
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
```

#### Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

#### Terraform Cloud Backend

```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      name = "production"
    }
  }
}
```

#### Consul Backend

```hcl
terraform {
  backend "consul" {
    address = "consul.example.com:8500"
    scheme  = "https"
    path    = "terraform/production"
  }
}
```

### State Commands

```bash
# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.example

# Remove resource from state (doesn't destroy)
terraform state rm aws_instance.example

# Move resource to new address
terraform state mv aws_instance.example aws_instance.web_server

# Show current state
terraform show

# Show specific plan file
terraform show tfplan

# Output state in JSON format
terraform show -json > state.json

# Pull remote state
terraform state pull > terraform.tfstate

# Push local state to remote
terraform state push terraform.tfstate
```

### State Locking

State locking prevents concurrent operations that could corrupt your state.

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Importing Existing Resources

```bash
# Import AWS instance
terraform import aws_instance.example i-0abc123def456

# Import with module
terraform import module.network.aws_vpc.main vpc-0123456789abcdef
```

**Configuration needed before import:**
```hcl
resource "aws_instance" "example" {
  # Configuration will be populated after import
  # Define the basic structure matching the resource
}
```

### State Migration

```bash
# Initialize with backend
terraform init

# Migrate from local to remote
terraform init -migrate-state

# Backend configuration from CLI
terraform init -backend-config="bucket=my-other-bucket" \
               -backend-config="key=my-state"
```

## Workspaces

Workspaces allow you to manage multiple instances of a single configuration.

### Workspace Commands

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new production

# Switch to workspace
terraform workspace select staging

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete development
```

### Workspace Workflow

```bash
# Example workflow:
terraform workspace new development
terraform apply  # Creates resources in development workspace

terraform workspace new staging
terraform apply  # Creates separate resources in staging workspace

terraform workspace new production
terraform apply  # Creates separate resources in production workspace
```

### Using Workspace in Configuration

```hcl
locals {
  environment = terraform.workspace
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = terraform.workspace == "production" ? "t3.large" : "t3.micro"

  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Workspace-specific variables
variable "instance_counts" {
  type = map(number)
  default = {
    development = 1
    staging     = 2
    production  = 5
  }
}

resource "aws_instance" "app" {
  count = var.instance_counts[terraform.workspace]

  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "app-${terraform.workspace}-${count.index + 1}"
  }
}
```

### Workspace State Isolation

Each workspace has its own state file:
- `terraform.tfstate.d/development/terraform.tfstate`
- `terraform.tfstate.d/staging/terraform.tfstate`
- `terraform.tfstate.d/production/terraform.tfstate`

## Provider Configuration

Providers are plugins that enable Terraform to interact with cloud platforms and other services.

### Single Provider

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "MyApp"
    }
  }
}
```

### Multiple Provider Instances (Aliases)

```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "east_server" {
  provider = aws.east

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_instance" "west_server" {
  provider = aws.west

  ami           = "ami-0123456789abcdef"
  instance_type = "t2.micro"
}
```

### Multi-Cloud Setup

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

# AWS resources
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

# Azure resources
resource "azurerm_storage_account" "data" {
  name                     = "mydatastorageacct"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# GCP resources
resource "google_storage_bucket" "data" {
  name     = "my-data-bucket-gcp"
  location = "US"
}
```

### Provider Configuration in Modules

```hcl
# Root module
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "dr"
  region = "us-east-1"
}

module "app" {
  source = "./modules/app"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}
```

**Module configuration:**
```hcl
# modules/app/main.tf
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dr]
    }
  }
}

resource "aws_instance" "primary" {
  provider = aws
  # ...
}

resource "aws_instance" "dr" {
  provider = aws.dr
  # ...
}
```

## Advanced Features

### Dynamic Blocks

Dynamic blocks allow you to dynamically construct repeatable nested blocks.

```hcl
variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### For_Each Meta-Argument

```hcl
resource "aws_s3_bucket" "buckets" {
  for_each = toset(["logs", "data", "backups"])

  bucket = "my-app-${each.key}"

  tags = {
    Purpose = each.key
  }
}

# With map
variable "instances" {
  type = map(object({
    ami           = string
    instance_type = string
  }))

  default = {
    web = {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.micro"
    }
    app = {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.small"
    }
  }
}

resource "aws_instance" "servers" {
  for_each = var.instances

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}
```

### Count Meta-Argument

```hcl
resource "aws_instance" "servers" {
  count = 3

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"
  }
}

# Conditional resource creation
variable "create_db" {
  type    = bool
  default = true
}

resource "aws_db_instance" "database" {
  count = var.create_db ? 1 : 0

  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
}
```

### Conditional Expressions

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.environment == "production" ? "t3.large" : "t3.micro"

  tags = {
    Name = var.environment == "production" ? "prod-web" : "dev-web"
  }
}

locals {
  instance_count = var.environment == "production" ? 5 : var.environment == "staging" ? 2 : 1
}
```

### Functions

```hcl
locals {
  # String functions
  name_upper = upper(var.name)
  name_lower = lower(var.name)
  name_title = title(var.name)

  # Collection functions
  subnet_count = length(var.subnet_cidrs)
  first_az     = element(var.availability_zones, 0)
  all_azs      = join(",", var.availability_zones)

  # Numeric functions
  min_instances = min(var.instance_count, 10)
  max_instances = max(var.instance_count, 1)

  # Type conversion
  instance_count_string = tostring(var.instance_count)
  az_set                = toset(var.availability_zones)

  # Map functions
  merged_tags = merge(var.common_tags, var.specific_tags)

  # File functions
  user_data = file("${path.module}/scripts/init.sh")
  config    = templatefile("${path.module}/templates/config.tpl", {
    environment = var.environment
    region      = var.region
  })

  # Encoding functions
  encoded = base64encode("secret data")
  decoded = base64decode(var.encoded_data)

  # Date/Time functions
  timestamp = timestamp()

  # IP Network functions
  cidr_subnets = cidrsubnets("10.0.0.0/16", 8, 8, 8, 8)
}
```

### Terraform Functions in Practice

```hcl
# Creating multiple subnets across availability zones
locals {
  subnet_cidrs = cidrsubnets(var.vpc_cidr, 8, 8, 8, 8)
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-${count.index + 1}"
  }
}
```

## Dependencies

### Implicit Dependencies

Terraform automatically infers dependencies from resource references.

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id  # Implicit dependency
  cidr_block = "10.0.1.0/24"
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id  # Implicit dependency
}
```

### Explicit Dependencies

Use `depends_on` when dependencies cannot be inferred automatically.

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  depends_on = [aws_db_instance.database]
}

resource "aws_db_instance" "database" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
}
```

### Module Dependencies

```hcl
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
}

module "app" {
  source = "./modules/app"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  depends_on = [module.vpc]
}
```

## Provisioners

Provisioners are used to execute scripts on a local or remote machine as part of resource creation or destruction.

### Local-Exec Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Instance ${self.id} destroyed' >> destroy_log.txt"
  }
}
```

### Remote-Exec Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}
```

### File Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/init.sh"
    destination = "/tmp/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init.sh",
      "sudo /tmp/init.sh"
    ]
  }
}
```

### Provisioner Failure Behavior

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command     = "./configure.sh"
    on_failure  = continue  # or fail (default)
  }
}
```

## Best Practices

### 1. State Management

- **Always use remote state** for team collaboration
- **Enable state locking** to prevent concurrent modifications
- **Enable encryption** for sensitive data
- **Regular state backups** for disaster recovery

### 2. Code Organization

```
project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
├── modules/
│   ├── vpc/
│   ├── compute/
│   └── database/
└── global/
    └── s3/
```

### 3. Variable Management

```hcl
# Use meaningful descriptions
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

# Use validation
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}
```

### 4. Naming Conventions

```hcl
# Resource naming
resource "aws_instance" "web_server" {  # Use descriptive names
  tags = {
    Name = "${var.project}-${var.environment}-web-${count.index + 1}"
  }
}

# Module naming
module "vpc_production" {
  source = "./modules/vpc"
}
```

### 5. DRY Principle

```hcl
# Use locals for repeated values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}

resource "aws_instance" "web" {
  tags = merge(
    local.common_tags,
    {
      Name = "web-server"
      Role = "webserver"
    }
  )
}
```

### 6. Security Best Practices

```hcl
# Never hardcode credentials
# BAD
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# GOOD - Use environment variables or IAM roles
provider "aws" {
  # Credentials from environment or IAM role
}

# Use sensitive flag for outputs
output "database_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}

# Encrypt sensitive data
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 7. Testing

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Plan before apply
terraform plan -out=tfplan

# Review plan
terraform show tfplan
```

### 8. Version Control

**.gitignore:**
```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude variable files that may contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration files
.terraformrc
terraform.rc

# Plan files
*.tfplan
```

### 9. Module Best Practices

```hcl
# Module versioning
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Pin to major version
}

# Module documentation
# Always include README.md with:
# - Description
# - Requirements
# - Providers
# - Inputs
# - Outputs
# - Example usage
```

### 10. Resource Tagging

```hcl
# Consistent tagging strategy
locals {
  required_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner_email
    CostCenter  = var.cost_center
    Compliance  = var.compliance_level
  }
}

# Use default tags at provider level
provider "aws" {
  region = var.region

  default_tags {
    tags = local.required_tags
  }
}
```

## CI/CD Integration

### GitHub Actions

**.github/workflows/terraform.yml:**
```yaml
name: Terraform

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  TF_VERSION: 1.5.0

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -no-color
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### GitLab CI

**.gitlab-ci.yml:**
```yaml
image:
  name: hashicorp/terraform:1.5.0
  entrypoint: [""]

stages:
  - validate
  - plan
  - apply

before_script:
  - terraform init

validate:
  stage: validate
  script:
    - terraform validate
    - terraform fmt -check -recursive

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan
    expire_in: 1 week

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan
  only:
    - main
  when: manual
```

### Jenkins Pipeline

**Jenkinsfile:**
```groovy
pipeline {
    agent any

    environment {
        TF_VERSION = '1.5.0'
        AWS_CREDENTIALS = credentials('aws-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Apply Terraform changes?', ok: 'Apply'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

### Azure DevOps

**azure-pipelines.yml:**
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  - name: terraformVersion
    value: '1.5.0'

stages:
  - stage: Validate
    jobs:
      - job: ValidateTerraform
        steps:
          - task: TerraformInstaller@0
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformTaskV2@2
            displayName: 'Terraform Init'
            inputs:
              provider: 'aws'
              command: 'init'
              backendServiceAWS: 'AWS-Connection'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Validate'
            inputs:
              provider: 'aws'
              command: 'validate'

          - script: terraform fmt -check -recursive
            displayName: 'Terraform Format Check'

  - stage: Plan
    dependsOn: Validate
    jobs:
      - job: PlanTerraform
        steps:
          - task: TerraformTaskV2@2
            displayName: 'Terraform Plan'
            inputs:
              provider: 'aws'
              command: 'plan'
              commandOptions: '-out=tfplan'

  - stage: Apply
    dependsOn: Plan
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: ApplyTerraform
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: TerraformTaskV2@2
                  displayName: 'Terraform Apply'
                  inputs:
                    provider: 'aws'
                    command: 'apply'
                    commandOptions: '-auto-approve tfplan'
```

### Pre-commit Hooks

**.pre-commit-config.yaml:**
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.81.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
      - id: terraform_checkov
```

### Automated Testing

**test/terraform_test.go:**
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformVPC(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/vpc",

        Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
            "region":     "us-west-2",
        },
    }

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

## Additional Commands and Tools

### Terraform Console

```bash
# Start console
terraform console

# Example session:
> aws_instance.example.public_ip
"54.183.22.100"
> var.region
"us-west-2"
> length(aws_instance.example.tags)
3
```

### Terraform Graph

```bash
# Generate graph in DOT format
terraform graph > graph.dot

# Convert to image with Graphviz
terraform graph | dot -Tpng > graph.png

# Generate graph for specific plan
terraform graph -type=plan > plan-graph.dot
```

### Terraform Taint

```bash
# Taint a resource (mark for recreation)
terraform taint aws_instance.example

# Untaint a resource
terraform untaint aws_instance.example
```

### Terraform Providers

```bash
# List required providers
terraform providers

# Show provider schemas
terraform providers schema -json > schemas.json

# Lock provider versions
terraform providers lock
```

## Conclusion

This comprehensive guide covers the essential aspects of Terraform Infrastructure as Code, from basic concepts to advanced patterns and CI/CD integration. By following these practices and patterns, you can build maintainable, scalable, and secure infrastructure deployments across any cloud provider.

Key takeaways:
- Use modules for reusable components
- Implement remote state with locking for team collaboration
- Leverage workspaces for environment isolation
- Follow security best practices and never hardcode credentials
- Integrate Terraform into CI/CD pipelines for automated deployments
- Use validation, formatting, and testing tools
- Maintain clear documentation and consistent naming conventions
- Implement proper tagging strategies for resource management

Terraform enables infrastructure teams to adopt DevOps practices, improve collaboration, reduce manual errors, and accelerate deployment cycles while maintaining full control and visibility over infrastructure changes.
