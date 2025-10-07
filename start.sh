#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="
mkdir -p /root/.ollama /app/ollama_models
export OLLAMA_HOME=/root/.ollama
export OLLAMA_MODELS=/app/ollama_models
export PATH=$PATH:/root/.ollama/bin

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &

for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama running"
    break
  fi
  echo "[startup] waiting... ($i)"
  sleep 2
done

curl -s http://127.0.0.1:11434/api/tags || cat /tmp/ollama.log
