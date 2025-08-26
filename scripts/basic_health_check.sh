#!/bin/bash
set -e

APP_URL="http://localhost:8080/"   # Change if your WAR is not at ROOT
MAX_ATTEMPTS=15
SLEEP_TIME=5

echo "Starting health check for $APP_URL"

for i in $(seq 1 $MAX_ATTEMPTS); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL || true)
  echo "Attempt $i/$MAX_ATTEMPTS: Got HTTP code $HTTP_CODE"

  if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Application is healthy!"
    exit 0
  fi

  sleep $SLEEP_TIME
done

echo "❌ Server did not come up healthy after $MAX_ATTEMPTS attempts."
exit 1
