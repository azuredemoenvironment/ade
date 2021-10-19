function Deploy-AzureGovernance {
    param(
        [object] $armParameters
    )

    # Deploy the Azure Governance Bicep template at the subscription scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Governance' $armParameters -resourceLevel 'sub' -bicep


    # Parameters
    ##################################################
    $keyVaultName = $armParameters.keyVaultName
    $containerRegistrySPNName = $armParameters.containerRegistrySPNName
    $githubActionsSPNName = $armParameters.githubActionsSPNName
    $restAPISPNName = $armParameters.restAPISPNName


    # Create Container Registry Service Principal
    ##################################################
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


    # Assign Container Registry Service Principal outputs to Key Vault Secrets.
    ##################################################
    Write-Log "Assigning Container Registry Service Principal outputs to Key Vault Secrets."

    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryUserName' (ConvertTo-SecureString $containerRegistrySPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryPassword' (ConvertTo-SecureString $containerRegistrySPN.password -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'containerRegistryObjectId' (ConvertTo-SecureString $containerRegistrySPNObjectID -AsPlainText -Force)

    Write-Log "Finished assigning Container Registry Service Principal outputs to Key Vault Secrets."


    # Create GitHub Actions Service Principal
    ##################################################
    Write-Log "Creating GitHub Actions Service Principal $githubActionsSPNName"    
    
    $githubActionsSPN = $(az ad sp create-for-rbac -n http://$githubActionsSPNName --skip-assignment true --role contributor --output json) | ConvertFrom-Json
    $armParameters['githubActionsSPNPassword'] = $githubActionsSPN.password
    $armParameters['githubActionsSPNAppId'] = $githubActionsSPN.appId
    
    Write-Log "Pausing for 10 seconds to allow for propagation."
    Start-Sleep -Seconds 10

    $githubActionsSPNObjectID = az ad sp show --id $githubActionsSPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['githubActionsSPNObjectID'] = $githubActionsSPNObjectID

    Write-Log "Finished Creating GitHub Actions Service Principal $githubActionsSPNName"


    # Assign GitHub Actions Service Principal outputs to Key Vault Secrets.
    ##################################################
    Write-Log "Assigning GitHub Actions Service Principal outputs to Key Vault Secrets."

    Set-AzureKeyVaultSecret $keyVaultName 'githubActionsUserName' (ConvertTo-SecureString $githubActionsSPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'githubActionsPassword' (ConvertTo-SecureString $githubActionsSPN.password -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'githubActionsObjectId' (ConvertTo-SecureString $githubActionsSPNObjectID -AsPlainText -Force)

    Write-Log "Finished assigning GitHub Actions Service Principal outputs to Key Vault Secrets."


    # Create REST API Service Principal
    ##################################################
    Write-Log "Creating REST API Service Principal $restAPISPNName"

    $restAPISPN = $(az ad sp create-for-rbac -n http://$restAPISPNName --skip-assignment true --role contributor --output json) | ConvertFrom-Json
    $armParameters['restAPISPNPassword'] = $restAPISPN.password
    $armParameters['restAPISPNAppId'] = $restAPISPN.appId

    $restAPISPNObjectID = az ad sp show --id $restAPISPN.appId --query objectId --output tsv
    Confirm-LastExitCode
    $armParameters['restAPISPNObjectID'] = $restAPISPNObjectID

    Write-Log "Finished Creating REST API Service Principal $restAPISPNName"
        
    Write-Status "Finished Creating Service Principals"


    # Assign REST API Service Principal outputs to Key Vault Secrets.
    ##################################################
    Write-Log "Assigning REST API Service Principal outputs to Key Vault Secrets."

    Set-AzureKeyVaultSecret $keyVaultName 'restAPIUserName' (ConvertTo-SecureString $restAPISPN.appId -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'restAPIPassword' (ConvertTo-SecureString $restAPISPN.password -AsPlainText -Force)
    Set-AzureKeyVaultSecret $keyVaultName 'restAPIObjectId' (ConvertTo-SecureString $restAPISPNObjectID -AsPlainText -Force)

    Write-Log "Finished assigning REST API Service Principal outputs to Key Vault Secrets."


    # Configure Azure KeyVault
    ##################################################
    Write-Status "Configuring Azure Key Vault $keyVaultName"

    # Configure the resource password KeyVault secret.
    Set-AzureKeyVaultSecret $keyVaultName 'resourcePassword' $secureResourcePassword

    # Deploy the wildcard certificate KeyVault secret.
    Deploy-WildcardCertificateToAzureKeyVault $keyVaultName $secureCertificatePassword $wildcardCertificatePath

    # Create the Container Registry encryption key.
    New-AzureKeyVaultKey $keyVaultName 'containerRegistry'
    
    # Set the Azure KeyVault resource id for future deployments.
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $keyVaultName"
}