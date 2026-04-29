#!/bin/bash
set -e
echo "=== BeforeInstall: stopping nginx ==="
systemctl stop nginx || true
mkdir -p /var/www/html
