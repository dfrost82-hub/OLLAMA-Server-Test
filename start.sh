#!/bin/sh
set -eu

# Use /data for everything (writable on Spaces)
HOME="${HOME:-/data}"
export HOME
export OLLAMA_HOME="${OLLAMA_HOME:-/data/.ollama}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-/data/ollama}"

MODEL_NAME="${MODEL_NAME:-qwen2.5vl:3b}"
PULL_ON_START="${PULL_ON_START:-true}"
MAX_WAIT="${MAX_WAIT:-60}"

# Ensure dirs exist & writable
mkdir -p "$HOME" "$OLLAMA_HOME" "$OLLAMA_MODELS"
chmod -R 777 "$HOME" "$OLLAMA_HOME" "$OLLAMA_MODELS" || true

# Start server once (background)
(ollama serve >/tmp/ollama.log 2>&1 &) 
i=0
while [ "$i" -lt "$MAX_WAIT" ]; do
  if curl -sf http://127.0.0.1:11434/api/version >/dev/null; then break; fi
  i=$((i+1)); sleep 1
done

# Pull VL model if missing (first boot)
if [ "$PULL_ON_START" = "true" ]; then
  if ! curl -sf http://127.0.0.1:11434/api/tags | grep -q "\"name\":\"$MODEL_NAME\""; then
    curl -s -X POST http://127.0.0.1:11434/api/pull \
      -d "{\"name\":\"$MODEL_NAME\"}" || true
  fi
fi

# Follow the single server we started
wait
