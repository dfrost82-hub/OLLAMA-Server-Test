# ==========================================================
# Hugging Face Space – Ollama + Qwen2.5-VL (72B)
# ==========================================================

FROM python:3.10-slim

# ---- Install core tools ----
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# ---- Install Ollama ----
RUN curl -fsSL https://ollama.com/install.sh | bash

# ---- Environment variables (use writable paths) ----
ENV OLLAMA_HOME=/home/user/.ollama
ENV OLLAMA_MODELS=/home/user/ollama_models
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434
ENV PATH=$PATH:/usr/local/bin:/home/user/.ollama/bin

# ---- Create writable directories ----
RUN mkdir -p /home/user/.ollama /home/user/ollama_models /home/user/app

WORKDIR /home/user/app

# ---- Python dependencies ----
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- App files ----
COPY start.sh .
COPY test_qwen_vl.py .

# ---- Entrypoint ----
ENTRYPOINT ["/usr/bin/tini", "--"]

# ---- CMD: start Ollama, wait, then run test ----
CMD ["bash", "-c", "bash /home/]()
