---
title: Ollama + Qwen2.5-VL (72B) — Multimodal Baseline
emoji: 🧠
colorFrom: purple
colorTo: blue
sdk: docker
sdk_version: "1.0"
app_file: start.sh
pinned: false
license: apache-2.0
---

# 🧩 Ollama + Qwen2.5-VL (72B) — Multimodal Baseline

This Space extends the working **Qwen 2.5 (3B)** text-only baseline to the **Qwen 2.5-VL (72B)** multimodal model for text + image understanding, running locally on Ollama inside a Hugging Face Space.

---

## 🚀 What It Does

1. Installs and starts **Ollama**
2. Pulls **`qwen2.5-vl:72b`**
3. Runs **multimodal test** using `test_qwen_vl.py`  
   (first a text-only prompt, then an image + text prompt)

Example success logs:

