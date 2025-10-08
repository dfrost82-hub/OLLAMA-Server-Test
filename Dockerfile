# R1 – Reasoning (Qwen2.5‑VL via Ollama)
# Slim baseline + FastAPI + Prometheus metrics
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/data/ollama \
    HF_HUB_CACHE=/cache/hf

# System deps + tini
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates wget gnupg tini ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Install Ollama (CPU baseline ok for 3B)
RUN curl -fsSL https://ollama.com/install.sh | bash

# Model cache
RUN mkdir -p /data/ollama /cache/hf && chmod -R 777 /data/ollama /cache/hf

# Python deps
WORKDIR /app
COPY app/ /app/app/
COPY README.md /app/
RUN pip3 install --no-cache-dir fastapi uvicorn[standard] pydantic requests pillow prometheus-client

# Pre-pull baseline model (VL 3B)
RUN ollama pull qwen2.5vl:3b || true

EXPOSE 7860 11434
ENTRYPOINT ["/usr/bin/tini","--"]
CMD bash -lc '(ollama serve > /tmp/ollama.log 2>&1 &) && sleep 2 && uvicorn app.api:api --host 0.0.0.0 --port 7860'
