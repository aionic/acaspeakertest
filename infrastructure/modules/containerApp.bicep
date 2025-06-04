@description('The name of the Container App')
param name string

@description('The Azure region for the app')
param location string

@description('The managed environment resource ID')
param environmentId string

@description('The container image to deploy (leave empty to deploy no container)')
param containerImage string

@description('The target port for the container (optional)')
param targetPort int = 80

resource containerApp 'Microsoft.App/containerapps@2023-05-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: containerImage != '' ? {
        external: true
        targetPort: targetPort
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      } : null
      registries: []
    }
    template: {
      containers: containerImage != '' ? [
        {
          name: name
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ] : []
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: []
      }
    }
  }
}

output appId string = containerApp.id
output appUrl string = containerImage != '' ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''
