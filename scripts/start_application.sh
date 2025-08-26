#!/bin/bash
set -e

TOMCAT_DIR="/opt/tomcat"
WAR_SOURCE="/opt/tomcat/webapps/SampleMavenTomcatApp.war"
WAR_DEST="$TOMCAT_DIR/webapps/ROOT.war"

echo "[INFO] Stopping Tomcat before deploying..."
sudo systemctl stop tomcat || true

echo "[INFO] Deploying WAR..."
if [ ! -f "$WAR_SOURCE" ]; then
    echo "[ERROR] WAR file not found at $WAR_SOURCE"
    exit 1
fi

sudo cp $WAR_SOURCE $WAR_DEST
sudo chown tomcat:tomcat $WAR_DEST

echo "[INFO] Starting Tomcat..."
sudo systemctl start tomcat
