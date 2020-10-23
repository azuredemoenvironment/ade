# Azure Virtual Machine Windows 10 Client

- [Azure Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview "Azure Virtual Machine Documentation")

## Description

The Azure Virtual Machine Windows 10 Client deployment creates a Windows 10 2004 client on the clientServices Subnet.  This client is used to test routing via the Azure Firewall.

## Files Used

- azure_virtual_machine_w10client.json
- azure_virtual_machine_w10client.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, RDP to the Virtual Machine and attempt to access the following websites:

- <https://www.microsoft.com>
- <https://www.github.com>
- <https://www.bing.com>

Accessing microsoft.com and github.com should be successful, but accessing bing.com should fail.
