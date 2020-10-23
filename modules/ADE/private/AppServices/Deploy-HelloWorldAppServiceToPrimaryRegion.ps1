function Deploy-HelloWorldAppServiceToPrimaryRegion {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service HelloWorld Primary Region' $armParameters -resourceGroupName $armParameters.primaryRegionHelloWorldWebAppResourceGroupName
}