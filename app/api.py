import time
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from prometheus_client import Counter, Histogram, CollectorRegistry, generate_latest, CONTENT_TYPE_LATEST

from .ollama_client import ollama_generate
from .utils import resolve_images_to_base64, parse_shotplan

api = FastAPI(title="R1 – Qwen2.5‑VL Reasoning")

# --- Prometheus metrics ---
REGISTRY = CollectorRegistry()
REQS = Counter('r1_requests_total', 'Total requests', ['route'], registry=REGISTRY)
ERRS = Counter('r1_errors_total', 'Total errors', ['route'], registry=REGISTRY)
LAT = Histogram('r1_latency_seconds', 'Request latency', ['route'], buckets=(0.1,0.25,0.5,1,2,5,10), registry=REGISTRY)

class GenerateReq(BaseModel):
    prompt: str
    images: Optional[List[str]] = None  # URLs or base64 strings
    options: Dict[str, Any] = Field(default_factory=dict)

@api.get("/healthz")
def healthz():
    # Basic probe – extend to NVML if GPU present
    return {"status": "ok", "model_loaded": True, "vram_free_mb": None}

@api.get("/metrics")
def metrics():
    data = generate_latest(REGISTRY)
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

@api.post("/generate")
def generate(req: GenerateReq):
    route = "generate"
    REQS.labels(route).inc()
    t0 = time.perf_counter()
    try:
        b64_images = resolve_images_to_base64(req.images or [])
        raw = ollama_generate(
            model=req.options.get("model", "qwen2.5vl:3b"),
            prompt=req.prompt,
            images=b64_images,
            options=req.options,
        )
        plan = parse_shotplan(req.prompt, raw)
        return plan
    except Exception as e:
        ERRS.labels(route).inc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        LAT.labels(route).observe(time.perf_counter() - t0)
