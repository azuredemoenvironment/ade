# Azure Virtual Machine NTier

- [Azure N-Tier Architecture Documentation](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/n-tier/n-tier-sql-server "Azure N-Tier Architecture Documentation")
- [Azure Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview "Azure Virtual Machine Documentation")
- [Azure Monitor for VMs Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/vminsights-overview "Azure Monitor for VMs Documentation")
- [Azure Availability Set Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-availability-sets "Azure Availability Set Documentation")
- [Azure Load Balancer Documentation](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview "Azure Load Balancer Documentation")

## Description

The Azure Virtual Machine NTier deployment creates the following infrastructure to support a standard N-Tier Application Architecture on IaaS:

- 2 Availability Sets for each tier of the Application
- 1 Azure Internal Load Balancer
- 2 Ubuntu Servers in the Web Application Tier
- 2 Ubuntu Servers in the Database Tier

Public access to the application will be provided during the deployment of the Azure Application Gateway.  Diagnostic settings is enabled for all resources utilizing Azure Log Analytics for log and metric storage, and Azure Monitor for Virtual Machines is enabled for Virtual Machine Insights utilizing Azure Log Analytics.

(Application and Database coming soon.)

## Files Used

- azure_virtual_machine_ntier.json
- azure_virtual_machine_ntier.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, SSH into each Virtual Machine to verify access.
