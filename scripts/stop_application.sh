#!/bin/bash
set -e

echo ">>> Stopping Tomcat service..."

if systemctl is-active --quiet tomcat; then
    sudo systemctl stop tomcat
    echo ">>> Tomcat stopped successfully."
else
    echo ">>> Tomcat is not running, skipping stop."
fi
