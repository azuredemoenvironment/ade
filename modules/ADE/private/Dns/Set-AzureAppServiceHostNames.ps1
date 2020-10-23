function Set-AzureAppServiceHostNames {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing AzureAppServiceHostNames Deployment"

    $helloWorldHostName = "helloworld.$rootDomainName"

    az webapp config hostname add -g $armParameters.primaryRegionHelloWorldWebAppResourceGroupName --webapp-name $armParameters.primaryRegionHelloWorldWebAppName --hostname $helloWorldHostName
    Confirm-LastExitCode

    az webapp config hostname add -g $armParameters.secondaryRegionHelloWorldWebAppResourceGroupName --webapp-name $armParameters.secondaryRegionHelloWorldWebAppName --hostname $helloWorldHostName
    Confirm-LastExitCode

    Write-Status "Finished AzureAppServiceHostNames Deployment"
}