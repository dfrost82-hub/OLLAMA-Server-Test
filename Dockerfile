# Baseline: Ollama server exposing native REST API (no extra apps)
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/data/ollama

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tini && \
    rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Prepare model cache dir
RUN mkdir -p /data/ollama && chmod -R 777 /data/ollama

# Pre-pull baseline model (VL 3B). Safe to ignore if offline; Space will pull on first run.
RUN ollama pull qwen2.5vl:3b || true

EXPOSE 11434
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["ollama","serve"]
