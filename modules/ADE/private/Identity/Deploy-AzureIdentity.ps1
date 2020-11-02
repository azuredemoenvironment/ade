function Deploy-AzureIdentity {
    param(
        [object] $armParameters
    )

    $managedIdentityResourceGroupName = $armParameters.managedIdentityResourceGroupName
    $crManagedIdentityName = $armParameters.crManagedIdentityName
    $appGWManagedIdentityName = $armParameters.appGWManagedIdentityName
    $helloWorldManagedIdentityName = $armParameters.helloWorldManagedIdentityName
    $keyVaultResourceGroupName = $armParameters.keyVaultResourceGroupName
    $keyVaultName = $armParameters.keyVaultName
    $restAPISPNName = $armParameters.restAPISPNName
    $ghaSPNName = $armParameters.ghaSPNName
    $crSPNName = $armParameters.crSPNName
    
    Write-ScriptSection "Starting Azure Identity Deployment"

    New-ResourceGroup $managedIdentityResourceGroupName $armParameters.defaultPrimaryRegion

    Write-Status "Creating Managed Identities"

    Write-Log "Creating Managed Identity $($armParameters.crManagedIdentityName)"
    az identity create -g $managedIdentityResourceGroupName -n $armParameters.crManagedIdentityName
    Confirm-LastExitCode

    Write-Log "Creating Managed Identity $($armParameters.appGWManagedIdentityName)"
    az identity create -g $managedIdentityResourceGroupName -n $armParameters.appGWManagedIdentityName
    Confirm-LastExitCode

    Write-Log "Creating Managed Identity $($armParameters.helloWorldManagedIdentityName)"
    az identity create -g $managedIdentityResourceGroupName -n $armParameters.helloWorldManagedIdentityName
    Confirm-LastExitCode

    Write-Status "Finished Creating Managed Identities"

    Write-Status "Assigning Managed Identities to Key Vault"
    $crManagedIdentitySPNID = az identity show -g $managedIdentityResourceGroupName -n $crManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['crManagedIdentitySPNID'] = $crManagedIdentitySPNID

    Write-Log "Assigning $crManagedIdentitySPNID to $keyVaultName Key Vault"
    az keyvault set-policy -g $keyVaultResourceGroupName -n $keyVaultName --object-id $crManagedIdentitySPNID --key-permissions get unwrapKey wrapKey
    Confirm-LastExitCode

    $appGWManagedIdentitySPNID = az identity show -g $managedIdentityResourceGroupName -n $appGWManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['appGWManagedIdentitySPNID'] = $appGWManagedIdentitySPNID

    Write-Log "Assigning $appGWManagedIdentitySPNID to $keyVaultName Key Vault"
    az keyvault set-policy -g $keyVaultResourceGroupName -n $keyVaultName --object-id $appGWManagedIdentitySPNID --secret-permissions get
    Confirm-LastExitCode

    # Added Hello World Identity for use with App Services
    $hwManagedIdentitySPNID = az identity show -g $managedIdentityResourceGroupName -n $helloWorldManagedIdentityName --query principalId
    Confirm-LastExitCode

    $armParameters['helloWorldManagedIdentitySPNID'] = $hwManagedIdentitySPNID

    Write-Log "Assigning $hwManagedIdentitySPNID to $keyVaultName Key Vault"
    az keyvault set-policy -g $keyVaultResourceGroupName -n $keyVaultName --object-id $hwManagedIdentitySPNID --certificate-permissions get
    Confirm-LastExitCode

    Write-Status "Finished Assigning Managed Identities to Key Vault"

    Write-Status "Creating Service Principals"

    # TODO: this could be made into a function
    Write-Log "Creating REST API Service Principal $restAPISPNName"

    $restAPISPNPassword = az ad sp create-for-rbac -n http://$restAPISPNName --query password --output tsv
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

    Set-AzureKeyVaultSecret $keyVaultName 'restAPIUserName' (ConvertTo-SecureString $restAPISPNAppID -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'restAPIPassword' (ConvertTo-SecureString $restAPISPNPassword -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'restAPIObjectId' (ConvertTo-SecureString $restAPISPNObjectID -AsPlainText -Force)

    Write-Log "Finished Creating REST API Service Principal $restAPISPNName"    
    
    # TODO: this could be made into a function
    Write-Log "Creating GitHub Actions Service Principal $ghaSPNName"

    $ghaSPNPassword = az ad sp create-for-rbac -n http://$ghaSPNName --query password --output tsv
    Confirm-LastExitCode
    $armParameters['ghaSPNPassword'] = $ghaSPNPassword

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $ghaSPNAppID = az ad sp show --id http://$ghaSPNName --query appId --output tsv
    Confirm-LastExitCode
    $armParameters['ghaSPNAppID'] = $ghaSPNAppID

    $ghaSPNObjectID = az ad sp show --id http://$ghaSPNName --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['ghaObjectId'] = $ghaSPNObjectID

    Set-AzureKeyVaultSecret $keyVaultName 'ghaUserName' (ConvertTo-SecureString $ghaSPNAppID -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'ghaPassword' (ConvertTo-SecureString $ghaSPNPassword -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'ghaObjectId' (ConvertTo-SecureString $ghaSPNObjectID -AsPlainText -Force)

    Write-Log "Finished Creating GitHub Actions Service Principal $ghaSPNName"
        
    # TODO: this could be made into a function
    Write-Log "Creating Container Registry Service Principal $crSPNName"

    $crSPNPassword = az ad sp create-for-rbac -n http://$crSPNName --skip-assignment true --role acrpull --query password --output tsv
    Confirm-LastExitCode
    $armParameters['crSPNPassword'] = $crSPNPassword

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $crSPNAppID = az ad sp show --id http://$crSPNName --query appId --output tsv
    Confirm-LastExitCode
    $armParameters['crSPNAppID'] = $crSPNAppID

    $crSPNObjectID = az ad sp show --id http://$crSPNName --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['containerRegistryObjectId'] = $crSPNObjectID

    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryUserName' (ConvertTo-SecureString $crSPNAppID -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryPassword' (ConvertTo-SecureString $crSPNPassword -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryObjectId' (ConvertTo-SecureString $crSPNObjectID -AsPlainText -Force)

    Write-Log "Finished Creating Container Registry Service Principal $crSPNName"

    Write-Status "Finished Creating Service Principals"
}