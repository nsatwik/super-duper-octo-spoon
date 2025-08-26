#!/bin/bash
set -e

# Change this to your actual EC2 private/public IP or use localhost if Tomcat is bound to 0.0.0.0
APP_IP="13.232.44.136"
APP_PORT="8080"
APP_CONTEXT="SampleMavenTomcatApp"   # Your WAR name = context path

URL="http://$APP_IP:$APP_PORT/$APP_CONTEXT/"

echo "Checking application health at $URL"

# Retry for up to 2 minutes (24 attempts with 5s gap)
for i in {1..24}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || true)

    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "Application is UP! HTTP $HTTP_CODE"
        exit 0
    else
        echo "Attempt $i: App not ready yet (HTTP $HTTP_CODE). Retrying in 5s..."
        sleep 5
    fi
done

echo "Server did not become healthy after 2 minutes. Failing deployment."
exit 1
