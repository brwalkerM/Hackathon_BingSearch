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


