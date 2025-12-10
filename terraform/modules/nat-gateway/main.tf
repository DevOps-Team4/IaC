# Cloud Router - Required for NAT Gateway
resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.vpc_name}-router-${var.environment}"
  region  = var.region
  network = var.network_id
  
  bgp {
    asn = 64514
  }
}

# Cloud NAT - Provides internet access for private instances
resource "google_compute_router_nat" "nat_gateway" {
  count  = var.enable_nat ? 1 : 0
  name   = "${var.vpc_name}-nat-${var.environment}"
  router = google_compute_router.router[0].name
  region = var.region
  
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  
  subnetwork {
    name                    = var.private_subnet_id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}