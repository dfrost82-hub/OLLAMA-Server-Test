#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &

# ---- Wait for Ollama daemon ----
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama is running on port 11434"
    break
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 2
done

# ---- Pull model ----
echo "[startup] Downloading qwen2.5-vl:72b..."
ollama pull qwen2.5-vl:72b || echo "[startup] ⚠️ Model pull skipped or cached."

# ---- Verify connectivity ----
echo "[startup] Checking API connectivity..."
curl -s http://127.0.0.1:11434/api/tags || cat /tmp/ollama.log

echo "[startup] Ollama container ready."
