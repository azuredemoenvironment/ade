function Deploy-AzureFrontendLoadBalancers {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Frontend Load Balancers' $armParameters -resourceLevel 'sub' -bicep
}