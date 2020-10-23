function Deploy-HelloWorldAppServiceToSecondaryRegion {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service HelloWorld Secondary Region' $armParameters -resourceGroupName $armParameters.secondaryRegionHelloWorldWebAppResourceGroupName -region $armParameters.defaultSecondaryRegion
}