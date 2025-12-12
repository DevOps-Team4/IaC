variable "subnets" {
  type = list(object({
    name = string
    zone = string
  }))
  description = "List of subnets available for instances"
}

variable "vm_instances" {
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
  description = "List of VM instances to create"
}

variable "network_name" {
  type        = string
  description = "VPC network name for instances"
}

variable "provisioning_public_key" {
  type        = string
  description = "Public key for provisioning user (used by Ansible)"
}

variable "provisioning_user" {
  type        = string
  description = "User for Ansible provisioning"
}

#variable "ssh_public_keys" {
#  type        = list(string)
#  description = "List of SSH public keys for accessing instances"
#  default     = []
#}
