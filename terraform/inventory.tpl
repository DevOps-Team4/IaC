# Bastion
[bastion-host]
bastion ansible_host=${bastion_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path}
# Frontend
[web-server]
frontend ansible_host=${frontend_private_ip} ansible_user=${ssh_user}

# Backend
[app-server]
backend ansible_host=${backend_private_ip} ansible_user=${ssh_user}

# Database
[postgres-db]
database ansible_host=${db_ip} ansible_user=${ssh_user}

# Internal servers group
[internal:children]
web-server
app-server
postgres-db

# Internal servers proxy configuration
[internal:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_user}@${bastion_ip} -i ${ssh_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"'
ansible_ssh_private_key_file=${ssh_key_path}

# Global variables
[all:vars]
postgres_user=${postgres_user}
postgres_password=${postgres_password}
postgres_db=${postgres_db}
postgres_host=${postgres_host}