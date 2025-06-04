# Sample PowerShell deployment script for Bicep solution
# Usage: .\deploy.ps1 -ResourceGroupName <name> -TemplateFile <path-to-main.bicep> -ParametersFile <path-to-parameters.json>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [string]$TemplateFile = "./main.bicep",
    [string]$ParametersFile = "./main.parameters.json",
    [string]$Location = "eastus2"
)

Write-Host "Starting deployment to resource group: $ResourceGroupName" -ForegroundColor Green

# Create resource group if it doesn't exist
Write-Host "Checking if resource group exists..." -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroupName --output tsv
if ($rgExists -eq "false") {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create resource group"
        exit 1
    }
}

# Deploy the Bicep template
Write-Host "Deploying Bicep template..." -ForegroundColor Yellow
az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $TemplateFile `
    --parameters @$ParametersFile `
    --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
} else {
    Write-Error "Deployment failed!"
    exit 1
}
