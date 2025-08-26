#!/bin/bash
chmod +x $(dirname "$0")/*.sh

echo "Stopping Tomcat..."
systemctl stop tomcat || true
