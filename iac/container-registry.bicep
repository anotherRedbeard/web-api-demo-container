@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

param resourcePrincipalId string
param slotResourcePrincipalId string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

@description('This is the built-in Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

//you will need write permission to do this which is more than a Contributor
resource AssignAcrPullToResource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (resourcePrincipalId != '') {
  name: guid(acrResource.id, resourcePrincipalId, 'AssignAcrPullToAks')       // want consistent GUID on each run
  scope: acrResource
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: resourcePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: acrPullRoleDefinition.id
  }
}

//you will need write permission to do this which is more than a Contributor
resource AssignAcrPullToSlotResource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (slotResourcePrincipalId != '') {
  name: guid(acrResource.id, slotResourcePrincipalId, 'AssignAcrPullToAks')       // want consistent GUID on each run
  scope: acrResource
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: slotResourcePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: acrPullRoleDefinition.id
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
output registryName string = acrResource.name
