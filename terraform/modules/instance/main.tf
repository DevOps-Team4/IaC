locals {
  subnets_by_zone = {
    for s in var.subnets :
    s.zone => s
  }
}

resource "google_compute_instance" "vm" {
  for_each     = { for vm in var.vm_instances : vm.name => vm }
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = "${var.project.region}-${local.subnets_by_zone[var.subnets[0].zone].zone}"
  tags         = each.value.tags

  labels = {
    role        = each.value.role
    environment = var.project.environment
  }

  boot_disk {
    initialize_params {
      image = var.project.os_image
    }
  }

  network_interface {
    subnetwork = local.subnets_by_zone[var.subnets[0].zone].name

    dynamic "access_config" {
      for_each = each.value.public_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    ssh-keys = join("\n", [
      for key in var.project.ssh_public_keys :
      "${var.project.terraform_username}:${key}"
    ])
  }
}

resource "google_compute_firewall" "allow_service" {
  for_each = { for vm in var.vm_instances : vm.name => vm }
  name    = "${each.value.name}-allow-port"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["${each.value.port}"]
  }

  target_tags = each.value.tags
}
