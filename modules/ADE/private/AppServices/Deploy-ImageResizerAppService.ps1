function Deploy-ImageResizerAppService {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service ImageResizer' $armParameters -resourceGroupName $armParameters.imageResizerResourceGroupName
}