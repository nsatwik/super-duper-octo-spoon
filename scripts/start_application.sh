#!/bin/bash
set -e

CATALINA_HOME="/usr/share/tomcat-codedeploy"
WAR_SOURCE="$CATALINA_HOME/webapps/SampleMavenTomcatApp.war"
CONTEXT="ROOT"

echo "[INFO] Stopping Tomcat before deploying new WAR..."
if [ -f "$CATALINA_HOME/bin/shutdown.sh" ]; then
    chmod +x $CATALINA_HOME/bin/*.sh
    $CATALINA_HOME/bin/shutdown.sh || true
    sleep 5
fi

echo "[INFO] Deploying WAR..."
# Remove old application
if [ -d "$CATALINA_HOME/webapps/$CONTEXT" ]; then
    rm -rf $CATALINA_HOME/webapps/$CONTEXT
fi
if [ -f "$CATALINA_HOME/webapps/$CONTEXT.war" ]; then
    rm -f $CATALINA_HOME/webapps/$CONTEXT.war
fi

# Copy WAR (already deployed by AppSpec, but just to be safe)
if [ -f "$WAR_SOURCE" ]; then
    cp $WAR_SOURCE $CATALINA_HOME/webapps/$CONTEXT.war
else
    echo "[ERROR] WAR file not found at $WAR_SOURCE"
    exit 1
fi

echo "[INFO] Starting Tomcat..."
$CATALINA_HOME/bin/startup.sh

echo "[INFO] Application deployed and Tomcat started successfully."
