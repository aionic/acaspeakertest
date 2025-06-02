from fastapi import FastAPI
from speechbrain.inference import SpeakerRecognition

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

@app.post("/recognize/")
def recognize_speaker(audio_file: bytes):
    # Logic for speaker recognition
    return {"message": "Speaker recognized"}