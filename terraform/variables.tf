variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

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

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}
