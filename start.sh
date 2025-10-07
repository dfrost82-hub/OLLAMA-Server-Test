#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

# Ensure writable paths exist
mkdir -p /app/.ollama /app/ollama_models

echo "[startup] Launching Ollama..."
OLLAMA_HOME=/app/.ollama OLLAMA_MODELS=/app/ollama_models ollama serve > /tmp/ollama.log 2>&1 &

# Wait until Ollama is ready
for i in {1..40}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    break
  else
    echo "[startup] waiting for Ollama... ($i)"
    sleep 3
  fi
done

# Check if it started successfully
if ! curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[startup] ❌ ERROR: Ollama failed to start."
  cat /tmp/ollama.log || true
  exit 1
fi
