variable "name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "zone" {
  type = string
}

variable "os_image" {
  description = "OS image for DB VM"
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "docker_image" {
  type = string
}

variable "db_port" {
  type = number
}

variable "public_ip" {
  type = bool
}

variable "service_account" {
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

variable "postgres_db" {
  type    = string
}
