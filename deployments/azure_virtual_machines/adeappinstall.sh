#!/bin/sh

set -x
set -e

##########################################
# Setup variables
##########################################

# These are from parameters passed in
ACR_SERVER="$1"
ACR_PASSWORD="$2"
APPCONFIG_CONNECTIONSTRING="$3"
ADE_PACKAGE="$4"

# These are for consistency
STARTUP_SCRIPT_PATH="/etc/systemd/system/ade.service"

##########################################
# Pre-reqs
##########################################

echo "Installing Prerequisites"

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Installing Docker Engine"

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

##########################################
# Create Startup Script
##########################################

echo "Creating Startup Script"

sudo rm -f $STARTUP_SCRIPT_PATH
sudo touch $STARTUP_SCRIPT_PATH
sudo chmod 766 $STARTUP_SCRIPT_PATH

sudo tee -a $STARTUP_SCRIPT_PATH << EOF
echo "Logging Into ACR"

sudo docker login $ACR_SERVER.azurecr.io --username $ACR_SERVER --password "$ACR_PASSWORD"
EOF

if [ "$ADE_PACKAGE" = "frontend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF
echo "Starting Frontend ADE Service"

sudo docker run -d --restart unless-stopped -p 80:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" acradebrmareus001.azurecr.io/ade-frontend:latest
EOF
fi

if [ "$ADE_PACKAGE" = "backend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF
echo "Starting Backend ADE Services"

# external api gateway
sudo docker run -d --restart unless-stopped -p 80:80 $ACR_SERVER.azurecr.io/ade-apigateway:latest

# local docker network services
sudo docker run -d --restart unless-stopped -p 5000:80 $ACR_SERVER.azurecr.io/ade-dataingestorservice:latest
sudo docker run -d --restart unless-stopped -p 5001:80 $ACR_SERVER.azurecr.io/ade-datareporterservice:latest
sudo docker run -d --restart unless-stopped -p 5002:80 $ACR_SERVER.azurecr.io/ade-userservice:latest
sudo docker run -d --restart unless-stopped -p 5003:80 $ACR_SERVER.azurecr.io/ade-eventingestorservice:latest
EOF
fi

echo "Enabling ADE Docker Services on Startup"
sudo systemctl enable ade

##########################################
# Launch Script
##########################################

echo "Starting ADE Docker Services"

sudo systemctl start ade

echo "Done!"
