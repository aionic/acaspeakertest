# FastAPI Containerized Python API

This project is a simple FastAPI application, containerized with Docker.

## Features
- FastAPI web server
- Docker containerization
- Basic `/` endpoint returning a Hello World message
- Production-ready Gunicorn server with Uvicorn worker

## Getting Started

### Prerequisites
- Docker installed

### Build the Docker image
```powershell
docker build -t fastapi-app .
```

### Run the container
```powershell
docker run -d -p 8000:8000 fastapi-app
```

### Run locally with Gunicorn (optional)
```powershell
gunicorn -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
```

### Access the API
Open your browser and go to: [http://localhost:8000](http://localhost:8000)

### API Docs
Visit [http://localhost:8000/docs](http://localhost:8000/docs) for interactive API documentation.
