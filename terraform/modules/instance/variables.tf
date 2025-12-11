variable "project" {
  type = object({
    name                = string
    environment         = string
    region              = string
    os_image            = string
    terraform_username  = string
    ssh_public_keys     = list(string)
  })
  description = "Project configuration object"
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

variable "network_name" {
  type        = string
  description = "VPC network name for instances"
}
