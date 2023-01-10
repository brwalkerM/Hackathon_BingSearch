// Scope
targetScope = 'resourceGroup'

// params
param subId string
param RGName string
param asa_name string
param location string 
param AdminGroup_objId string
param sqlAdmin string
@secure()
param sqlAdminPassword string   
param adlsObj object 

// vars
//var adlsID = '/subscriptions/${adlsObj.subscriptionId}/resourceGroups/${adlsObj.resourceGroupName}/providers/${adlsObj.resourceId}'
var adlsID2 = resourceId('Microsoft.Storage/storageAccounts',adlsObj.resourceId)

resource asa_name_resource 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: asa_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: adlsID2
      createManagedPrivateEndpoint: false
      accountUrl: 'https://adlsbs.dfs.core.windows.net'
      filesystem: 'asadefault'
    }
    encryption: {
    }
    connectivityEndpoints: {
      web: 'https://web.azuresynapse.net?workspace=%2fsubscriptions%2f${subId}%2fresourceGroups%2f${RGName}%2fproviders%2fMicrosoft.Synapse%2fworkspaces%2f${asa_name}'
      dev: 'https://${asa_name}.dev.azuresynapse.net'
      sqlOnDemand: '${asa_name}-ondemand.sql.azuresynapse.net'
      sql: '${asa_name}.sql.azuresynapse.net'
    }
    managedResourceGroupName: 'mrg-${asa_name}'
    sqlAdministratorLogin: sqlAdmin
    sqlAdministratorLoginPassword: sqlAdminPassword
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
    cspWorkspaceAdminProperties: {
      initialWorkspaceAdminObjectId: AdminGroup_objId
    }
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: false
  }
}

resource Microsoft_Synapse_workspaces_azureADOnlyAuthentications_asa_name_default 'Microsoft.Synapse/workspaces/azureADOnlyAuthentications@2021-06-01' = {
  parent: asa_name_resource
  name: 'default'
  properties: {
    azureADOnlyAuthentication: false
  }
}

resource Microsoft_Synapse_workspaces_dedicatedSQLminimalTlsSettings_asa_name_default 'Microsoft.Synapse/workspaces/dedicatedSQLminimalTlsSettings@2021-06-01' = {
  parent: asa_name_resource
  name: 'default'
  properties: {
    minimalTlsVersion: '1.2'
  }
}

resource asa_name_allowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: asa_name_resource
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}


resource Microsoft_Synapse_workspaces_securityAlertPolicies_asa_name_Default 'Microsoft.Synapse/workspaces/securityAlertPolicies@2021-06-01' = {
  parent: asa_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}


output asa object = asa_name_resource
