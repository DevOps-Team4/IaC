variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for NAT"
  type        = string
}

variable "enable_nat" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}