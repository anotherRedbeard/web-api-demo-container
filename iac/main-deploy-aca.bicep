// =========== main.bicep ===========
@minLength(1)
@description('The location of the container app service')
param location string = resourceGroup().location

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@maxLength(10)
@minLength(2)
@description('The prefix name of the app service to create.')
param app_service_prefix string 

@maxLength(10)
@minLength(2)
@description('The postfix name of the app service to create.')
param app_service_postfix string 

// =================================

// Create Log Analytics workspace
module logws './log-analytics-ws.bicep' = {
  name: 'LogWorkspaceDeployment'
  params: {
    prefix: app_service_prefix
    name: app_service_postfix
    location: location
  }
}

// Create Container Registry
module acr 'container-registry.bicep' = {
  name: 'ContainerRegistryDeployment'
  params: {
    acrName: acrName
    location: location
    acrSku: acrSku
    // Pass principal IDs only if they are defined
    resourcePrincipalId: ''
    slotResourcePrincipalId: ''
  }
}
