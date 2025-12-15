locals {
  # Find public and private subnet names
  public_subnet  = [for s in var.subnets : s.name if strcontains(s.name, "public")][0]
  private_subnet = [for s in var.subnets : s.name if strcontains(s.name, "private")][0]
}

resource "google_compute_instance" "vm" {
  for_each     = { for vm in var.vm_instances : vm.name => vm }
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = each.value.zone
  tags         = each.value.tags

  labels = {
    application = "app"
    environment = "stage"
  }

  boot_disk {
    initialize_params {
      image = each.value.os_image
      size  = each.value.disk_size_gb
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = each.value.subnet == "public" ? local.public_subnet : local.private_subnet

    dynamic "access_config" {
      for_each = each.value.public_ip ? [1] : []
      content {}
    }
  }

  metadata = length(var.ssh_public_keys) > 0 ? {
    ssh-keys = join("\n", [for key in var.ssh_public_keys : "debian:${key}"])
  } : {}

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Basic system setup - packages will be installed via Ansible
    apt-get update
    
    # Create marker file to indicate VM is ready for Ansible
    touch /tmp/terraform-setup-complete
    echo "Instance ${each.value.name} ready for Ansible configuration" > /var/log/terraform-setup.log
  EOF

  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }
}

# Firewall rules are handled by the dedicated firewall module
# This prevents duplication and security issues
