# ==========================================================
# Ollama + Qwen 2.5-VL (72B)
# Regression-safe build derived from working Qwen 2.5 3B baseline
# ==========================================================

FROM python:3.10-slim

# ---- Install core tools ----
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*

# ---- Install Ollama ----
RUN curl -fsSL https://ollama.com/install.sh | bash

# ---- Environment ----
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434

# ---- App setup ----
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_qwen_vl.py .

ENTRYPOINT ["/usr/bin/tini", "--"]

# Run Ollama, wait, then test multimodal reasoning
CMD ["bash", "-c", "bash /app/start.sh & sleep 40 && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
