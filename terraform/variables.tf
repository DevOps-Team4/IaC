variable "zone" {
  type = string
}

variable "db" {
  description = "Database VM configuration"
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

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC network."
  type        = string
}

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "project" {
  type = object({
    id                = string
    name              = string
    environment       = string
    region            = string
    zone              = string
    os_image          = string
    terraform_username= string
    ssh_public_keys   = list(string)
  })
  description = "Project configuration object for GCP and VM instances"
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    zone = string
  }))
  description = "List of subnets to create"
}

variable "vm_instances" {
  type = list(object({
    name         = string
    role         = string
    machine_type = string
    public_ip    = bool
    tags         = list(string)
    port         = number
  }))
  description = "List of VM instances to create"
}
