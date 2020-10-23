function Set-AzureFirewallToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Allocated"

    # TODO: implement this fully
    <#
    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $firewallName = $armParameters.firewallName

    $vnet = Get-AzVirtualNetwork -Name "vnet" -ResourceGroupName "rgName"
    $publicIp = Get-AzPublicIpAddress -Name "firewallpip" -ResourceGroupName "rgName"
    $firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $networkingResourceGroupName
    $firewall.Allocate($vnet, $publicIp)
    #>

    Write-Log "Finished Allocating Azure Firewall"
}