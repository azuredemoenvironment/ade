# Azure DNS

- [Azure DNS Documentation](https://docs.microsoft.com/en-us/azure/dns/ "Azure DNS Documentation")
- [Azure App Service Custom Domain Documentation](https://docs.microsoft.com/en-us/Azure/app-service/app-service-web-tutorial-custom-domain "Azure App Service Custom Documentation")

## Description

The Azure DNS deployment creates a series of A Records and CNAME records for publicly accessible services. A Records are created for the Public IP Addresses of the JumpBox VM, the Developer VM, the NTIER VMs, the Virtual Machine Scale Set, Image Resizer, SQL ToDo and WordPress, CNAME records are created for HelloWorld (Traffic Manager.), and Custom Domains are created for the HelloWorld App Services.

## Files Used

- Azure_DNS.azcli

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following the deployment, verify the creating of the DNS Records and the Custom Domain Name settings on the Hello World App Services.
