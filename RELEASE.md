# Azure Demo Environment v1.1.0 Update

Welcome to v1.1.0 of the Azure Demo Environment. The main focus of this update
is Private Endpoints! A new deployment, called Inspector Gadget, utilizes
Private Endpoints and Regional VNET Integration to demo a private application
with database backend.

## Deployment Updates

### azure key vault

- added a pfx-certificate entry under certificates for use with azure app
  services

### azure identity

- configured the microsoft.azure.app.service service principal with get
  permissions for both secrets and certificates to be used with azure app
  services

### azure networking

- updated vnet-alias-region-03
  - added subnet 'inspectorGadget-appservice-privateendpoint' with address
    prefix of 10.103.30.0/24
    - disabled privateEndpointNetworkPolicies
  - added subnet 'inspectorGadget-appservice-vnetintegration' with address
    prefix of 10.103.31.0/24
    - created a subnet delegation for Microsoft.Web/serverFarms
  - added subnet 'inspectorGadget-azuresql-privateendpoint' with address prefix
    of 10.103.32.0/24
    - disabled privateEndpointNetworkPolicies

### azure private dns

- new deployment
- creates private dns zones for privatelink.azurewebsites.net and
  privatelinke.windows.database.net

### azure container instances wordpress

- updated azure storage apis to latest version to resolve a deployment issue

### azure kubernetes services

- updated kubernetes version to 1.18.14

### azure app service plan primary region

- updated the sku of the app service plan to p1v3 to take advantage of app
  service regional vnet integration and app service private link
- configured a script to scale down the app service plan to p1v2 after initial
  deployment

### azure private link inspector gadget

- new deployment
- creates an azure app service, azure sql database, and private endpoints to
  demo private accessing an application via azure private link

### azure app service helloworld primary region

- configured for https only
- configured custom domain name binding based on user input
- configured ssl binding based on user provided ssl certificate (from key vault)

### azure app service helloworld secondary region

- configured for https only
- configured custom domain name binding based on user input
- configured ssl binding based on user provided ssl certificate (from key vault)

### azure application gateway

- added configuration for inspector gadget app service (backend pool, listener,
  http setting, health probe, routing rule)
- added http to https redirection rules for all sites

### azure dns

- added a record for inspector gadget app service pointing to public ip address
  of application gateway
