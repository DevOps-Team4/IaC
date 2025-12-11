# Генеруємо тимчасовий SSH ключ для provisioning
resource "tls_private_key" "provisioning_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Зберігаємо приватний ключ локально (для Ansible)
resource "local_file" "provisioning_private_key" {
  content         = tls_private_key.provisioning_key.private_key_pem
  filename        = "${path.root}/.ssh/provisioning_key"
  file_permission = "0600"
}

resource "google_compute_instance" "postgres" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags

  labels = {
    application = "database"
    role        = "postgres"
  }

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size_gb
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.public_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  # Додаємо тимчасовий SSH ключ для provisioning
  metadata = {
    ssh-keys = "provisioning:${tls_private_key.provisioning_key.public_key_openssh}"
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    DB_PORT           = var.db_port
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
    DOCKER_IMAGE      = var.docker_image
  })
}

# Output для Ansible
output "provisioning_user" {
  value = "provisioning"
}

output "provisioning_key_path" {
  value = local_file.provisioning_private_key.filename
}

output "db_instance_ip" {
  value = google_compute_instance.postgres.network_interface[0].access_config[0].nat_ip
}