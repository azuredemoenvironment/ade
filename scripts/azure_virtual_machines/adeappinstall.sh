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
ADE_BACKEND_IPADDRESS="$5"
ADE_NGINX_CONF_URI="$6"

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
ExecStart=/bin/bash $STARTUP_SCRIPT_PATH

[Install]
WantedBy=multi-user.target
EOF

sudo rm -f $STARTUP_SCRIPT_PATH
sudo touch $STARTUP_SCRIPT_PATH
sudo chmod 766 $STARTUP_SCRIPT_PATH

sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Logging Into ACR"

sudo docker login $ACR_SERVER.azurecr.io --username $ACR_SERVER --password "$ACR_PASSWORD"

echo "Stopping Any Existing Docker Containers"

sudo docker kill \$(sudo docker ps -q)

echo "Pruning Any Existing Docker Containers"
sudo docker container prune -f

EOF

if [ "$ADE_PACKAGE" = "frontend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Pulling Latest ADE Images"

sudo docker pull $ACR_SERVER.azurecr.io/ade-frontend:latest
sudo docker pull $ACR_SERVER.azurecr.io/ade-apigateway:latest

echo "Pulling nginx"
sudo docker pull nginx:latest

echo "Starting Frontend ADE Service"

sudo docker run --name "ade-frontend" -d --restart unless-stopped -p 5000:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" -e ADE__ENVIRONMENT="virtualmachines" $ACR_SERVER.azurecr.io/ade-frontend:latest

# external api gateway - note, we override the connection info to our local docker instances
sudo docker run --name "ade-apigateway" -d --restart unless-stopped -p 5001:80 \\
    -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" \\
    -e ADE__ENVIRONMENT="virtualmachines" \\
    -e ADE__DATAINGESTORSERVICEURI="http://$ADE_BACKEND_IPADDRESS:5000" \\
    -e ADE__DATAREPORTERSERVICEURI="http://$ADE_BACKEND_IPADDRESS:5001" \\
    -e ADE__EVENTINGESTORSERVICEURI="http://$ADE_BACKEND_IPADDRESS:5002" \\
    -e ADE__USERSERVICEURI="http://$ADE_BACKEND_IPADDRESS:5003" \\
    $ACR_SERVER.azurecr.io/ade-apigateway:latest

echo "Configuring Reverse Proxy"
mkdir -p /app/ade/nginx/logs
curl -o /app/ade/nginx/nginx.conf $ADE_NGINX_CONF_URI

sudo docker run --name "ade-reverseproxy" -d --restart unless-stopped -p 80:80 -v /app/ade/nginx/nginx.conf:/etc/nginx/nginx.conf -v /app/ade/nginx/logs/:/etc/nginx/logs/ nginx:latest
EOF
fi

if [ "$ADE_PACKAGE" = "backend" ]
then
    sudo tee -a $STARTUP_SCRIPT_PATH << EOF > /dev/null
echo "Pulling Latest ADE Images"

sudo docker pull $ACR_SERVER.azurecr.io/ade-dataingestorservice:latest
sudo docker pull $ACR_SERVER.azurecr.io/ade-datareporterservice:latest
sudo docker pull $ACR_SERVER.azurecr.io/ade-userservice:latest
sudo docker pull $ACR_SERVER.azurecr.io/ade-eventingestorservice:latest

echo "Starting Backend ADE Services"

# local docker network services
sudo docker run --name "ade-dataingestorservice" -d --restart unless-stopped -p 5000:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" -e ADE__ENVIRONMENT="virtualmachines" $ACR_SERVER.azurecr.io/ade-dataingestorservice:latest
sudo docker run --name "ade-datareporterservice" -d --restart unless-stopped -p 5001:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" -e ADE__ENVIRONMENT="virtualmachines" $ACR_SERVER.azurecr.io/ade-datareporterservice:latest
sudo docker run --name "ade-userservice" -d --restart unless-stopped -p 5002:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" -e ADE__ENVIRONMENT="virtualmachines" $ACR_SERVER.azurecr.io/ade-userservice:latest
sudo docker run --name "ade-eventingestorservice" -d --restart unless-stopped -p 5003:80 -e CONNECTIONSTRINGS__APPCONFIG="$APPCONFIG_CONNECTIONSTRING" -e ADE__ENVIRONMENT="virtualmachines" $ACR_SERVER.azurecr.io/ade-eventingestorservice:latest
EOF
fi

echo "Enabling ADE Docker Services on Startup"
sudo systemctl enable ade

##########################################
# Reboot
##########################################

echo "Rebooting VM in 1 minute for changes to complete"

sudo shutdown -r +1 "Server will restart in 1 minute."
