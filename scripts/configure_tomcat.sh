#!/bin/bash
set -e

TOMCAT_DIR="/opt/tomcat"
SERVICE_FILE="/etc/systemd/system/tomcat.service"
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))

echo ">>> Configuring Tomcat systemd service..."
if [ ! -f "$SERVICE_FILE" ]; then
    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=JAVA_HOME=$JAVA_HOME_PATH
Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR

ExecStart=$TOMCAT_DIR/bin/catalina.sh start
ExecStop=$TOMCAT_DIR/bin/catalina.sh stop

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
fi

echo ">>> Reloading systemd and starting Tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl restart tomcat
