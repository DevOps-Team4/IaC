# Ultimate IaC - GCP Infrastructure as Code

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com)
[![Team](https://img.shields.io/badge/Team-4%20Members-brightgreen?style=for-the-badge)](https://github.com/DevOps-Team4)

## 📋 Project Overview

This repository contains Terraform Infrastructure as Code (IaC) for deploying a secure, scalable application infrastructure on Google Cloud Platform (GCP). The infrastructure includes VPC networking, compute instances, security groups, and NAT gateway - equivalent to AWS VPC architecture but on GCP.

### 🏗️ Infrastructure Architecture

```
┌─── Public Subnet (10.1.1.0/24) ────┐    ┌─── Private Subnet (10.1.2.0/24) ───┐
│  • Bastion Host (SSH Gateway)       │    │  • Backend Server (API)             │
│  • Web Server (Frontend)            │    │  • PostgreSQL Database              │
└─────────────────────────────────────┘    └─────────────────────────────────────┘
                    │                                       │
            Internet Gateway                        NAT Gateway
                    │                                       │
                    └─────────── Internet ─────────────────┘
```

### 🚀 Features

- **Secure VPC Architecture**: Public and private subnets with proper isolation
- **NAT Gateway**: Private subnet internet access without public IPs
- **Firewall Rules**: Comprehensive security groups with least privilege
- **SSH Access**: Multi-user SSH key management for team collaboration  
- **Remote State**: GCS bucket with versioning for state management
- **Service Account**: Production-ready authentication with minimal permissions
- **Modular Design**: Reusable Terraform modules for different environments


## 📁 Repository Structure

```
IaC/
├── README.md                    # This documentation
├── .gitignore                   # Git ignore rules
└── terraform/                   # Terraform configuration
    ├── startscript.sh          # Production setup script
    ├── main.tf                 # Main Terraform configuration
    ├── variables.tf            # Variable definitions
    ├── outputs.tf              # Output definitions
    ├── values/
    │   └── stage.tfvars        # Environment-specific variables
    ├── backend/
    │   └── stage.properties    # Remote state configuration
    └── modules/                # Reusable Terraform modules
        ├── network/            # VPC, subnets, routing
        ├── firewall/           # Security groups
        ├── nat-gateway/        # NAT gateway for private subnets
        ├── instances/          # VM instances with SSH keys
        └── db/                 # Database instances
```

## 🛠️ Prerequisites

### Required Tools
- **Terraform** >= 1.0
- **Google Cloud SDK** (gcloud CLI)
- **Git** for version control
- **Bash** shell (for setup script)

### GCP Requirements
- Active GCP project with billing enabled
- Project Owner or Editor permissions
- APIs that will be automatically enabled:
  - Compute Engine API
  - Cloud Storage API  
  - IAM Credentials API
  - Secret Manager API
  - And others (handled by setup script)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/DevOps-Team4/IaC.git
git checkout network-sg-natgw
cd IaC/terraform
```

### 2. Authenticate with GCP
```bash
gcloud auth login
gcloud config set project terraform-test-480809 (name of your project here)
```

### 3. Run Production Setup Script
```bash
# Make script executable
chmod +x startscript.sh

# Execute setup (creates service account, bucket, enables APIs)
./startscript.sh

# Set service account credentials
export GOOGLE_APPLICATION_CREDENTIALS=terraform-sa-key.json
```

### 4. Initialize and Deploy Infrastructure
```bash
# Initialize Terraform with remote backend
terraform init -backend-config=backend/stage.properties

# Plan infrastructure deployment
terraform plan -var-file=values/stage.tfvars

# Deploy infrastructure
terraform apply -var-file=values/stage.tfvars
```

## 📖 Detailed Setup Guide

### Phase 1: Production Setup (One-time)

The `startscript.sh` automates the complete production environment setup:

#### What the Script Creates:
- ✅ **Service Account**: `terraform-sa@terraform-test-480809.iam.gserviceaccount.com`
- ✅ **IAM Roles**: 11 roles with minimal required permissions
- ✅ **GCS Bucket**: `terraform-11-12-2025-sytoss-bucket` for remote state
- ✅ **API Services**: All required GCP APIs enabled
- ✅ **Secrets**: Database credentials in Secret Manager
- ✅ **Security**: Key files added to .gitignore

#### Service Account Permissions:
```
roles/editor                        # Primary infrastructure management
roles/compute.networkAdmin          # VPC, subnets, firewall management  
roles/compute.securityAdmin         # Security groups management
roles/secretmanager.secretAccessor  # Database credentials access
roles/iam.serviceAccountViewer      # View service accounts
roles/logging.logWriter             # Write logs
roles/monitoring.metricWriter       # Write metrics
roles/monitoring.viewer             # View monitoring
roles/storage.admin                 # GCS bucket management
roles/storage.objectAdmin           # GCS object management  
roles/serviceusage.serviceUsageAdmin # API management
```

### Phase 2: Infrastructure Configuration

#### Environment Variables (`values/stage.tfvars`):
```hcl
project_id = "terraform-test-480809"
region     = "europe-west3"
environment = "stage"

# VPC Network configuration
vpc_name            = "app-vpc"
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"
enable_nat_gateway  = true

# Database configuration
postgres_user = "postgres"
postgres_password = "SecureStagePass2024!"

# SSH Configuration - Team member public keys
ssh_public_keys = [
  "ssh-rsa AAAAB3NzaC1... # Ivan Kaliuzhnyi",
  "ssh-rsa AAAAB3NzaC1... # Yevhen Naumchyk", 
  "ssh-rsa AAAAB3NzaC1... # Yuliia Ivanchuk",
  "ssh-rsa AAAAB3NzaC1... # Marta Hentosh"
]
```

#### Backend Configuration (`backend/stage.properties`):
```properties
bucket = "terraform-11-12-2025-sytoss-bucket"
prefix = "test-app/terraform"
```

### Phase 3: Terraform Operations

#### Complete Command Reference:
```bash
# === INITIALIZATION ===
terraform init -backend-config=backend/stage.properties

# === DEVELOPMENT WORKFLOW ===
terraform fmt                                    # Format code
terraform validate                               # Validate configuration
terraform plan -var-file=values/stage.tfvars    # Preview changes
terraform apply -var-file=values/stage.tfvars   # Deploy infrastructure

# === MANAGEMENT COMMANDS ===
terraform state list                             # List all resources
terraform output                                 # Show infrastructure outputs
terraform show                                   # Show current state details

# === RESOURCE MANAGEMENT ===
terraform state show 'module.instances.google_compute_instance.vm["bastion-host"]'
terraform import 'resource.name' gcp-resource-id
terraform destroy -target='module.db.google_compute_instance.postgres' -var-file=values/stage.tfvars

# === CLEANUP ===
terraform destroy -var-file=values/stage.tfvars # Destroy all infrastructure
```

## 🏗️ Infrastructure Components

### 1. Network Module
- **VPC**: `app-vpc-stage` with custom subnets
- **Public Subnet**: `10.1.1.0/24` for internet-facing resources
- **Private Subnet**: `10.1.2.0/24` for internal resources
- **Routes**: Internet gateway routing for public subnet

### 2. Firewall Module  
- **Bastion SSH**: SSH access from internet to bastion host
- **Frontend Web**: HTTP/HTTPS access to web servers
- **Backend API**: Internal API communication
- **Database Access**: PostgreSQL access from backend servers
- **Internal SSH**: SSH from bastion to all internal servers
- **Internal All**: Full internal VPC communication

### 3. NAT Gateway Module
- **Cloud Router**: BGP routing for NAT functionality  
- **Cloud NAT**: Internet access for private subnet instances
- **Logging**: Error-only logging for troubleshooting

### 4. Instance Module
- **Bastion Host**: SSH gateway in public subnet
- **Web Server**: Frontend application server in public subnet
- **Backend Server**: API server in private subnet
- **Database Server**: PostgreSQL instance in private subnet

### 5. Database Module
- **PostgreSQL**: Dedicated database instance
- **Private Placement**: No public IP for security
- **Startup Scripts**: Ansible-ready configuration

## 🔒 Security Features

### Network Security
- **Subnet Isolation**: Public/private subnet separation
- **Firewall Rules**: Least privilege access controls
- **No Public IPs**: Private subnet instances use NAT gateway
- **SSH Gateway**: Bastion host for secure access

### Access Control  
- **Service Account**: Dedicated credentials for Terraform
- **IAM Roles**: Minimal required permissions
- **SSH Keys**: Multi-user team access management
- **Secret Manager**: Encrypted database credential storage

### State Management
- **Remote State**: GCS bucket with versioning enabled
- **State Locking**: Prevents concurrent modifications
- **Encryption**: Server-side encryption for state files
- **Versioning**: Historical state backup and recovery

## 📊 Deployment Outputs

After successful deployment, Terraform provides these outputs:

```bash
vpc_network_name    = "app-vpc-stage"
vpc_network_id      = "projects/terraform-test-480809/global/networks/app-vpc-stage"
public_subnet_name  = "app-vpc-public-stage" 
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_name = "app-vpc-private-stage"
private_subnet_cidr = "10.1.2.0/24"
nat_gateway_name    = "app-vpc-nat-stage"
router_name         = "app-vpc-router-stage"
firewall_rule_names = [
  "fw-bastion-ssh-stage",
  "fw-frontend-web-stage", 
  "fw-backend-api-stage",
  "fw-database-access-stage",
  "fw-internal-ssh-stage",
  "fw-internal-all-stage"
]
```

## 🔧 Customization

### Adding Team Members
1. Add SSH public key to `values/stage.tfvars`:
```hcl
ssh_public_keys = [
  # Existing keys...
  "ssh-rsa AAAAB3NzaC1... # New Team Member"
]
```
2. Apply changes:
```bash
terraform apply -var-file=values/stage.tfvars
```

### Modifying Infrastructure
1. Edit relevant `.tf` files in modules
2. Test changes with `terraform plan`
3. Apply with `terraform apply`

### Environment Management
- **Development**: Copy `values/stage.tfvars` to `values/dev.tfvars`
- **Production**: Copy `values/stage.tfvars` to `values/prod.tfvars`
- **Backend**: Create corresponding `.properties` files for each environment

## 🚨 Troubleshooting

### Common Issues

**1. Permission Errors**
```bash
# Verify service account authentication
gcloud auth application-default print-access-token

# Check IAM roles
gcloud projects get-iam-policy terraform-test-480809 \
  --flatten="bindings[].members" \
  --filter="bindings.members:terraform-sa@terraform-test-480809.iam.gserviceaccount.com"
```

**2. State Lock Issues**  
```bash
# Force unlock if needed (use carefully)
terraform force-unlock LOCK_ID
```

**3. Backend Initialization Errors**
```bash
# Verify bucket exists
gsutil ls gs://terraform-11-12-2025-sytoss-bucket

# Check backend configuration
cat backend/stage.properties
```

### Getting Help

1. **Check Logs**: Review Terraform output for detailed error messages
2. **Validate Configuration**: Run `terraform validate` before deployment
3. **Plan First**: Always use `terraform plan` before `apply`
4. **State Inspection**: Use `terraform state` commands for debugging
