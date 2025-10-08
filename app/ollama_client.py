import requests
from typing import List, Optional, Dict, Any

OLLAMA_URL = "http://localhost:11434/api/generate"

def ollama_generate(model: str, prompt: str, images: Optional[List[str]], options: Dict[str, Any]):
    payload = {
        "model": model,
        "prompt": _json_instruct(prompt),
        "stream": False,
    }
    if images:
        payload["images"] = images
    # Allow temperature, max_tokens, etc.
    for k in ["temperature","top_p","repeat_penalty","mirostat","num_ctx","max_tokens"]:
        if k in options: payload[k] = options[k]
    r = requests.post(OLLAMA_URL, json=payload, timeout=180)
    r.raise_for_status()
    # Ollama returns JSON with `response` when stream=False
    return r.json() if r.headers.get("content-type","").startswith("application/json") else {"response": r.text}

def _json_instruct(user_prompt: str) -> str:
    system = (
        "You are a planner. Respond ONLY as compact JSON with keys: "
        "task, objects, style, neg, shots. 'shots' is a list of items with "
        "prompt, seed, cfg, steps, size as [w,h]. No prose."
    )
    return f"<SYS>{system}</SYS>\n<USER>{user_prompt}</USER>"
