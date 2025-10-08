import requests, os
BASE=os.environ.get("BASE","http://localhost:7860")

def test_health():
    r=requests.get(f"{BASE}/healthz")
    assert r.status_code==200
    assert r.json()["status"]=="ok"
