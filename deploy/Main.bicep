// Scope
targetScope = 'subscription'

// Params
param tenantId string = subscription().tenantId
param subId string = subscription().subscriptionId
param RGName  string 
param OHUser string 
param location string 
param AdminGroup_objId string
param sqlAdmin string
@secure()
param sqlAdminPassword string

// Variables
var adf_name = 'adf-bs-${OHUser}'
var akv_name = 'akv-bs-${OHUser}'
var asa_name = 'asa-bs-${OHUser}'
var adls_name = 'adlsbs${OHUser}'
var cdb_name = 'cdb-bs-${OHUser}'

// Deploy
// Resource Group
resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RGName
  location: location
}

// ADF
module CreateADF 'Modules/CreateADF.bicep' = {
  scope: ResourceGroup
  name: 'CreateADF'
  params: {
    adfName: adf_name
    location: location
  }
}
output adfObj object = CreateADF.outputs.adf

// AKV
module CreateAKV 'Modules/CreateAKV.bicep' = {
  scope: ResourceGroup
  name: 'CreateAKV'
  params: {
    akv_name: akv_name
    location: location
    tenantId: tenantId
    AdminGroup_objId: AdminGroup_objId
    adf_msi_objId: CreateADF.outputs.adf.identity.principalId
  }
}

// ASA
module CreateASA 'modules/CreateASA.bicep' = {
  scope: ResourceGroup
  name: 'CreateASA'
  params: {
    subId: subId
    RGName: RGName
    asa_name: asa_name
    location: location
    AdminGroup_objId: AdminGroup_objId
    sqlAdmin: sqlAdmin
    sqlAdminPassword: sqlAdminPassword
    adlsObj: CreateADLS.outputs.adls
  }
}
output asaObj object = CreateASA.outputs.asa

// ADLS
module CreateADLS 'Modules/CreateADLS.bicep' = {
  scope: ResourceGroup
  name: 'CreateADLS'
  params: {
    adls_name: adls_name
    location: location
    adfObj: CreateADF.outputs.adf
    adf_name: adf_name
  }
}
output adlsObj object = CreateADLS.outputs.adls

// CosmosDB
module CreateCDB 'Modules/CreateCDB.bicep' = {
  scope: ResourceGroup
  name: 'CreateCDB'
  params: {
    cdb_name: cdb_name
    location: location
   }
}








