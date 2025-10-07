# ==========================================================
# Hugging Face Space - Ollama + Qwen2.5-VL:72B
# Version 1.6 – GPU Ready + Smart Startup
# ==========================================================

FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    curl tini pciutils lshw bash-completion && \
    rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV CUDA_VISIBLE_DEVICES=0

RUN curl -fsSL https://ollama.com/install.sh | bash

WORKDIR /app
RUN mkdir -p /app/ollama_models /app/.ollama

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_qwen_vl.py .
COPY README.md .

EXPOSE 11434

CMD ["bash", "-c", "bash /app/start.sh && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
