variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for internal traffic"
  type        = string
}