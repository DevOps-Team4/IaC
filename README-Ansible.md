# Complete Setup Instructions

## Prerequisites

1. **WSL (Windows Subsystem for Linux)** - Ubuntu 24.04 or similar
2. **Terraform** installed and configured
3. **Ansible** installed
4. **GCP credentials** - Ensure you have:
   - GCP service account key file: `terraform/terraform-sa-key.json`
   - GCP project ID configured
   - Backend bucket access configured

## Step 1: Prepare Your Environment

### 1.1 Set up GitHub Container Registry credentials (if needed)
```bash
export GHCR_USER="your-github-username"
export GHCR_TOKEN="your-github-personal-access-token"
```

### 1.2 Navigate to the project directory
```bash
cd ~/my-ansible-project/IaC
# or wherever your project is located
```

## Step 2: Set up SSH Configuration

### 2.1 Copy the provisioning key to your ~/.ssh directory
```bash
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy the key from terraform directory
cp ~/my-ansible-project/IaC/terraform/.ssh/provisioning_key ~/.ssh/provisioning_key
chmod 600 ~/.ssh/provisioning_key
```

### 2.2 Update ~/.ssh/config file
Get the bastion IP from terraform outputs, then create/update `~/.ssh/config`:

```bash
nano ~/.ssh/config
# or
vim ~/.ssh/config
```

Add/update the following content (replace `BASTION_IP` with your IP):

```
Host bastion
  HostName BASTION_IP
  User provisioning
  IdentityFile ~/.ssh/provisioning_key
  IdentitiesOnly yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host 10.1.*
  User provisioning
  IdentityFile ~/.ssh/provisioning_key
  IdentitiesOnly yes
  ProxyJump bastion
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

**Important**: Replace `BASTION_IP` with your bastion IP!

### 2.3 Set correct permissions on SSH config
```bash
chmod 600 ~/.ssh/config
```

### 2.4 Update Ansible configuration with absolute SSH config path

**Important**: The `ansible.cfg` file contains an absolute path to the SSH config file. You must update it with your own home directory path.

Open `ansible/ansible.cfg` and update line 9 to use your home directory:

```bash
# Find your home directory first
echo $HOME

# Then edit ansible.cfg
nano ansible/ansible.cfg
# or
vim ansible/ansible.cfg
```

Change this line:
```
ssh_args = -F /home/marta/.ssh/config -o ControlMaster=auto ...
```

To use **your** username instead of `marta`. For example, if your username is `john`:
```
ssh_args = -F /home/john/.ssh/config -o ControlMaster=auto ...
```

## Step 3: Verify SSH Connection

### 3.1 Test connection to bastion
```bash
ssh bastion
# You should be able to connect without password
```

### 3.2 Test connection to a private host (via bastion)
```bash
# Get the private IP from terraform output or inventory.ini
ssh provisioning@10.1.1.2
# This should work through ProxyJump
```

## Step 4: Verify Inventory File

### 4.1 Check the generated inventory
```bash
cd ../ansible
cat inventory.ini
```

The file should have:
- Correct IP addresses for all hosts
- `ansible_ssh_private_key_file` pointing to the path of the key like this (e.g., `~/.ssh/provisioning_key`)
- All required variables

**Note**: If the inventory has an incorrect key path, you may need to update it manually or check that terraform generated it correctly.

## Step 5: Run Ansible Playbooks

### 5.1 Navigate to Ansible directory
```bash
cd ansible
```

### 5.2 Run the playbook
```bash
ansible-playbook -i inventory.ini playbooks/site.yml \
  --vault-password-file=.vault_pass \
  -v
```

If you need more verbose output:
```bash
ansible-playbook -i inventory.ini playbooks/site.yml \
  --vault-password-file=.vault_pass \
  -vvv
```

## Troubleshooting

### SSH Config Not Found Error
If you get "Can't open user config file ~/.ssh/config":
1. Verify the file exists: `ls -la ~/.ssh/config`
2. **Update `ansible.cfg` with your absolute path** (see Step 3.4 above):
   ```bash
   # In ansible/ansible.cfg, change line 9 to use your home directory:
   ssh_args = -F /home/YOUR_USERNAME/.ssh/config -o ControlMaster=auto ...
   ```
   Replace `YOUR_USERNAME` with your actual username (you can find it with `echo $USER` or `whoami`)

### Key Permission Denied
```bash
chmod 600 ~/.ssh/provisioning_key
chmod 600 ~/.ssh/config
```

### Cannot Connect to Private Hosts
1. Verify bastion connection works: `ssh bastion`
2. Check that ProxyJump is configured in `~/.ssh/config`
3. Verify private IPs in inventory.ini match the network configuration

### Inventory Has Wrong Key Path
The inventory file uses an absolute path from Terraform. If you're running from WSL, make sure:
- The path in inventory.ini is accessible from WSL
- Or copy the key to ~/.ssh and update inventory.ini to use `~/.ssh/provisioning_key`

## After Terraform Destroy

If you run `terraform destroy` and then `terraform apply` again:
1. **New SSH key will be generated** - Copy it again: `cp terraform/.ssh/provisioning_key ~/.ssh/provisioning_key`
2. **Bastion IP will change** - Update `~/.ssh/config` with the new IP
3. **Inventory will be regenerated** - It will have the correct new IPs automatically

