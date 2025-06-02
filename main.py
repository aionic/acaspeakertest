from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from typing import List
import tempfile
import shutil
import os
from speechbrain.inference import SpeakerRecognition

app = FastAPI()

# Load the speaker recognition model once
speaker_model = SpeakerRecognition.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir="pretrained_models/spkrec-ecapa-voxceleb"
)

@app.post("/compare-speakers/")
async def compare_speakers(files: List[UploadFile] = File(...)):
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

        # Extract embeddings
        embeddings = [speaker_model.encode_batch(tmp_path).squeeze(0) for tmp_path in temp_paths]

        # Compare all pairs and return similarity scores
        results = []
        for i in range(len(embeddings)):
            for j in range(i + 1, len(embeddings)):
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
