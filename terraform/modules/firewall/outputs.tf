output "firewall_rule_names" {
  description = "Names of created firewall rules"
  value = [
    google_compute_firewall.bastion_ssh.name,
    google_compute_firewall.frontend_web.name,
    google_compute_firewall.backend_api.name,
    google_compute_firewall.database_access.name,
    google_compute_firewall.internal_ssh.name,
    google_compute_firewall.internal_all.name,
  ]
}

output "firewall_rules" {
  description = "Created firewall rules details"
  value = {
    bastion_ssh     = google_compute_firewall.bastion_ssh.id
    frontend_web    = google_compute_firewall.frontend_web.id
    backend_api     = google_compute_firewall.backend_api.id
    database_access = google_compute_firewall.database_access.id
    internal_ssh    = google_compute_firewall.internal_ssh.id
    internal_all    = google_compute_firewall.internal_all.id
  }
}