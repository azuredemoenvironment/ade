# Azure Virtual Machine Developer

- [Azure Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview "Azure Virtual Machine Documentation")
- [Azure Custom Script Extension Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows "Azure Custom Script Extension Documentation")
- [Azure Monitor for VMs Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/vminsights-overview "Azure Monitor for VMs Documentation")

## Description

The Azure Virtual Machine Developer deployment creates a Windows Virtual Machine that provides a pre-configured development environment.  The virtual machine is deployed on the Development Subnet in the virtual machine workloads virtual network. The virtual machine is configured with a public IP address, but is protected by a Network Security Group that only allows access from a specific location.  Boot Diagnostics, Guest OS Diagnostics, and Log Analytics is configured on the Virtual Machine and uses an existing Storage Account.  Diagnostic settings is enabled for all resources utilizing Azure Log Analytics for log and metric storage, and Azure Monitor for Virtual Machines is enabled for Virtual Machine Insights utilizing Azure Log Analytics.  Custom Script Extension is configured to install a series of applications after deployment of the Virtual Machine, including:

- Visual Studio 2019
- Visual Studio Code
- Microsoft Edge
- .NET Core SDK
- PowerShell Core 7
- SQL Server Management Studio
- Windows Admin Center
- Windows Subsystem for Linux
- AZ Copy
- Azure CLI
- Azure PowerShell
- Azure Data Studio
- Cosmos DB Explorer
- Azure Storage Explorer
- Service Bus Explorer
- 7-Zip
- Docker Desktop
- Foxit Reader
- Google Chrome
- Marktext
- Node.js
- Notepad++
- Postman
- Putty
- Visual Studio Extensions

## Files Used

- azure_virtual_machine_development.json
- azure_virtual_machine_development.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, RDP into the Development Virtual Machine and verify the installation of the development tools.
