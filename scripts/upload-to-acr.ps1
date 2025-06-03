param(
    [string]$acrName = "acatest", #replace with your ACR name
    [string]$imageName = "speakertest-app",
    [string]$tag = "latest",
    [string]$resourceGroupName = "ACA-Speakertest" #replace with your resource group name
)

if (-not $acrName) {
    $acrName = Read-Host "Enter the Azure Container Registry name (acrName)"
}
if (-not $imageName) {
    $imageName = Read-Host "Enter the Docker image name (imageName) [default: speakertest-app]"
    if (-not $imageName) { $imageName = "speakertest-app" }
}
if (-not $tag) {
    $tag = Read-Host "Enter the image tag [default: latest]"
    if (-not $tag) { $tag = "latest" }
}
if (-not $resourceGroupName) {
    $resourceGroupName = Read-Host "Enter the Azure resource group name (resourceGroupName)"
}

# Log in to Azure (uncomment if needed)
# az login

# Get ACR login server
$acrLoginServer = az acr show --name $acrName --resource-group $resourceGroupName --query loginServer -o tsv

# Build the Docker image (ensure correct path to Dockerfile)
docker build -f ../Dockerfile -t $imageName ..

# Tag the image for ACR
docker tag $imageName "$acrLoginServer/$imageName`:$tag"

# Log in to ACR
az acr login --name $acrName

# Push the image to ACR
docker push "$acrLoginServer/$imageName`:$tag"

Write-Host "Image pushed: $acrLoginServer/$imageName`:$tag"
