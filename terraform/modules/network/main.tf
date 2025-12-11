# Enable required API
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_dependent_services = true
  disable_on_destroy         = false
}

# Only VPC module
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "${var.vpc_name}-${var.environment}"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${var.vpc_name}-public-${var.environment}"
      subnet_ip             = var.public_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet for ${var.environment}"
    },
    {
      subnet_name           = "${var.vpc_name}-private-${var.environment}"
      subnet_ip             = var.private_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet for ${var.environment}"
    }
  ]

  routes = [
    {
      name              = "egress-internet-${var.environment}"
      description       = "Route to internet gateway"
      destination_range = "0.0.0.0/0"
      tags              = "internet-${var.environment}"
      next_hop_internet = "true"
    }
  ]

  depends_on = [google_project_service.compute_api]
}