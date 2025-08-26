#!/bin/bash
set -e

echo ">>> Stopping Tomcat..."

if systemctl is-active --quiet tomcat9; then
    sudo systemctl stop tomcat9
    echo ">>> Tomcat stopped successfully."
else
    echo ">>> Tomcat is not running, skipping stop."
fi
