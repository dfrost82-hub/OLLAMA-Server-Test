import requests
import base64

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
MODEL = "qwen2.5-vl:72b"

def ask_ollama(prompt, image_path=None):
    payload = {"model": MODEL, "prompt": prompt, "stream": False}
    if image_path:
        with open(image_path, "rb") as f:
            payload["images"] = [base64.b64encode(f.read()).decode("utf-8")]
    try:
        r = requests.post(OLLAMA_URL, json=payload, timeout=300)
        r.raise_for_status()
        data = r.json()
        return data.get("response", "No response received.")
    except Exception as e:
        return f"❌ Request failed: {e}"

def run_tests():
    print("🧠 Testing Qwen2.5-VL:72B via Ollama REST API...")

    # --- Test 1: Text-only ---
    txt_prompt = "Summarize the key benefits of multimodal AI for creative tools."
    print("\n--- Prompt 1 ---")
    print(txt_prompt)
    print("\n--- Response ---")
    print(ask_ollama(txt_prompt))

    # --- Test 2: Image + Text (if available) ---
    img_path = "Cat 1.jpg"
    try:
        with open(img_path, "rb"):
            print("\n--- Prompt 2 ---")
            print("Describe this image and place a fish in the plate.")
            print("\n--- Response ---")
            print(ask_ollama("place a fish in the plate", img_path))
    except FileNotFoundError:
        print("\n[skip] Cat 1.jpg not found, skipping image test.")

if __name__ == "__main__":
    run_tests()
