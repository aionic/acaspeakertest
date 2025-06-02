# FastAPI Speaker Recognition API

This project is a containerized FastAPI application for comparing multiple WAV files to determine if they are from the same speaker, using SpeechBrain and deployable to Azure Container Apps.

## Features
- FastAPI web server using gunicorn
- Speaker comparison endpoint (`/compare-speakers/`)
- Health check endpoint (`/health`)
- Containerized with Docker
- Production-ready with Gunicorn and Uvicorn worker
- Infrastructure-as-Code (Bicep) for Azure deployment

## Project Structure
```
app/                # FastAPI application code
requirements/       # Python dependencies
scripts/            # Utility scripts (run, test)
infrastructure/     # Bicep, parameters, and deployment scripts
```

## Getting Started

### Prerequisites
- Docker
- Azure CLI (for Azure deployment)

### Build and Run Locally (Docker)
```powershell
cd scripts
./run_docker.ps1
```
The API will be available at [http://localhost:8000](http://localhost:8000)

### Test the API
Use the provided script:
```powershell
cd scripts
python sample_request.py
```
Or use Swagger UI at [http://localhost:8000/docs](http://localhost:8000/docs)

### Health Check
```http
GET /health
```
Returns `{ "status": "ok" }`

## Deploy to Azure Container Apps
1. Build and push your Docker image to Azure Container Registry (ACR).
2. Update `infrastructure/main.parameters.json` with your image name and registry.
3. Deploy with:
```powershell
cd infrastructure
./deploy.ps1
```

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
