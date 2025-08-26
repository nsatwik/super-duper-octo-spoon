#!/bin/bash
set -e

TOMCAT_DIR="/opt/tomcat"
WAR_FILE="$TOMCAT_DIR/webapps/SampleMavenTomcatApp.war"

echo "[INFO] Stopping Tomcat before deploying..."
sudo systemctl stop tomcat || true

# Ensure WAR exists
if [ ! -f "$WAR_FILE" ]; then
    echo "[ERROR] WAR file not found at $WAR_FILE"
    exit 1
fi

# Set proper ownership
sudo chown tomcat:tomcat "$WAR_FILE"

echo "[INFO] Starting Tomcat..."
sudo systemctl start tomcat

echo "[INFO] WAR deployed and Tomcat started successfully."
