#!/bin/bash
set -e

echo ">>> Updating system packages..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y
else
    sudo yum update -y
fi

echo ">>> Installing Java (OpenJDK 21 if available, fallback to 17)..."
JAVA_HOME_PATH=""
if command -v dnf >/dev/null 2>&1; then
    # Amazon Linux 2023
    if sudo dnf list java-21-amazon-corretto-headless >/dev/null 2>&1; then
        sudo dnf install -y java-21-amazon-corretto-headless
        JAVA_HOME_PATH="/usr/lib/jvm/java-21-amazon-corretto"
    else
        sudo dnf install -y java-17-amazon-corretto-headless
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-amazon-corretto"
    fi
else
    # Amazon Linux 2
    if command -v amazon-linux-extras >/dev/null 2>&1; then
        sudo amazon-linux-extras enable corretto21 || true
        if sudo yum install -y java-21-amazon-corretto-headless; then
            JAVA_HOME_PATH="/usr/lib/jvm/java-21-amazon-corretto"
        else
            sudo yum install -y java-17-amazon-corretto-headless
            JAVA_HOME_PATH="/usr/lib/jvm/java-17-amazon-corretto"
        fi
    else
        sudo yum install -y java-17-amazon-corretto-headless
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-amazon-corretto"
    fi
fi

echo ">>> Installing Tomcat..."
TOMCAT_VERSION=9.0.93
INSTALL_DIR="/usr/share/tomcat9-codedeploy"
sudo mkdir -p $INSTALL_DIR

cd /tmp
curl -fSL https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -o apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C $INSTALL_DIR --strip-components=1
rm -f apache-tomcat-$TOMCAT_VERSION.tar.gz

sudo chmod +x $INSTALL_DIR/bin/*.sh

echo ">>> Creating Tomcat systemd service..."
sudo tee /etc/systemd/system/tomcat9.service > /dev/null <<EOL
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=root
Group=root
Environment=JAVA_HOME=$JAVA_HOME_PATH
Environment=CATALINA_HOME=$INSTALL_DIR
Environment=CATALINA_BASE=$INSTALL_DIR
ExecStart=$INSTALL_DIR/bin/startup.sh
ExecStop=$INSTALL_DIR/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOL

echo ">>> Reloading systemd and enabling Tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat9
sudo systemctl restart tomcat9

echo ">>> Installation complete!"
