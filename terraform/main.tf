terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
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