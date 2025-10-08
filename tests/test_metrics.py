import requests, os
BASE=os.environ.get("BASE","http://localhost:7860")

def test_metrics():
    r=requests.get(f"{BASE}/metrics")
    assert r.status_code==200
    assert b"r1_requests_total" in r.content
