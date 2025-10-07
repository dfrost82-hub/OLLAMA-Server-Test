# ===========================
# Hugging Face Space: Ollama + Qwen2.5-VL 72B (fixed)
# ===========================
FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Set environment for local Ollama data
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434
ENV OLLAMA_MODELS=/app/ollama_models
ENV OLLAMA_HOME=/app/.ollama
ENV PATH="$PATH:/root/.ollama/bin"

# Create writable dirs
RUN mkdir -p /app/ollama_models /app/.ollama

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_qwen_vl.py .

# Pre-pull model (optional, may take time)
RUN ollama pull qwen2.5-vl:72b || true

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-c", "bash /app/start.sh & sleep 60 && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
