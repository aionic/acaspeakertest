import os
import sys
import tempfile
from fastapi.testclient import TestClient
import pytest

# Ensure app is importable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../app')))
from main import app

client = TestClient(app)

temp_dir = os.path.join(os.path.dirname(__file__), 'temp')
os.makedirs(temp_dir, exist_ok=True)

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
    # Create two small dummy wav files in the tests/temp dir
    f1_path = os.path.join(temp_dir, 'file1.wav')
    f2_path = os.path.join(temp_dir, 'file2.wav')
    with open(f1_path, 'wb') as f1, open(f2_path, 'wb') as f2:
        f1.write(b'RIFF....WAVEfmt ')
        f2.write(b'RIFF....WAVEfmt ')
    files = [
        ("files", ("file1.wav", open(f1_path, "rb"), "audio/wav")),
        ("files", ("file2.wav", open(f2_path, "rb"), "audio/wav")),
    ]
    response = client.post("/compare-speakers/", files=files)
    for _, (name, f, _) in files:
        f.close()
    assert response.status_code == 200
    assert "results" in response.json()
    # Clean up temp files
    os.remove(f1_path)
    os.remove(f2_path)
