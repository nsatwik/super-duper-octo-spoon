#!/bin/bash
set -e

echo ">>> Running health check..."

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://3.109.157.198:8080/SampleMavenTomcatApp/ || true)

if [ "$STATUS" -eq 200 ]; then
    echo ">>> Health check passed. App is running."
    exit 0
else
    echo ">>> Health check failed. HTTP Status: $STATUS"
    exit 1
fi
