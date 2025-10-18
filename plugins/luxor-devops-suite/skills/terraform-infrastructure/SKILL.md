---
name: terraform-infrastructure
description: Comprehensive Terraform infrastructure-as-code skill covering providers, resources, modules, state management, and enterprise patterns for multi-cloud infrastructure
---

# Terraform Infrastructure-as-Code

A comprehensive skill for building, managing, and scaling cloud infrastructure using Terraform. Master declarative infrastructure, multi-cloud deployments, state management, module composition, and enterprise-grade patterns for AWS, Azure, GCP, and other providers.

## When to Use This Skill

Use this skill when:

- Provisioning cloud infrastructure across AWS, Azure, GCP, or multi-cloud environments
- Building reusable infrastructure modules for teams and organizations
- Managing infrastructure state across multiple environments (dev, staging, production)
- Implementing infrastructure as code (IaC) best practices and governance
- Migrating from manual infrastructure to automated, version-controlled deployments
- Creating repeatable, testable infrastructure configurations
- Orchestrating complex multi-tier application architectures
- Managing Kubernetes clusters, databases, networks, and compute resources
- Implementing disaster recovery and multi-region deployments
- Collaborating on infrastructure changes with teams using GitOps workflows

## Core Concepts

### Infrastructure as Code Philosophy

Terraform enables declarative infrastructure management:

- **Declarative Configuration**: Define desired state, Terraform handles execution
- **Immutable Infrastructure**: Replace rather than modify infrastructure
- **Version Control**: Track infrastructure changes like application code
- **Plan Before Apply**: Preview changes before execution
- **Resource Graph**: Automatic dependency resolution and parallel execution
- **State Management**: Track real-world resources and their configuration

### Key Terraform Components

1. **Providers**: Plugins for infrastructure platforms (AWS, Azure, GCP, Kubernetes, etc.)
2. **Resources**: Infrastructure objects (VMs, networks, databases, storage)
3. **Data Sources**: Query existing infrastructure or external data
4. **Variables**: Parameterize configurations for reusability
5. **Outputs**: Export values for consumption by other configurations
6. **Modules**: Reusable, composable infrastructure components
7. **State**: JSON file tracking managed infrastructure
8. **Workspaces**: Manage multiple instances of infrastructure

### Terraform Workflow

```
Write → Init → Plan → Apply → Destroy
  ↓       ↓       ↓       ↓       ↓
 .tf    Download Review  Execute Remove
files   providers changes changes resources
```

## Terraform Language (HCL)

### Basic Syntax

HCL (HashiCorp Configuration Language) is declarative and human-readable:

```hcl
# Block structure
block_type "block_label" "block_name" {
  argument_name = argument_value

  nested_block {
    nested_argument = value
  }
}

# Example: EC2 instance resource
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "WebServer"
    Environment = "production"
  }
}
```

### Variables and Types

Terraform supports rich type system:

```hcl
# String variable
variable "region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
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
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Map variable
variable "instance_tags" {
  type = map(string)
  default = {
    Environment = "production"
    Project     = "web-app"
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
    engine         = "postgres"
    engine_version = "13.7"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Set variable
variable "allowed_cidr_blocks" {
  type = set(string)
  default = ["10.0.0.0/8", "172.16.0.0/12"]
}

# Tuple variable
variable "server_config" {
  type = tuple([string, number, bool])
  default = ["t3.micro", 2, true]
}
```

### Variable Validation

Add custom validation rules:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}

variable "environment" {
  type = string

  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cidr_block" {
  type = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}
```

### Locals and Expressions

Locals compute values once and reuse them:

```hcl
locals {
  # Simple local
  environment = terraform.workspace

  # Computed local
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }

  # Conditional local
  instance_count = var.environment == "prod" ? 5 : 2

  # List manipulation
  all_subnets = concat(var.public_subnets, var.private_subnets)

  # Map merging
  merged_tags = merge(
    local.common_tags,
    var.additional_tags
  )

  # String interpolation
  bucket_name = "${var.project_name}-${local.environment}-data"

  # For expression
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  # For expression with filtering
  prod_instances = [
    for instance in aws_instance.app :
    instance.id if instance.tags["Environment"] == "prod"
  ]

  # Map transformation
  instance_map = {
    for idx, instance in aws_instance.app :
    instance.tags["Name"] => instance.id
  }
}
```

### Functions

Terraform provides built-in functions:

```hcl
# String functions
upper("hello")                    # "HELLO"
lower("WORLD")                    # "world"
title("hello world")              # "Hello World"
trim("  spaces  ")                # "spaces"
trimprefix("prefix-value", "prefix-") # "value"
format("Server %03d", 1)          # "Server 001"
join("-", ["a", "b", "c"])        # "a-b-c"
split("-", "a-b-c")               # ["a", "b", "c"]
substr("hello", 0, 3)             # "hel"
replace("hello", "l", "r")        # "herro"

# Numeric functions
max(5, 12, 9)                     # 12
min(5, 12, 9)                     # 5
ceil(5.1)                         # 6
floor(5.9)                        # 5
parseint("100", 10)               # 100

# Collection functions
length([1, 2, 3])                 # 3
element(["a", "b", "c"], 1)       # "b"
concat([1, 2], [3, 4])            # [1, 2, 3, 4]
contains(["a", "b"], "a")         # true
distinct([1, 2, 2, 3])            # [1, 2, 3]
flatten([[1, 2], [3, 4]])         # [1, 2, 3, 4]
keys({a = 1, b = 2})              # ["a", "b"]
values({a = 1, b = 2})            # [1, 2]
lookup({a = 1, b = 2}, "a", 0)    # 1
merge({a = 1}, {b = 2})           # {a = 1, b = 2}
reverse([1, 2, 3])                # [3, 2, 1]
slice([1, 2, 3, 4], 1, 3)         # [2, 3]
sort(["c", "a", "b"])             # ["a", "b", "c"]

# Encoding functions
base64encode("hello")             # "aGVsbG8="
base64decode("aGVsbG8=")          # "hello"
jsonencode({key = "value"})       # "{\"key\":\"value\"}"
jsondecode("{\"key\":\"value\"}")  # {key = "value"}
yamlencode({key = "value"})       # "key: value\n"
yamldecode("key: value")          # {key = "value"}

# Filesystem functions
file("path/to/file.txt")          # Read file content
templatefile("template.tpl", {    # Render template
  var1 = "value1"
})

# Date/time functions
timestamp()                       # "2024-01-15T12:30:45Z"
formatdate("DD MMM YYYY", timestamp()) # "15 Jan 2024"

# Network functions
cidrhost("10.0.0.0/24", 5)        # "10.0.0.5"
cidrnetmask("10.0.0.0/24")        # "255.255.255.0"
cidrsubnet("10.0.0.0/16", 8, 2)   # "10.0.2.0/24"

# Type conversion
tostring(42)                      # "42"
tonumber("42")                    # 42
tobool("true")                    # true
tolist([1, 2, 3])                 # [1, 2, 3]
toset([1, 2, 2, 3])              # [1, 2, 3]
tomap({a = 1})                    # {a = 1}

# Conditional functions
can(regex("^[a-z]+$", var.name))  # true if valid
try(var.optional_value, "default") # Return first valid value
```

### Conditional Expressions

```hcl
# Ternary operator
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

# With count for conditional resources
resource "aws_instance" "web" {
  count = var.create_instance ? 1 : 0
  # ... configuration
}

# Dynamic blocks
resource "aws_security_group" "example" {
  name = "example"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Meta-Arguments

Resources support special arguments:

```hcl
# depends_on: Explicit dependencies
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web_sg]
  # ...
}

# count: Create multiple instances
resource "aws_instance" "web" {
  count         = 3
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}

# for_each: Create from map or set
resource "aws_instance" "servers" {
  for_each = var.servers  # map or set

  ami           = each.value.ami
  instance_type = each.value.type

  tags = {
    Name = each.key
  }
}

# provider: Specify provider configuration
resource "aws_instance" "replica" {
  provider = aws.us-west-2
  # ...
}

# lifecycle: Control resource behavior
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true  # Create new before destroying old
    prevent_destroy       = true  # Prevent accidental deletion
    ignore_changes        = [      # Ignore specific changes
      tags,
      user_data
    ]
  }
}
```

## Providers

### Provider Configuration

Configure infrastructure platforms:

```hcl
# AWS Provider
terraform {
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
      ManagedBy = "Terraform"
      Project   = var.project_name
    }
  }
}

# Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

# GCP Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Multiple provider configurations (aliases)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

# Use aliased provider
resource "aws_instance" "east" {
  provider = aws.us_east_1
  # ...
}
```

### Provider Authentication

Secure authentication methods:

```hcl
# AWS - Environment variables (recommended)
# export AWS_ACCESS_KEY_ID="..."
# export AWS_SECRET_ACCESS_KEY="..."
# export AWS_SESSION_TOKEN="..."  # for temporary credentials

provider "aws" {
  region = "us-east-1"
  # Credentials from environment or ~/.aws/credentials
}

# AWS - Assume role
provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
    session_name = "terraform-session"
    external_id  = "unique-id"
  }
}

# Azure - Service principal
provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Azure - Managed identity
provider "azurerm" {
  features {}
  use_msi = true
}

# GCP - Service account
provider "google" {
  credentials = file("path/to/service-account-key.json")
  project     = var.gcp_project_id
  region      = var.gcp_region
}
```

## Resources

### Resource Declaration

Define infrastructure components:

```hcl
resource "resource_type" "resource_name" {
  argument_name = argument_value
}

# Example: S3 bucket
resource "aws_s3_bucket" "data" {
  bucket = "my-application-data"

  tags = {
    Name        = "Data Bucket"
    Environment = "production"
  }
}

# Reference resource attributes
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id  # Reference bucket ID

  versioning_configuration {
    status = "Enabled"
  }
}
```

### Resource Lifecycle

```hcl
# Create, update, destroy lifecycle
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Lifecycle customization
  lifecycle {
    # Create replacement before destroying
    create_before_destroy = true

    # Prevent destruction
    prevent_destroy = false

    # Ignore changes to specific attributes
    ignore_changes = [
      tags["LastModified"],
      user_data
    ]

    # Replace if specific attributes change
    replace_triggered_by = [
      aws_security_group.web.id
    ]
  }
}
```

## Data Sources

Query existing infrastructure or external data:

```hcl
# AWS AMI lookup
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use data source in resource
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}

# VPC lookup
data "aws_vpc" "default" {
  default = true
}

# Availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Current region
data "aws_region" "current" {}

# Current account
data "aws_caller_identity" "current" {}

# External data source
data "external" "example" {
  program = ["python", "${path.module}/script.py"]

  query = {
    key = "value"
  }
}

# HTTP data source
data "http" "ip" {
  url = "https://ifconfig.me"
}

# Template file (deprecated, use templatefile())
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = 8080
    db_address  = aws_db_instance.main.address
  }
}
```

## Modules

### Module Structure

Organize code into reusable modules:

```
modules/
├── vpc/
│   ├── main.tf       # Resources
│   ├── variables.tf  # Input variables
│   ├── outputs.tf    # Output values
│   └── README.md     # Documentation
├── compute/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf   # Provider requirements
└── database/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

### Creating a Module

```hcl
# modules/vpc/variables.tf
variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT gateway for private subnets"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${count.index + 1}"
      Type = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${count.index + 1}"
      Type = "private"
    }
  )
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# modules/vpc/outputs.tf
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

### Using Modules

```hcl
# Root main.tf
module "vpc" {
  source = "./modules/vpc"

  vpc_name               = "production-vpc"
  vpc_cidr               = "10.0.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  enable_nat_gateway     = true

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Reference module outputs
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "web-server"
  }
}

# Use remote module from Terraform Registry
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"

  bucket = "my-application-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }
}

# Use module from GitHub
module "consul" {
  source = "github.com/hashicorp/consul//terraform/aws"

  servers = 3
}

# Use module from Git with specific branch
module "vpc" {
  source = "git::https://github.com/organization/terraform-modules.git//vpc?ref=v1.2.0"

  # ...
}
```

### Module Versioning

```hcl
# In module source (versions.tf)
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Using versioned modules
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Allow minor and patch updates

  # ...
}
```

## State Management

### Local State

Default state stored locally:

```hcl
# terraform.tfstate (automatically created)
{
  "version": 4,
  "terraform_version": "1.5.0",
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t3.micro"
          }
        }
      ]
    }
  ]
}
```

### Remote State - S3 Backend

Store state in S3 for team collaboration:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"

    # Optional: KMS encryption
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

# Create S3 bucket and DynamoDB table for state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Remote State - Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstate12345"
    container_name       = "tfstate"
    key                  = "production.terraform.tfstate"
  }
}
```

### Remote State - GCS Backend

```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "production"
  }
}
```

### Remote State - Terraform Cloud

```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      name = "production-infrastructure"
    }
  }
}
```

### Remote State Data Source

Read state from another configuration:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use outputs from remote state
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  # ...
}
```

## Workspaces

Manage multiple environments:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging
terraform workspace new production

# Select workspace
terraform workspace select staging

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete staging
```

### Workspace-Based Configuration

```hcl
# Use workspace in resource naming
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Workspace-specific variables
locals {
  env_config = {
    dev = {
      instance_count = 1
      instance_type  = "t3.micro"
    }
    staging = {
      instance_count = 2
      instance_type  = "t3.small"
    }
    prod = {
      instance_count = 5
      instance_type  = "t3.large"
    }
  }

  current_env = local.env_config[terraform.workspace]
}

resource "aws_instance" "app" {
  count         = local.current_env.instance_count
  instance_type = local.current_env.instance_type
  # ...
}
```

## Best Practices

### Code Organization

```
terraform-project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── ...
│   └── production/
│       └── ...
├── modules/
│   ├── vpc/
│   ├── compute/
│   └── database/
├── global/
│   ├── iam/
│   └── route53/
└── README.md
```

### Naming Conventions

```hcl
# Resource naming: <resource_type>_<name>_<purpose>
resource "aws_security_group" "web_server_public" { }
resource "aws_instance" "web_server_primary" { }

# Variable naming: descriptive and specific
variable "vpc_cidr_block" { }
variable "database_instance_class" { }
variable "enable_auto_scaling" { }

# Tags: consistent and comprehensive
tags = {
  Name        = "resource-name"
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "Terraform"
  Owner       = "team-name"
  CostCenter  = "engineering"
}
```

### Security Best Practices

```hcl
# Never hardcode credentials
# BAD
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# GOOD - Use environment variables or IAM roles
provider "aws" {
  region = "us-east-1"
}

# Use sensitive flag for secrets
variable "database_password" {
  type      = string
  sensitive = true
}

# Encrypt state files
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

# Use .gitignore
# .gitignore
*.tfstate
*.tfstate.*
.terraform/
*.tfvars  # if contains secrets
crash.log
override.tf
override.tf.json
```

### DRY (Don't Repeat Yourself)

```hcl
# Use locals for repeated values
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

resource "aws_instance" "web" {
  tags = local.common_tags
}

resource "aws_s3_bucket" "data" {
  tags = local.common_tags
}

# Use modules for reusable infrastructure
module "web_server" {
  source = "./modules/ec2-instance"

  instance_type = "t3.micro"
  tags          = local.common_tags
}

# Use for_each to avoid duplication
resource "aws_instance" "servers" {
  for_each = var.servers

  ami           = each.value.ami
  instance_type = each.value.type

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}
```

### Documentation

```hcl
# Document variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC. Must not overlap with existing VPCs."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

# Document outputs
output "vpc_id" {
  description = "ID of the VPC. Use this to reference the VPC in other configurations."
  value       = aws_vpc.main.id
}

# Add README.md to modules
# modules/vpc/README.md
# VPC Module

Creates a VPC with public and private subnets across multiple AZs.

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "my-vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | Name of the VPC | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | 10.0.0.0/16 | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnet_ids | IDs of public subnets |
```

### Testing Infrastructure

```hcl
# Use terraform validate
terraform validate

# Use terraform plan
terraform plan -out=tfplan

# Use terraform fmt for consistent formatting
terraform fmt -recursive

# Use external tools
# tflint - Terraform linter
# checkov - Security scanner
# terraform-docs - Generate documentation
# terrascan - Policy scanner
```

## Advanced Patterns

### Dynamic Backend Configuration

```hcl
# backend-config-dev.hcl
bucket = "terraform-state-dev"
key    = "dev/terraform.tfstate"
region = "us-east-1"

# backend-config-prod.hcl
bucket = "terraform-state-prod"
key    = "prod/terraform.tfstate"
region = "us-east-1"

# Initialize with backend config
# terraform init -backend-config=backend-config-dev.hcl
```

### Conditional Resource Creation

```hcl
# Create resource only in production
resource "aws_cloudwatch_alarm" "high_cpu" {
  count = var.environment == "prod" ? 1 : 0

  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
}
```

### Zero-Downtime Deployments

```hcl
# Blue-Green deployment with create_before_destroy
resource "aws_autoscaling_group" "app" {
  name                = "${var.app_name}-${var.version}"
  launch_configuration = aws_launch_configuration.app.name
  min_size            = var.min_size
  max_size            = var.max_size

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "app" {
  name_prefix   = "${var.app_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}
```

### Moved Blocks for Refactoring

```hcl
# Refactor without destroying resources
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.web
}

moved {
  from = aws_security_group.web[0]
  to   = aws_security_group.web["primary"]
}
```

### Import Existing Resources

```bash
# Import existing resource into Terraform state
terraform import aws_instance.web i-1234567890abcdef0

# Import with for_each
terraform import 'aws_instance.servers["web-1"]' i-1234567890abcdef0
```

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Infrastructure as Code, Cloud Engineering, DevOps
**Compatible With**: AWS, Azure, GCP, Kubernetes, Terraform Cloud
