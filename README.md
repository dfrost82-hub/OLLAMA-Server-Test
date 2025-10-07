---
title: Ollama Qwen2.5-VL:72B GPU Test
emoji: 🧠
colorFrom: blue
colorTo: green
sdk: docker
sdk_version: "1.0.0"
app_file: test_qwen_vl.py
pinned: false
---

# 🧠 Ollama Qwen2.5-VL:72B GPU Test Space

This Hugging Face Space launches **Ollama** inside a container, downloads the **Qwen 2.5 VL 72B** multimodal model, and validates connectivity through the REST API.

### ✅ Features
- Smart startup wait loop (~5 min readiness)
- GPU-aware (NVIDIA L40s / CUDA visible)
- Automatic model pull + basic text + image tests

### 🧩 Usage
1. Deploy to Hugging Face → Docker SDK  
2. Logs show:
