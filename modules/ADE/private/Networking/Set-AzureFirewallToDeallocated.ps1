function Set-AzureFirewallToDeallocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Deallocated (for Cost Savings)"

    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $azureFirewallName = $armParameters.azureFirewallName

    $azureFirewall = Get-AzFirewall -Name $azureFirewallName -ResourceGroupName $networkingResourceGroupName
    $azureFirewall.Deallocate()

    Set-AzFirewall -AzureFirewall $azureFirewall

    Write-Log "Finished Deallocating Azure Firewall"
}