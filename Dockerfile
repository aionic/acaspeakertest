# Use official Python image
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for torchaudio
RUN apt-get update && \
    apt-get install -y ffmpeg sox libsox-fmt-all && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
