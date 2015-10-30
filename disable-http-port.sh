#!/bin/bash

CONTROLLER_HOME=/opt/AppDynamics/Controller

echo "This will disable the Controller's HTTP port."
echo "When prompted, enter 'admin' as the user and the password for the Controller's 'root' user."
read -rsp $'Press enter to continue or CTRL-C to exit.\n\n'

$CONTROLLER_HOME/appserver/glassfish/bin/asadmin delete-http-listener http-listener-1
echo "HTTP port disabled. Restart the Controller app server:"
echo "$CONTROLLER_HOME/bin/controller.sh stop-appserver && $CONTROLLER_HOME/bin/controller.sh start-appserver"
