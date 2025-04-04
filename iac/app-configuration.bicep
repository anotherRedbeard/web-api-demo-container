param configStoreName string = 'appconfig${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param keyValueNames array = [
  'myKey'
  'myKey$myLabel'
]
param keyValueValues array = [
  'Key-value without label'
  'Key-value with label'
]
param contentTypes array = [
  'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
]
param tagsArray array = [
  {tag1: 'value1'}
  {tag2: 'value2'}
]

resource configStore 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    encryption: {}
    disableLocalAuth: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
    dataPlaneProxy: {
      authenticationMode: 'Local'
      privateLinkDelegation: 'Disabled'
    }
  }
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = [for (item, i) in keyValueNames: {
  parent: configStore
  name: item
  properties: {
    value: i < length(keyValueValues) ? keyValueValues[i] : ''
    contentType: i < length(contentTypes) ? contentTypes[i] : ''
    tags: i < length(tagsArray) ? tagsArray[i] : {}
  }
}]
