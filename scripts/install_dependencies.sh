#!/bin/bash
set -e

# Variables
TOMCAT_VERSION=10.1.30
CATALINA_HOME=/usr/share/tomcat-codedeploy
TOMCAT_TAR="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"

echo ">>> Installing Java (OpenJDK 21)"
sudo amazon-linux-extras enable corretto21
sudo yum install -y java-21-amazon-corretto-devel wget tar

echo ">>> Setting up Tomcat ${TOMCAT_VERSION}"
# Cleanup old
if [ -d "$CATALINA_HOME" ]; then
  rm -rf $CATALINA_HOME
fi
mkdir -p $CATALINA_HOME

cd /tmp
wget -q $TOMCAT_URL
tar -xzf $TOMCAT_TAR
cp -r apache-tomcat-${TOMCAT_VERSION}/* $CATALINA_HOME

# Create service
cat >/etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat ${TOMCAT_VERSION}
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto"
Environment="CATALINA_HOME=${CATALINA_HOME}"
ExecStart=${CATALINA_HOME}/bin/startup.sh
ExecStop=${CATALINA_HOME}/bin/shutdown.sh
User=root
Group=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
