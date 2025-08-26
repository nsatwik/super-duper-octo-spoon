#!/bin/bash
set -e

echo ">>> Installing dependencies on Amazon Linux..."

# Update packages
sudo yum update -y

# Install Java (Amazon Corretto 17)
if ! command -v java &> /dev/null; then
    echo ">>> Installing Amazon Corretto 17..."
    sudo amazon-linux-extras enable corretto17
    sudo yum install -y java-17-amazon-corretto wget tar
fi

# Install Tomcat 9.0.108 manually if not already installed
TOMCAT_VERSION=9.0.108
TOMCAT_DIR=/usr/share/tomcat-codedeploy

if [ ! -d "$TOMCAT_DIR" ]; then
    echo ">>> Installing Tomcat $TOMCAT_VERSION..."
    cd /tmp
    wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O tomcat9.tar.gz
    sudo mkdir -p $TOMCAT_DIR
    sudo tar xzvf tomcat9.tar.gz -C $TOMCAT_DIR --strip-components=1

    # Create Tomcat user if not exists
    if ! id "tomcat" &>/dev/null; then
        sudo useradd -r -m -U -d $TOMCAT_DIR -s /bin/false tomcat
    fi
    sudo chown -R tomcat:tomcat $TOMCAT_DIR

    # Setup systemd service
    echo ">>> Creating Tomcat 9 systemd service..."
    sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOL
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"
Environment="CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid"
Environment="CATALINA_HOME=$TOMCAT_DIR"
Environment="CATALINA_BASE=$TOMCAT_DIR"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

ExecStart=$TOMCAT_DIR/bin/startup.sh
ExecStop=$TOMCAT_DIR/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and enable service
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable tomcat
    sudo systemctl stop tomcat
fi

echo ">>> Dependencies installed successfully."


#!/bin/bash
set -e

echo ">>> Updating system packages..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y
else
    sudo yum update -y
fi

echo ">>> Installing Java 21 (Amazon Corretto)..."
if command -v java >/dev/null 2>&1; then
    echo ">>> Java already installed"
else
    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y java-21-amazon-corretto-headless
    else
        sudo yum install -y java-21-amazon-corretto-headless
    fi
fi

JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo ">>> JAVA_HOME=$JAVA_HOME_PATH"

echo ">>> Installing Tomcat 9.0.108..."
TOMCAT_DIR="/opt/tomcat"
if [ ! -d "$TOMCAT_DIR" ]; then
    sudo mkdir -p $TOMCAT_DIR
    cd /tmp
    curl -fSL https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.108/bin/apache-tomcat-9.0.108.tar.gz -o apache-tomcat-9.0.108.tar.gz
    sudo tar xzf apache-tomcat-9.0.108.tar.gz -C $TOMCAT_DIR --strip-components=1
    rm -f apache-tomcat-9.0.108.tar.gz
fi

echo ">>> Creating tomcat user..."
if ! id -u tomcat >/dev/null 2>&1; then
    sudo useradd -m -U -d $TOMCAT_DIR -s /bin/false tomcat
fi

echo ">>> Setting permissions..."
sudo chown -R tomcat:tomcat $TOMCAT_DIR
sudo chmod +x $TOMCAT_DIR/bin/*.sh

