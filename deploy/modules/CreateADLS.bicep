// Scope
targetScope = 'resourceGroup'

// params
param adls_name string
param location string 
param adfObj object
param adf_name string
 
//RBAC Roles
var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageBlobDataContributorRoleID = resourceId('Microsoft.Authorization/roleDefinitions',storageBlobDataContributorRole)
var SBDCAdfRoleAssignmentName = guid(subscription().subscriptionId,adf_name,'Storage Blob Data Contributor')

// deploy
resource adls_name_resource 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: adls_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}



resource adls_name_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  parent: adls_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}


resource adls_name_default_asadefault 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  parent: adls_name_default
  name: 'asadefault'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource rbacadfSBC 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: SBDCAdfRoleAssignmentName
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleID
    principalId: adfObj.identity.principalId
  }
} 

output adls object = adls_name_resource
