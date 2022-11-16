param clusterName string
param location string = resourceGroup().location
param dnsPrefix string
param osDiskSizeGB int = 0
param agentCount int = 3
param agentVMSize string = 'Standard_DS2_v2'
param logwsid string

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logwsid
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'notepool1'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: logwsid
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
output agentPoolIdentityId string =  aks.properties.identityProfile.kubletidentity.objectId
