# PowerShell script to deploy Azure resources using Bicep

param(
    [string]$parametersFile = "./main.parameters.json"
)

# Log in to Azure
az login

# Extract resource group name from parameters file
$resourceGroupName = (Get-Content $parametersFile | ConvertFrom-Json).parameters.resourceGroupName.value
$location = (Get-Content $parametersFile | ConvertFrom-Json).parameters.location.value

# Create the resource group
az group create --name $resourceGroupName --location $location

# Deploy the Bicep template
az deployment group create --resource-group $resourceGroupName --template-file ./main.bicep --parameters @$parametersFile
