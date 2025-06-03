# Use official Python image
FROM python:3.11-slim

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

# Install system dependencies for torchaudio
RUN apt-get update && \
    apt-get install -y ffmpeg sox libsox-fmt-all && \
    rm -rf /var/lib/apt/lists/*

COPY requirements/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r ./requirements.txt

COPY app ./app

# Create the model cache directory and set permissions (ignore errors if it doesn't exist yet)
RUN mkdir -p /app/pretrained_models && \
    chown -R appuser:appuser /app && \
    chmod -R u+rwX /app/pretrained_models

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl --fail http://localhost:8000/health || exit 1

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:8000"]
