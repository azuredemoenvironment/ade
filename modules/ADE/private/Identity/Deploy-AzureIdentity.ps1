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
    $crSPNName = $armParameters.crSPNName
    $aksSPNName = $armParameters.aksSPNName
    
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

    Write-Status "Finished Assigning Managed Identities to Key Vault"

    Write-Status "Creating Service Principals"

    Write-Log "Creating Service Principal $restAPISPNName"
    az ad sp create-for-rbac -n "http://$restAPISPNName"
    Confirm-LastExitCode

    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10
        
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

    Write-Log "Finished Creating AKS Service Principal $aksSPNName"

    Write-Status "Finished Creating Service Principals"
}