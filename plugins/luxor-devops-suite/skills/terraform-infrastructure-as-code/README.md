# Terraform Infrastructure as Code

A comprehensive skill for building, managing, and deploying cloud infrastructure using Terraform, the industry-standard Infrastructure as Code tool.

## Overview

Terraform is HashiCorp's declarative Infrastructure as Code tool that enables you to define, provision, and manage infrastructure across multiple cloud providers using a consistent workflow. This skill provides production-ready patterns, best practices, and examples for building scalable, maintainable infrastructure.

## Quick Start

### Installation

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux (Ubuntu/Debian):**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows (Chocolatey):**
```bash
choco install terraform
```

**Verify Installation:**
```bash
terraform version
# Terraform v1.5.0
```

### Your First Terraform Configuration

Create a simple AWS EC2 instance:

**main.tf:**
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
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloTerraform"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

**Run it:**
```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration
terraform apply

# Destroy resources
terraform destroy
```

## The Terraform Workflow

Terraform follows a simple, repeatable workflow:

```
┌─────────────┐
│    WRITE    │  Write infrastructure as code
└──────┬──────┘
       │
       v
┌─────────────┐
│    INIT     │  Initialize working directory
└──────┬──────┘
       │
       v
┌─────────────┐
│    PLAN     │  Preview changes
└──────┬──────┘
       │
       v
┌─────────────┐
│   APPLY     │  Create/update infrastructure
└──────┬──────┘
       │
       v
┌─────────────┐
│  DESTROY    │  Remove infrastructure (when needed)
└─────────────┘
```

### 1. Write

Define your infrastructure using HCL (HashiCorp Configuration Language):

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}
```

### 2. Initialize

Download provider plugins and initialize the backend:

```bash
terraform init
```

This command:
- Downloads required provider plugins
- Initializes the backend for state storage
- Prepares the working directory

### 3. Plan

Preview what changes Terraform will make:

```bash
terraform plan

# Save plan to file
terraform plan -out=tfplan
```

The plan shows:
- Resources to be created (+)
- Resources to be modified (~)
- Resources to be destroyed (-)

### 4. Apply

Execute the planned changes:

```bash
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve (use cautiously)
terraform apply -auto-approve
```

### 5. Destroy

Remove all managed infrastructure:

```bash
terraform destroy

# Destroy specific resource
terraform destroy -target=aws_instance.web
```

## Architecture Overview

### Directory Structure

A well-organized Terraform project follows this structure:

```
terraform-project/
├── environments/
│   ├── dev/
│   │   ├── main.tf           # Main configuration
│   │   ├── variables.tf      # Variable declarations
│   │   ├── outputs.tf        # Output definitions
│   │   ├── terraform.tfvars  # Variable values
│   │   └── backend.tf        # Backend configuration
│   ├── staging/
│   │   └── ...
│   └── production/
│       └── ...
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   │   └── ...
│   └── database/
│       └── ...
├── global/
│   └── s3/               # Shared resources
│       └── ...
└── README.md
```

### Core Components

#### 1. Resources

Resources are the fundamental building blocks representing infrastructure objects:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "AppServer"
  }
}
```

#### 2. Data Sources

Query existing infrastructure or external data:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }
}
```

#### 3. Variables

Parameterize configurations for reusability:

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be t2.micro or t2.small."
  }
}
```

#### 4. Outputs

Export values for use by other configurations or display:

```hcl
output "instance_public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.app.public_ip
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}
```

#### 5. Modules

Reusable, composable infrastructure components:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "production"
  }
}
```

## State Management

Terraform state is critical for tracking infrastructure. Understanding state management is essential for team collaboration.

### Local State (Default)

```hcl
# Stored in terraform.tfstate
# Good for: Individual learning, testing
# Bad for: Team collaboration, production
```

### Remote State (Recommended)

**S3 Backend with DynamoDB Locking:**

```hcl
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

**Benefits:**
- Team collaboration
- State locking prevents concurrent modifications
- Encrypted storage for sensitive data
- Versioning and backup capabilities

### State Commands

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_instance.web

# Remove resource from state (doesn't destroy)
terraform state rm aws_instance.web

# Move resource to new address
terraform state mv aws_instance.old aws_instance.new

# Pull remote state to local
terraform state pull > terraform.tfstate

# Push local state to remote
terraform state push terraform.tfstate
```

### Importing Existing Resources

```bash
# Import existing AWS instance
terraform import aws_instance.web i-1234567890abcdef0

# First, create the resource configuration:
# resource "aws_instance" "web" {
#   # Configuration to be filled
# }

# Then run import
terraform import aws_instance.web i-1234567890abcdef0

# Finally, run plan to see differences
terraform plan
```

## Workspaces

Workspaces enable managing multiple instances of the same infrastructure:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new development

# Switch workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete development
```

**Using workspaces in code:**

```hcl
resource "aws_instance" "app" {
  ami   = var.ami_id
  count = terraform.workspace == "production" ? 5 : 1

  instance_type = terraform.workspace == "production" ? "t3.large" : "t3.micro"

  tags = {
    Name        = "app-${terraform.workspace}-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```

## Common Patterns

### 1. Multi-Environment Setup

**Using Directory Structure:**

```
project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
```

**Using Workspaces:**

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new production
```

### 2. Module Composition

```hcl
# Root configuration
module "network" {
  source = "./modules/network"

  vpc_cidr = "10.0.0.0/16"
  region   = var.region
}

module "compute" {
  source = "./modules/compute"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.private_subnet_ids[0]
}

module "database" {
  source = "./modules/database"

  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.private_subnet_ids
  security_group = module.network.database_security_group_id
}
```

### 3. Dynamic Configuration with For_Each

```hcl
variable "instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
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

### 4. Conditional Resources

```hcl
variable "enable_monitoring" {
  type    = bool
  default = false
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
}
```

## Anti-Patterns to Avoid

### 1. Hardcoded Credentials

```hcl
# BAD - Never do this!
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# GOOD - Use environment variables or IAM roles
provider "aws" {
  region = var.region
  # Credentials from AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # Or use IAM instance profile/role
}
```

### 2. Monolithic Configurations

```hcl
# BAD - One giant main.tf with everything

# GOOD - Split into logical modules
module "network" { ... }
module "compute" { ... }
module "database" { ... }
```

### 3. No State Locking

```hcl
# BAD - Local state in team environment
# No backend configuration

# GOOD - Remote state with locking
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
```

### 4. Ignoring terraform fmt

```bash
# ALWAYS format your code
terraform fmt -recursive

# Add to pre-commit hooks
# Add to CI/CD pipeline
```

### 5. Applying Without Planning

```bash
# BAD
terraform apply -auto-approve

# GOOD
terraform plan -out=tfplan
# Review plan carefully
terraform apply tfplan
```

## Learning Path

### Beginner (Week 1-2)

1. Install Terraform and configure AWS CLI
2. Create your first resource (EC2 instance)
3. Understand variables and outputs
4. Learn about state files
5. Practice with basic data sources

**Practice Project:** Deploy a simple web server on AWS

### Intermediate (Week 3-4)

1. Create reusable modules
2. Set up remote state with S3
3. Use workspaces for multiple environments
4. Implement for_each and count
5. Work with multiple providers

**Practice Project:** Build a multi-tier web application (VPC, ALB, EC2, RDS)

### Advanced (Week 5-8)

1. Implement dynamic blocks
2. Create custom providers (Go)
3. Set up CI/CD pipelines
4. Implement testing with Terratest
5. Multi-cloud deployments
6. State migration strategies

**Practice Project:** Full production infrastructure with monitoring, logging, and auto-scaling

## Essential Commands

```bash
# Initialization
terraform init                    # Initialize working directory
terraform init -upgrade           # Upgrade providers

# Planning
terraform plan                    # Preview changes
terraform plan -out=tfplan        # Save plan to file
terraform plan -destroy           # Plan destruction

# Applying
terraform apply                   # Apply changes
terraform apply tfplan            # Apply saved plan
terraform apply -auto-approve     # Skip confirmation

# Destruction
terraform destroy                 # Destroy all resources
terraform destroy -target=...     # Destroy specific resource

# State Management
terraform state list              # List resources
terraform state show RESOURCE     # Show resource details
terraform state rm RESOURCE       # Remove from state
terraform state mv OLD NEW        # Rename resource

# Workspaces
terraform workspace list          # List workspaces
terraform workspace new NAME      # Create workspace
terraform workspace select NAME   # Switch workspace

# Validation & Formatting
terraform validate                # Validate syntax
terraform fmt                     # Format code
terraform fmt -recursive          # Format all files

# Output
terraform output                  # Show all outputs
terraform output NAME             # Show specific output
terraform output -json            # JSON format

# Import
terraform import ADDR ID          # Import existing resource

# Utilities
terraform console                 # Interactive console
terraform graph                   # Generate dependency graph
terraform providers               # Show providers
terraform show                    # Show state or plan
```

## Troubleshooting

### Common Issues

**1. State Lock Issues**

```bash
# If state is locked and terraform crashed
terraform force-unlock LOCK_ID
```

**2. Provider Version Conflicts**

```bash
# Update provider versions
terraform init -upgrade

# Lock provider versions in configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**3. Resource Already Exists**

```bash
# Import the existing resource
terraform import aws_instance.web i-1234567890abcdef0
```

**4. Debugging**

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

## Resources

### Official Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Tools & Extensions

- **Terraform-LSP**: Language server for IDE integration
- **Terraform-docs**: Generate documentation from modules
- **TFLint**: Terraform linter
- **Terratest**: Testing framework for Terraform
- **Infracost**: Cost estimation for Terraform

### Community

- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform GitHub](https://github.com/hashicorp/terraform)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)

## Next Steps

1. Review the comprehensive [SKILL.md](SKILL.md) guide
2. Explore production examples in [EXAMPLES.md](EXAMPLES.md)
3. Set up your first multi-environment infrastructure
4. Implement CI/CD integration
5. Practice with real-world scenarios

## Contributing

This skill is designed to be comprehensive and production-ready. For updates and improvements, refer to the official Terraform documentation and community best practices.

---

**Remember**: Infrastructure as Code is not just about automation—it's about creating reproducible, testable, and maintainable infrastructure that can evolve with your organization's needs.
