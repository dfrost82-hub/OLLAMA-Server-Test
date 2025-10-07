# ==========================================================
# Hugging Face Space - Ollama + Qwen2.5-VL:72B
# Version 1.6.1 – GPU Ready + Smart Startup + ps fix
# ==========================================================

FROM python:3.10-slim

# Install system tools, GPU detection utils, curl & tini
# Added `procps` for `ps` command used in start.sh
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl tini pciutils lshw procps bash-completion && \
    rm -rf /var/lib/apt/lists/*

# GPU visibility (HF GPU runtime auto-mounts drivers)
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV CUDA_VISIBLE_DEVICES=0

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Create working directory
WORKDIR /app
RUN mkdir -p /app/ollama_models /app/.ollama

# Copy dependency list and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY start.sh .
COPY test_qwen_vl.py .
COPY README.md .

# Expose Ollama default port
EXPOSE 11434

# Startup: serve Ollama, wait for readiness, run tests
CMD ["bash", "-c", "bash /app/start.sh && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
