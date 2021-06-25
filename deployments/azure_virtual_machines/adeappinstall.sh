#!/bin/sh

set -x
set -e

$ACR_SERVER=$1
$ACR_PASSWORD=$2
$ADE_PACKAGE=$3
$ADE_BACKEND_URI=$4

echo "Installing Prerequisites"

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Installing Docker Engine"

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Logging into ACR"

sudo docker login $ACR_LOGIN.azurecr.io --username acradebrmareus001 --password "fH5=cbXIu47TPlW1izjiNP3nkGTNuDOk"

echo "Starting Container from ACR Image"

if($ADE_PACKAGE == "frontend") {
    # TODO: fix the backend uri
    sudo docker run -d --restart unless-stopped -p 80:80 -e BACKEND_URI=$ADE_BACKEND_URI acradebrmareus001.azurecr.io/ade-frontend:latest
}

if($ADE_PACKAGE == "backend") {
    # external api gateway
    sudo docker run -d --restart unless-stopped -p 80:80 acradebrmareus001.azurecr.io/ade-apigateway:latest

    # local docker network services
    sudo docker run -d --restart unless-stopped acradebrmareus001.azurecr.io/ade-dataingestorservice:latest
    sudo docker run -d --restart unless-stopped acradebrmareus001.azurecr.io/ade-datareporterservice:latest
    sudo docker run -d --restart unless-stopped acradebrmareus001.azurecr.io/ade-userservice:latest
}


echo "Done!"
