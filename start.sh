#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

# ---- Launch Ollama ----
ollama serve > /tmp/ollama.log 2>&1 &

# ---- Wait for Ollama to start ----
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    break
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 2
done

# ---- Pull the model (Qwen 2.5 3B) ----
echo "[startup] Pulling model qwen2.5:3b ..."
ollama pull qwen2.5:3b || echo "[startup] ⚠️ Model pull skipped or cached."

# ---- Print tags for verification ----
curl -s http://127.0.0.1:11434/api/tags || cat /tmp/ollama.log
