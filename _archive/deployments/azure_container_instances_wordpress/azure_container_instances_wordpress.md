# Azure Container Instances (WordPress)

- [Azure Container Instances Documentation](https://docs.microsoft.com/en-us/azure/container-instances/ "Azure Container Instances Documentation")

## Description

The Azure Container Instances Wordpress deployment creates a three-tier application using Azure Container Instances. A Storage Account share, web app, and database server are created using the latest versions of their Docker images. Public access to the Wordpress deployment is provided by the Application Gateway in a future deployment.

## Files Used

- azure_container_instances_wordpress.json
- azure_container_instances_wordpress.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the deployment of the three Container Groups.
