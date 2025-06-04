@description('The name of the Container Registry')
param name string

@description('The Azure region for the registry')
param location string

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    // Add or parameterize more properties as needed
  }
}

output registryId string = registry.id
output loginServer string = registry.properties.loginServer
output registryName string = registry.name
