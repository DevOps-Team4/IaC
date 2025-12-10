provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "terraform" {
  account_id   = "terraform-user"
  display_name = "Terraform Service Account"
}

resource "google_project_iam_member" "terraform_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "terraform_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

module "db" {
  source = "./modules/db"

  name         = var.db.name
  machine_type = var.db.machine_type
  zone         = var.zone
  public_ip    = var.db.public_ip
  tags         = var.db.tags
  docker_image = var.db.docker_image
  db_port      = var.db.port

  os_image     = var.db.os_image
  disk_size_gb = var.db.disk_size_gb

  network         = var.network_name
  subnetwork      = var.subnetwork_name
  service_account = google_service_account.terraform.email

  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.db.postgres_db
}
