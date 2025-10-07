# ===========================
# Hugging Face Space: Ollama + Qwen2.5-VL 72B
# ===========================
FROM python:3.10-slim

# Install Ollama dependencies
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Set environment
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434
ENV PATH="$PATH:/root/.ollama/bin"

WORKDIR /app

# Copy your app files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_qwen_vl.py .

# ---------------------------
# Pre-pull model (Qwen2.5-VL 72B)
# ---------------------------
RUN ollama pull qwen2.5-vl:72b || true

# ---------------------------
# Entrypoint
# ---------------------------
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-c", "bash /app/start.sh & sleep 40 && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
