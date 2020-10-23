# Azure Virtual Machine Jump Box

- [Azure Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview "Azure Virtual Machine Documentation")
- [Azure Custom Script Extension Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows "Azure Custom Script Extension Documentation")
- [Azure Monitor for VMs Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/vminsights-overview "Azure Monitor for VMs Documentation")

## Description

The Azure Virtual Machine deployment creates a Windows virtual machine that provides Jump Box access to the Azure Demo Environment.  The virtual machine is deployed on the Management Subnet in the virtual network for virtual machine workloads.  The virtual machine is configured with a public IP address, but is protected by a Network Security Group that only allows access from a specific location.  Boot Diagnostics, Guest OS Diagnostics, and Log Analytics is configured on the Virtual Machine and uses an existing Storage Account.  Diagnostic settings is enabled for all resources utilizing Azure Log Analytics for log and metric storage, and Azure Monitor for virtual Machines is enabled for Virtual Machine Insights utilizing Azure Log Analytics.  Custom Script Extension is configured to install Putty after deployment of the Virtual Machine.

## Files Used

- azure_virtual_machine_jumpbox.json
- azure_virtual_machine_jumpbox.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, RDP into the Jump Box and verify the installation of Putty.
