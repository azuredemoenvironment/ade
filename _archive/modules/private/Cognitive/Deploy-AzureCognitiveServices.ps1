function Deploy-AzureCognitiveServices {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Cognitive Services' $armParameters -resourceGroupName $armParameters.cognitiveServicesResourceGroupName
}