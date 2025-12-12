# Network Outputs
output "vpc_network_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = module.network.network_id
}

output "public_subnet_name" {
  description = "Public subnet name"
  value       = module.network.public_subnet_name
}

output "public_subnet_cidr" {
  description = "Public subnet CIDR"
  value       = module.network.public_subnet_cidr
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = module.network.private_subnet_name
}

output "private_subnet_cidr" {
  description = "Private subnet CIDR"
  value       = module.network.private_subnet_cidr
}

# NAT Gateway Outputs
output "nat_gateway_name" {
  description = "NAT Gateway name (null if disabled)"
  value       = module.nat_gateway.nat_gateway_name
}

output "router_name" {
  description = "Cloud Router name (null if NAT disabled)"
  value       = module.nat_gateway.router_name
}

# Firewall Outputs
output "firewall_rule_names" {
  description = "List of firewall rule names"
  value       = module.firewall.firewall_rule_names
}