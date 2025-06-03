import os
import sys
import tempfile
from fastapi.testclient import TestClient
import pytest

# Ensure app is importable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../app')))
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "Welcome" in response.json()["message"]

def test_compare_speakers_invalid():
    # Should fail with less than 2 files
    response = client.post("/compare-speakers/", files={})
    assert response.status_code == 422 or response.status_code == 400

@pytest.mark.skipif(os.environ.get("SKIP_SPEAKER_TESTS"), reason="Skip heavy model test")
def test_compare_speakers_valid():
    # Create two small dummy wav files in a guaranteed-writable temp dir
    with tempfile.NamedTemporaryFile(suffix='.wav', dir=tempfile.gettempdir()) as f1, tempfile.NamedTemporaryFile(suffix='.wav', dir=tempfile.gettempdir()) as f2:
        f1.write(b'RIFF....WAVEfmt ')  # minimal header
        f1.flush()
        f2.write(b'RIFF....WAVEfmt ')
        f2.flush()
        files = [
            ("files", ("file1.wav", open(f1.name, "rb"), "audio/wav")),
            ("files", ("file2.wav", open(f2.name, "rb"), "audio/wav")),
        ]
        response = client.post("/compare-speakers/", files=files)
        assert response.status_code == 200
        assert "results" in response.json()
