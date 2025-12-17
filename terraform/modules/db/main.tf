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

  metadata = {
    ssh-keys = "${var.provisioning_user}:${var.provisioning_public_key}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Basic system setup - packages will be installed via Ansible
    apt-get update
    
    # Create user provisioning і sudo without password
    useradd -m -s /bin/bash ${var.provisioning_user} || true
    mkdir -p /home/${var.provisioning_user}/.ssh
    echo "${var.provisioning_public_key}" > /home/${var.provisioning_user}/.ssh/authorized_keys
    chmod 600 /home/${var.provisioning_user}/.ssh/authorized_keys
    chown -R ${var.provisioning_user}:${var.provisioning_user} /home/${var.provisioning_user}/.ssh

    echo "${var.provisioning_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${var.provisioning_user}
    chmod 440 /etc/sudoers.d/${var.provisioning_user}

    # Create marker file to indicate VM is ready for Ansible
    touch /tmp/terraform-setup-complete
    echo "Instance postgres_db ready for Ansible configuration" > /var/log/terraform-setup.log
  EOF
}