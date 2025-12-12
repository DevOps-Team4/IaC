# Bastion Security - SSH from internet
resource "google_compute_firewall" "bastion_ssh" {
  name    = "fw-bastion-ssh-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
  description   = "Allow SSH to bastion from anywhere"
}

# Frontend Security - HTTP/HTTPS from internet
resource "google_compute_firewall" "frontend_web" {
  name    = "fw-frontend-web-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8081", "4200"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["frontend"]
  description   = "Allow HTTP/HTTPS and custom 8081 to frontend"
}

# Backend Security - API access from frontend only
resource "google_compute_firewall" "backend_api" {
  name    = "fw-backend-api-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  
  source_tags = ["frontend"]
  target_tags = ["backend"]
  description = "Allow API traffic from frontend to backend"
}

# Database Security - Access from backend only
resource "google_compute_firewall" "database_access" {
  name    = "fw-database-access-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  
  source_tags = ["backend"]
  target_tags = ["postgres"]
  description = "Allow database access from backend"
}

# Internal SSH - SSH from bastion to all instances
resource "google_compute_firewall" "internal_ssh" {
  name    = "fw-internal-ssh-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_tags = ["bastion"]
  target_tags = ["frontend", "backend", "postgres"]
  description = "Allow SSH from bastion to all instances"
}

# Internal Communication - All traffic within VPC
resource "google_compute_firewall" "internal_all" {
  name    = "fw-internal-all-${var.environment}"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.vpc_cidr]
  description   = "Allow all internal communication within VPC"
}