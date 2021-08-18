function Deploy-AzureApplicationGateway {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Application Gateway' $armParameters -resourceGroupName $armParameters.applicationGatewayResourceGroupName
}