#!/bin/bash
set -e

BASTION_IP=$1
SSH_KEY=$2
ANSIBLE_DIR=$3

echo "Waiting for instances to be ready..."
sleep 90

cd "$ANSIBLE_DIR"

MAX_RETRIES=12
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if ssh -o StrictHostKeyChecking=no \
         -o ConnectTimeout=10 \
         -o BatchMode=yes \
         -i "$SSH_KEY" \
         "provisioning@$BASTION_IP" \
         "echo 'Bastion SSH ready'" 2>/dev/null; then
    echo "Bastion is accessible"
    break
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "Waiting for bastion SSH (attempt $RETRY_COUNT/$MAX_RETRIES)..."
  sleep 10
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "Failed to connect to bastion after $MAX_RETRIES attempts"
  exit 1
fi

echo "Checking if instances are fully initialized..."
sleep 15

echo "Running Ansible playbook..."
ansible-playbook -i inventory.ini playbooks/site.yml --vault-password-file=.vault_pass -v

echo "Cleaning up provisioning user..."
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no marta@$BASTION_IP \
  "sudo userdel -r provisioning 2>/dev/null || true"

echo "Ansible provisioning completed successfully!"
echo "Temporary provisioning user removed"



# Automated start of Ansible playbooks after infrastructure will be created
resource "null_resource" "run_ansible" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.provisioning_private_key,
    module.instances,
    module.db
  ]

  # Triggers restarting if inventory or instances will be changed
  triggers = {
    inventory_changed = local_file.ansible_inventory.content
    instances_changed = jsonencode(module.instances.instance_ips)
    db_changed        = module.db.private_ip
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/run_ansible.sh ${module.instances.bastion_ip} ${local_file.provisioning_private_key.filename} ${path.module}/../ansible"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_FORCE_COLOR       = "True"
    }
  }

  # After destroy of infrastructure deleting temporary key
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.root}/.ssh/provisioning_key*"
  }
}