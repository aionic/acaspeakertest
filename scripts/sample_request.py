import requests
import os

# Set your file paths here
first_wav_path = r"C:\\Users\\anevico\\OneDrive - Microsoft\\Documents\\Sound Recordings\\an-test123.wav"
second_wav_path = r"C:\\Users\\anevico\\OneDrive - Microsoft\\Documents\\Sound Recordings\\an-test321.wav"

file_paths = [
    ("first.wav", first_wav_path),
    ("second.wav", second_wav_path)
]

wav_files = []
for label, path in file_paths:
    if not os.path.isfile(path):
        print(f"File not found or inaccessible: {path}")
        exit(1)
    try:
        wav_files.append(("files", (label, open(path, "rb"), "audio/wav")))
    except Exception as e:
        print(f"Could not open file {path}: {e}")
        exit(1)

response = requests.post("http://localhost:8000/compare-speakers/", files=wav_files)
print(response.status_code)
try:
    print(response.json())
except Exception:
    print(response.text)
