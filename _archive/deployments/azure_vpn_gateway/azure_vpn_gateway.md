# Azure VPN Gateway (Optional)

- [Azure Virtual Network Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview "Azure Virtual Network Documentation")
- [Azure Virtual Network Gateway Documentation](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways "Azure Virtual Network Gateway Documentation")

## Description

The Azure VPN Gateway deployment creates an Azure VNET Gateway of the Basic SKU and the Routing VPN type, a Local Network Gateway resource representing an "on-premises" VPN appliance, and a Connection the connects the Azure VNET Gateway with the "on-premises" appliance. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_vpn_gateway.json
- azure_vpn_gateway.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Pre-Deployment

For instructions on configuring a Windows Server Routing and Remote Access Server for VPN Connectivity, please refer to the article below. It is possible to configure the Routing and Remote Access Server prior to deploying the Virtual Network Gateway.

- [Azure VPN with Windows Server Routing and Remote Access](https://blogs.technet.microsoft.com/jletsch/2016/03/15/lets-configure-azure-site-to-site-vpn-with-rras-in-azure-resource-manager/ "Azure VPN with Windows Server Routing and Remote Access")

Additionaly, it may be necessary to configure Static Routes in the IPv4 section of the Routing and Remote Access Server as shown in the graphic below:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vpn_gateway/vpn1.jpg "Static Routes")

## Post-Deployment

Following the deployment, verify the creation of your Virtual Network Gateway within the Azure Portal under the Virtual Network Gateways blade.
