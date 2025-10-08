#!/usr/bin/env bash
set -euo pipefail

LOG_TAG="[startup]"
echo "$LOG_TAG Launching Ollama..."

# Start Ollama in the background
ollama serve > /tmp/ollama.log 2>&1 &
sleep 5

# --- Wait until service responds ---
for i in {1..30}; do
  if curl -sf http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "$LOG_TAG ✅ Ollama is running on port 11434"
    break
  fi
  echo "$LOG_TAG waiting for Ollama... ($i)"
  sleep 1
  if [ "$i" -eq 30 ]; then
    echo "$LOG_TAG ❌ ERROR: Ollama failed to start."
    cat /tmp/ollama.log || true
    exit 1
  fi
done

# --- Pull a small base model to verify network ---
if ! ollama list | grep -q "qwen2.5:3b"; then
  echo "$LOG_TAG Downloading qwen2.5:3b..."
  ollama pull qwen2.5:3b || echo "$LOG_TAG (optional) Model pull failed, you can retry manually."
fi

# --- Connectivity test ---
echo "$LOG_TAG Checking API connectivity..."
curl -s http://127.0.0.1:11434/api/tags || echo "$LOG_TAG curl test failed."

# --- Keep container alive for manual tests ---
echo "$LOG_TAG Ollama container ready."
echo "$LOG_TAG Try the following commands in the HF Space terminal:"
echo "    ollama list"
echo "    ollama run qwen2.5:3b"
echo "    curl http://127.0.0.1:11434/api/tags"
tail -f /tmp/ollama.log
