function Deploy-InspectorGadgetAppService {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Private Link InspectorGadget' $armParameters -resourceGroupName $armParameters.inspectorGadgetResourceGroupName
}