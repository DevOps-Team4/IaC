terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
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

resource "tls_private_key" "provisioning_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "provisioning_private_key" {
  content         = tls_private_key.provisioning_key.private_key_pem
  filename        = "${path.root}/.ssh/provisioning_key"
  file_permission = "0600"
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
  
  provisioning_user       = "provisioning"
  provisioning_public_key = tls_private_key.provisioning_key.public_key_openssh

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
  #ssh_public_keys = var.ssh_public_keys
  provisioning_public_key = tls_private_key.provisioning_key.public_key_openssh
  provisioning_user       = "provisioning"
  
  depends_on = [module.network]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    bastion_ip          = module.instances.bastion_ip
    frontend_private_ip = module.instances.frontend_private_ip
    backend_private_ip  = module.instances.backend_private_ip
    db_ip               = module.db.private_ip

    ssh_user     = "provisioning"
    ssh_key_path = local_file.provisioning_private_key.filename

    postgres_user       = var.postgres_user
    postgres_password   = var.postgres_password
    postgres_db         = var.db.postgres_db
    postgres_host       = module.db.private_ip
  })
}

