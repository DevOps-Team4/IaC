terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    # Configuration will be provided via -backend-config flag
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Network Module - Creates VPC + Subnets + Routes
module "network" {
  source = "./modules/network"
  
  project_id          = var.project_id
  region              = var.region
  vpc_name            = var.vpc_name
  environment         = var.environment
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# 2. NAT Gateway Module - Creates Cloud Router + Cloud NAT
module "nat_gateway" {
  source = "./modules/nat-gateway"
  
  project_id        = var.project_id
  region            = var.region
  vpc_name          = var.vpc_name
  environment       = var.environment
  network_id        = module.network.network_id
  private_subnet_id = module.network.private_subnet_id
  enable_nat        = var.enable_nat_gateway
  
  depends_on = [module.network]
}

# 3. Firewall Module - Creates Security Groups (Firewall Rules)
module "firewall" {
  source = "./modules/firewall"
  
  network_name = module.network.network_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  
  depends_on = [module.network]
}

module "db" {
  source            = "./modules/db"
  name              = var.db.name
  machine_type      = var.db.machine_type
  zone              = var.zone
  public_ip         = var.db.public_ip
  tags              = var.db.tags
  docker_image      = var.db.docker_image
  db_port           = var.db.port
  os_image          = var.db.os_image
  disk_size_gb      = var.db.disk_size_gb
  network           = module.network.network_name
  subnetwork        = module.network.private_subnet_name
  service_account   = "default"
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.db.postgres_db
  
  depends_on = [module.network]
}

module "instances" {
  source       = "./modules/instance"
  
  subnets = [
    {
      name = module.network.public_subnet_name
      zone = "${var.region}-a"
    },
    {
      name = module.network.private_subnet_name
      zone = "${var.region}-b"
    }
  ]
  vm_instances    = var.vm_instances
  network_name    = module.network.network_name
  ssh_public_keys = var.ssh_public_keys
  
  depends_on = [module.network]
}
