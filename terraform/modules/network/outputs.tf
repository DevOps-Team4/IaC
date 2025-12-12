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
  value       = "${var.vpc_name}-public-${var.environment}"
}

output "public_subnet_id" {
  description = "Public subnet ID"  
  value       = module.vpc.subnets["${var.region}/${var.vpc_name}-public-${var.environment}"].id
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = "${var.vpc_name}-private-${var.environment}"
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.subnets["${var.region}/${var.vpc_name}-private-${var.environment}"].id
}

output "public_subnet_cidr" {
  description = "Public subnet CIDR"
  value       = var.public_subnet_cidr
}

output "private_subnet_cidr" {
  description = "Private subnet CIDR"
  value       = var.private_subnet_cidr
}