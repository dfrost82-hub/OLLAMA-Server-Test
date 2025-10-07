import requests

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
model = "qwen2.5:3b"
prompt = "Explain the benefits of multimodal AI for creative applications."

payload = {"model": model, "prompt": prompt}

print(f"🧠 Testing {model} ...")
r = requests.post(OLLAMA_URL, json=payload, timeout=60)
r.raise_for_status()
print("✅ Response:\n", r.text)
