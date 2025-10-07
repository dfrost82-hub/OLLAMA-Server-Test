#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

# --- Ensure writable directories ---
mkdir -p /home/user/.ollama /home/user/ollama_models
export OLLAMA_HOME=/home/user/.ollama
export OLLAMA_MODELS=/home/user/ollama_models
export OLLAMA_HOST=0.0.0.0
export OLLAMA_PORT=11434
export PATH=$PATH:/usr/local/bin:/home/user/.ollama/bin

echo "[startup] Launching Ollama..."
nohup ollama serve > /tmp/ollama.log 2>&1 &
OLLAMA_PID=$!
sleep 5

# --- Verify process is alive ---
if ! ps -p $OLLAMA_PID > /dev/null; then
  echo "[startup] ❌ Ollama process exited early. Dumping log:"
  cat /tmp/ollama.log || true
  exit 1
fi

# --- Wait until REST API ready ---
for i in {1..40}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    echo "[startup] Pulling model qwen2.5-vl:72b ..."
    ollama pull qwen2.5-vl:72b || echo "[startup] ⚠️ Model pull skipped or cached."
    exit 0
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 3
done

echo "[startup] ❌ ERROR: Ollama failed to start."
cat /tmp/ollama.log || true
exit 1
