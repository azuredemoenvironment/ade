function Deploy-AzureGovernance {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Governance' $armParameters -resourceLevel 'sub' -bicep

    # Identity Deployment
    $identityResourceGroupName = $armParameters.identityResourceGroupName
    $applicationGatewayManagedIdentityName = $armParameters.applicationGatewayManagedIdentityName
    $containerRegistryManagedIdentityName = $armParameters.containerRegistryManagedIdentityName
    $containerRegistrySPNName = $armParameters.containerRegistrySPNName
    $githubActionsSPNName = $armParameters.githubActionsSPNName
    $restAPISPNName = $armParameters.restAPISPNName

    # Assign Managed Identity Principal Ids to Parameter Values
    Write-Status "Assign Managed Identity Principal Ids to Parameter Values"
    $appGWManagedIdentitySPNID = az identity show -g $identityResourceGroupName -n $applicationGatewayManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['applicationGatewayManagedIdentitySPNID'] = $appGWManagedIdentitySPNID.replace('"','')

    $crManagedIdentitySPNID = az identity show -g $identityResourceGroupName -n $containerRegistryManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['containerRegistryManagedIdentitySPNID'] = $crManagedIdentitySPNID.replace('"','')

    Write-Status "Finished Assigning Managed Identity Principal Ids to Parameter Values"

    # Create Service Principals
    Write-Status "Creating Service Principals"


    # Create Container Registry Service Principal
    Write-Log "Creating Container Registry Service Principal $containerRegistrySPNName"

    $containerRegistrySPN = $(az ad sp create-for-rbac -n http://$containerRegistrySPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['containerRegistrySPNPassword'] = $containerRegistrySPN.password
    $armParameters['containerRegistrySPNAppId'] = $containerRegistrySPN.appId
    
    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $containerRegistrySPNObjectID = az ad sp show --id $containerRegistrySPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['containerRegistrySPNObjectID'] = $containerRegistrySPNObjectID

    Write-Log "Finished Creating Container Registry Service Principal $containerRegistrySPNName"


    # Create GitHub Actions Service Principal
    Write-Log "Creating GitHub Actions Service Principal $githubActionsSPNName"    
    
    $githubActionsSPN = $(az ad sp create-for-rbac -n http://$githubActionsSPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['githubActionsSPNPassword'] = $githubActionsSPN.password
    $armParameters['githubActionsSPNAppId'] = $githubActionsSPN.appId
    
    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $githubActionsSPNObjectID = az ad sp show --id $githubActionsSPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['githubActionsSPNObjectID'] = $githubActionsSPNObjectID

    Write-Log "Finished Creating GitHub Actions Service Principal $githubActionsSPNName"


    # Create REST API Service Principal
    Write-Log "Creating REST API Service Principal $restAPISPNName"

    $restAPISPN = $(az ad sp create-for-rbac -n http://$restAPISPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['restAPISPNPassword'] = $restAPISPN.password
    $armParameters['restAPISPNAppId'] = $restAPISPN.appId

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $restAPISPNObjectID = az ad sp show --id $restAPISPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['restAPISPNObjectID'] = $restAPISPNObjectID

    Write-Log "Finished Creating REST API Service Principal $restAPISPNName"
        
    Write-Status "Finished Creating Service Principals"

}