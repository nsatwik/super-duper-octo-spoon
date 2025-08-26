#!/bin/bash
set -e

TOMCAT_HOST="3.109.157.198"
TOMCAT_PORT=8080
URL="http://$TOMCAT_HOST:$TOMCAT_PORT/"

echo ">>> Running health check..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo ">>> Health check passed. HTTP Status: $HTTP_STATUS"
else
    echo ">>> Health check failed. HTTP Status: $HTTP_STATUS"
    exit 1
fi
