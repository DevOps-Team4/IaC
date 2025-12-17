# Bastion
[bastion-host]
bastion ansible_host=${bastion_ip}
# Frontend
[web-server]
frontend ansible_host=${frontend_private_ip}

# Backend
[app-server]
backend ansible_host=${backend_private_ip}

# Database
[postgres-db]
database ansible_host=${db_ip}

# Global variables
[all:vars]
ansible_user=provisioning
ansible_ssh_private_key_file=~/.ssh/provisioning_key
ansible_ssh_common_args='-F ~/.ssh/config'
postgres_user=${postgres_user}
postgres_password=${postgres_password}
postgres_db=${postgres_db}