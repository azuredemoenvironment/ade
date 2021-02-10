function Set-AppServiceManagedIdentities {
    param(
        [object] $armParameters
    )

    $managedIdentityResourceGroupName = $armParameters.managedIdentityResourceGroupName
    $asManagedIdentityName = $armParameters.asManagedIdentityName

    $asManagedIdentityNameID = az identity show --name $asManagedIdentityName --resource-group $managedIdentityResourceGroupName --query id --output tsv
    Confirm-LastExitCode

    Write-Log "Assigning UAMI to Hello World App Service Primary Region"
    $hwWebAppName = $armParameters.primaryRegionHelloWorldWebAppName
    $hwResourceGroupName = $armParameters.primaryRegionHelloWorldWebAppResourceGroupName    

    az webapp identity assign -g $hwResourceGroupName -n $hwWebAppName --identities $asManagedIdentityNameID
    Confirm-LastExitCode

    Write-Log "Assigning UAMI to Hello World App Service Secondary Region"
    $hwWebAppNameSecondary = $armParameters.secondaryRegionHelloWorldWebAppName
    $hwResourceGroupNameSecondary = $armParameters.secondaryRegionHelloWorldWebAppResourceGroupName

    az webapp identity assign -g $hwResourceGroupNameSecondary -n $hwWebAppNameSecondary --identities $asManagedIdentityNameID
    Confirm-LastExitCode    
}