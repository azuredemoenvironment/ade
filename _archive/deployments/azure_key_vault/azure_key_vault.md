# Azure Key Vault

- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/ "Azure Key Vault Documentation")

## Description

The Azure Key Vault deployment creates an Azure Key Vault, and sets an Access Policy for the user performing the deployment. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

Following the initial deployment of the Azure Key Vault, a series of secondary deployments will configure the following:

- Azure Key Vault secret for a resource password to be used in subsequent deployments
- Azure Key Vault secret for a certificate in Base64 encoded format to be used in subsequent deployments
- Azure Key Vault key for encryption to be used in subsequent deployments

## Files Used

- azure_key_vault.json
- azure_key_vault.parameters.json
- azure_key_vault_secret.azcli
- azure_key_vault.certificate.ps1
- azure_key_vault.key.azcli
- pfx certificate file (saved as /data/wildcard.pfx)

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, execute the following tasks:

Verify the creation of the Azure Key Vault, Access Policy, Secrets, and Keys.

## Additional Notes

To allow for subsequent deployments to succeed, it is necessary to enable 'Soft Delete' on the Key Vault. If the need arises to
remove a Secret from the Key Vault, or remove the entire Key Vault, it is necessary to "purge" the Secret or the Key Vault. Refer to the links below to perform the "purge" function for Secrets and the Key Vault. Additionaly, 'Purge Protection' has been enabled in assocition with the 'Soft Delete' feature.

- [Purging Key Vault Objects](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-soft-delete-cli "Purging Key Vault Objects")
- [Purging a Soft Delete Protected Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-soft-delete-cli "Purging a Soft Delete Protected Key Vault")
