# ================================
# Hugging Face Space: Ollama Setup
# ================================

FROM python:3.10-slim

# ---- System packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates wget gnupg tini && \
    rm -rf /var/lib/apt/lists/*

# ---- Install Ollama ----
RUN curl -fsSL https://ollama.com/install.sh | bash

# ---- Working directory ----
WORKDIR /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# ---- Model cache (persists between runs) ----
ENV OLLAMA_MODELS=/data/ollama
RUN mkdir -p /data/ollama && chmod -R 777 /data/ollama

# ---- Expose default port ----
EXPOSE 11434

# ---- Run as non-root for safety ----
RUN useradd -m user
USER user

# ---- Entrypoint ----
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "/app/start.sh"]
