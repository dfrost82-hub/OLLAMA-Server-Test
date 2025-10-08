import base64, json, re
from typing import List, Dict, Any
import requests

def _is_url(s: str) -> bool:
    return isinstance(s, str) and s.startswith(("http://","https://","data:"))

def resolve_images_to_base64(items: List[str]) -> List[str]:
    out = []
    for it in items:
        if not it:
            continue
        if it.startswith("data:"):
            # Already data URL -> extract base64 part
            b64 = it.split(",",1)[-1]
            out.append(b64)
        elif _is_url(it):
            resp = requests.get(it, timeout=20)
            resp.raise_for_status()
            b64 = base64.b64encode(resp.content).decode()
            out.append(b64)
        else:
            # assume it's already base64 or a file path
            try:
                # if looks like a file path, read it
                if len(it) < 260 and ("/" in it or "\" in it):
                    with open(it,"rb") as f:
                        b64 = base64.b64encode(f.read()).decode()
                        out.append(b64)
                else:
                    out.append(it)  # assume base64
            except Exception:
                # last resort: treat as base64
                out.append(it)
    return out

def parse_shotplan(user_prompt: str, raw: Dict[str, Any]) -> Dict[str, Any]:
    """Parse the model response into a ShotPlan dict.
    Expect Ollama stream=False JSON with key 'response'.
    If JSON is embedded in text, extract the first JSON object.
    Fallback to a minimal plan using the user prompt.
    """
    text = raw.get("response") or raw.get("text") or raw.get("message") or ""
    obj = None
    # Try direct JSON parse
    if isinstance(text, (dict, list)):
        obj = text
    else:
        # Extract the first JSON object
        m = re.search(r"\{[\s\S]*\}", str(text))
        if m:
            try:
                obj = json.loads(m.group(0))
            except Exception:
                obj = None
    if isinstance(obj, dict) and all(k in obj for k in ("task","objects","style","neg","shots")):
        return {**obj, "raw": raw}
    # Fallback minimal plan
    return {
        "task": "generic",
        "objects": [],
        "style": {"keywords": []},
        "neg": ["blurry","text artifacts"],
        "shots": [{"prompt": user_prompt, "seed": 123, "cfg": 6.0, "steps": 30, "size": [1024,1024]}],
        "raw": raw,
    }
