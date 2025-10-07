#!/usr/bin/env bash
# ==========================================================
# Hugging Face Space Startup Script for Ollama + Qwen Models
# Version 1.6.4 – with OLLAMA_HOME visibility + regression check
# ==========================================================

set -e  # Exit on first failure

echo "===== Application Startup at $(date) ====="

# 🧠 Confirm and display OLLAMA_HOME path
if [ -z "$OLLAMA_HOME" ]; then
  export OLLAMA_HOME=/app/.ollama
  echo "[startup] ⚠️ OLLAMA_HOME not set — defaulting to /app/.ollama"
else
  echo "[startup] ✅ OLLAMA_HOME detected: $OLLAMA_HOME"
fi

# 🧩 Create directory if missing (safety check)
mkdir -p "$OLLAMA_HOME" && chmod -R 777 "$OLLAMA_HOME"

# 🧠 Run regression environment validation
if [ -f "/app/regression_check.sh" ]; then
  echo "[startup] Running regression_check.sh..."
  bash /app/regression_check.sh || {
    echo "[startup] ❌ Regression check failed. Exiting."
    exit 1
  }
else
  echo "[startup] ⚠️ regression_check.sh not found — skipping environment checks."
fi

# 🚀 Launch Ollama in background
echo "[startup] Launching Ollama..."
OLLAMA_LOG=/tmp/ollama.log
ollama serve >"$OLLAMA_LOG" 2>&1 &
sleep 3

echo "[startup] Waiting up to 10 minutes for Ollama API..."
MAX_WAIT=600
WAIT_INTERVAL=10
elapsed=0

while ! curl -s http://127.0.0.1:11434/api/tags >/dev/null; do
  if [ "$elapsed" -ge "$MAX_WAIT" ]; then
    echo "[startup] ❌ ERROR: Ollama failed to start within timeout (${MAX_WAIT}s)."
    cat "$OLLAMA_LOG"
    exit 1
  fi
  echo "[startup] waiting for Ollama... ($((elapsed / WAIT_INTERVAL + 1)))"
  sleep "$WAIT_INTERVAL"
  elapsed=$((elapsed + WAIT_INTERVAL))
done

echo "[startup] ✅ Ollama is running on port 11434"
echo "[startup] Checking API connectivity..."
curl -s http://127.0.0.1:11434/api/tags || echo "[startup] ⚠️ API check failed."

echo "[startup] Ollama container ready."
