function Deploy-AzureIdentity {
    param(
        [object] $armParameters
    )

    $managedIdentityResourceGroupName = $armParameters.managedIdentityResourceGroupName
    $applicationGatewayManagedIdentityName = $armParameters.applicationGatewayManagedIdentityName
    $containerRegistryManagedIdentityName = $armParameters.containerRegistryManagedIdentityName
    $containerRegistrySPNName = $armParameters.containerRegistrySPNName
    $githubActionsSPNName = $armParameters.githubActionsSPNName
    $restAPISPNName = $armParameters.restAPISPNName
        
    # BICEP Template Deployment
    Deploy-ArmTemplate 'Azure Identity' $armParameters -resourceGroupName $armParameters.managedIdentityResourceGroupName -bicep

    # Assign Managed Identity Principal Ids to Parameter Values
    Write-Status "Assign Managed Identity Principal Ids to Parameter Values"
    $appGWManagedIdentitySPNID = az identity show -g $managedIdentityResourceGroupName -n $applicationGatewayManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['applicationGatewayManagedIdentitySPNID'] = $appGWManagedIdentitySPNID.replace('"','')

    $crManagedIdentitySPNID = az identity show -g $managedIdentityResourceGroupName -n $containerRegistryManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['containerRegistryManagedIdentitySPNID'] = $crManagedIdentitySPNID.replace('"','')

    Write-Status "Finished Assigning Managed Identity Principal Ids to Parameter Values"

    # Create Service Principals
    Write-Status "Creating Service Principals"

    # # TODO: this could be made into a function
    # Create Container Registry Service Principal
    Write-Log "Creating Container Registry Service Principal $containerRegistrySPNName"

    $containerRegistrySPNPassword = az ad sp create-for-rbac -n http://$containerRegistrySPNName --skip-assignment true --role acrpull --query password --output tsv
    Confirm-LastExitCode
    $armParameters['crSPNPassword'] = $containerRegistrySPNPassword

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $containerRegistrySPNAppID = az ad sp show --id http://$containerRegistrySPNName --query appId --output tsv
    Confirm-LastExitCode
    $armParameters['crSPNAppID'] = $containerRegistrySPNAppID

    $containerRegistrySPNObjectID = az ad sp show --id http://$containerRegistrySPNName --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['containerRegistryObjectId'] = $containerRegistrySPNObjectID

    Write-Log "Finished Creating Container Registry Service Principal $containerRegistrySPNName"

    # # TODO: this could be made into a function
    # Create GitHub Actions Service Principal
    Write-Log "Creating GitHub Actions Service Principal $githubActionsSPNName"

    $githubActionsSPNPassword = az ad sp create-for-rbac -n http://$githubActionsSPNName --role Contributor --query password --output tsv
    Confirm-LastExitCode
    $armParameters['githubActionsSPNPassword'] = $githubActionsSPNPassword

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $githubActionsSPNAppID = az ad sp show --id http://$githubActionsSPNName --query appId --output tsv
    Confirm-LastExitCode
    $armParameters['githubActionsSPNAppID'] = $githubActionsSPNAppID

    $githubActionsSPNObjectID = az ad sp show --id http://$githubActionsSPNName --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['githubActionsObjectId'] = $githubActionsSPNObjectID

    Write-Log "Finished Creating GitHub Actions Service Principal $githubActionsSPNName"

    # # TODO: this could be made into a function
    # Create REST API Service Principal
    Write-Log "Creating REST API Service Principal $restAPISPNName"

    $restAPISPNPassword = az ad sp create-for-rbac -n http://$restAPISPNName --role Contributor --query password --output tsv
    Confirm-LastExitCode
    $armParameters['restAPISPNPassword'] = $restAPISPNPassword

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $restAPISPNAppID = az ad sp show --id http://$restAPISPNName --query appId --output tsv
    Confirm-LastExitCode
    $armParameters['restAPISPNAppID'] = $restAPISPNAppID

    $restAPISPNObjectID = az ad sp show --id http://$restAPISPNName --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['restAPIObjectId'] = $restAPISPNObjectID

    Write-Log "Finished Creating REST API Service Principal $restAPISPNName"
        
    Write-Status "Finished Creating Service Principals"
}