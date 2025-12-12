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
