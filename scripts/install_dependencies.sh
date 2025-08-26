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

