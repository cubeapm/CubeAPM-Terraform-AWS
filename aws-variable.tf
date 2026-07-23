variable "aws_profile" {
  description = "The AWS profile to use for authentication (example: ~/.aws/credentials)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the resources to (default: us-east-1)"
  type        = string
  default     = "ap-south-1"
}

variable "aws_ec2_ami" {
  description = "The AWS AMI to use for the EC2 instance (default: Ubuntu 24.04 arm64 for ap-south-1)"
  type        = string
  default     = "ami-0f10ad22bd55251b2"
}

variable "aws_ec2_instance_type" {
  description = "The AWS instance type to use for the EC2 instance (default: m8g.xlarge)"
  type        = string
  default     = "m8g.xlarge"
}

# variable "aws_az" {
#   description = "The Availability Zone to deploy the EC2 instance to (default: us-east-1a)"
#   type        = string
#   default     = "ap-south-1a"
# }

variable "aws_vpc_id" {
  description = "VPC id"
  type        = string
}

variable "aws_subnet_id" {
  description = "Subnet id"
  type        = string
}

variable "aws_key_name" {
  description = "Key to SSH into the CubeAPM server (i.e. pem, ppk)"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "lb_subnet_ids" {
  description = "List of Public/Private subnets ids (i.e. [10.0.0.1, 10.0.0.2]). Required if create_alb is true."
  type        = list(string)
  default     = []
}

variable "load_balancer_internal" {
  description = "Select the internal or internet facing loadbalancer"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate to use for the ALB. Required if create_alb is true."
  type        = string
  default     = ""
}

variable "create_alb" {
  description = "Set to true to create a new Application Load Balancer. If false, an existing ALB listener will be used."
  type        = bool
  default     = true
}

variable "existing_alb_listener_arn" {
  description = "The ARN of the existing ALB listener to attach to (required if create_alb is false)"
  type        = string
  default     = ""
}

variable "cubeapm_host_header" {
  description = "The host header(s) to use for routing traffic from an existing ALB (e.g., [\"cubeapm.example.com\"])"
  type        = list(string)
  default     = []
}

variable "alb_listener_rule_priority" {
  description = "The priority of the listener rule when using an existing ALB"
  type        = number
  default     = 100
}

variable "existing_alb_security_group_id" {
  description = "The security group ID of the existing ALB to allow traffic to CubeAPM. If empty and create_alb is false, defaults to allowing the VPC CIDR."
  type        = string
  default     = ""
}
