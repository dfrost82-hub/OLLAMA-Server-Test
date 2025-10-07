import requests, time

for i in range(40):
    try:
        r = requests.get("http://127.0.0.1:11434/api/tags", timeout=3)
        if r.status_code == 200:
            print("✅ Ollama API reachable.")
            break
    except Exception:
        print(f"waiting for Ollama API... ({i+1})")
        time.sleep(3)
else:
    raise SystemExit("❌ Ollama never became reachable.")
