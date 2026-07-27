#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "GitLab Runner user-data started at $(date -Is)"

apt-get update
apt-get install -y curl ca-certificates openssh-server tzdata perl wget awscli docker.io

mkdir -p /tmp/ssm
wget -q "https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/debian_amd64/amazon-ssm-agent.deb" \
  -O /tmp/ssm/amazon-ssm-agent.deb
dpkg -i /tmp/ssm/amazon-ssm-agent.deb || apt-get install -f -y
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

systemctl enable docker
systemctl start docker

curl -fsSL "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install -y gitlab-runner
usermod -aG docker gitlab-runner

cat <<'REGISTER_SCRIPT' > /usr/local/bin/gitlab-runner-register.sh
#!/bin/bash
set -euo pipefail

REGION="${region}"
SSM_PARAM="${runner_token_ssm_parameter}"
GITLAB_URL="${gitlab_url}"
RUNNER_DESC="${runner_description}"
RUNNER_TAGS="${runner_tag_list}"
DOCKER_IMAGE="${docker_default_image}"

if [[ -f /etc/gitlab-runner/config.toml ]] && grep -q '^\s*\[\[runners\]\]' /etc/gitlab-runner/config.toml; then
  echo "GitLab Runner already registered"
  exit 0
fi

TOKEN="$(aws ssm get-parameter \
  --name "$SSM_PARAM" \
  --with-decryption \
  --region "$REGION" \
  --query 'Parameter.Value' \
  --output text 2>/dev/null || true)"

if [[ -z "$TOKEN" || "$TOKEN" == "unset" || "$TOKEN" == "None" ]]; then
  echo "Runner token not configured in SSM ($SSM_PARAM). Skipping registration."
  exit 0
fi

gitlab-runner register --non-interactive \
  --url "$GITLAB_URL" \
  --token "$TOKEN" \
  --executor "docker" \
  --docker-image "$DOCKER_IMAGE" \
  --description "$RUNNER_DESC" \
  --tag-list "$RUNNER_TAGS" \
  --run-untagged="true" \
  --locked="false"

systemctl restart gitlab-runner
echo "GitLab Runner registered successfully"
REGISTER_SCRIPT

chmod +x /usr/local/bin/gitlab-runner-register.sh

cat <<'UNIT' > /etc/systemd/system/gitlab-runner-register.service
[Unit]
Description=Register GitLab Runner using SSM token
After=network-online.target docker.service gitlab-runner.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/gitlab-runner-register.sh

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable gitlab-runner-register.service
systemctl start gitlab-runner-register.service

echo "GitLab Runner user-data finished at $(date -Is)"
