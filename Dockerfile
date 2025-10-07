# ====================================================
# Hugging Face Space — Ollama + Qwen2.5-VL-72B Runtime
# ====================================================
FROM python:3.10-slim

# Install base dependencies
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# Install Ollama runtime
RUN curl -fsSL https://ollama.com/install.sh | bash

# Environment setup
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434
ENV OLLAMA_HOME=/app/.ollama
ENV OLLAMA_MODELS=/app/ollama_models
ENV PATH="$PATH:/root/.ollama/bin"

# Create writable directories
RUN mkdir -p /app/.ollama /app/ollama_models
WORKDIR /app

# Install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy startup and test scripts
COPY start.sh .
COPY check_ollama.py .
COPY test_qwen_vl.py .

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-c", "bash /app/start.sh && python /app/check_ollama.py && python /app/test_qwen_vl.py"]
