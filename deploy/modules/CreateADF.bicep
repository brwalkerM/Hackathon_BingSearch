// Scope
targetScope = 'resourceGroup'

// Params
param adfName string
param location string // Pass in from PowerShell script


// Deploy
resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  properties:{
    publicNetworkAccess: 'Enabled'
  }
  location: location
  identity:{
    type: 'SystemAssigned'
  }
}


output adf object = adf

