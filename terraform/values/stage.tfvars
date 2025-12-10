project_id = "terraform-test-480809"
region     = "europe-west3"
environment = "stage"

# VPC Network configuration
vpc_name            = "app-vpc"
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"
enable_nat_gateway  = true