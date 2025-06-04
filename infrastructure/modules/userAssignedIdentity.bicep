@description('The name of the user-assigned managed identity')
param name string

@description('The Azure region for the identity')
param location string

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
}

output identityId string = userAssignedIdentity.id
