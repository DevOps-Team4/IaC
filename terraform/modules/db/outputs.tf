output "instance_name" {
  value = google_compute_instance.postgres.name
}

output "private_ip" {
  description = "Private IP address of PostgreSQL instance"
  value       = google_compute_instance.postgres.network_interface[0].network_ip
}

output "database_host" {
  value = google_compute_instance.postgres.network_interface[0].network_ip
}

output "port" {
  description = "PostgreSQL port"
  value       = var.db_port
}

output "self_link" {
  value = google_compute_instance.postgres.self_link
}
