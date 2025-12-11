variable "name" {
  type        = string
  description = "Instance name for the PostgreSQL VM"
}

variable "machine_type" {
  type        = string
  description = "GCP machine type (e.g., e2-small, e2-medium, n2-standard-2)"
}

variable "zone" {
  type        = string
  description = "GCP zone for the instance"
}

variable "os_image" {
  type        = string
  description = "OS image for DB VM (e.g., ubuntu-2004-lts, ubuntu-2204-lts)"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "network" {
  type        = string
  description = "VPC network name"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork name"
}

variable "tags" {
  type        = list(string)
  description = "Network tags for firewall rules"
}

variable "docker_image" {
  type        = string
  description = "Docker image for PostgreSQL (e.g., postgres:15, postgres:16)"
}

variable "db_port" {
  type        = number
  description = "PostgreSQL database port (default: 5432)"
}

variable "public_ip" {
  type        = bool
  description = "Whether to assign a public IP address"
}

variable "service_account" {
  type        = string
  description = "Service account email for instance"
}

variable "postgres_user" {
  type        = string
  sensitive   = true
  description = "PostgreSQL superuser username"
}

variable "postgres_password" {
  type        = string
  sensitive   = true
  description = "PostgreSQL superuser password (sensitive - use environment variable)"
}

variable "postgres_db" {
  type        = string
  description = "PostgreSQL database name to create"
}
