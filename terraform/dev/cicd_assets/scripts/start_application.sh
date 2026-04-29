#!/bin/bash
set -e
echo "=== ApplicationStart: starting nginx ==="
systemctl enable nginx
systemctl start  nginx
