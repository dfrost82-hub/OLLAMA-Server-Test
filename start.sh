#!/usr/bin/env bash
set -e

echo "[startup] Setting up OLLAMA_HOME..."
export OLLAMA_HOME="/app/.ollama"

# Ensure writable folder for Ollama
if [ ! -d "$OLLAMA_HOME" ]; then
  echo "[startup] Creating $OLLAMA_HOME..."
  mkdir -p "$OLLAMA_HOME"
fi

# Fix permissions (ignore errors if read-only FS)
chmod 777 "$OLLAMA_HOME" || echo "[warn] Could not change permissions on $OLLAMA_HOME"

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &

# Wait up to 10 minutes for the API
echo "[startup] Waiting for Ollama API (up to 600s)..."
for i in $(seq 1 60); do
  sleep 10
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    break
  else
    echo "[startup] waiting for Ollama... ($i)"
  fi
  if [ "$i" -eq 60 ]; then
    echo "[startup] ❌ ERROR: Ollama failed to start within timeout (600s)."
    echo "--------- Ollama Log Dump ---------"
    cat /tmp/ollama.log || echo "[warn] No ollama.log found"
    exit 1
  fi
done

echo "[startup] ✅ Startup sequence complete."
