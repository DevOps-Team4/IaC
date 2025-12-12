output "instance_ips" {
  value = {
    for name, vm in google_compute_instance.vm :
    name => {
      internal_ip = vm.network_interface[0].network_ip
      external_ip = try(vm.network_interface[0].access_config[0].nat_ip, null)
      zone        = vm.zone
      tags        = vm.tags
    }
  }
  description = "Map of instance names to their IP configurations"
}

output "bastion_ip" {
  value = try(
    [for vm in google_compute_instance.vm : vm.network_interface[0].access_config[0].nat_ip if contains(vm.tags, "bastion")][0],
    null
  )
}

output "frontend_private_ip" {
  value = [for vm in google_compute_instance.vm : vm.network_interface[0].network_ip if contains(vm.tags, "frontend")][0]
}

output "backend_private_ip" {
  value = [for vm in google_compute_instance.vm : vm.network_interface[0].network_ip if contains(vm.tags, "backend")][0]
}

output "instance_self_links" {
  value = {
    for name, vm in google_compute_instance.vm :
    name => vm.self_link
  }
  description = "Self links of created instances"
}

output "instance_ids" {
  value = {
    for name, vm in google_compute_instance.vm :
    name => vm.id
  }
  description = "IDs of created instances"
}
