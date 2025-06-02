# PowerShell script to build and run the FastAPI Docker container

# Build the Docker image
docker build -t fastapi-app .

# Stop and remove any existing container named fastapi-app
docker stop fastapi-app 2>$null | Out-Null
docker rm fastapi-app 2>$null | Out-Null

# Run the Docker container, mapping port 8000
docker run -d --name fastapi-app -p 8000:8000 fastapi-app

Write-Host "FastAPI app is running in Docker. Access it at http://localhost:8000"
