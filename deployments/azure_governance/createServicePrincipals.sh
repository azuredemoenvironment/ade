#!/bin/bash

CONTAINER_REGISTRY_SPN_NAME=$1
GITHUB_ACTIONS_SPN_NAME=$2
REST_API_SPN_NAME=$3

register_spn () {
    SPN_NAME=$1
    VARIABLE_PREFIX=$2

    echo "Creating new service principal for $SPN_NAME"
    
    SPN_OBJECT=$(az ad sp create-for-rbac -n http://$SPN_NAME --skip-assignment true --role acrpull --output json)
    SPN_PASSWORD=$(jq -r '.password' <<< "${SPN_OBJECT}")
    SPN_APPID=$(jq -r '.appId' <<< "${SPN_OBJECT}")

    echo "Pausing for 10 seconds to allow for propagation."
    sleep 10

    SPN_OBJECTID=$(az ad sp show --id $SPN_APPID --query objectId --output tsv)

    echo "\"${VARIABLE_PREFIX}Password\":\"$SPN_PASSWORD\"," >> $AZ_SCRIPTS_OUTPUT_PATH
    echo "\"${VARIABLE_PREFIX}UserName\":\"$SPN_APPID\"," >> $AZ_SCRIPTS_OUTPUT_PATH
    echo "\"${VARIABLE_PREFIX}ObjectId\":\"$SPN_OBJECTID\"," >> $AZ_SCRIPTS_OUTPUT_PATH

    echo "Finished creating $SPN_NAME"
}

echo '{' > $AZ_SCRIPTS_OUTPUT_PATH

register_spn $CONTAINER_REGISTRY_SPN_NAME 'containerRegistry'
register_spn $GITHUB_ACTIONS_SPN_NAME 'githubActions'
register_spn $REST_API_SPN_NAME 'restAPI'
echo $'"complete":true}' >> $AZ_SCRIPTS_OUTPUT_PATH
