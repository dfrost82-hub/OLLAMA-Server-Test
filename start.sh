#!/usr/bin/env bash
echo "===== Application Startup at $(date) ====="

echo "[startup] Launching Ollama..."
ollama serve > /tmp/ollama.log 2>&1 &
OLLAMA_PID=$!

# Wait for Ollama process and API
echo "[startup] Waiting up to 10 minutes for Ollama API..."
for i in {1..200}; do  # 200 × 3s = ~600s
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[startup] ✅ Ollama API reachable on port 11434"
    break
  fi
  if ! ps -p $OLLAMA_PID >/dev/null; then
    echo "[startup] ❌ Ollama exited prematurely. Dumping log:"
    cat /tmp/ollama.log || true
    exit 1
  fi
  echo "[startup] waiting for Ollama... ($i)"
  sleep 3
done

echo "[startup] Downloading qwen2.5-vl:72b..."
ollama pull qwen2.5-vl:72b || echo "[startup] ⚠️ Model pull skipped or cached."

echo "[startup] Checking API connectivity..."
curl -s http://127.0.0.1:11434/api/tags || cat /tmp/ollama.log

echo "[startup] Ollama container ready."
