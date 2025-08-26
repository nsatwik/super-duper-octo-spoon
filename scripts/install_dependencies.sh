#!/bin/bash
set -e

echo ">>> Installing dependencies..."

# Update packages
sudo apt-get update -y

# Install Java if not present
if ! command -v java &> /dev/null
then
    echo ">>> Installing OpenJDK..."
    sudo apt-get install -y openjdk-17-jdk
fi

# Install Tomcat if not present
if [ ! -d "/usr/share/tomcat-codedeploy" ]; then
    echo ">>> Installing Tomcat..."
    sudo apt-get install -y tomcat9
    sudo systemctl enable tomcat9
    sudo systemctl stop tomcat9
    sudo mv /var/lib/tomcat9 /usr/share/tomcat-codedeploy
fi

echo ">>> Dependencies installed successfully."
