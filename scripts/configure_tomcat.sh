#!/bin/bash
set -e

echo ">>> Configuring Tomcat deployment..."

TOMCAT_HOME="/usr/share/tomcat9-codedeploy"
DEPLOY_DIR="$TOMCAT_HOME/webapps"

# Create deploy directory if not exists
sudo mkdir -p $DEPLOY_DIR
sudo chown -R root:root $DEPLOY_DIR

echo ">>> Stopping Tomcat before deployment..."
sudo systemctl stop tomcat9 || true

echo ">>> Cleaning old deployment..."
sudo rm -rf $DEPLOY_DIR/ROOT*

echo ">>> Copying new WAR file..."
sudo cp /opt/codedeploy-agent/deployment-root/*/*/deployment-archive/target/*.war $DEPLOY_DIR/ROOT.war

echo ">>> Starting Tomcat..."
sudo systemctl start tomcat9

echo ">>> Tomcat deployment finished!"
