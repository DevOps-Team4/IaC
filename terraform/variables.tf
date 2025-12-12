variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west3"
}

variable "environment" {
  description = "Environment name (stage, prod)"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet"
  type        = bool
  default     = true
}

# Database variables
variable "db" {
  description = "Database configuration"
  type = object({
    name         = string
    machine_type = string
    public_ip    = bool
    tags         = list(string)
    docker_image = string
    port         = number
    os_image     = string
    disk_size_gb = number
    postgres_db  = string
  })
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

# Instance variables
variable "vm_instances" {
  description = "VM instances configuration"
  type = list(object({
    name         = string
    machine_type = string
    zone         = string
    subnet       = string
    public_ip    = bool
    tags         = list(string)
    ports        = list(number)  # Keep for firewall rules
    os_image     = string
    disk_size_gb = number
  }))
}

#variable "ssh_public_keys" {
#  description = "List of SSH public keys for accessing instances"
# type        = list(string)
# default     = []
#}
