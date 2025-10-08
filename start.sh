#!/bin/sh
set -eu

# Ensure env is set even if Docker didn't pass the layer env down for some reason
export HOME="${HOME:-/root}"
export OLLAMA_HOME="${OLLAMA_HOME:-/root/.ollama}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-/data/ollama}"

# Config (override via Space env if needed)
MODEL_NAME="${MODEL_NAME:-qwen2.5vl:3b}"
PULL_ON_START="${PULL_ON_START:-true}"
MAX_WAIT="${MAX_WAIT:-60}"

# Make sure dirs exist & are writable (defensive)
mkdir -p "$OLLAMA_HOME" "$OLLAMA_MODELS"
chmod 777 "$OLLAMA_HOME" "$OLLAMA_MODELS" || true

echo "=== Starting ollama serve (background) ==="
ollama serve >/tmp/ollama.log 2>&1 &
PID=$!

# Wait for readiness
i=0
while [ "$i" -lt "$MAX_WAIT" ]; do
  if curl -sf http://127.0.0.1:11434/api/version >/dev/null; then
    break
  fi
  i=$((i+1))
  sleep 1
done

# Optional: ensure VL model is present
if [ "$PULL_ON_START" = "true" ]; then
  if ! curl -sf http://127.0.0.1:11434/api/tags | grep -q "\"name\":\"$MODEL_NAME\""; then
    echo "=== Pulling model: $MODEL_NAME ==="
    curl -s -X POST http://127.0.0.1:11434/api/pull -d "{\"name\":\"$MODEL_NAME\"}" || true
  fi
fi

echo "=== Ollama is ready (PID=$PID). Following foreground process. ==="
# IMPORTANT: do NOT start a second server; wait on the one we started
wait "$PID"
