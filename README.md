---
title: R1 – Baseline Ollama API
emoji: "🧠"
colorFrom: blue
colorTo: indigo
sdk: docker
pinned: false
license: apache-2.0
---

This Space runs **Ollama** and exposes its **native REST API** (no extra app).  
**Model:** `qwen2.5vl:3b` (pre-pulled during build if possible).

## Endpoints
- `POST /api/generate` – text/multimodal generate
- `GET /api/tags` – list local models
- `GET /api/version` – Ollama version

> Base URL is the Space root; example uses local testing `http://localhost:11434`.

## Quick test (local docker run)
```bash
docker build -t r1-ollama .
docker run --rm -p 11434:11434 r1-ollama

# Check server
curl -s http://localhost:11434/api/version

# Ensure model is available (pulls if missing)
curl -s http://localhost:11434/api/tags | jq .

# Simple generate (no image)
curl -s http://localhost:11434/api/generate \
  -H "Content-Type: application/json" -d '{
    "model":"qwen2.5vl:3b",
    "prompt":"Write a haiku about sunrise",
    "stream": false
  }' | jq .
```

## Image input example
Encode an image as base64 (no data: prefix) in the `images` array.

```bash
IMG_B64=$(base64 -w0 sample.jpg) # mac: base64 -i sample.jpg
curl -s http://localhost:11434/api/generate \  -H "Content-Type: application/json" -d "{
    \"model\": \"qwen2.5vl:3b\",
    \"prompt\": \"Describe this image\",
    \"images\": [\"$IMG_B64\"],
    \"stream\": false
  }" | jq .
```

## Notes
- For GPU, use a CUDA base image and install NVIDIA drivers inside the container or rely on the host. For HF Spaces, select GPU hardware; Ollama will use it if available.
- Large models (e.g., 72B) require substantial VRAM; stick to `3b` for baseline verification.
