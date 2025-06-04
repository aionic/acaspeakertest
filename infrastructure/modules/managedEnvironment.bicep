@description('The name of the Container App environment')
param name string

@description('The Azure region for the environment')
param location string

@description('The Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

// Reference the existing Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: split(logAnalyticsWorkspaceId, '/')[8]
}

resource managedEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

output environmentId string = managedEnv.id
