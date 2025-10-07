FROM python:3.10-slim
RUN apt-get update && apt-get install -y curl tini && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ollama.com/install.sh | bash

ENV OLLAMA_HOME=/root/.ollama
ENV OLLAMA_MODELS=/app/ollama_models
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY start.sh .
COPY test_qwen_vl.py .

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-c", "bash /app/start.sh & sleep 40 && python /app/test_qwen_vl.py && tail -f /tmp/ollama.log"]
