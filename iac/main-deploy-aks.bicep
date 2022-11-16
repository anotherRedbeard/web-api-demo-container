// =========== main.bicep ===========
@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_DS2_v2'

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

// =================================

// Create Log Analytics workspace
module logws './log-analytics-ws.bicep' = {
  name: 'LogWorkspaceDeployment'
  params: {
    name:  substring(clusterName,0,10)
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
  }
}

// Create AKS cluster
module aks './aks.bicep' = {
  name: 'AKSClusterDeployment'
  params: {
    clusterName: clusterName
    location: location
    dnsPrefix: dnsPrefix
    osDiskSizeGB: osDiskSizeGB
    agentCount: agentCount
    agentVMSize: agentVMSize
    logwsid: logws.outputs.id
  }
}

output controlPlaneFQDN string = aks.outputs.controlPlaneFQDN
