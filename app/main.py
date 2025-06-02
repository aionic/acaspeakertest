import os
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from typing import List
import tempfile
import shutil
import logging
from speechbrain.inference import SpeakerRecognition
from fastapi import status

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MODEL_SOURCE = os.getenv("MODEL_SOURCE", "speechbrain/spkrec-ecapa-voxceleb")
MODEL_SAVEDIR = os.getenv("MODEL_SAVEDIR", "pretrained_models/spkrec-ecapa-voxceleb")

app = FastAPI(
    title="FastAPI Speaker Recognition API",
    description="API for comparing multiple WAV files to determine if they are from the same speaker using SpeechBrain.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

try:
    speaker_model = SpeakerRecognition.from_hparams(
        source=MODEL_SOURCE,
        savedir=MODEL_SAVEDIR
    )
except Exception as e:
    logger.error(f"Failed to load speaker model: {e}")
    speaker_model = None

@app.get("/")
def read_root():
    return {"message": "Welcome to the Speaker Recognition API"}

@app.get("/health")
def health_check():
    if speaker_model is None:
        return JSONResponse(status_code=500, content={"status": "error", "detail": "Model not loaded"})
    return {"status": "ok"}

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
    if speaker_model is None:
        logger.error("Speaker model is not loaded.")
        raise HTTPException(status_code=500, detail="Speaker model is not loaded.")
    if len(files) < 2:
        raise HTTPException(status_code=400, detail="At least two wav files are required.")

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
                try:
                    score, _ = speaker_model.verify_files(temp_paths[i], temp_paths[j])
                    results.append({
                        "file1": files[i].filename,
                        "file2": files[j].filename,
                        "similarity_score": float(score)
                    })
                except Exception as e:
                    logger.error(f"Error comparing {files[i].filename} and {files[j].filename}: {e}")
                    results.append({
                        "file1": files[i].filename,
                        "file2": files[j].filename,
                        "error": str(e)
                    })
        return {"results": results}
    except Exception as e:
        logger.error(f"Error processing files: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing files: {e}")
    finally:
        # Clean up temp files
        for path in temp_paths:
            try:
                os.remove(path)
            except Exception as e:
                logger.warning(f"Failed to remove temp file {path}: {e}")

@app.post("/recognize/")
def recognize_speaker(audio_file: bytes):
    # Logic for speaker recognition
    return {"message": "Speaker recognized"}