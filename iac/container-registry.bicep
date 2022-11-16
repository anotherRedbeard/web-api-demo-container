@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

param aksKubletPrincipalId string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

resource  AssignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, acrName, aksKubletPrincipalId, 'AssignAcrPullToAks')       // want consistent GUID on each run
  scope: acrResource
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: aksKubletPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
