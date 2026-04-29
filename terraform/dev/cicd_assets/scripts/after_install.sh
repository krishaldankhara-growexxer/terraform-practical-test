#!/bin/bash
set -e
echo "=== AfterInstall: setting permissions ==="
chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html
