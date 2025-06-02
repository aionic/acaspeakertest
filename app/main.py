from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from typing import List
import tempfile
import shutil
import os
from speechbrain.inference import SpeakerRecognition
from fastapi import status

app = FastAPI(
    title="FastAPI Speaker Recognition API",
    description="API for comparing multiple WAV files to determine if they are from the same speaker using SpeechBrain.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Load the speaker recognition model once
speaker_model = SpeakerRecognition.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir="pretrained_models/spkrec-ecapa-voxceleb"
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Speaker Recognition API"}

@app.post(
    "/compare-speakers/",
    summary="Compare speakers in uploaded WAV files",
    description="Upload at least two WAV files. The API will compare all pairs and return similarity scores.",
    status_code=status.HTTP_200_OK,
    response_description="Similarity scores for all file pairs."
)
async def compare_speakers(
    files: List[UploadFile] = File(..., description="Upload at least two WAV files.")
):
    if len(files) < 2:
        return JSONResponse(status_code=400, content={"error": "At least two wav files are required."})

    temp_paths = []
    try:
        # Save uploaded files to temp files
        for file in files:
            suffix = os.path.splitext(file.filename)[-1]
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                shutil.copyfileobj(file.file, tmp)
                temp_paths.append(tmp.name)

        # Compare all pairs and return similarity scores
        results = []
        for i in range(len(temp_paths)):
            for j in range(i + 1, len(temp_paths)):
                score, _ = speaker_model.verify_files(temp_paths[i], temp_paths[j])
                results.append({
                    "file1": files[i].filename,
                    "file2": files[j].filename,
                    "similarity_score": float(score)
                })
        return {"results": results}
    finally:
        # Clean up temp files
        for path in temp_paths:
            os.remove(path)

@app.post("/recognize/")
def recognize_speaker(audio_file: bytes):
    # Logic for speaker recognition
    return {"message": "Speaker recognized"}