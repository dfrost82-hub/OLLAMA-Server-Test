# R1 – Qwen2.5‑VL Reasoning

This Space exposes a small REST API over Ollama running **qwen2.5vl:3b**.

## Endpoints
- `GET /healthz` – basic readiness
- `GET /metrics` – Prometheus metrics
- `POST /generate` – returns a structured ShotPlan JSON

## Quick test
```bash
curl -s http://localhost:7860/healthz
curl -s http://localhost:7860/metrics | head
curl -s -X POST http://localhost:7860/generate \  -H 'Content-Type: application/json' \  -d '{"prompt":"Describe this image","images":[],"options":{"max_tokens":256}}'
```
