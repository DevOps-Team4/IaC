output "network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "network_id" {
  description = "VPC network ID"
  value       = module.vpc.network_id
}

output "network_self_link" {
  description = "VPC network self link"
  value       = module.vpc.network_self_link
}

output "public_subnet_name" {
  description = "Public subnet name"
  value       = module.vpc.subnets_names[0]
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.subnets_ids[0]
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = module.vpc.subnets_names[1]
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.subnets_ids[1]
}

output "public_subnet_cidr" {
  description = "Public subnet CIDR"
  value       = module.vpc.subnets_ips[0]
}

output "private_subnet_cidr" {
  description = "Private subnet CIDR"
  value       = module.vpc.subnets_ips[1]
}