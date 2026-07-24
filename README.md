# CubeAPM Terraform Module (AWS)

This Terraform module automates the deployment of **CubeAPM** on Amazon Web Services (AWS). It provisions all necessary infrastructure, including the backend EC2 instance, Security Groups, and network configurations.

It is designed to be highly flexible: you can either let the module provision a brand-new Application Load Balancer (ALB), or seamlessly integrate CubeAPM behind an **existing ALB** in your infrastructure using Host Header routing.

## Features
- Deploys CubeAPM on an AWS EC2 instance (default: Ubuntu 24.04 ARM64, `m8g.xlarge`).
- Automatically configures Security Groups for SSH (22), UI (3125), Metrics (3130), and MCP (3140).
- **ALB Flexibility**: Choose to create a new ALB or attach to an existing one.

## Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed (v1.0.0 or higher).
- AWS Credentials configured locally (e.g., via `aws configure`).
- An existing AWS VPC and Subnet.
- An SSH Key Pair in your AWS account.

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/cubeapm/CubeAPM-Terraform-AWS.git
   cd CubeAPM-Terraform-AWS
   ```

2. Create a `terraform.tfvars` file and provide your environment-specific values (see examples below).

3. Initialize and apply:
   ```bash
   terraform init
   terraform apply
   ```

## Configuration Examples

### Option 1: Create a New ALB (Default)
```hcl
aws_profile            = "default"
aws_region             = "ap-south-1"
aws_vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
aws_subnet_id          = "subnet-xxxxxxxxxxxxxxxxx"
aws_vpc_cidr           = "10.0.0.0/16"
aws_key_name           = "my-ssh-key"

# ALB Configuration
create_alb             = true
lb_subnet_ids          = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
load_balancer_internal = false
certificate_arn        = "arn:aws:acm:ap-south-1:123456789012:certificate/xxx-xxx-xxx"
```

### Option 2: Use an Existing ALB
```hcl
aws_profile            = "default"
aws_region             = "ap-south-1"
aws_vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
aws_subnet_id          = "subnet-xxxxxxxxxxxxxxxxx"
aws_vpc_cidr           = "10.0.0.0/16"
aws_key_name           = "my-ssh-key"

# Attach to an existing ALB
create_alb                     = false
existing_alb_listener_arn      = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:listener/app/xxx/xxx"
cubeapm_host_header            = ["cubeapm.mydomain.com"]
alb_listener_rule_priority     = 50
existing_alb_security_group_id = "sg-xxxxxxxxxxxxxxxxx" 
```

For detailed instructions and a full list of variables, please refer to the official [CubeAPM documentation](https://docs.cubeapm.com/install/terraform).