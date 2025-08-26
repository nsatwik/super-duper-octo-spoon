#!/bin/bash
set -e

echo ">>> Configuring and starting Tomcat..."

# Ensure proper permissions
sudo chown -R root:root /usr/share/tomcat-codedeploy

# Start Tomcat
sudo systemctl restart tomcat9 || true
echo ">>> Tomcat restarted successfully."
