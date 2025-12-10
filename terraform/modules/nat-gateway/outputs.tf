output "router_name" {
  description = "Cloud Router name"
  value       = var.enable_nat ? google_compute_router.router[0].name : null
}

output "nat_gateway_name" {
  description = "NAT Gateway name"
  value       = var.enable_nat ? google_compute_router_nat.nat_gateway[0].name : null
}

output "router_id" {
  description = "Cloud Router ID"
  value       = var.enable_nat ? google_compute_router.router[0].id : null
}