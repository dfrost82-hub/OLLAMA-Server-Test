FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root \
    OLLAMA_HOME=/root/.ollama \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/data/ollama

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tini jq && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://ollama.com/install.sh | bash

RUN mkdir -p "$OLLAMA_HOME" /data/ollama && chmod -R 777 "$OLLAMA_HOME" /data/ollama

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 11434
HEALTHCHECK --interval=10s --timeout=3s --retries=12 \
  CMD curl -sf http://127.0.0.1:11434/api/version >/dev/null || exit 1

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/usr/local/bin/start.sh"]
