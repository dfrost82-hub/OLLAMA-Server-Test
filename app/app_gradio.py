
import gradio as gr
import requests, base64, os

API_URL = os.environ.get("R1_API_URL", "http://localhost:7860/generate")

def plan(image, prompt, max_tokens, temperature):
    images = []
    if image is not None:
        # image comes as a filepath from Gradio
        with open(image, "rb") as f:
            b64 = base64.b64encode(f.read()).decode()
        images.append(b64)
    payload = {
        "prompt": prompt or "Describe the image and propose one shot",
        "images": images,
        "options": {"max_tokens": int(max_tokens), "temperature": float(temperature), "model": "qwen2.5vl:3b"}
    }
    r = requests.post(API_URL, json=payload, timeout=180)
    r.raise_for_status()
    return r.json()

with gr.Blocks(title="R1 – Qwen2.5-VL Reasoning") as demo:
    gr.Markdown("### R1 – Qwen2.5-VL Reasoning")
    with gr.Row():
        img = gr.Image(type="filepath", label="Image (optional)")
        with gr.Column():
            prompt = gr.Textbox(label="Prompt", value="Describe the image and propose one shot")
            max_tokens = gr.Slider(64, 1024, value=256, step=32, label="max_tokens")
            temperature = gr.Slider(0.0, 1.0, value=0.2, step=0.05, label="temperature")
            btn = gr.Button("Generate Plan")
    out = gr.JSON(label="ShotPlan")
    btn.click(plan, [img, prompt, max_tokens, temperature], out)

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)
