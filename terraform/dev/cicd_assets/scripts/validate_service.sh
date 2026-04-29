#!/bin/bash
set -e
echo "=== ValidateService: checking nginx ==="
curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep 200
echo "Validation passed — nginx is serving HTTP 200"
