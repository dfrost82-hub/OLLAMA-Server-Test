import requests, time, base64, os

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
HEALTH_URL = "http://127.0.0.1:11434/api/tags"
MODEL = "qwen2.5-vl:72b"

def wait_for_ollama(max_wait=600):
    """Wait up to max_wait seconds for Ollama API to become available."""
    print(f"[test] Waiting up to {max_wait//60} minutes for Ollama API readiness...")
    start = time.time()
    while time.time() - start < max_wait:
        try:
            r = requests.get(HEALTH_URL, timeout=5)
            if r.status_code == 200:
                print("[test] ✅ Ollama API is ready.")
                return True
        except Exception:
            pass
        print("[test] ...still waiting...")
        time.sleep(5)
    print("[test] ❌ Timeout: Ollama API never became available.")
    return False

def ask_ollama(prompt, image_path=None):
    payload = {"model": MODEL, "prompt": prompt, "stream": False}
    if image_path and os.path.exists(image_path):
        with open(image_path, "rb") as f:
            payload["images"] = [base64.b64encode(f.read()).decode("utf-8")]
    try:
        r = requests.post(OLLAMA_URL, json=payload, timeout=600)
        r.raise_for_status()
        return r.json().get("response", "No response text found.")
    except Exception as e:
        return f"❌ Request failed: {e}"

def run_tests():
    if not wait_for_ollama():
        return

    print("\n🧠 Testing Qwen2.5-VL:72B via Ollama REST API...")

    txt_prompt = "Summarize the key benefits of multimodal AI for creative tools."
    print("\n--- Prompt 1 ---\n", txt_prompt)
    print("\n--- Response ---\n", ask_ollama(txt_prompt))

    img_path = "Cat 1.jpg"
    if os.path.exists(img_path):
        print("\n--- Prompt 2 ---\n place a fish in the plate")
        print("\n--- Response ---\n", ask_ollama("place a fish in the plate", img_path))
    else:
        print("\n[skip] Cat 1.jpg not found — skipping image test.")

if __name__ == "__main__":
    run_tests()
