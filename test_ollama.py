import os
import json
import time
import requests

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:3b")
LOG_FILE = "/tmp/ollama_test_output.log"


def send_prompt(prompt: str):
    """Send a simple prompt to the Ollama REST API and return JSON."""
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.3}
    }

    try:
        r = requests.post(OLLAMA_URL, json=payload, timeout=60)
        r.raise_for_status()
        data = r.json()
        return data
    except Exception as e:
        return {"error": str(e)}


def run_tests():
    """Run a few prompts to validate text generation."""
    tests = [
        "Rewrite this instruction for image editing: brighten the sky and make it blue",
        "Explain briefly what this model does",
        "Generate a tagline for an AI photo editor app"
    ]

    print(f"\n🧠 Testing Ollama endpoint: {OLLAMA_URL}\n")
    with open(LOG_FILE, "w") as f:
        for t in tests:
            print(f"--- Prompt ---\n{t}")
            f.write(f"PROMPT: {t}\n")
            result = send_prompt(t)
            text = result.get("response", "")
            print(f"--- Response ---\n{text}\n")
            f.write(f"RESPONSE: {json.dumps(result, indent=2)}\n\n")
            time.sleep(1)

    print(f"✅ All prompts executed. Full log saved to {LOG_FILE}")


if __name__ == "__main__":
    run_tests()
