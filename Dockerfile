# ==========================================================
# ✅ Verified Working Baseline: Ollama + Qwen 2.5 (3B)
# ==========================================================

FROM python:3.10-slim

# ---- Install basic tools ----
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# ---- Install Ollama ----
RUN curl -fsSL https://ollama.com/install.sh | bash

# ---- Environment Variables ----
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434

# ---- Create app directory ----
WORKDIR /app

# ---- Copy files ----
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_ollama.py .

# ---- Entrypoint ----
ENTRYPOINT ["/usr/bin/tini", "--"]

# ---- CMD ----
CMD ["bash", "-c", "bash /app/start.sh & sleep 40 && python /app/test_ollama.py && tail -f /tmp/ollama.log"]
