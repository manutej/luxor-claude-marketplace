# Terraform Infrastructure-as-Code Skill

> Comprehensive Terraform skill for building, managing, and scaling cloud infrastructure using declarative configuration and enterprise-grade patterns.

## Overview

Terraform is an open-source infrastructure-as-code (IaC) tool that enables you to define and provision data center infrastructure using a declarative configuration language. This skill provides comprehensive knowledge of Terraform patterns, best practices, and real-world implementations across AWS, Azure, GCP, and other cloud providers.

## What is Terraform?

Terraform allows you to:

- **Define Infrastructure as Code**: Write infrastructure configuration in human-readable HCL (HashiCorp Configuration Language)
- **Manage Multi-Cloud Resources**: Support for 1000+ providers including AWS, Azure, GCP, Kubernetes, and more
- **Version Control Infrastructure**: Track infrastructure changes in Git like application code
- **Automate Provisioning**: Eliminate manual infrastructure setup and configuration
- **Preview Changes**: See what will change before applying modifications
- **Collaborate Safely**: Share state and coordinate team changes with remote backends

## Key Features

### Declarative Configuration

Define the desired end state of your infrastructure, and Terraform determines the steps to achieve it:

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "WebServer"
  }
}
```

### Multi-Cloud Support

Manage resources across multiple cloud providers in a single configuration:

- **AWS**: EC2, S3, RDS, Lambda, ECS, EKS, VPC, Route53, CloudFront, etc.
- **Azure**: Virtual Machines, Storage, SQL Database, App Service, AKS, etc.
- **GCP**: Compute Engine, Cloud Storage, Cloud SQL, GKE, etc.
- **Kubernetes**: Deployments, Services, ConfigMaps, Secrets, etc.
- **100+ other providers**: GitHub, Datadog, PagerDuty, Cloudflare, etc.

### Resource Graph

Terraform builds a dependency graph of resources and executes operations in parallel when possible:

```
VPC → Subnets → Security Groups → EC2 Instances
  ↓      ↓            ↓               ↓
Internet Gateway   Route Tables    Load Balancer
```

### State Management

Terraform tracks infrastructure state to detect drift and plan changes:

- **Local State**: Simple single-user workflows
- **Remote State**: Team collaboration with S3, Azure Storage, GCS, Terraform Cloud
- **State Locking**: Prevent concurrent modifications with DynamoDB, Azure Blob, etc.
- **State Versioning**: Rollback capability with S3 versioning

### Modules

Create reusable infrastructure components:

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "production"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# Use module outputs
resource "aws_instance" "web" {
  subnet_id = module.vpc.public_subnet_ids[0]
}
```

## Core Workflow

### 1. Write

Create `.tf` files with your infrastructure configuration:

```hcl
# main.tf
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
  region = "us-east-1"
}

resource "aws_s3_bucket" "data" {
  bucket = "my-application-data"
}
```

### 2. Initialize

Download provider plugins and prepare the working directory:

```bash
terraform init
```

### 3. Plan

Preview changes before applying:

```bash
terraform plan
```

Output shows:
- Resources to be created (+)
- Resources to be modified (~)
- Resources to be destroyed (-)

### 4. Apply

Execute the planned changes:

```bash
terraform apply
```

### 5. Destroy (when needed)

Remove infrastructure when no longer needed:

```bash
terraform destroy
```

## Installation

### macOS

```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform version
```

### Linux

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# RHEL/CentOS/Fedora
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

### Windows

```powershell
# Using Chocolatey
choco install terraform

# Using Scoop
scoop install terraform
```

### Docker

```bash
docker run -it --rm hashicorp/terraform:latest version
```

## Quick Start

### Example 1: AWS S3 Bucket

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name-12345"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.example.id
}
```

Run:
```bash
terraform init
terraform plan
terraform apply
```

### Example 2: AWS EC2 Instance

```hcl
# variables.tf
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# main.tf
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = "WebServer"
  }
}

# outputs.tf
output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
```

### Example 3: Multi-Environment Setup

```hcl
# Create workspaces for environments
# terraform workspace new dev
# terraform workspace new staging
# terraform workspace new prod

locals {
  environment_config = {
    dev = {
      instance_type = "t3.micro"
      instance_count = 1
    }
    staging = {
      instance_type = "t3.small"
      instance_count = 2
    }
    prod = {
      instance_type = "t3.large"
      instance_count = 5
    }
  }

  config = local.environment_config[terraform.workspace]
}

resource "aws_instance" "app" {
  count         = local.config.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.config.instance_type

  tags = {
    Name        = "app-${terraform.workspace}-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```

## Project Structure

### Basic Project

```
my-infrastructure/
├── main.tf              # Primary resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values (add to .gitignore if sensitive)
├── versions.tf          # Provider version constraints
└── README.md           # Documentation
```

### Module-Based Project

```
terraform-infrastructure/
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
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   │   └── ...
│   ├── database/
│   │   └── ...
│   └── networking/
│       └── ...
├── global/
│   ├── iam/
│   │   └── main.tf
│   └── route53/
│       └── main.tf
└── README.md
```

## Essential Commands

### Initialization and Planning

```bash
# Initialize working directory
terraform init

# Initialize with backend config
terraform init -backend-config=backend.hcl

# Upgrade provider plugins
terraform init -upgrade

# Validate configuration syntax
terraform validate

# Format code (auto-fix)
terraform fmt -recursive

# Preview changes
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with specific variables
terraform plan -var="instance_type=t3.large"
```

### Applying Changes

```bash
# Apply changes (with confirmation)
terraform apply

# Apply saved plan (no confirmation)
terraform apply tfplan

# Apply with auto-approve
terraform apply -auto-approve

# Apply with variable file
terraform apply -var-file=production.tfvars

# Target specific resource
terraform apply -target=aws_instance.web
```

### State Management

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_instance.web

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state (keeps actual resource)
terraform state rm aws_instance.web

# Pull remote state
terraform state pull

# Push local state to remote
terraform state push

# Refresh state from real infrastructure
terraform refresh
```

### Workspace Management

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new production

# Select workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete staging
```

### Importing and Output

```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# Output in JSON format
terraform output -json
```

### Destruction

```bash
# Destroy all resources (with confirmation)
terraform destroy

# Destroy with auto-approve
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.web
```

## Configuration Files

### .gitignore

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (may contain sensitive data)
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore plan files
*.tfplan

# Lock files (commit .terraform.lock.hcl to version control)
# .terraform.lock.hcl
```

### terraform.tfvars.example

```hcl
# Copy this file to terraform.tfvars and fill in your values

aws_region         = "us-east-1"
environment        = "production"
project_name       = "my-app"
instance_type      = "t3.micro"
database_password  = "CHANGE_ME"
```

## Environment Variables

```bash
# AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Azure credentials
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"

# GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
export GOOGLE_PROJECT="your-project-id"

# Terraform-specific
export TF_LOG=DEBUG  # Enable debug logging (TRACE, DEBUG, INFO, WARN, ERROR)
export TF_LOG_PATH="terraform.log"  # Log to file
export TF_VAR_instance_type="t3.large"  # Set variable via environment
```

## Best Practices

### 1. Version Control Everything

- Commit all `.tf` files to Git
- Use `.gitignore` for state files and sensitive data
- Tag releases for infrastructure versions
- Use pull requests for infrastructure changes

### 2. Use Remote State

- Never commit state files to Git
- Use S3, Azure Storage, or Terraform Cloud for state
- Enable state locking to prevent concurrent modifications
- Enable state encryption for sensitive data

### 3. Organize with Modules

- Create reusable modules for common patterns
- Use Terraform Registry for community modules
- Version your modules
- Document module inputs and outputs

### 4. Implement Security

- Never hardcode credentials
- Use IAM roles and managed identities when possible
- Mark sensitive variables with `sensitive = true`
- Scan code with security tools (checkov, tfsec, terrascan)
- Encrypt state files

### 5. Test Before Applying

- Always run `terraform plan` before `apply`
- Review plan output carefully
- Use `terraform validate` and `terraform fmt`
- Test in dev environment first
- Use `-target` for incremental changes

### 6. Use Workspaces for Environments

- Separate dev/staging/prod with workspaces or directories
- Use consistent naming conventions
- Implement environment-specific configurations
- Avoid sharing state between environments

### 7. Document Your Code

- Add descriptions to variables and outputs
- Include README.md in modules
- Use comments to explain complex logic
- Keep documentation up to date

## Common Use Cases

1. **AWS Infrastructure**: EC2, VPC, RDS, S3, Lambda, ECS/EKS
2. **Azure Resources**: Virtual Machines, App Service, SQL Database, AKS
3. **GCP Deployments**: Compute Engine, GKE, Cloud SQL, Cloud Storage
4. **Kubernetes Management**: Deployments, Services, Ingress, ConfigMaps
5. **Multi-Cloud Architectures**: Resources across multiple providers
6. **Disaster Recovery**: Multi-region deployments
7. **GitOps Workflows**: Infrastructure changes via pull requests
8. **Compliance as Code**: Policy enforcement with Sentinel or OPA

## Learning Resources

### Official Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform CLI Reference](https://www.terraform.io/cli)

### Provider Documentation

- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

### Community Resources

- [Terraform GitHub](https://github.com/hashicorp/terraform)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)

### Tools and Extensions

- **tflint**: Terraform linter
- **checkov**: Security scanner
- **terraform-docs**: Documentation generator
- **terrascan**: Policy as code scanner
- **infracost**: Cost estimation
- **terragrunt**: Terraform wrapper for DRY configurations
- **VS Code Terraform Extension**: Syntax highlighting and IntelliSense

## Getting Help

If you encounter issues:

1. Run `terraform validate` to check syntax
2. Check provider documentation for resource arguments
3. Review Terraform logs with `TF_LOG=DEBUG`
4. Search [Terraform Registry](https://registry.terraform.io/) for modules
5. Ask questions on [HashiCorp Discuss](https://discuss.hashicorp.com/)
6. Review [GitHub Issues](https://github.com/hashicorp/terraform/issues)

## Next Steps

After mastering the basics:

1. Explore advanced state management with Terraform Cloud
2. Implement CI/CD pipelines with Terraform
3. Create custom providers for internal systems
4. Study Sentinel policies for governance
5. Build a module library for your organization
6. Implement GitOps workflows
7. Explore Terratest for infrastructure testing
8. Learn about drift detection and remediation

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintainer**: Infrastructure Team

For detailed examples and patterns, see [EXAMPLES.md](EXAMPLES.md).
For complete skill documentation, see [SKILL.md](SKILL.md).
