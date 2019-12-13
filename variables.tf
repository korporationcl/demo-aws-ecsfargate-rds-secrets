variable app_cpu {
  description = "CPU utilisation for webapp"
  type        = string
  default     = "128"
}

variable app_image {
  description = "Docker repository"
  type        = string
  default     = "korporation/webapp-demo"
}

variable app_memory {
  description = "Memory utilisation for webapp"
  type        = string
  default     = "128"
}

variable app_size {
  description = "num of apps running"
  type        = number
  default     = 3
}

variable app_port {
  description = "Port number application"
  type        = number
  default     = 80
}

variable app_autoscaling {
  description = "Application Autoscaling values"
  type        = map
  default = {
    min = 1
    max = 5
  }
}

variable "availability_zones" {
  description = "Availability zones to deploy stack"
  type        = list
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "db_encryption" {
  description = "Enable encryption RDS storage, for production say yes."
  default     = false
}

variable "db_multiaz" {
  description = "Enable MultiAZ on RDS, for production say yes."
  default     = false
}

variable instance_types {
  type = map
  default = {
    db = "db.t2.micro"
  }
}

variable "region" {
  description = "AWS region to use"
  default     = "us-east-1"
  type        = string
}

variable "tags" {
  description = "Basic tags"
  type        = map
  default = {
    Name        = "POC"
    Description = "POC for Web stack"
  }
}

variable "profile" {
  description = "AWS PROFILE"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "VPC private subnets"
  type        = list
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  description = "VPC public subnets"
  type        = list
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
