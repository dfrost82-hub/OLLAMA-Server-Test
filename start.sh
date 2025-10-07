#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &
OLLAMA_PID=$!

# --------------------------------------------------
# Wait for Ollama API (up to ~5 minutes)
# --------------------------------------------------
echo "[startup] Waiting for Ollama to expose API on port 11434..."
for i in {1..100}; do  # 100 × 3s = 300s ≈ 5min
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    break
  fi
  if ! ps -p $OLLAMA_PID >/dev/null; then
    echo "[startup] ❌ Ollama process exited early — dumping log:"
    cat /tmp/ollama.log || true
    exit 1
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 3
done

# --------------------------------------------------
# Pull Qwen2.5-VL 72B model
# --------------------------------------------------
echo "[startup] Downloading qwen2.5-vl:72b..."
ollama pull qwen2.5-vl:72b || echo "[startup] ⚠️ Model pull skipped or cached."

# --------------------------------------------------
# Connectivity check
# --------------------------------------------------
echo "[startup] Checking API connectivity..."
curl -s http://127.0.0.1:11434/api/tags || cat /tmp/ollama.log

echo "[startup] Ollama container ready."
