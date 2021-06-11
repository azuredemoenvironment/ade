# Azure Application Gateway

- [Azure Application Gateway Documentation](https://docs.microsoft.com/en-us/azure/application-gateway/ "Azure Application Gateway Documentation")
- [Azure Application Gateway SSL Termination with Key Vault Documentation](https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs "Azure Application Gateway SSL Termination with Key Vault Documentation")

## Description

The Azure Application Gateway deployment creates an Azure Application Gateway at
the WAFv2 SKU. The Application Gateway provides Layer 7 access and SSL
Termination for multiple deployed App Services, and Virtual Machines. The Web
Application Firewall is configured in Prevention Mode. Diagnostic settings are
enabled for all resources utilizing Azure Log Analytics for log and metric
storage.

## Files Used

- azure_application_gateway.json
- azure_application_gateway.parameters.json

The values for all parameters will be automatically generated based on the
values provided at script execution.

## Post-Deployment

Following deployment verify the creation of the Application Gateway.
