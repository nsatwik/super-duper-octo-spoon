#!/bin/bash
set -e

echo ">>> Updating system packages..."
if command -v dnf &>/dev/null; then
    sudo dnf update -y
else
    sudo yum update -y
fi

echo ">>> Installing Java (OpenJDK 21 if available, fallback to 17)..."
JAVA_HOME_PATH=""
if command -v dnf &>/dev/null; then
    # Amazon Linux 2023
    if sudo dnf list java-21-amazon-corretto-headless &>/dev/null; then
        sudo dnf install -y java-21-amazon-corretto-headless
        JAVA_HOME_PATH="/usr/lib/jvm/java-21-amazon-corretto"
    else
        sudo dnf install -y java-17-amazon-corretto-headless
        JAVA_HOME_PATH="/usr/lib/jvm/java-17-amazon-corretto"
    fi
else
    # Amazon Linux 2
    if command -v amazon-linux-extras &>/dev/null; then
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

echo "Java installed. JAVA_HOME: $JAVA_HOME_PATH"

echo ">>> Installing Tomcat 9.0.108..."
TOMCAT_VERSION=9.0.108
INSTALL_DIR="/usr/share/tomcat9-codedeploy"

# Stop and remove any previous instance
sudo systemctl stop tomcat-codedeploy || true
sudo rm -rf $INSTALL_DIR
sudo mkdir -p $INSTALL_DIR

cd /tmp
curl -fSL "https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -o tomcat.tar.gz
sudo tar xzf tomcat.tar.gz -C $INSTALL_DIR --strip-components=1
rm -f tomcat.tar.gz

sudo chmod +x $INSTALL_DIR/bin/*.sh

echo ">>> Creating Tomcat systemd service..."
sudo tee /etc/systemd/system/tomcat-codedeploy.service > /dev/null <<EOL
[Unit]
Description=Apache Tomcat 9 (CodeDeploy)
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
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

echo ">>> Reloading systemd and starting Tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat-codedeploy
sudo systemctl restart tomcat-codedeploy

echo ">>> Install dependencies complete! Tomcat 9.0.108 is installed and running under $INSTALL_DIR."
