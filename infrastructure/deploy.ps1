# PowerShell script to deploy Azure resources using Bicep

param(
    [string]$parametersFile = "./main.parameters.json"
)

function Deploy-SpeakerRecInfrastructure {
    param(
        [string]$parametersFile = "./main.parameters.json"
    )
    # Extract resource group name from parameters file
    $resourceGroupName = (Get-Content $parametersFile | ConvertFrom-Json).parameters.resourceGroupName.value
    $location = (Get-Content $parametersFile | ConvertFrom-Json).parameters.location.value

    # Create the resource group
    az group create --name $resourceGroupName --location $location

    # Deploy the Bicep template
    az deployment group create --resource-group $resourceGroupName --template-file ./main.bicep --parameters @$parametersFile

    # Assign AcrPull role to the managed identity for the ACR
    $acrName = (Get-Content $parametersFile | ConvertFrom-Json).parameters.acrName.value
    $containerAppName = (Get-Content $parametersFile | ConvertFrom-Json).parameters.containerAppName.value
    $acrId = az acr show --name $acrName --resource-group $resourceGroupName --query id -o tsv
    $uamiId = az identity show --name "$containerAppName-uami" --resource-group $resourceGroupName --query principalId -o tsv
    az role assignment create --assignee $uamiId --role "AcrPull" --scope $acrId
}

function Remove-SpeakerRecResourceGroup {
    param(
        [string]$parametersFile = "./main.parameters.json"
    )
    $resourceGroupName = (Get-Content $parametersFile | ConvertFrom-Json).parameters.resourceGroupName.value
    Write-Host "Deleting resource group: $resourceGroupName"
    az group delete --name $resourceGroupName --yes --no-wait
}

if ($MyInvocation.InvocationName -eq '.') {
    Write-Host "\nAvailable functions:"
    Write-Host "  Deploy-SpeakerRecInfrastructure - Deploys the infrastructure."
    Write-Host "  Remove-SpeakerRecResourceGroup - Deletes the resource group."
    Write-Host "\nExamples:"
    Write-Host "  . ./deploy.ps1; Deploy-SpeakerRecInfrastructure"
    Write-Host "  . ./deploy.ps1; Remove-SpeakerRecResourceGroup"
} else {
    Deploy-SpeakerRecInfrastructure
}
