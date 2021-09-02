function Deploy-AzureIdentity {
    param(
        [object] $armParameters
    )

    $managedIdentityResourceGroupName = $armParameters.managedIdentityResourceGroupName
    $crManagedIdentityName = $armParameters.crManagedIdentityName
    $appGWManagedIdentityName = $armParameters.appGWManagedIdentityName
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

    Write-Log "Assigning 'Microsoft Azure App Service System Assigned Identity' to $keyVaultName Key Vault"
    az keyvault set-policy -g $keyVaultResourceGroupName -n $keyVaultName --spn abfa0a7c-a6b6-4736-8310-5855508787cd --secret-permissions get --certificate-permissions get
    Confirm-LastExitCode

    Write-Status "Finished Assigning Managed Identities to Key Vault"

    Write-Status "Creating Service Principals"

    Write-Log "Creating REST API Service Principal $restAPISPNName"

    $restAPISPN = $(az ad sp create-for-rbac -n http://$restAPISPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['restAPISPNPassword'] = $restAPISPN.password
    $armParameters['restAPISPNAppId'] = $restAPISPN.appId

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    Set-AzureKeyVaultSecret $keyVaultName 'restAPIUserName' (ConvertTo-SecureString $restAPISPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'restAPIPassword' (ConvertTo-SecureString $restAPISPN.password -AsPlainText -Force)

    Write-Log "Finished Creating REST API Service Principal $restAPISPNName"    
    
    Write-Log "Creating GitHub Actions Service Principal $ghaSPNName"

    $ghaSPN = $(az ad sp create-for-rbac -n http://$ghaSPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['ghaSPNPassword'] = $ghaSPN.password
    $armParameters['ghaSPNAppId'] = $ghaSPN.appId

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    Set-AzureKeyVaultSecret $keyVaultName 'ghaUserName' (ConvertTo-SecureString $ghaSPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'ghaPassword' (ConvertTo-SecureString $ghaSPN.password -AsPlainText -Force)

    Write-Log "Finished Creating GitHub Actions Service Principal $ghaSPNName"
        
    Write-Log "Creating Container Registry Service Principal $crSPNName"

    $crSPN = $(az ad sp create-for-rbac -n http://$crSPNName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
    $armParameters['crSPNPassword'] = $crSPN.password
    $armParameters['crSPNAppId'] = $crSPN.appId

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $crSPNObjectID = az ad sp show --id $crSPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['crSPNObjectID'] = $crSPNObjectID

    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryUserName' (ConvertTo-SecureString $crSPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryPassword' (ConvertTo-SecureString $crSPN.password -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryObjectId' (ConvertTo-SecureString $crSPNObjectID -AsPlainText -Force)

    Write-Log "Finished Creating Container Registry Service Principal $crSPNName"

    Write-Status "Finished Creating Service Principals"
}