import base64
import requests
from PIL import Image
import io

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
MODEL = "qwen2.5-vl:72b"

# --- prepare text and image ---
txt_prompt = "Describe what you see in this image and suggest an artistic caption."
image_path = "Cat 1.jpg"  # or any image available in /app

def encode_image(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

try:
    image_b64 = encode_image(image_path)
except FileNotFoundError:
    image_b64 = None
    print(f"⚠️ Warning: {image_path} not found, running text-only test.")

def ask_ollama(prompt, image_b64=None):
    payload = {"model": MODEL, "prompt": prompt}
    if image_b64:
        payload["images"] = [image_b64]

    print(f"\n--- Prompt to {MODEL} ---\n{prompt}\n")
    r = requests.post(OLLAMA_URL, json=payload, timeout=120)
    r.raise_for_status()
    print("--- Response ---\n", r.text)

# --- run tests ---
print(f"🧠 Testing {MODEL} via Ollama REST API...")

ask_ollama("Summarize: benefits of multimodal AI for creative tools.")
ask_ollama(txt_prompt, image_b64=image_b64)
