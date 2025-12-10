output "db_instance_name" {
  value = module.db.instance_name
}

output "db_private_ip" {
  value = module.db.private_ip
}

output "db_host" {
  value = module.db.database_host
}

output "db_port" {
  value = module.db.port
}

output "db_instance_self_link" {
  value = module.db.self_link
}

output "terraform_service_account_email" {
  value = google_service_account.terraform.email
}
