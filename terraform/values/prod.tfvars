project_id = "your-production-project-id"
region     = "europe-west3"
environment = "prod"

# VPC Network configuration
vpc_name            = "app-vpc"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
enable_nat_gateway  = true