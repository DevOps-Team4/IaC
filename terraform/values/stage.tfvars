project_id = "hip-voyager-481321-p3"   #This needs to be unique, change this before applying
region     = "europe-west3"
environment = "stage"

# VPC Network configuration
vpc_name            = "app-vpc"
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"
enable_nat_gateway  = true

# Database configuration
zone = "europe-west3-a"
postgres_user = "postgres"
postgres_password = "SecureStagePass2024!"

db = {
  name         = "postgres-db"
  machine_type = "e2-micro"
  public_ip    = false
  tags         = ["database", "postgres"]
  docker_image = "postgres:13"  
  port         = 5432
  os_image     = "debian-cloud/debian-11"
  disk_size_gb = 20
  postgres_db  = "appdb"
}

# VM Instances configuration
vm_instances = [
  {
    name         = "bastion-host"
    machine_type = "e2-micro"
    zone         = "europe-west3-a"
    subnet       = "public"
    public_ip    = true
    tags         = ["bastion"]
    ports        = [22]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 10
  },
  {
    name         = "web-server-1"
    machine_type = "e2-micro"
    zone         = "europe-west3-a"
    subnet       = "public"
    public_ip    = true
    tags         = ["web", "frontend"]
    ports        = [80, 443]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 10
  },
  {
    name         = "app-server-1"
    machine_type = "e2-micro"
    zone         = "europe-west3-b"
    subnet       = "private"
    public_ip    = false
    tags         = ["app", "backend"]
    ports        = [3000]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 15
  }
]