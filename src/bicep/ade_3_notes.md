# ADE

- Make ADE more usable for our customers (ISVs and Startups)
- Leverage CAF / WAF / Landing Zones from and ISV and Startup perspective
- Build on the demo!
  - Add / remove soutions that are / are not necessary
- Modular deployment for demo purposes
  - Availability Zone option
- Still needs to be valuable for us as engineers
- Integrated into GitHub Actions
- Central instance?
- Improve consistency?
  - Virtual machine deployment issues
- Move policy initiatives to Resource Group scope
- Introduce configuration maps (prod, staging, demo)
- Consider separate pipeline for application deployment
- Leverage uniqueString for resources that need globally unique names

## Azure Management

### Log Analytics

- Implement additional solutions
  - Automation
  - Azure SQL Analytics
  - DNS Analytics
  - Logic Apps Management Analytics

### Policy

- Removal of the location policy definition?
- Removal of the Virtual Machine SKU policy definition
- Leveraging Policy for "Deploy if not exist" Policies
  - Azure Monitor for VMs
  - etc.
- Scope Azure Policy to ADE specific Resource Groups

## Azure Identity

- Merge into Security Deployment
- Additional identities

## Azure Security

### App Config

- Review implementations and best practices
- Implement App Config everywhere it can be used

## Azure Networking

## Azure Container Registry

- Consider implementing Private Endpoints and Managed Identity authentication

## Azure Databases

## Azure Virtual Machines

## Azure App Services

## Azure Kubernetes Services

## Azure Container Instances

## Azure Load Balancers

## Service Cleanup

## Azure Alerts

## Azure DNS
