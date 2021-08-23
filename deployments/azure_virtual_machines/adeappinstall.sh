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
STARTUP_SCRIPT_PATH="/etc/systemd/system/ade.sh"
STARTUP_SERVICE_PATH="/etc/systemd/system/ade.service"

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
sudo apt autoremove -y

##########################################
# Create Startup Script
##########################################

echo "Creating Startup Service and Script"

sudo tee $STARTUP_SERVICE_PATH << EOF > /dev/null
[Unit]
Description=ADE

[Service]
ExecStart=$STARTUP_SCRIPT_PATH

[Install]
WantedBy=multi-user.target
EOF

sudo rm -f $STARTUP_SCRIPT_PATH
sudo touch $STARTUP_SCRIPT_PATH
sudo chmod 766 $STARTUP_SCRIPT_PATH

sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Logging Into ACR"

sudo docker login $ACR_SERVER.azurecr.io --username $ACR_SERVER --password "$ACR_PASSWORD"
EOF

if [ "$ADE_PACKAGE" = "frontend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Starting Frontend ADE Service"

sudo docker run --name "ade-frontend" -d --restart unless-stopped -p 80:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" $ACR_SERVER.azurecr.io/ade-frontend:latest
EOF
fi

if [ "$ADE_PACKAGE" = "backend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Starting Backend ADE Services"

# external api gateway - note, we override the connection info to our local docker instances
sudo docker run --name "ade-apigateway" -d --restart unless-stopped -p 80:80 \
    -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" \
    -e ADE__DATAINGESTORSERVICEURI="http://localhost:5000" \
    -e ADE__DATAREPORTERSERVICEURI="http://localhost:5001" \
    -e ADE__EVENTINGESTORSERVICEURI="http://localhost:5002" \
    -e ADE__USERSERVICEURI="http://localhost:5003" \
    $ACR_SERVER.azurecr.io/ade-apigateway:latest

# local docker network services
sudo docker run --name "ade-dataingestorservice" -d --restart unless-stopped -p 5000:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" $ACR_SERVER.azurecr.io/ade-dataingestorservice:latest
sudo docker run --name "ade-datareporterservice" -d --restart unless-stopped -p 5001:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" $ACR_SERVER.azurecr.io/ade-datareporterservice:latest
sudo docker run --name "ade-userservice" -d --restart unless-stopped -p 5002:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" $ACR_SERVER.azurecr.io/ade-userservice:latest
sudo docker run --name "ade-eventingestorservice" -d --restart unless-stopped -p 5003:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" $ACR_SERVER.azurecr.io/ade-eventingestorservice:latest
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
