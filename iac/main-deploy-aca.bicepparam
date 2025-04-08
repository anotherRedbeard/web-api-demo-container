using './main-deploy-aca.bicep'

param location = 'eastus2'
param acrName = 'containerreg01'
param acrSku = 'Basic'
param productPrefix = 'red'
param regionAbbrv = 'eus2'
param configStoreName = 'academo-appconfig'
param contentTypes = [
  'string'
  'string'
  'string'
  'string'
  'string'
  'string'
  'string'
  'string'
]
param tagsArray = [
  {dev: 'dev'}
]
param containerAppEnvName = 'dev-env'
