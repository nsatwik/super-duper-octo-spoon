#!/bin/bash
set -e

echo ">>> Configuring and starting Tomcat..."

TOMCAT_DIR="/usr/share/tomcat-codedeploy"
TOMCAT_USER="tomcat"

# Create tomcat user if not exists
if ! id -u $TOMCAT_USER >/dev/null 2>&1; then
    echo ">>> Creating tomcat user..."
    sudo useradd -m -U -d $TOMCAT_DIR -s /bin/false $TOMCAT_USER
fi

# Ensure proper permissions
sudo mkdir -p $TOMCAT_DIR
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR

# Create systemd service if not exists
if [ ! -f /etc/systemd/system/tomcat.service ]; then
    echo ">>> Creating Tomcat systemd service..."
    cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_USER

Environment=JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR

ExecStart=$TOMCAT_DIR/bin/startup.sh
ExecStop=$TOMCAT_DIR/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
fi

# Reload systemd and start Tomcat
echo ">>> Reloading systemd and starting Tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl restart tomcat

echo ">>> Tomcat confi
