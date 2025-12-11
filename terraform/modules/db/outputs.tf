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
