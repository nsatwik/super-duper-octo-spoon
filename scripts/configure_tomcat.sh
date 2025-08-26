#!/bin/bash
set -e

echo ">>> Configuring and starting Tomcat..."

TOMCAT_DIR="/usr/share/tomcat-codedeploy"
TOMCAT_USER="tomcat"

# Detect JAVA_HOME automatically
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo ">>> Using JAVA_HOME=$JAVA_HOME_PATH"

# Create tomcat user if not exists
if ! id -u $TOMCAT_USER >/dev/null 2>&1; then
    echo ">>> Creating tomcat user..."
    sudo useradd -m -U -d $TOMCAT_DIR -s /bin/false $TOMCAT_USER
fi

# Ensure proper permissions
sudo mkdir -p $TOMCAT_DIR
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR
sudo chmod +x $TOMCAT_DIR/bin/*.sh

# Create systemd service if not exists
SERVICE_FILE="/etc/systemd/system/tomcat.service"
if [ ! -f $SERVICE_FILE ]; then
    echo ">>> Creating Tomcat systemd service..."
    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_USER

Environment=JAVA_HOME=$JAVA_HOME_PATH
Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR

Exec
