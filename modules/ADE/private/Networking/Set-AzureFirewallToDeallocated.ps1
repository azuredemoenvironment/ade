function Set-AzureFirewallToDeallocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Deallocated (for Cost Savings)"

    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $firewallName = $armParameters.firewallName

    $firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $networkingResourceGroupName
    $firewall.Deallocate()

    Set-AzFirewall -AzureFirewall $firewall

    Write-Log "Finished Deallocating Azure Firewall"
}