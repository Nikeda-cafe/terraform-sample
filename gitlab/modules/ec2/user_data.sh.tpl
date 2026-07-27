#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "GitLab user-data started at $(date -Is)"

apt-get update
apt-get install -y curl ca-certificates openssh-server tzdata perl wget

# Session Manager (no inbound SSH from the internet)
mkdir -p /tmp/ssm
wget -q "https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/debian_amd64/amazon-ssm-agent.deb" \
  -O /tmp/ssm/amazon-ssm-agent.deb
dpkg -i /tmp/ssm/amazon-ssm-agent.deb || apt-get install -f -y
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
EXTERNAL_URL="${external_url}" apt-get install -y gitlab-ce

echo "GitLab user-data finished at $(date -Is)"
