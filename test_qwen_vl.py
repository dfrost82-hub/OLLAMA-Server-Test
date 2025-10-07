import base64, io, requests
from PIL import Image

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
MODEL = "qwen2.5-vl:72b"

def encode_image(img_path):
    with open(img_path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

def ask_ollama(prompt, images=None):
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }
    if images:
        payload["images"] = images
    r = requests.post(OLLAMA_URL, json=payload, timeout=120)
    r.raise_for_status()
    return r.json().get("response", "(no response)")

def run_tests():
    print(f"\n🧠 Testing {MODEL} via Ollama REST API...\n")

    # Test 1: Text-only
    txt_prompt = "Summarize: benefits of multimodal AI for creative tools."
    print(f"--- Prompt ---\n{txt_prompt}")
    print(f"--- Response ---\n{ask_ollama(txt_prompt)}\n")

    # Test 2: Image + Text
    img = Image.new("RGB", (256, 256), color=(255, 215, 0))
    img.save("/tmp/test_img.jpg")
    img_b64 = encode_image("/tmp/test_img.jpg")

    vis_prompt = "Describe what you see in this image in one short sentence."
    print(f"--- Prompt ---\n{vis_prompt}")
    print(f"--- Response ---\n{ask_ollama(vis_prompt, [img_b64])}\n")

    print("✅ All tests completed successfully.\n")

if __name__ == "__main__":
    run_tests()
