# Suggestion: All outputs from db module properly exposed
output "db_instance_name" {
  value       = module.db.instance_name
  description = "Name of the PostgreSQL database instance"
}

output "db_private_ip" {
  value       = module.db.private_ip
  description = "Private IP address of PostgreSQL instance (for internal access)"
}

output "db_host" {
  value       = module.db.database_host
  description = "Database host address for connection strings"
}

output "db_port" {
  value       = module.db.port
  description = "PostgreSQL service port number"
}

output "db_instance_self_link" {
  value       = module.db.self_link
  description = "Self link of the PostgreSQL compute instance for reference"
}

output "terraform_service_account_email" {
  value       = google_service_account.terraform.email
  description = "Email of the Terraform service account managing resources"
}

# Suggestion: Consider adding these useful connection outputs:
output "database_connection_string" {
  value       = "postgresql://[user]:***@${module.db.database_host}:${module.db.port}/[dbname]"
  description = "PostgreSQL connection string template (requires password)"
  sensitive   = true
}

output "service_account_unique_id" {
  value       = google_service_account.terraform.unique_id
  description = "Unique ID of the Terraform service account"
}

# Instance module outputs
output "instance_ips" {
  value       = module.instances.instance_ips
  description = "Map of instance names to their IP configurations"
}

output "instance_self_links" {
  value       = module.instances.instance_self_links
  description = "Self links of created instances"
}

output "instance_ids" {
  value       = module.instances.instance_ids
  description = "IDs of created instances"
}
