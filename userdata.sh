#!/bin/bash
set -euo pipefail
exec > /var/log/userdata.log 2>&1

echo "=== BOOT START $(date) ==="

DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /etc/nginx/sites-available/default << 'NGINXEOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINXEOF

cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
  <head><title>Terraform Modules</title></head>
  <body>
    <h1>Three-Tier Infrastructure via Terraform Modules</h1>
    <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
    <p><strong>Private IP:</strong> $PRIVATE_IP</p>
    <p><strong>AZ:</strong> $AZ</p>
    <p><strong>Deployed at:</strong> $(date)</p>
    <p><em>Managed by Terraform — no bash scripts</em></p>
  </body>
</html>
EOF

nginx -t
systemctl restart nginx
systemctl enable nginx

echo "=== BOOT END $(date) ==="
