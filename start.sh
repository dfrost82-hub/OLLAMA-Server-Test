# start.sh
#!/usr/bin/env bash
set -euo pipefail

# Ensure the VL model is present at boot; override via env if needed
MODEL_NAME="${MODEL_NAME:-qwen2.5vl:3b}"
PULL_ON_START="${PULL_ON_START:-true}"
MAX_WAIT="${MAX_WAIT:-60}"

# Start server in background
(ollama serve >/tmp/ollama.log 2>&1 &)

# Wait for readiness
for ((i=0;i<MAX_WAIT;i++)); do
  if curl -sf http://127.0.0.1:11434/api/version >/dev/null; then
    break
  fi
  sleep 1
done

# Ensure the VL model is present (self-heal on boot)
if [ "$PULL_ON_START" = "true" ]; then
  if ! curl -sf http://127.0.0.1:11434/api/tags | grep -q '"name":"'"${MODEL_NAME}"'"'; then
    curl -s -X POST http://127.0.0.1:11434/api/pull -d '{"name":"'"${MODEL_NAME}"'"}' || true
  fi
fi

# Optional: show tags once
curl -s http://127.0.0.1:11434/api/tags || true

# Keep server in foreground
exec ollama serve
