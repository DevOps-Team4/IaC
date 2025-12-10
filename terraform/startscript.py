import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def run_command(cmd, check=True, capture_output=False, ignore_errors=False):
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            check=check,
            capture_output=capture_output,
            text=True
        )
        if capture_output:
            return result.stdout.strip()
        return result
    except subprocess.CalledProcessError as e:
        if ignore_errors:
            print(f"=== {cmd} failed (ignored) ===")
            return None
        print(f"=== Error running command: {cmd} ===")
        print(f"Error: {e}")
        sys.exit(1)


def get_json_value(config_path, key):
    with open(config_path, 'r') as f:
        content = f.read()
    match = re.search(rf'"{key}":\s*"([^"]+)"', content)
    if match:
        return match.group(1)
    return None


def check_secret_exists(secret_name, project_id):
    cmd = f'gcloud secrets describe "{secret_name}" --project="{project_id}"'
    result = run_command(cmd, check=False, capture_output=True)
    return result is not None and result != ""


def create_secret(secret_name, project_id, secret_value):
    if check_secret_exists(secret_name, project_id):
        print(f"=== Secret '{secret_name}' already exists. ===")
    else:
        print(f"Creating secret '{secret_name}'...")
        cmd = f'gcloud secrets create "{secret_name}" --replication-policy="automatic" --project="{project_id}"'
        if run_command(cmd, check=False):
            try:
                process = subprocess.Popen(
                    ['gcloud', 'secrets', 'versions', 'add', secret_name,
                     '--data-file=-', f'--project={project_id}'],
                    stdin=subprocess.PIPE,
                    text=True
                )
                process.communicate(input=secret_value)
                if process.returncode == 0:
                    print(f"=== Secret '{secret_name}' created and value added. ===")
                else:
                    print(f"=== Failed to add secret value for '{secret_name}'. ===")
                    sys.exit(1)
            except Exception as e:
                print(f"=== Error adding secret value: {e} ===")
                sys.exit(1)
        else:
            print(f"=== Failed to create secret '{secret_name}'. ===")
            sys.exit(1)


def main():
    if len(sys.argv) < 3:
        print("Usage: python startscript.py <config_path> <key_file>")
        sys.exit(1)

    CONFIG_PATH = sys.argv[1]
    KEY_FILE = sys.argv[2] if not sys.argv[2].endswith('.json') else sys.argv[2]
    if not KEY_FILE.endswith('.json'):
        KEY_FILE = f"{KEY_FILE}.json"
    
    ENV_FILE = "gcp_cloud_env.sh"
    SERVICE_ACCOUNT_NAME = get_json_value(CONFIG_PATH, "terraform_username")
    PROJECT_ID = run_command('gcloud config get-value project', capture_output=True)
    DESCRIPTION = "The service account for the Terraform"
    BUCKET_LOCATION = get_json_value(CONFIG_PATH, "state_bucket_location_gcp")
    DB_USERNAME = "postgres"
    DB_PASS = "postgres"
    SECRET_NAME_DB_USERNAME = "db_username"
    SECRET_NAME_DB_PASS = "db_pass"
    NEW_BUCKET_NAME = ""

    if not PROJECT_ID:
        print("=== Error: Unable to retrieve GCP project ID. Use 'gcloud config set project YOUR_PROJECT_ID' ===")
        sys.exit(1)
    else:
        print(f"=== Project's ID: '{PROJECT_ID}' ===")
        print()

    REQUIRED_APIS = [
        "iamcredentials.googleapis.com",
        "compute.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "serviceusage.googleapis.com",
        "storage.googleapis.com",
        "artifactregistry.googleapis.com",
        "secretmanager.googleapis.com",
        "sqladmin.googleapis.com",
        "monitoring.googleapis.com",
        "logging.googleapis.com",
        "cloudtrace.googleapis.com",
        "servicenetworking.googleapis.com",
    ]

    print(f"=== Enabling required APIs for project: {PROJECT_ID} ===")
    for api in REQUIRED_APIS:
        print(f"- Enabling '{api}'...")
        run_command(
            f'gcloud services enable "{api}" --project="{PROJECT_ID}"',
            ignore_errors=True
        )
    print("=== All required APIs were enabled ===")
    print()

    print(f"=== Checking for service account {SERVICE_ACCOUNT_NAME}... ===")
    service_account_email = f"{SERVICE_ACCOUNT_NAME}@{PROJECT_ID}.iam.gserviceaccount.com"
    cmd = f'gcloud iam service-accounts describe "{service_account_email}"'
    result = run_command(cmd, check=False, capture_output=True)
    
    if result:
        print(f"=== Service account: {SERVICE_ACCOUNT_NAME} already exists. ===")
    else:
        print(f"=== Creating service account: {SERVICE_ACCOUNT_NAME} ===")
        run_command(
            f'gcloud iam service-accounts create "{SERVICE_ACCOUNT_NAME}" '
            f'--description="{DESCRIPTION}" '
            f'--display-name="{SERVICE_ACCOUNT_NAME}"'
        )
    print()

    IAM_ROLES = [
        "editor",
        "compute.networkAdmin",
        "secretmanager.secretAccessor",
        "iam.serviceAccountViewer",
        "logging.logWriter",
        "monitoring.metricWriter",
        "monitoring.viewer",
        "iam.serviceAccountViewer",
        "servicenetworking.admin",
        "compute.networkAdmin",
        "storage.objectAdmin",
    ]

    for iam_role in IAM_ROLES:
        print(f"=== Binding role '{iam_role}' to service account... ===")
        run_command(
            f'gcloud projects add-iam-policy-binding "{PROJECT_ID}" '
            f'--member="serviceAccount:{service_account_email}" '
            f'--role="roles/{iam_role}"',
            ignore_errors=True
        )
        print()
    print("=== All iam roles were enabled ===")
    print()

    print(f"=== Checking if key file: {KEY_FILE} already exists ===")
    if os.path.exists(KEY_FILE):
        print(f"=== Key file: {KEY_FILE} already exists. ===")
        print()
    else:
        print(f"=== Creating key file: {KEY_FILE} ===")
        run_command(
            f'gcloud iam service-accounts keys create "{KEY_FILE}" '
            f'--iam-account="{service_account_email}"'
        )
        print()
    print()

    create_secret(SECRET_NAME_DB_USERNAME, PROJECT_ID, DB_USERNAME)
    create_secret(SECRET_NAME_DB_PASS, PROJECT_ID, DB_PASS)
    print()

    run_command(
        f'gcloud projects add-iam-policy-binding "{PROJECT_ID}" '
        f'--member="serviceAccount:{service_account_email}" '
        f'--role="roles/secretmanager.secretAccessor"'
    )

    print("=== Creating the bucket ===")
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = KEY_FILE
    
    if os.path.exists(ENV_FILE):
        with open(ENV_FILE, 'r') as f:
            content = f.read()
            match = re.search(r'export TF_VAR_cloud_bucket=(\S+)', content)
            if match:
                existing_bucket = match.group(1)
                cmd = f'gsutil ls -b "gs://{existing_bucket}"'
                result = run_command(cmd, check=False, capture_output=True)
                if result:
                    print(f"=== The bucket: gs://{existing_bucket} already exists. ===")
                    NEW_BUCKET_NAME = existing_bucket

    if not NEW_BUCKET_NAME:
        BUCKET_NAME = get_json_value(CONFIG_PATH, "bucket_state_name")
        timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
        NEW_BUCKET_NAME = f"{BUCKET_NAME}-{timestamp}"

        print(f"=== Creating bucket: gs://{NEW_BUCKET_NAME} ===")
        run_command(
            f'gcloud storage buckets create "gs://{NEW_BUCKET_NAME}" '
            f'--location="{BUCKET_LOCATION}" '
            f'--uniform-bucket-level-access'
        )

        print(f"=== Enabling versioning on gs://{NEW_BUCKET_NAME} ===")
        run_command(
            f'gsutil versioning set on "gs://{NEW_BUCKET_NAME}"',
            ignore_errors=True
        )

        with open(ENV_FILE, 'w') as f:
            f.write(f"export TF_VAR_cloud_bucket={NEW_BUCKET_NAME}\n")

        GITIGNORE_FILE = ".gitignore"
        if not os.path.exists(GITIGNORE_FILE):
            Path(GITIGNORE_FILE).touch()
        
        with open(GITIGNORE_FILE, 'r') as f:
            gitignore_content = f.read()
        
        if ENV_FILE not in gitignore_content:
            with open(GITIGNORE_FILE, 'a') as f:
                f.write(f"{ENV_FILE}\n")
            print(f"Added {ENV_FILE} to {GITIGNORE_FILE}")
    print()

    def start_terraform_and_apply(bucket_name):
        print("=== Initializing Terraform ===")
        run_command(
            f'terraform init -backend-config="bucket={bucket_name}" -reconfigure'
        )
        print("=== Terraform initialized ===")
        print("=== Applying Terraform ===")
        run_command('terraform apply -auto-approve')
        print("=== Terraform apply completed ===")

    start_terraform_and_apply(NEW_BUCKET_NAME)


if __name__ == "__main__":
    main()

