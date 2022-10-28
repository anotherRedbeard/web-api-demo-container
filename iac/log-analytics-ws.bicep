// =========== ws.bicep ===========
param name string
param location string = resourceGroup().location
var lawName = toLower('red-logworkspace-${name}-01')

// =================================

// Create log analytics workspace
resource logws 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018' // Standard
    }
  }
}

// Return the workspace identifier
output id string = logws.id
output lawName string = logws.name
