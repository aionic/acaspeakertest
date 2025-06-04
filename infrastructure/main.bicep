@description('A seed value to apply to all resource names for uniqueness and convention')
param seed string

@description('The Azure region for all resources')
param location string = resourceGroup().location

// Azure best practices for naming
// Log Analytics Workspace: letters, numbers, hyphens, <= 63 chars, start/end with letter/number
var logAnalyticsWorkspaceName = 'law-${seed}'
// Container App Environment: lowercase, alphanumeric, hyphens, <= 32 chars
var managedEnvironmentName = 'cae-${seed}'
// Container Registry: lowercase, alphanumeric only, <= 50 chars
var registryName = toLower('cr${seed}')
// User Assigned Identity: lowercase, alphanumeric, hyphens, <= 128 chars
var userAssignedIdentityName = 'id-${seed}'
// Container App: lowercase, alphanumeric, hyphens, <= 32 chars
var containerAppName = 'ca-${seed}'

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
  }
}

module managedEnv 'modules/managedEnvironment.bicep' = {
  name: 'managedEnv'
  params: {
    name: managedEnvironmentName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

module registry 'modules/containerRegistry.bicep' = {
  name: 'registry'
  params: {
    name: registryName
    location: location
  }
}

module userAssignedIdentity 'modules/userAssignedIdentity.bicep' = {
  name: 'userAssignedIdentity'
  params: {
    name: userAssignedIdentityName
    location: location
  }
}

module containerApp 'modules/containerApp.bicep' = {
  name: 'containerApp'
  params: {
    name: containerAppName
    location: location
    environmentId: managedEnv.outputs.environmentId
    containerImage: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    targetPort: 80
  }
}

// Outputs for integration with CI/CD or other automation
output resourceGroupName string = resourceGroup().name
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output containerAppEnvironmentId string = managedEnv.outputs.environmentId
output containerRegistryId string = registry.outputs.registryId
output containerRegistryName string = registryName
output userAssignedIdentityId string = userAssignedIdentity.outputs.identityId
output containerAppId string = containerApp.outputs.appId
output containerAppUrl string = containerApp.outputs.appUrl




