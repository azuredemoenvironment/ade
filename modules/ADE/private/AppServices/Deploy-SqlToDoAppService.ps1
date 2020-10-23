function Deploy-SqlToDoAppService {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure SQL ToDo' $armParameters -resourceGroupName $armParameters.sqlTodoResourceGroupName
}