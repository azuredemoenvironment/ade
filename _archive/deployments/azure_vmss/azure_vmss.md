# Azure Virtual Machine Scale Set

- [Azure Virtual Machine Scale Set Documentation](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview "Azure Virtual Machine Scale Set Documentation")
- [Azure Custom Script Extension Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows "Azure Custom Script Extension Documentation")
- [Azure Load Balancer Documentation](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview "Azure Load Balancer Documentation")

## Description

The Azure Virtual Machine Scale Set deployment creates an Azure Virtual Machine Scale Set running a Work Server Application to simulate utilization on the Scale Set and force autoscaling. Custom Script Extension is configured to install the Work Server Application after deployment of the Virtual Machine Scale Set. Public access to the application is available via the Public IP Address of the Load Balancer over port 9000.  Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_vmss.json
- azure_vmss.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the Virtual Machine Scale set and access the Work Server Application via it's external URL on port 9000.

## Additional Notes

The following commands execute an allocation and deallocation on the Virtual Machine Scale Set.

### Allocate VMSS

    $resourceGroup='rg-alias-region-vmss'
    $vmssName='vmss01'
    az vmss start -g $resourceGroup -n $vmssName

### Deallocate VMSS

    $resourceGroup='rg-alias-region-vmss'
    $vmssName='vmss01'
    az vmss deallocate -g $resourceGroup -n $vmssName
