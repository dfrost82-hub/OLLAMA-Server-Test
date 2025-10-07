# ==========================================================
# Hugging Face Space - Ollama + Qwen2.5-VL:72B
# Version 1.6.4 – Fix for OLLAMA_HOME propagation
# ==========================================================

FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl tini pciutils lshw procps bash-completion && \
    rm -rf /var/lib/apt/lists/*

# GPU / CUDA hints (harmless if no GPU visible)
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV CUDA_VISIBLE_DEVICES=0

# ✅ Define and create writable Ollama home
ENV OLLAMA_HOME=/app/.ollama
RUN mkdir -p /app/.ollama && chmod -R 777 /app/.ollama

# ✅ Force Ollama to use our path by exporting during install
RUN curl -fsSL https://ollama.com/install.sh | bash && \
    echo "export OLLAMA_HOME=/app/.ollama" >> /etc/profile && \
    echo "export OLLAMA_HOME=/app/.ollama" >> /root/.bashrc

WORKDIR /app
RUN mkdir -p /app/ollama_models

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY regression_check.sh .
COPY start.sh .
COPY test_qwen_vl.py .
COPY README.md .

EXPOSE 11434

# ✅ Run Ollama serve with explicit env var to avoid propagation loss
CMD ["bash", "-c", "export OLLAMA_HOME=/app/.ollama && bash /app/start.sh && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
