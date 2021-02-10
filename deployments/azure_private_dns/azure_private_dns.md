# Azure Private DNS

- [Azure Private DNS Documentation](https://docs.microsoft.com/en-us/azure/dns/private-dns-overview "Azure Private DNS Documentation")

## Description

The Azure Private DNS deployment creates a series of Azure Private DNS Zones for
use with Private Link and Private Endpoints. The following zones are created:

- privatelink.azurewebsites.net
- privatelink.windows.database.net

Each private DNS that is created, is linked to all of the Virtual Networks
deployed within the Azure Demo Environment. This link allows other resources
within the Virtual Networks to utilized the Azure Private DNS Zones.

## Files Used

- azure_private_dns.json
- azure_private_dns.parameters.json

The values for all parameters will be automatically generated based on the
values provided at script execution.

## Post-Deployment

Following the deployment, verify the creation of the Azure Private DNS Zones.
