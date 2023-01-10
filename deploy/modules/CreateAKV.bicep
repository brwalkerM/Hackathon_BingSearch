// Scope
targetScope = 'resourceGroup'

// params
param akv_name string
param location string 
param tenantId string
param AdminGroup_objId string
param adf_msi_objId string

resource vaults_akv_bs_name_resource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: akv_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: AdminGroup_objId // admin user/group
        permissions: {
          keys: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'GetRotationPolicy'
            'SetRotationPolicy'
            'Rotate'
          ]
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
          ]
          certificates: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'ManageContacts'
            'ManageIssuers'
            'GetIssuers'
            'ListIssuers'
            'SetIssuers'
            'DeleteIssuers'
          ]
        }
      }
      {
        tenantId: tenantId
        objectId: adf_msi_objId 
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: false
    vaultUri: 'https://${akv_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}


resource vaults_akv_bs_name_BINGSEARCH_KEY1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
    parent: vaults_akv_bs_name_resource
    name: 'BINGSEARCH-KEY1'
    properties: {
      contentType: 'Bing Search Access Key 1'
      attributes: {
        enabled: true
      }
    }
  }

