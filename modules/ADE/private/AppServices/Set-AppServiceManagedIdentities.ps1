function Set-AppServiceManagedIdentities {
    param(
        [object] $armParameters
    )

    # Get UAMI ID
    $uamiRG = $armParameters.managedIdentityResourceGroupName
    $uami = $armParameters.helloWorldManagedIdentityName

    $uamiID = az identity show --name $uami --resource-group $uamiRG --query id --output tsv
    # Primary Region Hello World, set UAMI to App Service
    Write-Log "Assigning UAMI to Hello World App Service Primary Region"
    $hwWebAppName = $armParameters.primaryRegionHelloWorldWebAppName
    $hwResourceGroupName = $armParameters.primaryRegionHelloWorldWebAppResourceGroupName
    

    az webapp identity assign -g $hwResourceGroupName -n $hwWebAppName --identities $uamiID
    Confirm-LastExitCode

    # Secondary Region Hello World, set UAMI to App Service
    Write-Log "Assigning UAMI to Hello World App Service Primary Region"
    $hwWebAppNameSecondary = $armParameters.secondaryRegionHelloWorldWebAppName
    $hwResourceGroupNameSecondary = $armParameters.secondaryRegionHelloWorldWebAppResourceGroupName
    $uami = $armParameters.helloWorldManagedIdentityName

    az webapp identity assign -g $hwResourceGroupNameSecondary -n $hwWebAppNameSecondary --identities $uamiID
    Confirm-LastExitCode
    
}