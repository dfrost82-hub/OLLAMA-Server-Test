import requests, os, base64
BASE=os.environ.get("BASE","http://localhost:7860")

def test_generate_smoke():
    # Use a tiny 1x1 PNG to avoid weight; generated below
    png = base64.b64encode(open("tests/assets/sample.jpg","rb").read()).decode()
    req={"prompt":"Describe this image","images":[png],"options":{"max_tokens":256}}
    r=requests.post(f"{BASE}/generate", json=req, timeout=240)
    assert r.status_code==200
    j=r.json()
    assert "shots" in j and len(j["shots"])>=1
