#!/bin/bash
set -euo pipefail

#########################################################################
# Script to setup GCP project for Terraform based on stage.tfvars and stage.properties
# Usage: ./setup-stage.sh [key_file_name]
#########################################################################

TFVARS_FILE="values/stage.tfvars"
PROPERTIES_FILE="backend/stage.properties"
KEY_FILE="${1:-terraform-key}.json"

# Extract values from stage.tfvars
PROJECT_ID=$(grep -oP 'project_id\s*=\s*"\K[^"]+' "$TFVARS_FILE" || echo "")
REGION=$(grep -oP 'region\s*=\s*"\K[^"]+' "$TFVARS_FILE" | head -1 || echo "")
ENVIRONMENT=$(grep -oP 'environment\s*=\s*"\K[^"]+' "$TFVARS_FILE" || echo "")

# Extract values from stage.properties
BUCKET_NAME=$(grep -oP 'bucket\s*=\s*"\K[^"]+' "$PROPERTIES_FILE" || echo "")
BUCKET_PREFIX=$(grep -oP 'prefix\s*=\s*"\K[^"]+' "$PROPERTIES_FILE" || echo "")
BUCKET_REGION=$(grep -oP 'region\s*=\s*"\K[^"]+' "$PROPERTIES_FILE" || echo "")

# Service account configuration
SERVICE_ACCOUNT_NAME="terraform-${ENVIRONMENT}-sa"
DESCRIPTION="Service account for Terraform in ${ENVIRONMENT} environment"

#########################################################################
# Validation
#########################################################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "=== Error: Unable to extract project_id from $TFVARS_FILE ==="
    exit 1
fi

if [[ -z "$BUCKET_NAME" ]]; then
    echo "=== Error: Unable to extract bucket name from $PROPERTIES_FILE ==="
    exit 1
fi

echo "=== Configuration ==="
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Environment: $ENVIRONMENT"
echo "Bucket: $BUCKET_NAME"
echo "Service Account: $SERVICE_ACCOUNT_NAME"
echo

#########################################################################
# Set GCP project
#########################################################################
echo "=== Setting GCP project to $PROJECT_ID ==="
gcloud config set project "$PROJECT_ID" || {
    echo "=== Error: Failed to set project ==="
    exit 1
}
echo

#########################################################################
# Enable required APIs
#########################################################################
REQUIRED_APIS=(
    "iamcredentials.googleapis.com"
    "compute.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "serviceusage.googleapis.com"
    "storage.googleapis.com"
    "artifactregistry.googleapis.com"
    "secretmanager.googleapis.com"
    "sqladmin.googleapis.com"
    "monitoring.googleapis.com"
    "logging.googleapis.com"
    "cloudtrace.googleapis.com"
    "servicenetworking.googleapis.com"
)

echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
    echo "- Enabling '$api'..."
    gcloud services enable "$api" --project="$PROJECT_ID" || echo "=== Failed to enable $api (may already be enabled) ==="
done
echo "=== All required APIs were enabled ==="
echo

#########################################################################
# Create service account
#########################################################################
echo "=== Checking for service account $SERVICE_ACCOUNT_NAME... ==="
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" > /dev/null 2>&1; then
    echo "=== Service account: $SERVICE_ACCOUNT_NAME already exists. ==="
else
    echo "=== Creating service account: $SERVICE_ACCOUNT_NAME ==="
    gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
        --description="$DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_NAME"
    echo "=== Service account created ==="
fi
echo

#########################################################################
# Assign IAM roles to service account
#########################################################################
IAM_ROLES=(
    "roles/editor"
    "roles/compute.networkAdmin"
    "roles/secretmanager.secretAccessor"
    "roles/iam.serviceAccountViewer"
    "roles/logging.logWriter"
    "roles/monitoring.metricWriter"
    "roles/monitoring.viewer"
    "roles/servicenetworking.admin"
    "roles/storage.objectAdmin"
    "roles/storage.admin"
)

echo "=== Binding IAM roles to service account... ==="
for iam_role in "${IAM_ROLES[@]}"; do
    echo "- Binding role '$iam_role'..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$iam_role" || echo "=== Role binding may already exist ==="
done
echo "=== All IAM roles were assigned ==="
echo

#########################################################################
# Create service account key file
#########################################################################
echo "=== Checking if key file: $KEY_FILE already exists ==="
if [[ -f "$KEY_FILE" ]]; then
    echo "=== Key file: $KEY_FILE already exists. ==="
    echo "=== Skipping key creation. Delete the file if you want to create a new one. ==="
else
    echo "=== Creating key file: $KEY_FILE ==="
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SERVICE_ACCOUNT_EMAIL"
    echo "=== Key file created ==="
fi
echo

#########################################################################
# Create GCS bucket for Terraform state
#########################################################################
echo "=== Creating GCS bucket for Terraform state ==="
export GOOGLE_APPLICATION_CREDENTIALS="$KEY_FILE"

# Use bucket region from properties, or fallback to region from tfvars
BUCKET_LOCATION="${BUCKET_REGION:-$REGION}"

if gsutil ls -b "gs://$BUCKET_NAME" > /dev/null 2>&1; then
    echo "=== Bucket: gs://$BUCKET_NAME already exists. ==="
else
    echo "=== Creating bucket: gs://$BUCKET_NAME in location: $BUCKET_LOCATION ==="
    gcloud storage buckets create "gs://$BUCKET_NAME" \
        --location="$BUCKET_LOCATION" \
        --uniform-bucket-level-access

    echo "=== Enabling versioning on gs://$BUCKET_NAME ==="
    gsutil versioning set on "gs://$BUCKET_NAME" || echo "=== Versioning already enabled ==="

    echo "=== Bucket created successfully ==="
fi
echo

#########################################################################
# Create secrets for database credentials (optional)
#########################################################################
check_secret_exists() {
    gcloud secrets describe "$1" --project="$2" &>/dev/null
}

create_secret() {
    SECRET_NAME=$1
    PROJECT_ID=$2
    SECRET_VALUE=$3

    if check_secret_exists "$SECRET_NAME" "$PROJECT_ID"; then
        echo "=== Secret '$SECRET_NAME' already exists. ==="
    else
        echo "=== Creating secret '$SECRET_NAME'... ==="
        if gcloud secrets create "$SECRET_NAME" \
                --replication-policy="automatic" \
                --project="$PROJECT_ID"; then
            echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" \
                --data-file=- \
                --project="$PROJECT_ID"
            echo "=== Secret '$SECRET_NAME' created and value added. ==="
        else
            echo "=== Failed to create secret '$SECRET_NAME'. ==="
            exit 1
        fi
    fi
}

# Extract database credentials from tfvars if available
DB_USERNAME=$(grep -oP 'postgres_user\s*=\s*"\K[^"]+' "$TFVARS_FILE" || echo "postgres")
DB_PASSWORD=$(grep -oP 'postgres_password\s*=\s*"\K[^"]+' "$TFVARS_FILE" || echo "")

if [[ -n "$DB_PASSWORD" && "$DB_PASSWORD" != "your-secure-password-here" ]]; then
    echo "=== Creating database secrets ==="
    create_secret "db_username_${ENVIRONMENT}" "$PROJECT_ID" "$DB_USERNAME"
    create_secret "db_password_${ENVIRONMENT}" "$PROJECT_ID" "$DB_PASSWORD"
    echo
fi

#########################################################################
# Add key file to .gitignore
#########################################################################
GITIGNORE_FILE=".gitignore"
if [[ ! -f "$GITIGNORE_FILE" ]]; then
    touch "$GITIGNORE_FILE"
fi

if ! grep -Fxq "$KEY_FILE" "$GITIGNORE_FILE"; then
    echo "$KEY_FILE" >> "$GITIGNORE_FILE"
    echo "Added $KEY_FILE to $GITIGNORE_FILE"
fi
echo

#########################################################################
# Summary
#########################################################################
echo "=== Setup Summary ==="
echo "✓ APIs enabled"
echo "✓ Service account created: $SERVICE_ACCOUNT_NAME"
echo "✓ IAM roles assigned"
echo "✓ Key file: $KEY_FILE"
echo "✓ Bucket created: gs://$BUCKET_NAME"
echo
echo "=== Next steps ==="
echo "1. Set credentials: export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE"
echo "2. Initialize Terraform: terraform init -backend-config=$PROPERTIES_FILE"
echo "3. Apply Terraform: terraform apply -var-file=$TFVARS_FILE"
echo

