# Bastion
[bastion]
${bastion_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path}

# Frontend (через Bastion)
[frontend]
${frontend_private_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path} ansible_ssh_common_args='-o ProxyJump=${ssh_user}@${bastion_ip}'

# Backend (через Bastion)
[backend]
${backend_private_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path} ansible_ssh_common_args='-o ProxyJump=${ssh_user}@${bastion_ip}'

# Database (напряму в приватній мережі)
[database]
${db_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path}

[all:vars]
postgres_user=${postgres_user}
postgres_password=${postgres_password}
postgres_db=${postgres_db}
postgres_host=${postgres_host}
