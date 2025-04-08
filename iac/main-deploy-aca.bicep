// =========== main.bicep ===========
@minLength(1)
@description('The location of the container app service')
param location string = resourceGroup().location

@minLength(5)
@maxLength(25)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@maxLength(10)
@minLength(2)
@description('The product prefix name for all the services.')
param productPrefix string 

@maxLength(10)
@minLength(2)
@description('The region abbreviation.')
param regionAbbrv string 

@description('Specifies the name of the App Configuration store.')
param configStoreName string = 'appconfig${uniqueString(resourceGroup().id)}'

@description('Specifies the names of the key-value resources. The name is a combination of key and label with $ as delimiter. The label is optional.')
param keyValueNames array = [
  'myKey'
  'myKey$myLabel'
]

@description('Specifies the values of the key-value resources. It\'s optional')
param keyValueValues array = [
  'Key-value without label'
  'Key-value with label'
]

@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentTypes array = [
  'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
]

@description('Adds tags for the key-value resources. It\'s optional')
param tagsArray array = [
  {tag1: 'value1'}
  {tag2: 'value2'}
]

@description('The name of the container app environment.')
param containerAppEnvName string = '<environment-name>'

var fullAcrName = toLower('${productPrefix}${regionAbbrv}${acrName}')
var fullAppConfigName = toLower('${productPrefix}-${regionAbbrv}-${configStoreName}')

// =================================

// Create Log Analytics workspace
module logws './log-analytics-ws.bicep' = {
  name: 'LogWorkspaceDeployment'
  params: {
    prefix: productPrefix
    name: regionAbbrv
    location: location
  }
}

// Create Container Registry
module acr 'container-registry.bicep' = {
  name: 'ContainerRegistryDeployment'
  params: {
    acrName: fullAcrName
    location: location
    acrSku: acrSku
    // Pass principal IDs only if they are defined
    resourcePrincipalId: ''
    slotResourcePrincipalId: ''
  }
}

// Create container app
module containerApp './container-app.bicep' = {
  name: 'ContainerAppDeployment'
  params: {
    location: location
    envName: containerAppEnvName
    lawCustomerId: logws.outputs.lawCustomerId // Corrected to use the correct output property
    lawSharedKey: logws.outputs.lawPrimarySharedKey // Corrected to use the correct output property
  }
}

// Create app configuration
module appConfig './app-configuration.bicep' = {
  name: 'AppConfigurationDeployment'
  params: {
    configStoreName: fullAppConfigName
    location: location
    keyValueNames: keyValueNames
    keyValueValues: keyValueValues
    contentTypes: contentTypes
    tagsArray: tagsArray
    connectingResourcePrincipalId: containerApp.outputs.acaEnvPrincipalId // Assuming the container app has a managed identity
  }
}
