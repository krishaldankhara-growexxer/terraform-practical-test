#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

yum update -y
amazon-linux-extras install nginx1 -y
yum install -y git unzip ruby wget

cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
./install auto || true
systemctl enable codedeploy-agent || true
systemctl start codedeploy-agent  || true

mkdir -p /usr/share/nginx/html
cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Terraform Practical Test</title>
<style>body{font-family:sans-serif;text-align:center;padding-top:80px;background:#0a3d62;color:#fff}h1{font-size:42px}</style>
</head>
<body>
  <h1>${welcome_message}</h1>
  <p>Served by $(hostname) - $(date -u)</p>
</body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
