#!/usr/bin/env bash
# ==========================================================
# Regression Environment Check for Ollama + HF Spaces
# ==========================================================

echo "[check] Starting regression environment validation..."

FAILED=0

# 1️⃣ Check required binaries
for cmd in ps curl bash python3; do
  if ! command -v $cmd &>/dev/null; then
    echo "[error] Missing required command: $cmd"
    FAILED=1
  else
    echo "[ok] $cmd present."
  fi
done

# 2️⃣ Check Ollama binary
if ! command -v ollama &>/dev/null; then
  echo "[error] Ollama binary not found in PATH!"
  FAILED=1
else
  echo "[ok] Ollama binary available: $(ollama --version)"
fi

# 3️⃣ Check writable OLLAMA_HOME
if [ -z "$OLLAMA_HOME" ]; then
  echo "[warn] OLLAMA_HOME not set — defaulting to /app/.ollama"
  export OLLAMA_HOME=/app/.ollama
fi

mkdir -p "$OLLAMA_HOME"
if touch "$OLLAMA_HOME/testfile" 2>/dev/null; then
  echo "[ok] OLLAMA_HOME writable: $OLLAMA_HOME"
  rm -f "$OLLAMA_HOME/testfile"
else
  echo "[error] OLLAMA_HOME is not writable: $OLLAMA_HOME"
  FAILED=1
fi

# 4️⃣ GPU visibility check
if command -v lspci &>/dev/null; then
  GPU_INFO=$(lspci | grep -i nvidia || true)
  if [ -n "$GPU_INFO" ]; then
    echo "[ok] NVIDIA GPU detected: $GPU_INFO"
  else
    echo "[warn] No NVIDIA GPU visible to container."
  fi
else
  echo "[warn] lspci not installed — skipping GPU check."
fi

# 5️⃣ Verify Ollama API readiness probe (local)
echo "[check] Testing local Ollama API endpoint..."
if curl -s http://127.0.0.1:11434/api/tags >/dev/null; then
  echo "[ok] Ollama API endpoint responsive."
else
  echo "[warn] Ollama API not responding yet (expected before serve)."
fi

# ✅ Summary
if [ "$FAILED" -eq 0 ]; then
  echo "[check] ✅ Environment regression check PASSED."
else
  echo "[check] ❌ Environment regression check FAILED."
  exit 1
fi
