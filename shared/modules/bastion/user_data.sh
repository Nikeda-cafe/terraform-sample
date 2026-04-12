#!/bin/bash
set -e

# Update system packages
yum update -y

# Install MariaDB client (MySQL compatible)
yum install -y mariadb105

# Ensure SSM agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Log initialization completion
echo "Bastion host initialized at $(date)" >> /var/log/user-data.log
