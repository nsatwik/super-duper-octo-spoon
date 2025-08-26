#!/bin/bash
set -e

CATALINA_HOME='/usr/share/tomcat9-codedeploy'
DEPLOY_TO_ROOT='true'
SERVER_HTTP_PORT='80'

TEMP_STAGING_DIR='/tmp/codedeploy-deployment-staging-area'
WAR_STAGED_LOCATION="$TEMP_STAGING_DIR/SampleMavenTomcatApp.war"
HTTP_PORT_CONFIG_XSL_LOCATION="$TEMP_STAGING_DIR/configure_http_port.xsl"

# In Tomcat, ROOT.war maps to the server root
if [[ "$DEPLOY_TO_ROOT" = 'true' ]]; then
    CONTEXT_PATH='ROOT'
else
    CONTEXT_PATH='SampleMavenTomcatApp'
fi

echo "[INFO] Stopping Tomcat service before deploying new WAR..."
sudo systemctl stop tomcat9 || true

# Remove old app
if [[ -f $CATALINA_HOME/webapps/$CONTEXT_PATH.war ]]; then
    rm -f $CATALINA_HOME/webapps/$CONTEXT_PATH.war
fi
if [[ -d $CATALINA_HOME/webapps/$CONTEXT_PATH ]]; then
    rm -rf $CATALINA_HOME/webapps/$CONTEXT_PATH
fi

echo "[INFO] Copying new WAR to Tomcat webapps..."
cp $WAR_STAGED_LOCATION $CATALINA_HOME/webapps/$CONTEXT_PATH.war

# Configure Tomcat server HTTP connector (set port to $SERVER_HTTP_PORT)
if ! command -v xsltproc &> /dev/null; then
    echo "[INFO] Installing xsltproc..."
    sudo apt-get update -y
    sudo apt-get install -y xsltproc
fi

cp $CATALINA_HOME/conf/server.xml $CATALINA_HOME/conf/server.xml.bak
xsltproc $HTTP_PORT_CONFIG_XSL_LOCATION $CATALINA_HOME/conf/server.xml.bak > $CATALINA_HOME/conf/server.xml

echo "[INFO] Starting Tomcat..."
sudo systemctl start tomcat9

echo "[INFO] Deployment completed successfully!"
