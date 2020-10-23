function Deploy-VnetPeering {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting VNET Peering Deployment"

    Write-Log "Creating Peering $($armParameters.peering01)"
    az network vnet peering create -g $armParameters.networkingResourceGroupName -n $armParameters.peering01 --vnet-name $armParameters.virtualNetwork01Name --remote-vnet $armParameters.virtualNetwork02Name --allow-vnet-access --allow-gateway-transit
    Confirm-LastExitCode

    Write-Log "Creating Peering $($armParameters.peering02)"
    az network vnet peering create -g $armParameters.networkingResourceGroupName -n $armParameters.peering02 --vnet-name $armParameters.virtualNetwork02Name --remote-vnet $armParameters.virtualNetwork01Name --allow-vnet-access --use-remote-gateway --allow-forwarded-traffic
    Confirm-LastExitCode

    Write-Log "Creating Peering $($armParameters.peering03)"
    az network vnet peering create -g $armParameters.networkingResourceGroupName -n $armParameters.peering03 --vnet-name $armParameters.virtualNetwork01Name --remote-vnet $armParameters.virtualNetwork03Name --allow-vnet-access --allow-gateway-transit
    Confirm-LastExitCode

    Write-Log "Creating Peering $($armParameters.peering04)"
    az network vnet peering create -g $armParameters.networkingResourceGroupName -n $armParameters.peering04 --vnet-name $armParameters.virtualNetwork03Name --remote-vnet $armParameters.virtualNetwork01Name --allow-vnet-access --use-remote-gateway --allow-forwarded-traffic
    Confirm-LastExitCode
}