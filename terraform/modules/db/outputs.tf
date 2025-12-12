output "instance_name" {
  value       = google_compute_instance.postgres.name
  description = "Name of the PostgreSQL instance"
}

output "private_ip" {
  value       = google_compute_instance.postgres.network_interface[0].network_ip
  description = "Private IP address of PostgreSQL instance"
}

output "database_host" {
  value       = google_compute_instance.postgres.network_interface[0].network_ip
  description = "Database host address for connection strings"
}

output "port" {
  value       = var.db_port
  description = "PostgreSQL port"
}

output "self_link" {
  value       = google_compute_instance.postgres.self_link
  description = "Self link of the PostgreSQL instance"
}

output "public_ip" {
  description = "Public IP of PostgreSQL instance (null if not assigned)"
  value       = try(google_compute_instance.postgres.network_interface[0].access_config[0].nat_ip, null)
}

#output "provisioning_user" {
 # description = "Temporary provisioning SSH user"
 # value       = "provisioning"
#}

#output "provisioning_key_path" {
 # description = "Path to provisioning private key"
 # value       = local_file.provisioning_private_key.filename
#}
