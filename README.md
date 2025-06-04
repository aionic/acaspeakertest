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

## Example API Usage

### Compare Speakers
Compare two or more WAV files to determine if they are from the same speaker.

**Request:**
```http
POST /compare-speakers/
Content-Type: multipart/form-data
files: [WAV file 1, WAV file 2, ...]
```

**Example using Python (requests):**
```python
import requests

files = [
    ("files", ("file1.wav", open("file1.wav", "rb"), "audio/wav")),
    ("files", ("file2.wav", open("file2.wav", "rb"), "audio/wav")),
]
response = requests.post("http://localhost:8000/compare-speakers/", files=files)
print(response.json())
```

**Example Response:**
```json
{
  "results": [
    {
      "file1": "file1.wav",
      "file2": "file2.wav",
      "similarity_score": 0.87654321
    }
  ]
}
```

- `similarity_score` closer to 1.0 means more likely the same speaker.
- If an error occurs for a file pair, an `error` field will be present instead of `similarity_score`.
- In internal testing a score of around .7 indicates the same user saying different things

### Health Check
```http
GET /health
```
Returns `{ "status": "ok" }`

## Deploy to Azure Container Apps
Currently the infra deployment creates the infrastructure using the hello world sample docker image
1. Deploy with:
```powershell
cd infrastructure
./deploy.ps1
```
Once everything is provisioned you can link continuous deployment through azure container apps.  This may get cleaned up in a future pull request.

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
