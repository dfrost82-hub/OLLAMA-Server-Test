#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

# Prepare writable dirs
mkdir -p /app/.ollama /app/ollama_models
export OLLAMA_HOME=/app/.ollama
export OLLAMA_MODELS=/app/ollama_models
export OLLAMA_HOST=0.0.0.0
export OLLAMA_PORT=11434

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &

# Wait for API readiness
for i in {1..40}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    exit 0
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 3
done

echo "[startup] ❌ ERROR: Ollama failed to start."
cat /tmp/ollama.log || true
exit 1
